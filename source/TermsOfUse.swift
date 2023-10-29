//
//  TermsOfUse.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        ZStack {
            Color.dynamicBackground
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                Spacer()
                
                Group {
                    Text("Terms of Use")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("1. Acceptance of Terms")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("By accessing or using the 'Journals' app, you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use the app.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("2. Use of the App")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("'Journals' provides features for writing diaries, tracking countdowns, and reviewing past mood patterns. You agree to use the app responsibly and in accordance with all applicable laws.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("3. Content Ownership")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("You retain ownership of all content you create within the app. You are solely responsible for the content you create and its legality.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("4. Data Storage")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("All data created within 'Journals' is stored locally on your device. We do not access or store your data on our servers.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("5. Changes to Terms")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of any changes.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("1. Personal Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("'Journals' does not collect or store any personal information. All data is stored locally on your device.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("2. Local Data Storage")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("All data you create within the app, including diaries and mood patterns, is stored solely on your device. We do not have access to this data, and it is not shared with third parties.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("3. Permissions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("The app may request permissions to access certain features on your device, such as notifications, Face ID / Touch ID, and photo album. You have the right to accept or deny these permissions.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }
                
                Group {
                    Text("4. Changes to Privacy Policy")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dynamicText)
                    
                    Text("We may update this privacy policy from time to time. We encourage you to review this policy regularly to stay informed about our privacy practices.")
                        .font(.system(size: 15))
                        .padding()
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.dynamicText)
                }

            }
            .padding(.top, 20)
        }
    }
}
