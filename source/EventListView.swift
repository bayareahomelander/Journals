//
//  EventListView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-02.
//

import Foundation
import SwiftUI

struct EventListView: View {
    @ObservedObject var viewModel: EventViewModel
    var pinnedEvents: [CountdownEvent]
    var unpinnedEvents: [CountdownEvent]
    @State private var showEventView = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var groupByTags = false
    
    // Function to handle deletion
    private func deleteEvent(at offsets: IndexSet, from events: [CountdownEvent]) {
        for index in offsets {
            let event = events[index]
            let _ = DatabaseManager.shared.deleteEvent(uuid: event.uuid)
        }
        // Fetch the updated events list
        viewModel.fetchEvents()
    }
    
    // Conditional check for displaying string
    private func countdownText(for days: Int) -> String {
        if days == 0 {
            return String(localized: "is Today")
        } else if days > 0 {
            return String(localized: "in \(String(days)) day(s)")
        } else {
            return String(localized: "has been \(String(abs(days))) day(s)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                GroupByView(
                    isSearching: $isSearching,
                    searchText: $searchText,
                    groupByTags: $groupByTags,
                    pinnedEvents: pinnedEvents,
                    unpinnedEvents: unpinnedEvents,
                    viewModel: viewModel,
                    deleteEvent: deleteEvent(at:from:),
                    countdownText: countdownText(for:)
                )
            }
            .toolbar {
                // Rearrange by Tags button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button (action: {
                        groupByTags.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .resizable()
                            .foregroundColor(Color.dynamicText)
                            .frame(width: 25, height: 25)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Add new event button
                        Button (action: {
                            showEventView = true
                        }) {
                            Image(systemName: "plus.rectangle")
                                .resizable()
                                .foregroundColor(Color.dynamicText)
                                .frame(width: 30, height: 25)
                        }
                        
                        // Search button
                        Button (action: {
                            withAnimation {
                                isSearching.toggle()
                            }
                        }) {
                            Image(systemName: "rectangle.and.text.magnifyingglass")
                                .resizable()
                                .foregroundColor(Color.dynamicText)
                                .frame(width: 30, height: 25)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showEventView) {
            EventView(viewModel: self.viewModel)
        }
        // Re-fetch events when the full screen cover is dismissed
        .onChange(of: showEventView) { oldValue, newValue in
            if !newValue {
                viewModel.fetchEvents()
            }
        }
    }
}

