//
//  Location_Based_Mood_TrackerApp.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/20/24.
//

import SwiftUI
import SwiftData

@main
struct Location_Based_Mood_TrackerApp: App {
    
   // private let modelContainer = try! ModelContainer(for: JournalEntries.self)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [JournalEntries.self])
    }
}
