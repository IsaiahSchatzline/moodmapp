import SwiftUI
import FirebaseFirestore

@MainActor
class JournalEntriesViewModel: ObservableObject {
  @Published var entries: [JournalEntries] = []
  @Published var entry: JournalEntries!
  @Published var filteredEntries: [JournalEntries] = []
  @Published var isLoading = false
//  private let authVM = AuthViewModel()
  static var moodRatingCount: [Int: Int] = [:]
  internal var authVM: AuthViewModel
  
  // Initialize with the shared AuthViewModel
  init(authViewModel: AuthViewModel = AuthViewModel.shared) {
    self.authVM = authViewModel
  }
  
  func loadEntries(descending: Bool = true) async {
    guard let uid = authVM.userSession?.uid else { return }
    isLoading = true
    do {
      entries = try await FirestoreManager.shared.fetchEntries(for: uid, descending: descending)
      isLoading = false
    } catch {
      print("Failed to load entries:", error)
      isLoading = false
    }
  }
  
  func loadEntry(entryID: String) async {
    guard let uid = authVM.userSession?.uid else { return }
    isLoading = true
    do {
      entry = try await FirestoreManager.shared.fetchEntry(entryID: entryID, for: uid)
      isLoading = false
    } catch {
      print("Failed to load entry:", error)
      isLoading = false
    }
  }
  
  func addEntry(_ entry: JournalEntries) async {
    guard let uid = authVM.userSession?.uid else { return }
    isLoading = true
    do {
      try await FirestoreManager.shared.saveEntry(entry, for: uid)
      await loadEntries() // Reload entries after adding a new one
      isLoading = false
    } catch {
      print("Failed to add entry:", error)
      isLoading = false
    }
  }
  
  func deleteEntry(_ entry: JournalEntries) async {
    guard let uid = authVM.userSession?.uid, let entryID = entry.id else { return }
    isLoading = true
    do {
      try await FirestoreManager.shared.deleteEntry(entryID: entryID, for: uid)
      await loadEntries() // Reload entries after deletion
      isLoading = false
    } catch {
      print("Failed to delete entry:", error)
      isLoading = false
    }
  }
  
  func filterEntriesWithin30Days(entries: [JournalEntries]) -> [JournalEntries] {
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
}
