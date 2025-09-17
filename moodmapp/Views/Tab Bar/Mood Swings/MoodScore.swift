import SwiftUI
import Charts

struct MoodScore: View {
  var scoreWidth: CGFloat = 150 // Fixed score width
  var scoreHeight: CGFloat = 75
  var journalEntries: [JournalEntries]
  
  var body: some View {
    let moodScore = journalEntries.count
    
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.black, lineWidth: 2)
        .fill(Color.white)
        .frame(width: scoreWidth, height: scoreHeight)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 5)
      
      VStack {
        
        Label("\(moodScore)", systemImage: "applepencil")
          .foregroundStyle(.black)
          .font(.system(size: fontSize(for: moodScore))) // Adjust font size dynamically
          .padding(.leading, 5)
          .frame(width: scoreWidth, alignment: .center) // Keep the width fixed
        
        Text("Mood Score")
          .font(.subheadline)
          .foregroundColor(.gray)
        
      }        }
  }
  
  // Function to adjust font size based on the mood score length
  private func fontSize(for moodScore: Int) -> CGFloat {
    let scoreLength = "\(moodScore)".count
    // Set font size based on score length, shrinking if the number gets larger
    switch scoreLength {
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
}
