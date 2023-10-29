//
//  BottomTabBar.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI
import UIKit

struct BottomTabBar: View {
    init() {
        UITabBar.appearance().barTintColor = UIColor(Color.dynamicBackground)
    }
    
    @State private var selectedTab = 1 // Set DiaryView to be the default View
    
    var body: some View {
        ZStack {
            Color.dynamicBackground
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                // First tab: CountDown
                CountDownView()
                    .tabItem {
                        Image(systemName: "calendar.badge.clock")
                        Text("CountDown")
                    }
                    .foregroundStyle(Color.dynamicText)
                    .tag(0)
                
                // Second tab: navigate to DiaryView
                DiaryView()
                    .tabItem {
                        Image(systemName: "books.vertical")
                        Text("Diary")
                    }
                    .foregroundStyle(Color.dynamicText)
                    .tag(1)
                
                // Third tab: Mood Tracker + analysis
                MoodAnalysisView()
                    .tabItem {
                        Image(systemName: "ellipsis.viewfinder")
                        Text("Summary")
                    }
                    .foregroundStyle(Color.dynamicText)
                    .tag(2)
                
                // Fourth tab: Settings
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .foregroundStyle(Color.dynamicText)
                    .tag(3)
            }
            .tint(Color.dynamicIcon)
        }
    }
}
