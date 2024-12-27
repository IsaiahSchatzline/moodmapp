//
//  MoodMap.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/21/24.
//
import SwiftUI
import MapKit
import SwiftData

struct MoodMap: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var journalEntries: [JournalEntries]

    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        Map(position: $position) {
            ForEach(journalEntries, id: \.self) { entry in
                if let moodPin = entry.moodPinLocation {
                    Marker(entry.moodTitle, systemImage: "mappin.circle.fill", coordinate: moodPin)
                }
            }
        }
        .mapStyle(.hybrid(elevation: .realistic))
        .onAppear {
            fetchEntries() // Optional if you need to explicitly trigger fetching on appear
        }
    }

    private func fetchEntries() {
        // Fetch the JournalEntries from the persistent store
        let journalEntries = try? modelContext.fetch(FetchDescriptor<JournalEntries>())
        for entry in journalEntries ?? [] {
            if let moodPin = entry.moodPinLocation {
                print("Pin location: \(moodPin.latitude), \(moodPin.longitude)")
            }
        }
    }
}
#Preview {
    MoodMap()
}
