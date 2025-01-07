//
//  SwipableButtonView.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 1/2/25.
//

import SwiftUI
import SwiftData
import MapKit

struct SwipableButtonView: View {
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \JournalEntries.dateOfEntry) var entries: [JournalEntries]
    @ObservedObject var locationManager = LocationManager()
    @State var animateGradient: Bool = false
    @Binding var moodTitle: String
    @Binding var selectedEmoji: Emoji
    @Binding var moodBar: Double
    @Binding var entry: String
    @State private var isShowing = false
    @State private var dragOffset: CGFloat = 0
    @State private var isSubmitted: Bool = false
    @State private var showBlueRing: Bool = false
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var latitude: CLLocationDegrees? = 0.0
    @State var longitude: CLLocationDegrees? = 0.0
        let buttonWidth: CGFloat = 325
        let buttonHeight: CGFloat = 60
        let circleDiameter: CGFloat = 60
        let threshold: CGFloat = 250 // Threshold for submission

        var body: some View {
            ZStack {
                // Background Capsule
                Capsule()
                    .stroke(Color.white, lineWidth: 7)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [
                            Color(hex: "#5ECC5E"),   // Moderate Green (Comfortable)
                            Color(hex: "#D8C91A"),   // Warm Yellow (Neutral)
                            Color(hex: "#D88E73"),   // Medium Orange (Energetic)
                            Color(hex: "#D86C73"),   // Moderate Red (Romantic)
                            Color(hex: "#7A5FBA"),   // Dark Violet (Angry)
                            Color(hex: "#7AD4D1")    // Moderate Blue (Calm)
                        ]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: buttonWidth, height: buttonHeight)
                    .offset(y: 175)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .overlay(
                        Text("Slide to submit")
                            .blendMode(.overlay)
                            .bold()
                            .foregroundStyle(.white)
                            .opacity(0.5)
                            .offset(x:0, y: 175)
                        )
                        

                // Animated Blue Ring
                if showBlueRing {
                    Circle()
                        .stroke(Color.green, lineWidth: 7) // Thinner blue ring
                        .frame(width: circleDiameter, height: circleDiameter) // Adjusted size to be closely connected to the circle
                        .opacity(showBlueRing ? 1 : 0)
                        .animation(.easeOut(duration: 2.0), value: showBlueRing)
                        .offset(x: dragOffset - (buttonWidth / 2) + 30, y: 175)
                }

                // Sliding White Circle with Text
                ZStack {
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                        .fill(Color.white)
                        .frame(width: circleDiameter, height: circleDiameter)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)

                    Image(systemName: showBlueRing ? "checkmark" : "arrow.right")
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.easeOut(duration: 1.0), value: showBlueRing)
                }
                .offset(x: dragOffset - (buttonWidth / 2) + 30, y: 175)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width > 0 {
                                dragOffset = min(value.translation.width, buttonWidth - circleDiameter)
                            } else {
                                dragOffset = 0 // To handle cases where dragging left might happen
                            }
                        }
                        .onEnded { value in
                            if dragOffset > threshold {
                                print("Threshold reached: \(dragOffset)")
                                
                                // Capture current state
                                let capturedMoodTitle = moodTitle
                                let capturedEntry = entry
                                let capturedMoodBar = moodBar
                                let capturedEmoji = selectedEmoji
                                let capturedLocation = locationManager.currentLocation?.coordinate
                                
                                // Submit the entry using captured values
                                submitEntry(
                                    moodTitle: capturedMoodTitle,
                                    entry: capturedEntry,
                                    moodBar: capturedMoodBar,
                                    emoji: capturedEmoji,
                                    location: capturedLocation
                                )
                                
                                withAnimation {
                                    showBlueRing = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    resetSlider()
                                }
                            } else {
                                withAnimation {
                                    dragOffset = 0
                                    showBlueRing = false
                                }
                            }
                        }
                )
            }
        }

    func submitEntry(
        moodTitle: String,
        entry: String,
        moodBar: Double,
        emoji: Emoji,
        location: CLLocationCoordinate2D?
    ) {
        let newEntry = JournalEntries(
            moodTitle: moodTitle,
            entryThoughts: entry,
            emoji: emoji.rawValue,
            dateOfEntry: Date(),
            moodRating: Int(moodBar),
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        
        JournalEntries.updateMoodRatingCount(entry: newEntry)
        
        do {
            context.insert(newEntry)
            try context.save()
            print("Entry successfully saved.")
        } catch {
            print("Failed to save entry: \(error.localizedDescription)")
        }
        
        // Reset inputs
        self.moodTitle = ""
        self.entry = ""
        self.moodBar = 5.0
        self.selectedEmoji = .happy
    }
    func resetSlider() {
        withAnimation {
            dragOffset = 0
            showBlueRing = false
        }
    }
}
