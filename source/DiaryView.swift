//
//  DiaryView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI
import SQLite3
import LocalAuthentication
import TipKit

struct DiaryView: View {
    @ObservedObject var sharedLocationManager = LocationManager()
    @State var centerDate = Date()
    @State var selectedDate = Date()
    @State private var showTextEditor = false // Toggle this when a date is clicked
    @State private var journalEntries: [String: String] = [:] // Initialize journalEntries dictionary
    @State private var isDatePickerPresented: Bool = false
    @State private var selectedMood: [String:Int] = [:]
    @State private var lastFetchTime: Date? = nil // Sets and refreshes checkpoint when the weather API is called
    @State private var weatherData: WeatherData? = nil
    @State private var isSearching: Bool = false
    @State private var dragAmount: CGFloat = 0.0
    @State private var initialDragAmount: CGFloat = 0.0
    @State private var initialLoad = true // True if app was fully removed from background
    
    var arrowTip = arrowTipView()
    let internalDateFormatter = DateUtility.shared.internalDateFormatter
    
    func loadEntries() {
        let diaryEntries = DatabaseManager.shared.fetchEntries()
        for entry in diaryEntries { // Convert the date string to Date object using `internalDateFormatter`
            if let date = internalDateFormatter.date(from: entry.date) {
                let internalDateString = internalDateFormatter.string(from: date)

                let plainText = entry.text // Use the plain text from the entry
                journalEntries[internalDateString] = plainText // Update the journalEntries dictionary using internalDateString
                selectedMood[internalDateString] = entry.mood // Update the selectedMood dictionary
            }
        }
    }
    
    func goBackward() { // Function to navigate backward by one day
        centerDate = Calendar.current.date(byAdding: .day, value: -3, to: centerDate) ?? centerDate
    }

    func goForward() { // Function to navigate forward by one day/
        centerDate = Calendar.current.date(byAdding: .day, value: 3, to: centerDate) ?? centerDate
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dynamicBackground.edgesIgnoringSafeArea(.all)
                
                if isSearching {
                    SearchView(journalEntries: $journalEntries, showTextEditor: $showTextEditor, selectedDate: $selectedDate)
                } else {
                    if !showTextEditor {
                        VStack {
                            HStack {
                                WeatherView(locationManager: sharedLocationManager, lastFetchTime: $lastFetchTime, weatherData: $weatherData)
                                    .frame(width: 200, height: 100)
                                    .padding(.leading, 20)
                            }
                            .padding(.top, 20)
                            
                            ScrollDateView(initialLoad: $initialLoad, centerDate: $centerDate, selectedDate: $selectedDate, showTextEditor: $showTextEditor, journalEntries: $journalEntries)
                            Spacer()
                        }
                    }
                }
            }
            .onAppear {
                loadEntries() // Populate `ScrollDateView` when DiaryView appears
            }
            
            .fullScreenCover(isPresented: $showTextEditor) { // Integrate `TextEditorView` here
                let internalDateString = internalDateFormatter.string(from: selectedDate)
                let diaryTextBinding = Binding<String>(
                    get: { journalEntries[internalDateString] ?? "" },
                    set: { journalEntries[internalDateString] = $0 }
                )
                let selectedMoodBinding = Binding<Int>(
                    get: { selectedMood[internalDateString] ?? -1 },
                    set: { selectedMood[internalDateString] = $0 }
                )
                
                TextEditorView(journalEntries: $journalEntries, diaryText: diaryTextBinding, showTextEditor: $showTextEditor, selectedDate: $selectedDate, selectedMood: selectedMoodBinding)
            }
            
            .sheet(isPresented: $isDatePickerPresented) { // DatePicker splash screen
                ZStack {
                    Color.dynamicBackground
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .padding()
                            .onChange(of: selectedDate) { oldValue, newValue in
                                centerDate = newValue
                                isDatePickerPresented = false
                            }
                        
                        // `Jump to Today` button
                        Button("Jump to Today") {
                            selectedDate = Date()
                            centerDate = Date()
                            isDatePickerPresented = false
                        }
                        .padding()
                        .foregroundColor(Color.dynamicText)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                }
            }
            
            .toolbar { // Top buttons
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Button(action: {
                            isDatePickerPresented = true
                        }) {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        
                        Button(action: {
                            withAnimation(.smooth) {
                                isSearching.toggle()
                            }
                        }) {
                            Image(systemName: "rectangle.and.text.magnifyingglass")
                                .resizable()
                                .frame(width: 30, height: 25)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: goBackward) {
                            Image(systemName: "arrow.backward.square")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        
                        Button(action: goForward) {
                            Image(systemName: "arrow.right.square")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .popoverTip(arrowTip, arrowEdge: .top)
                }
            }
        }
    }
}
