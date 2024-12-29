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
    @State private var mapStyleConfig = MapStyleConfig()
    @State private var pickMapStyle = false
    @Namespace private var mapScope

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position, selection: $selectedMoodID, scope: mapScope) {
                    ForEach(journalEntries, id: \.id) { entry in
                        Group {
                            if let moodPin = entry.moodPinLocation {
                                if entry.moodPinLocation != nil {
                                    Marker(coordinate: moodPin) {
                                        Label {
                                            Text(entry.moodTitle)
                                        } icon: {
                                            Text(Emoji(rawValue: entry.emoji)?.rawValue ?? Emoji.content.rawValue) // Display the emoji
                                        }
                                    }
                                    .tint(Color(red: 0.58, green: 0.86, blue: 0.97))
                                } else {
                                    Marker(entry.moodTitle, coordinate: moodPin)
                                }
                            }
                        }.tag(entry)
                    }
                }
                
                .mapStyle(mapStyleConfig.mapStyle)
                .mapControls {
                    MapScaleView()
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
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack {
                    MapCompass(scope: mapScope)
                    Button {
                        pickMapStyle.toggle()
                    } label: {
                        Image(systemName: "globe.americas.fill")
                            .imageScale(.large)
                    }
                    .padding(8)
                    .background(.thickMaterial)
                    .clipShape(.circle)
                    .sheet(isPresented: $pickMapStyle) {
                        MapStyleView(mapStyleConfig: $mapStyleConfig)
                            .presentationDetents([.height(275)])
                    }
                    MapUserLocationButton(scope: mapScope)
                    MapPitchToggle(scope: mapScope)
                        .mapControlVisibility(.visible)
                }
                .padding()
                .buttonBorderShape(.circle)
            }
        }
        .mapScope(mapScope)
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
