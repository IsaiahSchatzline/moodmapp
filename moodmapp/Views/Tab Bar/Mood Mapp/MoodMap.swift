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
    @State private var mapScope = Namespace().wrappedValue // Fixed map scope initialization
    var journalEntry: JournalEntries?

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position, selection: $selectedMoodID, scope: mapScope) {
                    ForEach(journalEntries, id: \.id) { entry in
                        Group {
                            if let moodPin = entry.moodPinLocation {
                                Marker(coordinate: moodPin) {
                                    Label {
                                        Text(entry.moodTitle)
                                    } icon: {
                                        Text(Emoji(rawValue: entry.emoji)?.rawValue ?? Emoji.content.rawValue)
                                    }
                                }
                                .tint(Color(red: 0.569, green: 0.788, blue: 0.969))
                            } else {
                                Marker(entry.moodTitle, coordinate: entry.moodPinLocation ?? CLLocationCoordinate2D())
                            }
                        }.tag(entry)
                    }
                }
                .mapStyle(mapStyleConfig.mapStyle)
                .mapControls {
                    MapScaleView()
                }
                .sheet(item: $selectedMoodID) { selectedMoodID in
                    if let selectedEntry = journalEntries.first(where: { $0.id == selectedMoodID }) {
                        ViewEntry(entry: selectedEntry, hideMapButton: true)
                            .presentationDetents([.height(450)])
                    }
                }
                .onAppear {
                    fetchEntries()
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
        let journalEntries = try? modelContext.fetch(FetchDescriptor<JournalEntries>())
        for entry in journalEntries ?? [] {
            if let moodPin = entry.moodPinLocation {
                print("Pin location: \(moodPin.latitude), \(moodPin.longitude)")
            }
        }
    }

    private func selectPinAndCenterMap(moodPin: CLLocationCoordinate2D, entry: JournalEntries) {
        // Set the camera with pitch, distance, and heading
        let camera = MapCamera(
            centerCoordinate: moodPin,
            distance: 980, // Adjust the distance for the desired zoom level
            heading: 242,  // Adjust the heading if needed
            pitch: 60      // Set the desired pitch angle
        )
        
        // Set the position to the camera view
        position = .camera(camera)
        
        // Update the selectedMoodID to show the corresponding entry
        selectedMoodID = entry.id
    }
}

#Preview {
    MoodMap()
}
