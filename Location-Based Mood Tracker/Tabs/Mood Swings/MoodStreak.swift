//
//  MoodStreak.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/31/24.
//

import SwiftUI
import SwiftData
import Charts

struct MoodStreak: View {
    
    var streakWidth: CGFloat = 150
    var streakHeight: CGFloat = 75
    
    var journalEntries: [JournalEntries]
    
    var body: some View {
        // Calculate streaks beforehand
        let moodStreak = calculateStreaks(from: journalEntries)
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
                .fill(Color.white)
                .frame(width: streakWidth, height: streakHeight)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 5)
            
            VStack {
                
                // Current and Longest Mood Streak
                Label("\(moodStreak.current)", systemImage: "bolt.fill")
                    .foregroundStyle(.black)
                    .font(.system(size: fontSize(for: moodStreak.current))) // Adjust font size dynamically
                    .padding(.leading, 5)
                    .frame(width: streakWidth, alignment: .center) // Keep the width fixed
                Text("Daily Streak")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
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

private func fontSize(for moodStreak: Int) -> CGFloat {
    let streakLength = "\(moodStreak)".count
    // Set font size based on streak length, shrinking if the number gets larger
    switch streakLength {
    case 1:
        return 35 // Large font size for 1-digit numbers
    case 2:
        return 35 // Slightly smaller font for 2-digit numbers
    case 3:
        return 30 // Smaller font for 3-digit numbers
    default:
        return 25 // Smallest font for larger numbers
    }
}

