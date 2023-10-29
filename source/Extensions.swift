//
//  ColorExtension.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-04.
//

import Foundation
import SwiftUI
import Combine
import LocalAuthentication
import UIKit
import NaturalLanguage
import IPADic
import Mecab_Swift
import SSNaturalLanguage
import TipKit

extension Color {
    static let lightModeThemes: [UIColor] = [
        UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1),
        UIColor(red: 243/255, green: 233/255, blue: 229/255, alpha: 1),
        UIColor(red: 203/255, green: 214/255, blue: 218/255, alpha: 1),
        UIColor(red: 129/255, green: 216/255, blue: 208/255, alpha: 1),
        UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1),
    ]

    
    static let dynamicBackground = Color(
        .init { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 22/255, green: 22/255, blue: 24/255, alpha: 1)
            } else {
                return lightModeThemes[UserDefaults.standard.integer(forKey: "selectedThemeIndex")]
            }
        }
    )

    static let dynamicContainer = Color(
        .init { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 33/255, green: 33/255, blue: 36/255, alpha: 1)
            } else {
                return lightModeThemes[UserDefaults.standard.integer(forKey: "selectedThemeIndex")]
            }
        }
    )
    
    static let dynamicBorder = Color(
        .init { $0.userInterfaceStyle == .dark ? UIColor(red: 81/255, green: 81/255, blue: 81/255, alpha: 1) : UIColor(Color.black)}
    )
    
    static let dynamicText = Color(
        .init { $0.userInterfaceStyle == .dark ? UIColor(Color.white) : UIColor(Color.black) }
    )
    
    static let dynamicSection = Color(
        .init { $0.userInterfaceStyle == .dark ? UIColor(red: 33/255, green: 33/255, blue: 36/255, alpha: 1) : UIColor(red: 248/255, green: 248/255, blue: 231/255, alpha: 1)}
    )
    
    static let dynamicIcon = Color(
        .init { $0.userInterfaceStyle == .dark ? UIColor(red: 81/255, green: 81/255, blue: 81/255, alpha: 1) : UIColor(Color.black)}
    )
}

func renderUIViewToImage(view: UIView, size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { ctx in
        view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
    }
    return image
}

// Function to fetch weather based on coordinates
func fetchWeather(byLatitude latitude: Double, longitude: Double, completion: @escaping (WeatherData?) -> ()) {
    let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=d1e0cf163fea7252456f054cdb369486"
    if let url = URL(string: urlString) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                
                do {
                    let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                    DispatchQueue.main.async {
                        completion(decodedData)
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                print("Network error: \(String(describing: error))")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}

func calculateDaysLeftOrPassed(for eventDate: String) -> Int {
    let calendar = Calendar.current
    guard let eventDateObj = internalDateFormatter.date(from: eventDate),
          let currentDateObj = internalDateFormatter.date(from: internalDateFormatter.string(from: Date())) else {
        return 0
    }
    let components = calendar.dateComponents([.day], from: currentDateObj, to: eventDateObj)
    return components.day ?? 0
}

public class DateUtility {
    public static let shared = DateUtility()
    
    public let internalDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private init() {}
}

// Observable ViewModel
class EventViewModel: ObservableObject {
    @Published var events: [CountdownEvent] = []
    @Binding var isReminderEnabled: Bool

    init(isReminderEnabled: Binding<Bool>? = nil) {
        if let binding = isReminderEnabled {
            self._isReminderEnabled = binding
        } else {
            self._isReminderEnabled = Binding(get: {
                UserDefaults.standard.bool(forKey: "isReminderEnabled")
            }, set: { newValue in
                UserDefaults.standard.setValue(newValue, forKey: "isReminderEnabled")
            })
        }
    }
    
    func fetchEvents() {
        self.events = DatabaseManager.shared.fetchAllEvents()
    }
    
    func updateAllDaysLeftOrPassed() {
        DatabaseManager.shared.updateAllDaysLeftOrPassed()
        fetchEvents()  // Refresh the local copy of events after updating the database
    }
    
    // Separate function for notifying
    func scheduleEventNotification(for event: CountdownEvent) {
        let center = UNUserNotificationCenter.current()
        self.isReminderEnabled = true
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Upcoming Event"
                content.body = "\(event.eventName) is in \(event.advanceNotice) day(s)."
                
                // Calculate the notification date based on the event date and advance notice
                guard let eventDate = internalDateFormatter.date(from: event.eventDate) else { return }
                let notificationDate: Date
                if event.advanceNotice == 0 {
                    notificationDate = eventDate // No days are subtracted for "On the day"
                } else {
                    notificationDate = Calendar.current.date(byAdding: .day, value: -event.advanceNotice, to: eventDate)!
                }
                
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                dateComponents.hour = 9
                dateComponents.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                
                center.add(request)
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func saveCheerUpMessage(for date: Date, message: String) {
    let key = "cheerUpMessage-\(date)"
    UserDefaults.standard.set(message, forKey: key)
}

func fetchCheerUpMessage(for date: Date) -> String? {
    let key = "cheerUpMessage-\(date)"
    return UserDefaults.standard.string(forKey: key)
}

func generateMoodComparisonText(selectedDate: Date) -> String {
    // Fetch the mood scores for the selected date and the previous day
    let (moodToday, moodYesterday) = DatabaseManager.shared.fetchTwoScores(for: selectedDate)
    
    // Initialize an empty string to store the comparison text
    var comparisonText = ""
    
    // Compare the mood scores and generate the comparison text
    if moodToday == -1 && moodYesterday == -1 {
        comparisonText = String(localized: "Start tracking your mood today!")
    } else if moodYesterday == -1 {
        comparisonText = String(localized: "No mood selected for yesterday.")
    } else {
        if moodToday > moodYesterday {
            comparisonText = String(localized: "You're feeling more upbeat today!")
        } else if moodToday < moodYesterday {
            comparisonText = String(localized: "Today's a bit tougher than yesterday, but that's okay.")
        } else {
            comparisonText = String(localized: "Your mood is consistent with yesterday.")
        }
    }
    
    return comparisonText
}

let displayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("MMMd")

    // Use the system's current locale
    formatter.locale = Locale.current
    
    if Locale.current.identifier.starts(with: "en") {
        formatter.dateFormat = "MMM dd"
    }

    // Handle the special case for Chinese locale
    if Locale.current.identifier.starts(with: "zh") {
        formatter.setLocalizedDateFormatFromTemplate("MMMd日")
    }
    
    return formatter
}()

// Use NLLanguage for keyword extraction on non-Japanese text
func extractAdjectives(from text: String, maxKeywords: Int = 5) -> [String] {
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = text
    
    var keywords: [String] = []
    
    let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
        if let tag = tag, tag == .adjective {
            keywords.append(String(text[tokenRange]))
        }
        return true
    }
    
    // Limit the number of keywords if necessary
    if keywords.count > maxKeywords {
        return Array(keywords.prefix(maxKeywords))
    }
    
    return keywords
}

// MeCab for Japanese language processing
class ipadicClass {
    var ipadicTokenizer: Tokenizer?

    init() {
        let ipadic = IPADic()
        do {
            self.ipadicTokenizer = try Tokenizer(dictionary: ipadic)
        } catch {
            print("Error initializing tokenizer: \(error)")
        }
    }
}

func extractJapaneseKeywords(text: String, maxKeywords: Int = 5) -> [String] {
    do {
        let ipadic = IPADic()  // Initialize the dictionary
        let tokenizer = try Tokenizer(dictionary: ipadic)  // Use the initialized dictionary
        let annotations = tokenizer.tokenize(text: text)
        
        // Filter annotations based on your criteria (e.g., part of speech)
        let filteredAnnotations = annotations.filter { $0.partOfSpeech == .noun }
        
        // Sort annotations based on some metric (e.g., frequency, length)
        let sortedAnnotations = filteredAnnotations.sorted { $0.base.count > $1.base.count }
        
        // Extract up to 'maxKeywords' keywords
        let keywords = sortedAnnotations.prefix(maxKeywords).map { $0.base }
        
        return keywords
    } catch {
        print("Error: \(error)")
        return []
    }
}

// Aggregated function
func extractKeywords(from text: String) -> [String] {
    // First, detect language
    let lang = NLLanguageRecognizer.dominantLanguage(for: text)
    var keywords: [String] = []
    
    // Use Mecab-Swift if text is Japanese
    if lang == NLLanguage.japanese {
        keywords = extractJapaneseKeywords(text: text)
        
    } else {
        keywords = extractAdjectives(from: text)
    }
    
    return keywords
}

// Sentiment score for selected journal entry
func getSentimentScore(text: String) -> Double? {
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    
    // Tokenize the text into sentences
    let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
    
    var totalScore: Double = 0.0
    var sentenceCount: Double = 0.0
    
    // Analyze each sentence's sentiment
    for sentence in sentences {
        tagger.string = sentence
        let (tag, _) = tagger.tag(at: text.startIndex,
                                  unit: .paragraph,
                                  scheme: .sentimentScore)
        
        if let sentimentScore = tag?.rawValue as? NSString {
            let scoreValue = sentimentScore.doubleValue
            totalScore += scoreValue
            sentenceCount += 1
        }
    }
    
    // Return the average sentiment score if applicable
    if sentenceCount == 0 {
        return nil
    }
    
    return totalScore / sentenceCount
}

func analyzeSentiment(text: String, dateHash: Int) -> String {
    // If Japanese, return a random and fixed mood based on dateHash
    if NLLanguageRecognizer.dominantLanguage(for: text) == NLLanguage.japanese {
        let moods = ["positive", "balanced", "negative"]
        let index = abs(dateHash) % moods.count
        return moods[index]
    }
    
    let sentimentalScore = getSentimentScore(text: text)
    
    if let unwrappedScore = sentimentalScore {
        switch unwrappedScore {
        case let s where s <= -0.33:
            return "negative"
        case let s where s > -0.33 && s <= 0.1:
            return "balanced"
        default:
            return "positive"
        }
    } else {
        return "balanced"
    }
}

var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("MMMMd")

    // Use the system's current locale
    formatter.locale = Locale.current
    
    if Locale.current.identifier.starts(with: "en") {
        formatter.dateFormat = "MMMM dd"
    }

    // Handle the special case for Chinese locale
    if Locale.current.identifier.starts(with: "zh") || Locale.current.identifier.starts(with: "ja") {
        formatter.setLocalizedDateFormatFromTemplate("MMMd日")
    }
    
    return formatter
}

func configure() {
    try? Tips.configure([.datastoreLocation(.applicationDefault), .displayFrequency(.immediate)])
}
