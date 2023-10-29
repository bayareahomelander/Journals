//
//  GroupByView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-04.
//

import Foundation
import SwiftUI
import TipKit

struct GroupByView: View {
    @Binding var isSearching: Bool
    @Binding var searchText: String
    @Binding var groupByTags: Bool
    
    var pinnedEvents: [CountdownEvent]
    var unpinnedEvents: [CountdownEvent]
    var viewModel: EventViewModel
    var deleteEvent: (IndexSet, [CountdownEvent]) -> ()
    var countdownText: (Int) -> String
    var filterTip = filterTipView()
    
    private var groupedEvents: [String: [CountdownEvent]] {
        let allEvents = pinnedEvents + unpinnedEvents
        return Dictionary(grouping: allEvents) { $0.tag }
    }
    
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
        ZStack {
            Color.dynamicBackground.ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    TipView(filterTip)
                }
                .background(Color.dynamicBackground.ignoresSafeArea(.all))
                .frame(width: UIScreen.main.bounds.width * 0.9)
                
                List {
                    if isSearching {
                        TextField("Search", text: $searchText)
                            .font(.system(size: 15))
                            .listRowBackground(Color.dynamicSection)
                    }
                    
                    if groupByTags {
                        ForEach(
                            groupedEvents.keys.filter { key in
                                searchText.isEmpty ? true :
                                key.lowercased().contains(searchText.lowercased()) ||
                                groupedEvents[key]!.contains(where: { $0.eventName.lowercased().contains(searchText.lowercased()) })
                            }.sorted(),
                            id: \.self
                        ) { key in
                            Section (header: Text(key)) {
                                ForEach(groupedEvents[key]!, id: \.uuid) { event in
                                    NavigationLink(destination: EventView(event: event, viewModel: self.viewModel)) {
                                        HStack {
                                            Text(event.eventName)
                                                .foregroundStyle(Color.dynamicText)
                                                .font(.system(size: 15))
                                            
                                            Spacer()
                                            
                                            Text(countdownText(for: event.daysLeftOrPassed))
                                                .foregroundColor(Color.dynamicText)
                                                .font(.system(size: 15))
                                        }
                                    }
                                    .listRowBackground(Color.dynamicSection)
                                }
                            }
                        }
                    } else {
                        Section (header: Text("Pinned")) {
                            ForEach(pinnedEvents.filter { searchText.isEmpty ? true : $0.eventName.lowercased().contains(searchText.lowercased()) || $0.tag.lowercased().contains(searchText.lowercased()) }, id: \.uuid) { event in
                                NavigationLink(destination: EventView(event: event, viewModel: self.viewModel)) {
                                    HStack {
                                        Text(event.eventName)
                                            .foregroundStyle(Color.dynamicText)
                                            .font(.system(size: 15))
                                        
                                        Spacer()
                                        
                                        Text(countdownText(for: event.daysLeftOrPassed))
                                            .foregroundColor(Color.dynamicText)
                                            .font(.system(size: 15))
                                    }
                                }
                                .listRowBackground(Color.dynamicSection)
                            }
                            .onDelete { offsets in
                                deleteEvent(at: offsets, from: pinnedEvents)
                            }
                        }
                        
                        Section (header: Text("General")) {
                            ForEach(unpinnedEvents.filter { searchText.isEmpty ? true : $0.eventName.lowercased().contains(searchText.lowercased()) || $0.tag.lowercased().contains(searchText.lowercased()) }, id: \.uuid) { event in
                                NavigationLink(destination: EventView(event: event, viewModel: self.viewModel)) {
                                    HStack {
                                        Text(event.eventName)
                                            .foregroundStyle(Color.dynamicText)
                                            .font(.system(size: 15))
                                        
                                        Spacer()
                                        
                                        Text(countdownText(for: event.daysLeftOrPassed))
                                            .foregroundColor(Color.dynamicText)
                                            .font(.system(size: 15))
                                    }
                                }
                                .listRowBackground(Color.dynamicSection)
                            }
                            .onDelete { offsets in
                                deleteEvent(at: offsets, from: unpinnedEvents)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.dynamicBackground)
                .onAppear {
                    viewModel.updateAllDaysLeftOrPassed()
                }
            }
        }
    }
}
