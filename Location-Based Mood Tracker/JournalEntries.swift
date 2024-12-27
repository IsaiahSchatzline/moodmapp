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
