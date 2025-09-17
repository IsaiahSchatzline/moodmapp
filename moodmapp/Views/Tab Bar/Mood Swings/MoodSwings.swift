import SwiftUI
import Charts

struct MoodSwings: View {
  @State private var filteredEntries: [JournalEntries] = []
  @State private var averageMoodRating: Double = 0.0
  @State private var selectedMood: String?
  @State private var selectedMoodPercentage: Double?
  @StateObject private var viewModel = JournalEntriesViewModel()
  @EnvironmentObject var authViewModel: AuthViewModel
  
  var body: some View {
    NavigationStack {
      ZStack {
        LinearGradient.rainbow
        .ignoresSafeArea()
        ScrollView {
          VStack {
            HStack {
              Spacer()
              MoodStreak(journalEntries: viewModel.entries)
              Spacer()
              MoodScore(journalEntries: viewModel.entries)
              Spacer()
            }
            .padding(.top, 25)
            
            let moodStreak = calculateStreaks(from: viewModel.entries)
            Label("Longest Streak: \(moodStreak.longest)", systemImage: "bolt.shield.fill")
              .bold()
              .foregroundColor(.black)
              .padding(.top, 20)
              .padding(.bottom, 25)
            
            VStack {
              MoodRing(journalEntries: viewModel.entries)
                .padding(.bottom, 50)
              
              ThirtyDayRating(journalEntries: viewModel.entries)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 25)
          }
          .background(
            ZStack {
              RoundedRectangle(cornerRadius: 10)  // Rounded corners
                .fill(Color.white)  // Background color
              RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
            }
          )
          .padding(15)
        }
      }
      .navigationTitle("moodswings")
      .navigationBarTitleDisplayMode(.large)
      .navigationBarItems(
        trailing: NavigationLink(destination: ProfileView()) {
          Image(systemName: "person.crop.circle")
            .font(.title)
            .foregroundColor(.black)
        }
      )
      .task {
        viewModel.authVM = authViewModel
        await viewModel.loadEntries(descending: true)
      }
    }
  }
  
  func prepareChartData(from entries: [JournalEntries]) -> [(key: String, value: Int)]? {
    guard !entries.isEmpty else { return nil }
    
    // Create a dictionary to count occurrences of each `emoji` (or combinedEmojiDisplay if used)
    let moodCounts = entries.reduce(into: [String: Int]()) { counts, entry in
      let mood = entry.emoji // Use `combinedEmojiDisplay` if implemented
      counts[mood, default: 0] += 1
    }
    
    // Convert dictionary to an array of tuples for `ForEach`
    return moodCounts.sorted { $0.key < $1.key }
  }
  
  
  func prepareBarChartData(from entries: [JournalEntries]) -> [(key: Int, value: Int)] {
    // Filter entries to only include the last 30 days
    let filteredEntries = viewModel.filterEntriesWithin30Days(entries: entries)
    
    // Create a dictionary to count occurrences of each mood rating
    let moodCounts = filteredEntries.reduce(into: [Int: Int]()) { counts, entry in
      let rating = entry.moodRating
      counts[rating, default: 0] += 1
    }
    
    // Convert dictionary to an array of tuples for `ForEach`
    return moodCounts.sorted { $0.key < $1.key }
  }
  
  func filterEntriesWithin30Days(entries: [JournalEntries]) -> [JournalEntries] {
    let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    return entries.filter { $0.dateOfEntry >= thirtyDaysAgo }
  }
}
#Preview {
  MoodSwings()
}

