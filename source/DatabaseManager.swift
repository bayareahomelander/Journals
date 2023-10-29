//
//  DatabaseManager.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SQLite3

let internalDateFormatter = DateUtility.shared.internalDateFormatter

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer? = nil

    private init() {
        if openDatabase() {
            if !createTable() || !createEventTable() {
                print("Error creating table")
            }
        } else {
            print("Error opening table")
        }
    }
    
    func openDatabase() -> Bool {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Diary.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return false
        }
        
        print(fileURL)
        
        return true
    }
    
    func createTable() -> Bool {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Diary (
            date TEXT PRIMARY KEY,
            text TEXT,
            mood INTEGER
        );
        """

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &stmt, nil) != SQLITE_OK {
            print("Error preparing create table")
            return false
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Error creating table")
            return false
        }
        
        return true
    }
    
    func saveEntry(date: String, text: String, mood: Int, sentimentAnalysis: String? = nil) -> Bool {
        let insertQuery = "INSERT OR REPLACE INTO Diary (date, text, mood) VALUES (?, ?, ?);"
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) != SQLITE_OK {
            print("Error preparing insert")
            return false
        }

        sqlite3_bind_text(stmt, 1, (date as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (text as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 3, Int32(mood))
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Error inserting row")
            return false
        }
        
        return true
    }
    
    func deleteEntry(date: String) -> Bool {
        let deleteQuery = "DELETE FROM Diary WHERE date = ?;"
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) != SQLITE_OK {
            print("Error preparing delete")
            return false
        }
        
        // Convert Swift String to C-style string using NSString
        let dateCString = (date as NSString).utf8String
        
        sqlite3_bind_text(stmt, 1, dateCString, -1, nil)
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Error deleting row")
            return false
        }
        
        return true
    }
    
    // Fetch all entries available
    func fetchEntries() -> [DiaryEntry] {
        let fetchQuery = "SELECT date, text, mood FROM Diary;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) != SQLITE_OK {
            print("Error preparing fetch")
            return []
        }
        
        var entries: [DiaryEntry] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let date = String(cString: sqlite3_column_text(stmt, 0))
            let text = String(cString: sqlite3_column_text(stmt, 1))
            let mood = Int(sqlite3_column_int(stmt, 2))
            entries.append(DiaryEntry(date: date, text: text, mood: mood))
        }
        
        return entries
    }
    
    // Fetch one specific entry, given date
    func fetchTextOnly(for date: Date) -> String? {
        let dateStr = internalDateFormatter.string(from: date)
        let fetchQuery = "SELECT text FROM Diary WHERE date = ?;"

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) != SQLITE_OK {
            print("Error preparing fetch")
            return nil
        }

        sqlite3_bind_text(stmt, 1, (dateStr as NSString).utf8String, -1, nil)

        if sqlite3_step(stmt) == SQLITE_ROW {
            let text = String(cString: sqlite3_column_text(stmt, 0))
            return text
        }

        return nil
    }
    
    // Fetch dates that contain an entry
    func fetchDatesWithEntries() -> [Date] {
        let fetchQuery = "SELECT DISTINCT date FROM Diary;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) != SQLITE_OK {
            print("Error preparing fetch")
            return []
        }

        var dates: [Date] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let dateString = String(cString: sqlite3_column_text(stmt, 0)!)
            if let date = internalDateFormatter.date(from: dateString) {
                dates.append(date)
            }
        }

        return dates
    }
    
    // Fetch mood scores and corresponding dates
    func fetchMoodScores() -> [(date: String, score: CGFloat)] {
        let fetchQuery = "SELECT date, mood FROM Diary ORDER BY date DESC LIMIT 7;"
        var stmt: OpaquePointer?
        var moodData: [(date: String, score: CGFloat)] = []

        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let date = String(cString: sqlite3_column_text(stmt, 0))
                let mood = CGFloat(sqlite3_column_int(stmt, 1))
                moodData.append((date: date, score: mood))
            }
        }

        return moodData.reversed()
    }
    
    // Fetch mood scores only
    func fetchScoresOnly(for date: Date) -> Int? {
        let dateStr = internalDateFormatter.string(from: date)
        let fetchQuery = "SELECT mood FROM Diary WHERE date = ?;"

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) != SQLITE_OK {
            print("Error preparing fetch")
            return nil
        }

        sqlite3_bind_text(stmt, 1, (dateStr as NSString).utf8String, -1, nil)

        if sqlite3_step(stmt) == SQLITE_ROW {
            let mood = Int(sqlite3_column_int(stmt, 0))
            return mood
        }

        return nil
    }
    
    // Fetch mood score for today and yesterday
    func fetchTwoScores(for date: Date) -> (Int, Int) {
        let dateStr = internalDateFormatter.string(from: date)
        let prevDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        let prevDateStr = internalDateFormatter.string(from: prevDate)
        
        var moodToday: Int = -1
        var moodYesterday: Int = -1
        
        let fetchQuery = """
        SELECT date, mood FROM Diary WHERE date IN (?, ?);
        """
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (dateStr as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (prevDateStr as NSString).utf8String, -1, nil)
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let fetchedDate = String(cString: sqlite3_column_text(stmt, 0))
                let mood = sqlite3_column_int(stmt, 1)
                
                if fetchedDate == dateStr {
                    moodToday = Int(mood)
                } else if fetchedDate == prevDateStr {
                    moodYesterday = Int(mood)
                }
            }
        }
        
        if sqlite3_finalize(stmt) != SQLITE_OK {
            print("Error finalizing statement")
        }
        
        return (moodToday, moodYesterday)
    }
    
    // CountdownView data table starts here
    func createEventTable() -> Bool {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS Event(
            uuid TEXT PRIMARY KEY,
            eventDate TEXT,
            eventName TEXT,
            daysLeftOrPassed INTEGER,
            isPinned INTEGER,
            note TEXT,
            advanceNotice INTEGER,
            tag TEXT
        );
        """
        
        var createTableStatement: OpaquePointer? = nil
        var isSuccess = false
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Event table created.")
                isSuccess = true
            } else {
                print("Event table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        
        sqlite3_finalize(createTableStatement)
        return isSuccess
    }

    // Add an event
    func addEvent(uuid: String, eventName: String, eventDate: String, isPinned: Bool, note: String, advanceNotice: Int, tag: String) -> Bool {
        let daysLeftOrPassed = calculateDaysLeftOrPassed(for: eventDate)
        let insertStatementString = """
        INSERT INTO Event (uuid, eventDate, eventName, daysLeftOrPassed, isPinned, note, advanceNotice, tag) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        var insertStatement: OpaquePointer? = nil
        var isSuccess = false

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (uuid as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (eventDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (eventName as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(daysLeftOrPassed))
            sqlite3_bind_int(insertStatement, 5, isPinned ? 1 : 0)
            sqlite3_bind_text(insertStatement, 6, (note as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 7, Int32(advanceNotice))
            sqlite3_bind_text(insertStatement, 8, (tag as NSString).utf8String, -1, nil)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                isSuccess = true
            } else {
                print("Could not insert row. Error: \(String(describing: String(cString: sqlite3_errmsg(db), encoding: .utf8)))")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }

        sqlite3_finalize(insertStatement)
        return isSuccess
    }
    
    // Update an existing event
    func updateEvent(uuid: String, eventName: String, eventDate: String, isPinned: Bool, note: String, advanceNotice: Int, tag: String) -> Bool {
        // Calculate daysLeftOrPassed based on eventDate
        let daysLeftOrPassed = calculateDaysLeftOrPassed(for: eventDate)
        
        // SQL UPDATE statement
        let updateStatementString = """
        UPDATE Event SET eventDate = ?, eventName = ?, daysLeftOrPassed = ?, isPinned = ?, note = ?, advanceNotice = ?, tag = ? WHERE uuid = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        var isSuccess = false
        
        // Prepare the SQL statement
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            // Bind parameters
            sqlite3_bind_text(updateStatement, 1, (eventDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (eventName as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 3, Int32(daysLeftOrPassed))
            sqlite3_bind_int(updateStatement, 4, isPinned ? 1 : 0)
            sqlite3_bind_text(updateStatement, 5, (note as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 6, Int32(advanceNotice))
            sqlite3_bind_text(updateStatement, 7, (tag as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 8, (uuid as NSString).utf8String, -1, nil)
            
            // Execute the SQL statement
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
                isSuccess = true
            } else {
                print("Could not update row. Error: \(String(describing: String(cString: sqlite3_errmsg(db), encoding: .utf8)))")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        // Finalize the SQL statement
        sqlite3_finalize(updateStatement)
        
        return isSuccess
    }
    
    // Refresh days value
    func updateAllDaysLeftOrPassed() {
        print("DatabaseManager: updateAllDaysLeftOrPassed called.")
        let allEvents = fetchAllEvents()
        for event in allEvents {
            let updatedDaysLeftOrPassed = calculateDaysLeftOrPassed(for: event.eventDate)
            updateEvent(uuid: event.uuid, eventName: event.eventName, eventDate: event.eventDate, isPinned: event.isPinned, note: event.note, advanceNotice: event.advanceNotice, tag: event.tag)
        }
    }

    // Fetch all events
    func fetchAllEvents() -> [CountdownEvent] {
        let fetchStatementString = "SELECT * FROM Event;"
        var fetchStatement: OpaquePointer? = nil
        var events: [CountdownEvent] = []
        
        if sqlite3_prepare_v2(db, fetchStatementString, -1, &fetchStatement, nil) == SQLITE_OK {
            while sqlite3_step(fetchStatement) == SQLITE_ROW {
                let uuid = String(cString: sqlite3_column_text(fetchStatement, 0))
                let eventDate = String(cString: sqlite3_column_text(fetchStatement, 1))
                let eventName = String(cString: sqlite3_column_text(fetchStatement, 2))
                let daysLeftOrPassed = Int(sqlite3_column_int(fetchStatement, 3))
                let isPinned = sqlite3_column_int(fetchStatement, 4) == 1
                let note = String(cString: sqlite3_column_text(fetchStatement, 5))
                let advanceNotice = Int(sqlite3_column_int(fetchStatement, 6))
                let tag = String(cString: sqlite3_column_text(fetchStatement, 7))
                
                events.append(CountdownEvent(uuid: uuid, eventDate: eventDate, eventName: eventName, daysLeftOrPassed: daysLeftOrPassed, isPinned: isPinned, note: note, advanceNotice: advanceNotice, tag: tag))
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(fetchStatement)
        return events
    }

    // Delete an event by uuid
    func deleteEvent(uuid: String) -> Bool {
        let deleteStatementString = "DELETE FROM Event WHERE uuid = ?;"
        var deleteStatement: OpaquePointer? = nil
        var isSuccess = false
        
        // Prepare the DELETE statement
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            // Bind the `uuid` to the statement
            sqlite3_bind_text(deleteStatement, 1, (uuid as NSString).utf8String, -1, nil)
            
            // Execute the DELETE statement
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
                isSuccess = true
            } else {
                print("Error: \(String(describing: String(cString: sqlite3_errmsg(db), encoding: .utf8)))")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        
        // Finalize the DELETE statement to release its resources
        sqlite3_finalize(deleteStatement)
        
        return isSuccess
    }
    
    // Fetch tag of an event by uuid
    func getTag(uuid: String) -> String? {
        let fetchTagStatementString = "SELECT tag FROM Event WHERE uuid = ?;"
        var fetchTagStatement: OpaquePointer? = nil
        var tag: String? = nil
        
        // Prepare the SELECT statement
        if sqlite3_prepare_v2(db, fetchTagStatementString, -1, &fetchTagStatement, nil) == SQLITE_OK {
            // Bind the uuid to the statement
            sqlite3_bind_text(fetchTagStatement, 1, (uuid as NSString).utf8String, -1, nil)
            
            // Execute the SELECT statement
            if sqlite3_step(fetchTagStatement) == SQLITE_ROW {
                tag = String(cString: sqlite3_column_text(fetchTagStatement, 0))
            } else {
                print("Could not fetch tag. Error: \(String(describing: String(cString: sqlite3_errmsg(db), encoding: .utf8)))")
            }
        } else {
            print("SELECT tag statement could not be prepared.")
        }
        
        // Finalize the SELECT statement to release its resources
        sqlite3_finalize(fetchTagStatement)
        
        return tag
    }

}

struct DiaryEntry {
    let date: String
    let text: String
    let mood: Int
}

struct CountdownEvent {
    let uuid: String
    let eventDate: String
    let eventName: String
    let daysLeftOrPassed: Int
    let isPinned: Bool
    let note: String
    let advanceNotice: Int
    let tag: String
}
