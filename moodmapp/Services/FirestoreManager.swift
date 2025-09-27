import FirebaseFirestore
import CoreLocation

class FirestoreManager {
  static let shared = FirestoreManager()
  private let db = Firestore.firestore()
  
  func saveEntry(_ entry: JournalEntries, for userID: String) async throws {
    let entryId = entry.id ?? UUID().uuidString
    let entryRef = db.collection("users")
      .document(userID)
      .collection("journalEntries")
      .document(entryId)
    
    let data: [String: Any] = [
      "id": entryId,
      "userID": entry.userID,
      "moodTitle": entry.moodTitle,
      "moodRating": entry.moodRating,
      "entryThoughts": entry.entryThoughts,
      "emoji": entry.emoji,
      "dateOfEntry": Timestamp(date: entry.dateOfEntry),
      "latitude": entry.latitude as Any,
      "longitude": entry.longitude as Any
    ]
    
    try await entryRef.setData(data, merge: true)
  }
  
  func fetchEntries(for userID: String, sortByDate: Bool = true, descending: Bool = true) async throws -> [JournalEntries] {
    let collectionRef = db.collection("users")
      .document(userID)
      .collection("journalEntries")
    
    let query: Query = sortByDate
    ? collectionRef.order(by: "dateOfEntry", descending: descending)
    : collectionRef
    
    let snapshot = try await query.getDocuments()
    
    return snapshot.documents.compactMap { doc in
      let d = doc.data()
      guard
        let userID = d["userID"] as? String,
        let moodTitle = d["moodTitle"] as? String,
        let moodRating = d["moodRating"] as? Int,
        let entryThoughts = d["entryThoughts"] as? String,
        let emoji = d["emoji"] as? String
      else { return nil }
      
      let date = (d["dateOfEntry"] as? Timestamp)?.dateValue() ?? Date()
      let lat = d["latitude"] as? CLLocationDegrees
      let lon = d["longitude"] as? CLLocationDegrees
      
      return JournalEntries(
        id: (d["id"] as? String) ?? doc.documentID,
        userID: userID,
        moodTitle: moodTitle,
        moodRating: moodRating,
        entryThoughts: entryThoughts,
        emoji: emoji,
        dateOfEntry: date,
        latitude: lat,
        longitude: lon
      )
    }
  }
  
  func fetchEntry(entryID: String, for userID: String) async throws -> JournalEntries {
    let snapshot = try await db.collection("users")
      .document(userID)
      .collection("journalEntries")
      .document(entryID)
      .getDocument()
    
    guard let d = snapshot.data() else {
      throw NSError(domain: "FirestoreError", code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Entry not found"])
    }
    
    guard
      let userID = d["userID"] as? String,
      let moodTitle = d["moodTitle"] as? String,
      let moodRating = d["moodRating"] as? Int,
      let entryThoughts = d["entryThoughts"] as? String,
      let emoji = d["emoji"] as? String
    else {
      throw NSError(domain: "FirestoreError", code: 422,
                    userInfo: [NSLocalizedDescriptionKey: "Malformed entry data"])
    }
    
    let date = (d["dateOfEntry"] as? Timestamp)?.dateValue() ?? Date()
    let lat = d["latitude"] as? CLLocationDegrees
    let lon = d["longitude"] as? CLLocationDegrees
    
    return JournalEntries(
      id: (d["id"] as? String) ?? snapshot.documentID,
      userID: userID,
      moodTitle: moodTitle,
      moodRating: moodRating,
      entryThoughts: entryThoughts,
      emoji: emoji,
      dateOfEntry: date,
      latitude: lat,
      longitude: lon
    )
  }
  
  func deleteEntry(entryID: String, for userID: String) async throws {
    try await db.collection("users")
      .document(userID)
      .collection("journalEntries")
      .document(entryID)
      .delete()
  }
  
  
  // Deletes all journal entries in the user's subcollection in a single or multiple batches.
  func deleteAllEntries(for userID: String) async throws {
    let collectionRef = db.collection("users").document(userID).collection("journalEntries")
    
    // Fetch all documents (for moderate datasets). For very large datasets, consider pagination.
    let snapshot = try await collectionRef.getDocuments()
    guard !snapshot.documents.isEmpty else { return }
    
    // Batch delete in chunks of 400 to stay comfortably under the 500 write limit.
    var batch = db.batch()
    var ops = 0
    
    for doc in snapshot.documents {
      batch.deleteDocument(doc.reference)
      ops += 1
      if ops == 400 {
        try await batch.commit()
        batch = db.batch()
        ops = 0
      }
    }
    if ops > 0 {
      try await batch.commit()
    }
  }
  
  // Deletes the top-level user document (does not delete authViewModel account).
  func deleteUserDocument(uid: String) async throws {
    try await db.collection("users").document(uid).delete()
  }
}
