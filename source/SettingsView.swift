//
//  SettingsView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI
import UserNotifications
import LocalAuthentication

struct SettingsView: View {
    @State private var isReminderEnabled = UserDefaults.standard.bool(forKey: "isReminderEnabled")
    @State private var notificationIdentifier: String?
    @State private var isFaceIDEnabled = UserDefaults.standard.bool(forKey: "isFaceIDEnabled")
    @State private var showExportActionSheet = false
    @State private var showTermsOfUse = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLanguageActionSheet = false
    @State private var selectedLanguage: String
    @State private var currentActionSheet: ActionSheetType?
    @State private var isShareSheetShowing = false
    @AppStorage("selectedThemeIndex") var selectedThemeIndex: Int = 0
    
    @ObservedObject var eventViewModel = EventViewModel(isReminderEnabled: Binding(get: {
        UserDefaults.standard.bool(forKey: "isReminderEnabled")
    }, set: { newValue in
        UserDefaults.standard.setValue(newValue, forKey: "isReminderEnabled")
    }))
    
    init() {
        let currentLanguageArray = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String] ?? Locale.preferredLanguages
        let currentLanguage = currentLanguageArray[0]
        
        switch currentLanguage {
        case "en":
            self._selectedLanguage = State(initialValue: "English")
        case "zh-Hans":
            self._selectedLanguage = State(initialValue: "简体中文")
        case "ja":
            self._selectedLanguage = State(initialValue: "日本語")
        default:
            self._selectedLanguage = State(initialValue: Locale.current.localizedString(forLanguageCode: currentLanguage) ?? "English")
        }
    }
    
    enum ActionSheetType: Identifiable {
        case exportData
        case selectLanguage
        
        var id: ActionSheetType { self }
    }
    
    let themeNames = [String(localized: "Lavender"),
                      String(localized: "Dawn Pink"),
                      String(localized: "Sea Mist"),
                      String(localized: "Tiffany Blue"),
                      String(localized: "Beige")]
    
    let internalDateFormatter = DateUtility.shared.internalDateFormatter
    
    // Activate notification at a fixed time
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                let content = UNMutableNotificationContent()
                content.body = String(localized: "The night is quite: Jot down today's inner words in your diary.")

                var dateComponents = DateComponents()
                dateComponents.hour = 21 // 9pm local time
                dateComponents.minute = 00

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

                center.add(request)
                self.notificationIdentifier = uuidString
            }
        }
    }

    // Improve privacy with biometric ID like Face ID and Touch ID
    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to enable this feature."
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.isFaceIDEnabled = true
                        UserDefaults.standard.setValue(true, forKey: "isFaceIDEnabled")
                    } else {
                        // Handle error or failed authentication
                        self.isFaceIDEnabled = false
                        UserDefaults.standard.setValue(false, forKey: "isFaceIDEnabled")
                    }
                }
            }
        } else {
            self.isFaceIDEnabled = false
            UserDefaults.standard.setValue(false, forKey: "isFaceIDEnabled")
        }
    }
    
    var body: some View {
        ZStack {
            Color.dynamicBackground.edgesIgnoringSafeArea(.all)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let topInset = (windowScene.windows.first?.safeAreaInsets.top ?? 0)
                
                // Non-translucent status bar background
                Rectangle()
                    .fill(Color.dynamicBackground.opacity(1))
                    .frame(width: UIScreen.main.bounds.width, height: topInset)
                    .position(x: UIScreen.main.bounds.width / 2, y: topInset / 2)
                    .ignoresSafeArea(edges: .top)
                    .zIndex(1) // Ensure it's above the background color
                
                VStack {
                    List {
                        // Notification section
                        Section (footer: Text("Default notification at 21:00 local time.").font(.system(size: 10))) {
                            Toggle(isOn: $isReminderEnabled) {
                                Text("Notification")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.dynamicText)
                            }
                            .listRowBackground(Color.dynamicSection)
                            .onChange(of: isReminderEnabled) { oldValue, newValue in
                                if newValue {
                                    scheduleNotification()
                                } else {
                                    if let identifier = notificationIdentifier {
                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                                        self.notificationIdentifier = nil // Reset the identifier
                                    }
                                }
                                UserDefaults.standard.setValue(newValue, forKey: "isReminderEnabled") // Save the state
                            }
                            
                            // FaceID section
                            Toggle(isOn: $isFaceIDEnabled) {
                                Text("Face ID / Touch ID")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.dynamicText)
                            }
                            .listRowBackground(Color.dynamicSection)
                            .onChange(of: isFaceIDEnabled) { oldValue, newValue in
                                if newValue {
                                    authenticateWithFaceID()
                                } else {
                                    self.isFaceIDEnabled = false
                                    UserDefaults.standard.setValue(false, forKey: "isFaceIDEnabled")
                                }
                            }
                        }
                        
                        // Theme customization
                        Section (footer: Text("Light mode themes. An app restart is required to see the changes.").font(.system(size: 10))) {
                            Picker(selection: $selectedThemeIndex, label: Text("Themes").font(.system(size: 15)).foregroundStyle(Color.dynamicText)) {
                                ForEach(themeNames.indices, id: \.self) { index in
                                    Text(themeNames[index])
                                        .font(.system(size: 15))
                                        .tag(index)
                                }
                            }
                            .foregroundStyle(Color.dynamicText)
                            .font(.system(size: 15))
                            .pickerStyle(.menu)
                        }
                        .listRowBackground(Color.dynamicSection)
                        
                        // Export data and language choice section
                        Section {
                            HStack {
                                Text("Language")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.dynamicText)
                                
                                Spacer()
                                
                                Text(selectedLanguage)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.dynamicText)
                                
                                Button(action: {
                                    currentActionSheet = .selectLanguage
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.dynamicText)
                                }
                            }
                            
                            HStack {
                                Text("Export Data")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.dynamicText)
                                
                                Spacer()
                                
                                Button(action: {
                                    currentActionSheet = .exportData
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.dynamicText)
                                }
                            }
                        }
                        .listRowBackground(Color.dynamicSection)
                    }
                    .scrollContentBackground(.hidden)
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showTermsOfUse = true
                        }) {
                            Text("Terms of Use & Privacy Policy")
                                .font(.system(size: 10))
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showTermsOfUse) {
            TermsOfUseView()
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                self.isReminderEnabled = UserDefaults.standard.bool(forKey: "isReminderEnabled")
            }
        }
        // Single action sheet for data export and language selection
        .actionSheet(item: $currentActionSheet) { item in
            switch item {
            case .selectLanguage:
                return ActionSheet(title: Text("An app restart is required to update app language."), buttons: [
                    .default(Text("English"), action: {
                        selectedLanguage = "English"
                        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                    }),
                    .default(Text("简体中文"), action: {
                        selectedLanguage = "简体中文"
                        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                    }),
                    .default(Text("日本語"), action: {
                        selectedLanguage = "日本語"
                        UserDefaults.standard.setValue(["ja"], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                    }),
                    .cancel()
                ])
                
            case .exportData:
                return ActionSheet(title: Text("Choose Export Format"), buttons: [
                    .default(Text("Plain Text"), action: {
                        let entries = DatabaseManager.shared.fetchEntries()
                        
                        if entries.isEmpty {
                            alertMessage = String(localized: "No entries to export.")
                            showAlert = true
                            return
                        }
                        
                        var plainText = ""
                        for entry in entries {
                            plainText += "Date: \(entry.date)\n"
                            plainText += "Text: \(entry.text)\n"
                            plainText += "Mood: \(entry.mood)\n\n"
                        }
                        
                        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DiaryEntries.txt")
                        do {
                            try plainText.write(to: fileURL, atomically: true, encoding: .utf8)
                            alertMessage = String(localized: "Export successful. File saved to system.")
                            isShareSheetShowing = true // Trigger the share sheet
                        } catch {
                            print("Error saving file: \(error)")
                            alertMessage = String(localized: "Export failed. Please try again.")
                        }
                    }),
                    .cancel()
                ])
            }
        }
        // Data export alert message
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Export Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isShareSheetShowing, onDismiss: {
            isShareSheetShowing = false // Reset the state
        }) {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DiaryEntries.txt")
            ShareSheet(activityItems: [fileURL])
        }

    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No actions
    }
}
