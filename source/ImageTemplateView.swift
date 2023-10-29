//
//  ImageTemplateView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-04.
//

import Foundation
import SwiftUI
import UIKit

struct ImageTemplateView: View {
    let title: String
    let days: String
    let date: String
    
    var body: some View {
        ZStack {
            Color.dynamicBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Upper 20%
                UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                    .foregroundStyle(Color.dynamicContainer)
                    .frame(height: 60)
                    .shadow(radius: 2, x: 0, y: 3)
                    .overlay(
                        Text("\(title) \(Int(days)! < 0 ? String(localized: "has been") : String(localized: "in"))")
                            .foregroundStyle(Color.dynamicText)
                    )
                
                // Lower 80% for Days and Date
                VStack {
                    Spacer()
                    
                    // Major part for the number of days passed or left
                    HStack {
                        
                        Text("\(String(abs(Int(days)!)))")
                            .font(.system(size: 100))
                            .padding(.bottom, 20)
                            .foregroundStyle(Color.dynamicText)
                    }
                    
                    Spacer()
                    
                    // Bottom part for the Date
                    Text(date)
                        .font(.caption)
                        .padding(.bottom)
                        .foregroundStyle(Color.dynamicText)
                }
                .frame(height: 200)
            }
            .frame(width: 300, height: 250)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.dynamicContainer)
                    .frame(width: 300, height: 260)
                    .shadow(color: Color.dynamicBorder.opacity(0.5), radius: 5, x: 0, y: 2)
            )
            
            
            VStack {
                Spacer()
                Text("Journals")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .padding(.bottom, -10)
            }
        }
    }
}
