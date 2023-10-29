//
//  TextEditorView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI

struct TextEditorView: View {
    @State private var text: String
    @State private var showDeleteAlert = false
    
    @Binding var diaryText: String
    @Binding var showTextEditor: Bool
    @Binding var selectedDate: Date
    @Binding var selectedMood: Int
    @Binding var journalEntries: [String: String]
    
    let internalDateFormatter = DateUtility.shared.internalDateFormatter
    
    // Access current color scheme
    @Environment(\.colorScheme) var colorScheme
    
    init(journalEntries: Binding<[String: String]>, diaryText: Binding<String>, showTextEditor: Binding<Bool>, selectedDate: Binding<Date>, selectedMood: Binding<Int>) {
        _journalEntries = journalEntries
        _diaryText = diaryText
        _showTextEditor = showTextEditor
        _selectedDate = selectedDate
        _selectedMood = selectedMood
        _text = State(initialValue: diaryText.wrappedValue) // Initialize with the value from diaryText
    }
    
    var body: some View {
        ZStack {
            Color.dynamicBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text(internalDateFormatter.string(from: selectedDate)) // Display the selected date
                        .font(.system(size: 15))
                        .padding(.leading, 20)
                        .padding(.bottom, 5)
                        .padding(.top, 15)
                        .foregroundColor(Color.dynamicText)
                    
                    Spacer() // Push the button to the right
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(title: Text("Deleting Entry"),
                              message: Text("This action is not reversible."),
                              primaryButton: .destructive(Text("Delete")) {
                                deleteEntry()
                                showTextEditor = false
                        },
                              secondaryButton: .cancel())
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
                    
                    Button(action: {
                        saveEntry()
                        showTextEditor = false
                    }) {
                        Image(systemName: "checkmark.square")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .padding(.trailing, 20) // Add some padding to the right
                }
                
                Divider()
                    .background(Color.black)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                
                MoodSelectorView(selectedMood: $selectedMood)
                
                TextEditor(text: $text)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color.dynamicBackground)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .background(Color.dynamicBackground)

        }
    }
    
    private func saveEntry() {
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return
        }
        
        let dateStr = internalDateFormatter.string(from: selectedDate)
        if DatabaseManager.shared.saveEntry(date: dateStr, text: text, mood: selectedMood) {
            diaryText = text
            journalEntries[dateStr] = text // Update journalEntries directly
        } else {
            print("Error saving entry to database")
        }
    }

    
    private func deleteEntry() {
        let dateStr = internalDateFormatter.string(from: selectedDate)
        if DatabaseManager.shared.deleteEntry(date: dateStr) {
            text = "" // Clear the text
            diaryText = text
            journalEntries[dateStr] = nil // Remove from journalEntries
            selectedMood = -1
        } else {
            print("Error deleting entry from database")
        }
    }
}

