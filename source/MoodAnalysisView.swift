//
//  MoodAnalysisView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI
import FSCalendar
import NaturalLanguage

class DatesWithEntries: ObservableObject {
    @Published var dates: [Date] = []
    
    func loadDates() {
        dates = DatabaseManager.shared.fetchDatesWithEntries()
    }
}

struct MoodAnalysisView: View {
    @ObservedObject var datesWithEntries = DatesWithEntries() // Populate calendar with dates with entries
    @ObservedObject var moodScores = MoodScores()
    @State private var selectedDate: Date? = nil
    @State private var greetingText: String = ""
    @State private var baseGreeting: String = ""
    @State private var moodMessage: String = ""
    
    func setPersonalizedGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Determine time of day
        if hour >= 5 && hour < 12 {
            baseGreeting = String(localized: "Good Morning.")
            moodMessage = String(localized: "Let's make the most of today.")
        } else if hour >= 12 && hour < 19 {
            baseGreeting = String(localized: "Good Afternoon.")
            moodMessage = String(localized: "Take a moment to breathe.")
        } else {
            baseGreeting = String(localized: "Good Evening.")
            moodMessage = String(localized: "Time to reflect in the moment of ease.")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
            
                Color.dynamicBackground
                    .edgesIgnoringSafeArea(.all)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let topInset = (windowScene.windows.first?.safeAreaInsets.top ?? 0)
                    
                    // Non-translucent status bar background
                    Rectangle()
                        .fill(Color.dynamicBackground.opacity(1))
                        .frame(width: UIScreen.main.bounds.width, height: topInset)
                        .position(x: UIScreen.main.bounds.width / 2, y: topInset / 2)
                        .ignoresSafeArea(edges: .top)
                        .zIndex(1) // Ensure it's above the background color
                    
                    ScrollView {
                        Spacer()
                        VStack {
                            HStack(alignment: .top) { // Greeting text part 1
                                Text(baseGreeting)
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.dynamicText)
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            
                            HStack(alignment: .top) { // Greeting text part 2
                                Text(moodMessage)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.dynamicText)
                                    .onAppear(perform: setPersonalizedGreeting)
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .padding(.bottom, 20)
                            
                            // CalendarView (FSCalendar) starts here
                            CalendarView(datesWithEntries: $datesWithEntries.dates, selectedDate: $selectedDate)
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.52)
                                .clipped() // Ensure the calendar does not overflow its bounds
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onAppear {
                                    if selectedDate == nil {
                                        selectedDate = Date() // Set the selected date to the current date only if it has not been set
                                    }
                                    datesWithEntries.loadDates()
                                    moodScores.loadMoodScores()
                                }
                                .onChange(of: datesWithEntries.dates) {
                                    datesWithEntries.loadDates()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.dynamicContainer)
                                        .frame(width: UIScreen.main.bounds.width * 0.9)
                                        .shadow(color: Color.dynamicBorder.opacity(0.5), radius: 2, x: 0, y: 2)
                                        .padding(.bottom, 20)
                                )
                            
                            HStack(alignment: .top) {
                                Text("Your Summary for \(selectedDate != nil ? dateFormatter.string(from: selectedDate!) : "\(dateFormatter.string(from: Date()))")")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, -2)
                                    .foregroundStyle(Color.dynamicText)
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            
                            // SummaryView starts here
                            SummaryView (
                                selectedDate: selectedDate,
                                moodScore: selectedDate != nil ? DatabaseManager.shared.fetchScoresOnly(for: selectedDate!) : nil,
                                entryText: selectedDate != nil ? DatabaseManager.shared.fetchTextOnly(for: selectedDate!) : nil,
                                descriptions: descriptions
                            )
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.dynamicContainer)
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .shadow(color: Color.dynamicBorder.opacity(0.5), radius: 2, x: 0, y: 2)
                            )
                            
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text("Your Mood Pattern")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.dynamicText)
                                        .padding(.bottom, -1)
                                        .padding(.top, 20)
                                }
                                
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            
                            // Line chart container
                            LineChartView(moodScores: moodScores)
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: 200)
                                .clipped() // Ensure the calendar does not overflow its bounds
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.dynamicContainer)
                                        .frame(width: UIScreen.main.bounds.width * 0.9)
                                        .shadow(color: Color.dynamicBorder.opacity(0.5), radius: 2, x: 0, y: 2)
                                )
                        }
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.horizontal, 0)
                        .padding(.bottom, 15)
                        .onAppear {
                            moodScores.loadMoodScores()
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}
