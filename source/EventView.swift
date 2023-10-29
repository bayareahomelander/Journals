//
//  EventView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-01.
//

import Foundation
import SwiftUI
import TipKit

struct EventView: View {
    var event: CountdownEvent?
    @ObservedObject var viewModel: EventViewModel
    let internalDateFormatter = DateUtility.shared.internalDateFormatter
    var savePicture = savePictureView()
    
    @Environment(\.presentationMode) var presentationMode
    @State private var eventName = ""
    @State private var eventDate = Date()
    @State private var showDatePicker: Bool = false
    @State private var isPinned: Bool = false
    @State private var eventNote = ""
    @State private var selectedAdvanceNotice: Int = -1  // Default to No Reminder
    @State private var selectedTag: String = String(localized: "")
    
    @State private var showAlert = false
    @State private var hasChanges = false
    @State private var showShareView = false
    
    init(event: CountdownEvent? = nil, viewModel: EventViewModel) {
        self.event = event
        self.viewModel = viewModel
    }
    
    private func saveAction() {
        // Dismiss View if nothing entered
        guard !eventName.isEmpty else {
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        let eventDateString = internalDateFormatter.string(from: eventDate)
        let uuid = event?.uuid ?? UUID().uuidString // Use existing UUID if editing, else generate new one
        
        var isSuccess = false
        if let _ = event {
            // Update existing event
            isSuccess = DatabaseManager.shared.updateEvent(uuid: uuid, eventName: eventName, eventDate: eventDateString, isPinned: isPinned, note: eventNote, advanceNotice: selectedAdvanceNotice, tag: selectedTag)
            
            // Remove existing notification with old UUID
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid])
        } else {
            // Create new event
            isSuccess = DatabaseManager.shared.addEvent(uuid: uuid, eventName: eventName, eventDate: eventDateString, isPinned: isPinned, note: eventNote, advanceNotice: selectedAdvanceNotice, tag: selectedTag)
        }
        
        if isSuccess {
            // Schedule or re-schedule the notification
            let newEvent = CountdownEvent(uuid: uuid, eventDate: eventDateString, eventName: eventName, daysLeftOrPassed: calculateDaysLeftOrPassed(for: eventDateString), isPinned: isPinned, note: eventNote, advanceNotice: selectedAdvanceNotice, tag: selectedTag)
            
            if selectedAdvanceNotice >= 0 {
                viewModel.scheduleEventNotification(for: newEvent)
            }
            
            viewModel.fetchEvents()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Title", text: $eventName)
                        .font(.system(size: 15))
                        .listRowBackground(Color.dynamicSection)
                    
                    HStack {
                        Text("Date")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.dynamicText)
                        
                        Spacer()
                        
                        if !showDatePicker {
                            Text(internalDateFormatter.string(from: eventDate))
                                .font(.system(size: 15))
                        }
                    }
                    .listRowBackground(Color.dynamicSection)
                    .onTapGesture {
                        showDatePicker.toggle()
                    }
                    
                    if showDatePicker {
                        DatePicker("", selection: $eventDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                    }
                }
                
                Section (footer: Text("Event notification at 9:00 local time.").font(.system(size: 10))) {
                    Toggle("Pin Event", isOn: $isPinned)
                        .font(.system(size: 15))
                        .listRowBackground(Color.dynamicSection)
                    
                    Picker("Notification", selection: $selectedAdvanceNotice) {
                        Text("No Reminder").tag(-1)
                        Text("On the Day").tag(0)
                        Text("1 day").tag(1)
                        Text("2 days").tag(2)
                        Text("1 week").tag(7)
                        Text("10 days").tag(10)
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 15))
                    .listRowBackground(Color.dynamicSection)
                }
                
                Section {
                    TextEditor(text: $eventNote)
                        .font(.system(size: 15))
                        .listRowBackground(Color.dynamicSection)
                        .frame(height: 200)
                }
                
                Section {
                    Picker("Tag", selection: $selectedTag) {
                        Text(String(localized: "")).tag(String(localized: ""))
                        Text(String(localized: "Anniversary")).tag(String(localized: "Anniversary"))
                        Text(String(localized: "Holiday")).tag(String(localized: "Holiday"))
                        Text(String(localized: "Life")).tag(String(localized: "Life"))
                        Text(String(localized: "Work")).tag(String(localized: "Work"))
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 15))
                    .listRowBackground(Color.dynamicSection)
                }
            }
            .gesture(DragGesture().onChanged {_ in
                UIApplication.shared.endEditing()
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { self.presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        // Share button, automatically generates a snapshot of the event and saves to photo album
                        Button(action: {
                            showShareView = true
                        }) {
                            Image(systemName: "square.and.arrow.up.on.square")
                                .resizable()
                                .frame(width: 18, height: 25)
                        }
                        Button("Save") { saveAction() }
                    }
                    .popoverTip(savePicture, arrowEdge: .top)
                }
            }
            .onAppear {
                if let event = event {
                    self.eventName = event.eventName
                    self.eventDate = internalDateFormatter.date(from: event.eventDate) ?? Date()
                    self.isPinned = event.isPinned
                    self.eventNote = event.note
                    self.selectedAdvanceNotice = event.advanceNotice
                    self.selectedTag = event.tag
                    
                    // Fetch the tag from the database
                    if let storedTag = DatabaseManager.shared.getTag(uuid: event.uuid) {
                        self.selectedTag = storedTag
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.dynamicBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showShareView) {
            ShareView(eventName: self.eventName,
                      eventDate: internalDateFormatter.string(from: self.eventDate),
                      daysLeftOrPassed: String(calculateDaysLeftOrPassed(for: internalDateFormatter.string(from: self.eventDate))))
        }
    }
}

class SharedSettings: ObservableObject {
    @Published var isReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.setValue(isReminderEnabled, forKey: "isReminderEnabled")
        }
    }
    
    init() {
        self.isReminderEnabled = UserDefaults.standard.bool(forKey: "isReminderEnabled")
    }
}
