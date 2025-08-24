import Foundation
import MapKit
import FirebaseFirestore

struct JournalEntries: Identifiable, Codable, Hashable {
  var id: String?
  var userID: String
  var moodTitle: String
  var moodRating: Int
  var entryThoughts: String
  var emoji: String
  var dateOfEntry: Date
  var latitude: CLLocationDegrees?
  var longitude: CLLocationDegrees?
  
  var combinedEmojiDisplay: String {
    return emoji.isEmpty ? "😊" : emoji
  }
  
  var moodPinLocation: CLLocationCoordinate2D? {
    guard let lat = latitude, let lon = longitude else {
      return nil
    }
    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }
}
