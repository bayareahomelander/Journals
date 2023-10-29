//
//  CountdownView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI

struct CountDownView: View{
    @ObservedObject var viewModel = EventViewModel()
    @State private var showEventView = false
    
    // Separate the events into pinned and unpinned arrays
    private var pinnedEvents: [CountdownEvent] {
        return viewModel.events.filter { $0.isPinned }
    }
    
    private var unpinnedEvents: [CountdownEvent] {
        return viewModel.events.filter { !$0.isPinned }
    }
    
    var body: some View {
        ZStack {
            Color.dynamicBackground.edgesIgnoringSafeArea(.all)
            
            if viewModel.events.isEmpty {
                VStack {
                    Button(action: {
                        showEventView = true
                    }) {
                        Image(systemName: "plus.rectangle")
                            .resizable()
                            .foregroundStyle(Color.dynamicText)
                            .frame(width: 45, height: 35)
                    }
                    .padding(.bottom, 5)
                    
                    Text("Tap to add an event.")
                        .font(.system(size: 13))
                        .foregroundColor(Color.dynamicText)
                }
            } else {
                // This child view contains a list of events created; allows searching, and grouping by either pin status or event tag (e.g. Holiday, Anniversary, etc).
                EventListView(viewModel: self.viewModel, pinnedEvents: pinnedEvents, unpinnedEvents: unpinnedEvents)
            }
        }
        .fullScreenCover(isPresented: $showEventView) {
            // This child view is where users will create/modify an event at, after clicking the "Plus" button
            EventView(viewModel: self.viewModel)
        }
        .onAppear {
            viewModel.fetchEvents()
        }
        // Re-fetch events when the fullScreenCover modifier is dismissed
        .onChange(of: showEventView) { oldValue, newValue in
            if !newValue {
                viewModel.fetchEvents()
            }
        }
    }
}
