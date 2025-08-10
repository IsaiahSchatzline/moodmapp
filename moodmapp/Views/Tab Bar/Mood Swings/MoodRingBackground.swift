import SwiftUI
import SwiftData
import Charts

struct MoodRingBackground: View {
    var selectedMood: String?
    var selectedMoodPercentage: Double?
    var journalEntries: [JournalEntries]
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            
            VStack {
                if let selectedMood = selectedMood, let moodPercentage = selectedMoodPercentage {
                    Text("Mood: \(selectedMood)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Percentage: \(String(format: "%.2f", moodPercentage))%")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                } else {
                    // Display most common mood when no selection
                    if let mostCommonMood = mostCommonMood(from: journalEntries) {
                        // Unpack the tuple to get mood and percentage
                        let combinedEmojiDisplay = mostCommonMood.mood
                        let percentage = mostCommonMood.percentage
                        
                        if let emoji = Emoji(rawValue: combinedEmojiDisplay) {
                            VStack {
                                
                                Text("Most Common Mood")
                                    .font(.callout)
                                    .bold()
                                    .foregroundStyle(.secondary)
                                
                                // Show the combinedEmojiDisplay (emoji.rawValue and emoji.moodWord) in the original Text view
                                Text("\(emoji.rawValue)")
                                    .font(.system(size: 40).bold())
                                    .foregroundStyle(.primary)
                                HStack {
                                    Text("\(String(format: "%.0f", percentage))%")
                                        .font(.title3.bold())
                                        .foregroundStyle(.primary)
                                    Text("\(emoji.moodWord)")
                                        .font(.title3.bold())
                                        .foregroundStyle(.primary)
                                }
                            }
                        } else {
                            Text("Most Common Mood")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text("No mood entries yet")
                                .font(.title2.bold())
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .position(x: frame.midX, y: frame.midY)
        }
    }
}

func mostCommonMood(from journalEntries: [JournalEntries]) -> (mood: String, percentage: Double)? {
    // Ensure the journalEntries array is not empty
    guard !journalEntries.isEmpty else { return nil }
    
    // Count the occurrences of each mood
    let moodCounts = journalEntries.reduce(into: [String: Int]()) { counts, entry in
        counts[entry.emoji, default: 0] += 1
    }
    
    // Find the highest count value
    let maxCount = moodCounts.values.max() ?? 0
    
    // Filter all moods that have the maximum count
    let mostCommonMoods = moodCounts.filter { $0.value == maxCount }
    
    // Get the most recent mood from the most common moods
    if let recentMood = journalEntries.last(where: { mostCommonMoods.keys.contains($0.emoji) }) {
        let percentage = (Double(maxCount) / Double(journalEntries.count)) * 100
        return (recentMood.emoji, percentage)
    }
    
    return nil
}
