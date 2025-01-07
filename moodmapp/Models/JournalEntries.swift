//
//  JournalEntries.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/21/24.
//

import Foundation
import SwiftData
import MapKit

@Model
class JournalEntries: Identifiable {
    
    
    var moodTitle: String
    var moodRating: Int
    var entryThoughts: String
    var emoji: String
    var dateOfEntry = Date()
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var combinedEmojiDisplay: String {
        // Return the saved emoji or a fallback value if empty
        return emoji.isEmpty ? "😊" : emoji
    }
    
    // Dictionary to hold mood rating counts
    static var moodRatingCount: [Int: Int] = [:] // Keeps track of counts for each mood rating (1-10)
    
    // Filter out entries older than 30 days
    static func filterEntriesWithin30Days(entries: [JournalEntries]) -> [JournalEntries] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        return entries.filter { $0.dateOfEntry >= thirtyDaysAgo }
    }

    // Update mood counts
    static func updateMoodRatingCount(entry: JournalEntries) {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        // Only update counts for entries within the last 30 days
        if entry.dateOfEntry >= thirtyDaysAgo {
            let rating = entry.moodRating
            // Increment the count for the selected mood rating
            moodRatingCount[rating, default: 0] += 1
        }
    }


    
    var moodPinLocation: CLLocationCoordinate2D? {
            guard let lat = latitude, let lon = longitude else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    
    // Designated Initializer
    init(moodTitle: String, entryThoughts: String, emoji: String, dateOfEntry: Date, moodRating: Int, latitude: CLLocationDegrees? = nil, longitude: CLLocationDegrees? = nil) {
        self.moodTitle  = moodTitle
        self.entryThoughts = entryThoughts
        self.emoji = emoji
        self.moodRating = moodRating
        self.dateOfEntry = Date() // Current timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}
