import FirebaseFirestore

class FirestoreManager {
  static let shared = FirestoreManager()
  private let db = Firestore.firestore()
  
  func saveEntry(_ entry: JournalEntries, for userID: String) async throws {
    let entryRef = db.collection("users")
      .document(userID)
      .collection("journalEntries")
      .document(entry.id ?? UUID().uuidString)
    
    try entryRef.setData(from: entry)
  }
  
  func fetchEntries(for userID: String, sortByDate: Bool = true, descending: Bool = true) async throws -> [JournalEntries] {
    let collectionRef = db.collection("users")
      .document(userID)
      .collection("journalEntries")
    
    // Use Query type, not CollectionReference
    let query: Query
    if sortByDate {
      query = collectionRef.order(by: "dateOfEntry", descending: descending)
    } else {
      query = collectionRef
    }
    
    let snapshot = try await query.getDocuments()
    return try snapshot.documents.compactMap { try $0.data(as: JournalEntries.self) }
  }
  
  func fetchEntry(entryID: String, for userID: String) async throws -> JournalEntries {
    let documentSnapshot = try await db.collection("users")
      .document(userID)
      .collection("journalEntries")
      .document(entryID)
      .getDocument()
    
    guard documentSnapshot.exists else {
      throw NSError(domain: "FirestoreError", code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Entry not found"])
    }
    
    return try documentSnapshot.data(as: JournalEntries.self)
  }
  
  func deleteEntry(entryID: String, for userID: String) async throws {
    try await db.collection("users")
      .document(userID)
      .collection("journalEntries")
      .document(entryID)
      .delete()
  }
}
