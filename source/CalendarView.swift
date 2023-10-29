//
//  CalendarView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable {
    @Binding var datesWithEntries: [Date] // Pass the dates with entries
    @Binding var selectedDate: Date?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> FSCalendar {
        
        let calendar = FSCalendar()
        
        // Determine the current appearance mode (dark or light)
        let userInterfaceStyle = calendar.traitCollection.userInterfaceStyle
        
        if userInterfaceStyle == .dark {
            // If in dark mode, set text colors to white
            calendar.appearance.weekdayTextColor = .white
            calendar.appearance.headerTitleColor = .white
            calendar.appearance.titleDefaultColor = .white
        } else {
            // If in light mode, set text colors to black
            calendar.appearance.weekdayTextColor = .black
            calendar.appearance.headerTitleColor = .black
            calendar.appearance.titleDefaultColor = .black
        }
        
        calendar.scope = .month // Set to display month view
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.appearance.todayColor = UIColor.gray.withAlphaComponent(0.5)
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // Trigger update if dates change or other properties need to be updated
        uiView.reloadData()
        
        // Determine the current appearance mode (dark or light)
        let userInterfaceStyle = uiView.traitCollection.userInterfaceStyle

        if userInterfaceStyle == .dark {
            // If in dark mode, set text colors to white
            uiView.appearance.weekdayTextColor = .white
            uiView.appearance.headerTitleColor = .white
            uiView.appearance.titleDefaultColor = .white
        } else {
            // If in light mode, set text colors to black
            uiView.appearance.weekdayTextColor = .black
            uiView.appearance.headerTitleColor = .black
            uiView.appearance.titleDefaultColor = .black
        }
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource { // Add FSCalendarDataSource
        var parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            // Compare dates by their components (year, month, day)
            if parent.datesWithEntries.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                return 1 // 1 == there is an event for this date
            }
            return 0
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: date)

            if let selectedDate = dateFormatter.date(from: formattedDate) {
                self.parent.selectedDate = selectedDate
            } else {
                print("Error formatting selected date")
            }
            
            calendar.collectionView.reloadItems(at: calendar.collectionView.indexPathsForVisibleItems) // Avoid flickering
        }
    }
}

