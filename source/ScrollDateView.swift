//
//  ScrollDateView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-10.
//

import Foundation
import SwiftUI

struct ScrollDateView: View {
    @Binding var initialLoad: Bool
    @Binding var centerDate: Date
    @Binding var selectedDate: Date
    @Binding var showTextEditor: Bool
    @Binding var journalEntries: [String: String]
    
    let internalDateFormatter = DateUtility.shared.internalDateFormatter
    
    func isToday(_ date: Date) -> Bool { // Check if date is today
        let startOfDay = Calendar.current.startOfDay(for: date)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return startOfDay == startOfToday
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {
                    ForEach((-3...3), id: \.self) { value in // Show 7 days, today in the middle, +3 && -3.
                        let date = Calendar.current.date(byAdding: .day, value: value, to: centerDate)!
                        let internalDateString = internalDateFormatter.string(from: date)
                        let displayDateString = displayDateFormatter.string(from: date)
                        let entry = self.journalEntries[internalDateString]
                        
                        Button(action: {
                            self.selectedDate = date
                            self.showTextEditor = true
                        }) {
                            VStack {
                                Text("\(displayDateString)\(isToday(date) ? String(localized: " (Today)") : "")")
                                    .font(.system(size: 15, weight: isToday(date) ? .semibold : .regular))
                                    .foregroundColor(Color.dynamicText)
                                    .frame(height: 24)
                                    .padding(.top, 7)
                                
                                Rectangle()
                                    .fill(Color.dynamicBorder)
                                    .frame(width: 230, height: 1)
                                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 4)
                                
                                Spacer()
                                
                                Text(entry?.count ?? 0 <= 50 ? entry ?? "" : "\(String(entry!.prefix(300)))...") // Show first 300 characters as preview
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.dynamicText)
                                    .frame(height: 160) // Fixed height
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(4)
                            }
                            .padding(10)
                            .background(Color.dynamicContainer)
                            .cornerRadius(10)
                            .shadow(color: Color.dynamicBorder.opacity(0.5), radius: 5, x: 0, y: 5)
                        }
                        .id(internalDateFormatter.string(from: date)) // Format to `yyyy-mm-dd` to exclude seconds
                        .frame(width: UIScreen.main.bounds.width * 0.64, height: UIScreen.main.bounds.height * 0.48)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.6)
                .scrollTargetLayout()
            }
            .onAppear {
                DispatchQueue.main.async {
                    if initialLoad { // If is app's first launch (app was closed or is first downloaded), jump to today
                        let startOfToday = internalDateFormatter.string(from: Date())
                        scrollProxy.scrollTo(startOfToday, anchor: .center)
                        initialLoad = false
                    } else { // Stay at the button clicked
                        let startOfSelectedDate = internalDateFormatter.string(from: selectedDate)
                        scrollProxy.scrollTo(startOfSelectedDate, anchor: .center)
                    }
                }
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 70)
        }
    }
}
