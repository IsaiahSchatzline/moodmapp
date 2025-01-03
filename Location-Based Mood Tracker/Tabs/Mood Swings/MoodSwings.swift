//
//  Settings.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/21/24.
//
import SwiftUI
import SwiftData
import Charts

struct MoodSwings: View {
    
    
    
    
    @Query(sort: \JournalEntries.dateOfEntry, order: .reverse)
    var journalEntries: [JournalEntries]
    @State private var filteredEntries: [JournalEntries] = []
    @State private var averageMoodRating: Double = 0.0
    @State private var selectedMood: String?
    @State private var selectedMoodPercentage: Double?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.133, green: 0.545, blue: 0.133),   // Moderate Green (Comfortable)
                    Color(red: 1.0, green: 0.843, blue: 0.0),       // Warm Yellow (Neutral)
                    Color(red: 1.0, green: 0.549, blue: 0.0),       // Medium Orange (Energetic)
                    Color(red: 1.0, green: 0.271, blue: 0.0),       // Moderate Red (Romantic)
                    Color(red: 0.58, green: 0.0, blue: 0.827),       // Dark Violet (Angry)
                    Color(red: 0.274, green: 0.51, blue: 0.706)    // Moderate Blue (Calm)
                ]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.container, edges: [.top, .leading, .trailing])

                ScrollView {
                    VStack {
                        HStack {
                            Spacer()
                            MoodStreak(journalEntries: journalEntries)
                            Spacer()
                            MoodScore(journalEntries: journalEntries)
                            Spacer()
                        }
                        .padding(.top, 25)
                        let moodStreak = calculateStreaks(from: journalEntries)
                        Label("Longest Streak: \(moodStreak.longest)", systemImage: "bolt.shield.fill")
                            .bold()
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .padding(.bottom, 25)

                        VStack {
                            MoodRing(journalEntries: journalEntries)
                                .padding(.bottom, 50)

                            ThirtyDayRating(journalEntries: journalEntries)
                        }
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                        .padding(.bottom, 100)
                        .padding(.top, 25)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)  // Rounded corners
                            .fill(Color.white)  // Background color
                    )
                    .padding(15)
                    .navigationTitle("moodswings")
                    .navigationBarTitleDisplayMode(.large) // Ensures large title even when scrolling
                    /*.onAppear {
                        // Customize the navigation bar appearance for this screen
                        let appearance = UINavigationBarAppearance()
                        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                        UINavigationBar.appearance().standardAppearance = appearance
                    }
                    .onDisappear {
                        // Reset the navigation bar appearance to default when leaving the screen
                        let appearance = UINavigationBarAppearance()
                        appearance.configureWithDefaultBackground()
                        UINavigationBar.appearance().standardAppearance = appearance
                    }*/
                }
            }
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
        let filteredEntries = JournalEntries.filterEntriesWithin30Days(entries: entries)
        
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
    
    
    #Preview {
        MoodSwings()
    }

