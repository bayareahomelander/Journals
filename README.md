# Journals

## Overview ##
Journals is an iOS application designed to provide a personal journaling experience, enhanced with mood tracking, event countdowns, and weather updates. It offers a secure and private platform for users to record their thoughts, feelings, and daily events.

## Features ##
### Diary Management ###
- **Journal Entries**: Users can create and manage their diary entries, each with a date, text, and mood indicator.
- **Mood Analysis**: The app includes a mood analysis feature, which likely provides insights based on the mood indicators from the diary entries.
- **Event Countdown**: Users can add events with countdown functionality to keep track of important dates.

### Calendar and Weather Integration ###
- **Calendar View**: The app integrates a calendar view using FSCalendar, allowing users to visualize and select dates with journal entries.
- **Weather Updates**: The app provides real time weather updates based on user's location using OpenWeatherMaps API.

### Privacy and Security ###
- **Biometric Authentication**: The app supports Face ID/Touch ID, allowing users to secure their journal entries with biometric authentication.
- **Local Data Storage**: By utilizing SQLite3 for data persistence, the app ensures all data is stored locally, enhancing control over privacy.

### Customization ##
- **Reminders**: Users can enable daily reminders to write in their journal. In addition, users can choose to be notified of an event, either on the day, 1 day, 2 days or 10 days in prior.
- **Themes**: Users can personalize their app experience by choosing from a selection of themes.
- **Language Selection**: Powered by Google Translation API, the app offers language options, including English, Simplified Chinese (简体中文), and Japanese (日本語).
- **Data Export**: Users have the option to export their journal entries. The export functionality includes a plain text format (PDF format soon), which compiles all entries into a single text file that can be shared or saved locally on device.

## Design and Technologies ##
### Swift and SwiftUI ###
- The application is built using Swift and SwiftUI, and follows the Model-View-ViewModel (MVVM) design pattern with the use of `@ObservedObject` and `@State` bindings.

### SQLite3 ###
- Data persistence is managed with SQLite3, allowing for efficient data storage and retrieval on the device. Introduction of SQLite3 also ensures privacy by performing data flow completely locally, without the need of a cloud server.

### Additional Technical Implementation ###
- **UserDefaults**: The app uses `UserDefaults` to store user preferences such as reminder settings, biometric authentication status, and selected language.
- **Notifications**: The app schedules local notifications using `UNUserNotificationCenter`.
- **Local Authentication**: The `LAContext` class is used to manage biometric authentication processes.
