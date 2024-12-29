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
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        // Current and Longest Mood Streak
                        let streaks = calculateStreaks(from: journalEntries)
                        Label("\(streaks.current) days", systemImage: "bolt.fill")
                            .font(.title)
                        Text("Longest Streak: \(streaks.longest) days")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    let moodScore = journalEntries.count
                    Text("Mood Score: \(moodScore)")
                        .font(.title)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                Text("Mood Ring")
                    .font(.title)
                    .padding()
                
                if let chartData = prepareChartData(from: journalEntries) {
                    Chart {
                        ForEach(chartData, id: \.key) { mood in
                            SectorMark(
                                angle: .value("Count", mood.value),
                                innerRadius: .ratio(0.5),
                                outerRadius: .ratio(1.0)
                            )
                            .foregroundStyle(by: .value("Mood", mood.key))
                            .annotation(position: .overlay, alignment: .center) {
                                Text(mood.key)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding()
                } else {
                    Text("No mood data available.")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("moodswings")
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



func calculateStreaks(from entries: [JournalEntries]) -> (current: Int, longest: Int) {
        guard !entries.isEmpty else { return (0, 0) }
        
        let calendar = Calendar.current
        
        // Extract dates and sort them in descending order
        let dates = entries.compactMap { $0.dateOfEntry }.sorted(by: >)
        
        var currentStreak = 1 // At least one day
        var longestStreak = 1
        var streakCounter = 1
        
        for i in 1..<dates.count {
            let previousDate = dates[i - 1]
            let currentDate = dates[i]
            
            // Check if the current date is exactly one day before the previous date
            if let difference = calendar.dateComponents([.day], from: currentDate, to: previousDate).day, difference == 1 {
                streakCounter += 1 // Continue the streak
                currentStreak = streakCounter
            } else {
                // Streak breaks, check if it's the longest
                longestStreak = max(longestStreak, streakCounter)
                streakCounter = 1 // Reset the streak counter
            }
        }
        
        // Final check for the longest streak
        longestStreak = max(longestStreak, streakCounter)
        
        return (currentStreak, longestStreak)
    }


#Preview {
    MoodSwings()
}
