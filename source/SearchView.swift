//
//  SearchView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-07.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @Binding var journalEntries: [String: String]
    @Binding var showTextEditor: Bool
    @Binding var selectedDate: Date

    var searchTip = SearchTipView()
    var filteredEntries: [String: String] {
        return journalEntries.filter {
            let textMatches = $0.value.lowercased().contains(searchText.lowercased())
            let dateMatches = internalDateFormatter.date(from: $0.key)?.description.contains(searchText) ?? false

            return textMatches || dateMatches
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationView {
                    VStack {
                        TextField("Search", text: $searchText)
                            .font(.system(size: 15))
                            .padding(10)
                            .background(Color.dynamicSection)
                            .cornerRadius(8)
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .popoverTip(searchTip, arrowEdge: .top)
                        
                        List(filteredEntries.keys.sorted(), id: \.self) { key in
                            Button(action: {
                                if let date = internalDateFormatter.date(from: key) {
                                    selectedDate = date
                                    showTextEditor = true
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(internalDateFormatter.string(from: internalDateFormatter.date(from: key) ?? Date()))
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.dynamicText)
                                    
                                    Text(filteredEntries[key] ?? "")
                                        .font(.system(size: 13))
                                        .lineSpacing(2)
                                        .foregroundColor(Color.dynamicText)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .gesture(DragGesture().onChanged {_ in
                            UIApplication.shared.endEditing()
                        })
                        
                        Spacer()
                    }
                    .background(Color.dynamicBackground)
                }
            }
        }
    }
}
