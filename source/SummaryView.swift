//
//  SummaryView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI

struct SummaryView: View {
    var selectedDate: Date?
    var moodScore: Int?
    var entryText: String?
    var descriptions: [String]
    
    private var summaryText: String {
        
        if let selectedDate = selectedDate,
           let moodScore = DatabaseManager.shared.fetchScoresOnly(for: selectedDate),
           let entryText = DatabaseManager.shared.fetchTextOnly(for: selectedDate),
           moodScore < descriptions.count {

            // Keyword extraction
            let keywords = extractKeywords(from: entryText).map { $0.capitalized }
            let keywordsString = keywords.joined(separator: ", ")

            // Sentiment analysis
            let sentimentDescription = analyzeSentiment(text: entryText, dateHash: selectedDate.hashValue)
            print(sentimentDescription)

            // Map sentiment to cheer-up category
            let cheerUpCategory: String
            switch sentimentDescription {
                case "positive": cheerUpCategory = "positive"
                case "negative": cheerUpCategory = "negative"
                default: cheerUpCategory = "balanced"
            }
            
            let hashValue = selectedDate.hashValue
            var cheerUpMessage: String? = fetchCheerUpMessage(for: selectedDate)
            let moodComparisonText = generateMoodComparisonText(selectedDate: selectedDate)
            
            if cheerUpMessage == nil {
                let messages = cheerUpMessages[cheerUpCategory] ?? []
                let index = abs(hashValue) % messages.count
                cheerUpMessage = messages[index]
                saveCheerUpMessage(for: selectedDate, message: cheerUpMessage!)
            }
            
            let moodDescriptionPart: String
            if moodScore == -1 {
                moodDescriptionPart = String(localized: "No mood selected for this day.")
            } else if moodScore >= 0 && moodScore < descriptions.count {
                moodDescriptionPart = String(localized: "You felt \(descriptions[moodScore]) on this day. \(moodComparisonText)")
            } else {
                moodDescriptionPart = String(localized: "Invalid mood score for this day.")
            }
            
            return String(localized: "Keywords of the Day: \n\(keywordsString). \n\n\(moodDescriptionPart)\n\n\(cheerUpMessage!)")
        }
        return String(localized: "No entry for this day.")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(summaryText)
                .lineLimit(nil)
                .lineSpacing(4)
                .foregroundColor(Color.dynamicText)
                .font(.system(size: 15))
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}
