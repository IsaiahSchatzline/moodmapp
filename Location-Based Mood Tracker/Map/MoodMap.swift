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
    @State private var selectedMoodID: PersistentIdentifier?

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position, selection: $selectedMoodID) {
                    ForEach(journalEntries, id: \.id) { entry in
                        Group {
                            if let moodPin = entry.moodPinLocation {
                                if entry.moodPinLocation != nil {
                                    Marker(coordinate: moodPin) {
                                        Label(entry.moodTitle, systemImage: "book.circle.fill")
                                    }
                                    .tint(.yellow)
                                } else {
                                    Marker(entry.moodTitle, coordinate: moodPin)
                                }
                            }
                        }.tag(entry)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapPitchToggle()
                }
                .sheet(item: $selectedMoodID) { selectedMoodID in
                    // Find the selected journal entry by its ID
                    if let selectedEntry = journalEntries.first(where: { $0.id == selectedMoodID }) {
                        // Use the existing ViewEntry struct
                        ViewEntry(entry: selectedEntry)
                            .presentationDetents([.height(450)])
                    }
                }
                .onAppear {
                    fetchEntries() // Optional if you need to explicitly trigger fetching on appear
                }
            }
            .navigationTitle("moodmapp")
            .toolbarBackground(.hidden, for: .navigationBar)
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
/*struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var moodPinLocation: Destination?
    var selectedMoodID: PersistentIdentifier?
    
    @State private var moodTitle = ""
    @State private var address = ""
    var body: some View {
        
    }
}*/
#Preview {
    MoodMap()
}
