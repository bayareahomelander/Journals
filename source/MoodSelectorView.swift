//
//  MoodSelectorView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI

struct MoodSelectorView: View {
    @Binding var selectedMood: Int
    @State private var selectedMoodArray1: Int = -1
    @State private var selectedMoodArray2: Int = -1
    @State private var currentArrayIndex = 0
    @State private var sliderValue: Double = 0.0
    @State private var showSlider: Bool = false
    @State private var clickCount = 0
    @State private var tempMoodText: String?
    @State private var moodTextTask: DispatchWorkItem?
    
    private func moodEmoji(for index: Int) -> String {
        let emojiLists = [
            ["😢", "😔", "🤦‍♂️", "😰", "🥺", "🤔", "😠", "😡", "🙂", "😃", "😊", "😌", "💪", "😮‍💨", "🥳", "🤩", "🤗"],
            ["💔", "🌫️", "🌑", "☁️", "📷", "🧘‍♂️", "😾", "💣", "☀️", "🌈", "🌠", "🎆", "💯", "🍵", "🎉", "⚡", "🌱"]
        ]
        
        if currentArrayIndex < emojiLists.count {
            let currentArray = emojiLists[currentArrayIndex]
            if index >= 0 && index < currentArray.count {
                return currentArray[index]
            }
        }
        return ""
    }
    
    var body: some View {
        // Mood Selector definition, wrapped in a rectangular container
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.dynamicBackground)
            .shadow(color: Color.dynamicBorder, radius: 5)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 130)
            .overlay(
                VStack{
                    HStack {
                        Text("How was your day?")
                            .font(.system(size: 15))
                            .padding(.top, 15)
                            .foregroundColor(Color.dynamicText)
                        
                        Button(action: {
                            clickCount += 1  // Increment the click count each time the button is pressed
                            
                            // Determine what to show based on the click count
                            if clickCount % 3 == 0 {
                                currentArrayIndex = 0
                                showSlider = false
                            } else if clickCount % 3 == 1 {
                                currentArrayIndex = 1
                                showSlider = false
                            } else {
                                currentArrayIndex = 0  // Default to the first array when showing the slider
                                showSlider = true
                            }
                        }) {
                            Image(systemName: "repeat")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                        .padding(.top, 15)
                    }
                    
                    if showSlider { // Conditional Slider and Text
                        Slider(value: $sliderValue, in: 0...16, step: 1)
                            .frame(height: 40)
                            .padding(.horizontal)
                            .onChange(of: sliderValue) { selectedMood = Int(sliderValue) }
                        
                        if Int(sliderValue) >= 0 && Int(sliderValue) < moodTexts.count {
                            Text("\(moodTexts[Int(sliderValue)])")
                                .foregroundStyle(Color.dynamicText)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .padding(.bottom, 15)
                        }
                            
                        Spacer()
                    } else {
                        ZStack { // Mood selector starts here
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 20) {
                                    ForEach(0..<17) { moodIndex in
                                        Button(action: {
                                            // Cancel selection if clicked again, otherwise set to the clicked mood; separate index for each array and slider
                                            if currentArrayIndex == 0 {
                                                selectedMoodArray1 = (selectedMoodArray1 == moodIndex) ? -1 : moodIndex
                                                selectedMood = selectedMoodArray1
                                            } else if currentArrayIndex == 1 {
                                                selectedMoodArray2 = (selectedMoodArray2 == moodIndex) ? -1 : moodIndex
                                                selectedMood = selectedMoodArray2
                                            }
                                            sliderValue = Double(selectedMood)
                                            tempMoodText = moodTexts[moodIndex]
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                tempMoodText = nil
                                            }

                                        }) {
                                            Text(moodEmoji(for: moodIndex))
                                                .font(.largeTitle)
                                                .background(selectedMood == moodIndex ? Color.gray.opacity(0.5) : Color.clear) // Gray background if selected
                                                .cornerRadius(8)
                                        }
                                        .padding(.top, 10)
                                        .padding(.bottom, 15)
                                    }
                                }
                                .scrollTargetLayout()
                                .safeAreaPadding(.horizontal, 20)
                            }
                            .scrollTargetBehavior(.viewAligned)
                            if let text = tempMoodText {
                                Text(text)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 10))
                                    .position(x: UIScreen.main.bounds.width / 2.2, y: 75)
                            }
                        }
                    }
                }
            )
    }
}
