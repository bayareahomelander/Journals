//
//  LineChartView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI
import UIKit

class MoodScores: ObservableObject {
    @Published var scores: [CGFloat] = []
    @Published var dates: [String] = []

    func loadMoodScores() {
        let moodData = DatabaseManager.shared.fetchMoodScores()
        scores = moodData.map { $0.score }
        dates = moodData.map { $0.date }
    }
}

struct LineChartView: View {
    @ObservedObject var moodScores: MoodScores

    // Calculate the minimum and maximum values for scaling
    private var maxY: CGFloat { moodScores.scores.max() ?? 0 }
    private var minY: CGFloat { moodScores.scores.min() ?? 0 }
    @State private var showScore: Bool = false
    
    // State to keep track of the selected index
    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    ForEach(0..<5) { index in
                        Path { path in
                            let yPosition = geometry.size.height * CGFloat(index) / 4
                            path.move(to: CGPoint(x: 0, y: yPosition))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition))
                        }
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1) // Grid line color and width
                    }

                    // Line chart path
                    if !moodScores.scores.isEmpty {
                        Path { path in
                            let yPositionForFirstValue = geometry.size.height - (geometry.size.height * (moodScores.scores[0] - minY) / (maxY - minY))
                            path.move(to: CGPoint(x: 0, y: yPositionForFirstValue))
                            
                            for index in 1..<moodScores.scores.indices.count {
                                let xPosition1 = geometry.size.width * CGFloat(index - 1) / CGFloat(moodScores.scores.count - 1)
                                let yPosition1 = geometry.size.height - (geometry.size.height * (moodScores.scores[index - 1] - minY) / (maxY - minY))
                                
                                let xPosition2 = geometry.size.width * CGFloat(index) / CGFloat(moodScores.scores.count - 1)
                                let yPosition2 = geometry.size.height - (geometry.size.height * (moodScores.scores[index] - minY) / (maxY - minY))
                                
                                let controlPoint1 = CGPoint(x: (xPosition1 + xPosition2) / 2, y: yPosition1)
                                let controlPoint2 = CGPoint(x: (xPosition1 + xPosition2) / 2, y: yPosition2)
                                
                                path.addCurve(to: CGPoint(x: xPosition2, y: yPosition2), control1: controlPoint1, control2: controlPoint2)
                            }
                        }
                        .stroke(Color.dynamicText, lineWidth: 2)
                        .shadow(color: Color.dynamicBorder.opacity(0.7), radius: 4, x: 0, y: 4)
                    }
                    
                    // Render mood scores when gesture detected
                    if let index = selectedIndex, showScore {
                        // Calculate the position for the score tooltip
                        let xPosition = geometry.size.width * CGFloat(index) / CGFloat(moodScores.scores.count - 1)
                        let yPosition = geometry.size.height - (geometry.size.height * (moodScores.scores[index] - minY) / (maxY - minY))
                        
                        // Display mood score
                        Text("\(Int(moodScores.scores[index]))")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.dynamicText)
                            .fontWeight(.semibold)
                            .background(Color.clear)
                            .position(x: xPosition, y: yPosition + 8)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Calculate the closest data point index
                            let index = Int(round(value.location.x / (geometry.size.width / CGFloat(moodScores.scores.count - 1))))
                            if index >= 0 && index < moodScores.scores.count {
                                selectedIndex = index
                                showScore = true
                            }
                        }
                        .onEnded { _ in
                            // Hide the score when the user lifts their finger
                            showScore = false
                        }
                )
            }
            .padding()
            .background(Color.dynamicContainer) // Background color
            .padding(.bottom, 3)
            
            // Render dates on the x-axis
            HStack {
                ForEach(moodScores.dates, id: \.self) { dateString in
                    let formattedDate = formatDate(dateString) // Format the date
                    Text(formattedDate)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.dynamicText)
                    Spacer()
                }
            }
            .padding(.bottom, 5)
            .padding(.leading, 15)
        }
        .onAppear {
            moodScores.loadMoodScores() // Fetch the mood scores when the view appears
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d"
            
            // Check for locale to modify the format for Chinese and Japanese
            if let languageCode = Locale.current.language.languageCode?.identifier {
                if languageCode == "zh" || languageCode == "ja" {
                    // For Chinese and Japanese, the day needs to be suffixed with "日"
                    dateFormatter.dateFormat = "M月d"
                    let formattedDate = dateFormatter.string(from: date)
                    return "\(formattedDate)日"
                }
            }
            return dateFormatter.string(from: date)
        }
        return ""
    }
}
