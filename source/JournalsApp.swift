//
//  JournalsApp.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import SwiftUI
import Foundation
import LocalAuthentication
import TipKit

// Custom AppDelegate class
class CustomAppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(true, forKey: "wasTerminated")
    }
}

struct AuthenticationView: View {
    @Binding var isAuthenticated: Bool

    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to access the app."
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        isAuthenticated = true
                    } else {
                        // Handle error or failed authentication
                    }
                }
            }
        } else {
            // Handle the case when authentication is not available
        }
    }

    var body: some View {
        ZStack {
            Color.dynamicBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Button(action: {
                    authenticateUser()
                }) {
                    Image(systemName: "lock.rectangle")
                        .resizable()
                        .frame(width: 50, height: 40)
                }
                .foregroundColor(Color.dynamicText)
                
                Text("Tap to authenticate Face ID/Touch ID.")
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.dynamicText)
                    .padding(.top, 5)
            }
            .padding()
            .onAppear {
                authenticateUser()
            }
        }
    }
}


@main
struct JournalsApp: App {
    @UIApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "isFaceIDEnabled") && !isAuthenticated {
                AuthenticationView(isAuthenticated: $isAuthenticated)
            } else {
                BottomTabBar()
            }
        }
    }
    
    init() {
        configure()
        let languageArray = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String] ?? ["en"]
        UserDefaults.standard.set(languageArray, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
