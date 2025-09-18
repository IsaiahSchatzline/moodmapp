import SwiftUI
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
  let today = calendar.startOfDay(for: Date())
  let dates = entries
    .map { calendar.startOfDay(for: $0.dateOfEntry) }
    .sorted(by: >)
    .reduce(into: [Date]()) { acc, d in if acc.last != d { acc.append(d) } }

  guard let mostRecent = dates.first else { return (0, 0) }
  var longestStreak = 1
  var run = 1
  if dates.count > 1 {
    for i in 1..<dates.count {
      let prev = dates[i - 1]
      let curr = dates[i]
      let diff = calendar.dateComponents([.day], from: curr, to: prev).day ?? 0
      if diff == 1 {
        run += 1
      } else if diff > 1 {
        run = 1
      }
      if run > longestStreak { longestStreak = run }
    }
  }

  var currentStreak = 0
  let startDiff = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? Int.max
  if startDiff <= 1 {
    currentStreak = 1
    if dates.count > 1 {
      for i in 1..<dates.count {
        let prev = dates[i - 1]
        let curr = dates[i]
        let diff = calendar.dateComponents([.day], from: curr, to: prev).day ?? 0
        if diff == 1 {
          currentStreak += 1
        } else {
          break
        }
      }
    }
  }

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

