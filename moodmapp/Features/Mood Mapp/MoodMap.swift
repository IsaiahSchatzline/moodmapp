import SwiftUI
import MapKit

extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct MoodMap: View {
    @ObservedObject private var viewModel: JournalEntriesViewModel
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedMoodID: String?
    @State private var mapStyleConfig = MapStyleConfig()
    @State private var pickMapStyle = false
    @Namespace private var mapScope
    
    // Allow other screens to open the map focused on a specific entry/coordinate
    init(selectedMoodID: String? = nil, focusCoordinate: CLLocationCoordinate2D? = nil, viewModel: JournalEntriesViewModel) {
        self.viewModel = viewModel
        if let focusCoordinate {
            let cam = MapCamera(centerCoordinate: focusCoordinate, distance: 980, heading: 0, pitch: 45)
            _position = State(initialValue: .camera(cam))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                mapContent
            }
            .safeAreaInset(edge: .bottom) {
                mapStyling
            }
            .sheet(item: $selectedMoodID) { moodID in
                if let selectedEntry = viewModel.entries.first(where: { $0.id == moodID.id }) {
                    ViewEntry(entry: selectedEntry, hideMapButton: true, viewModel: viewModel)
                        .presentationDetents([.height(600)])
                }
            }
            .mapScope(mapScope)
        }
    }
    
    private var markersAndControls: some View {
        Map(position: $position, selection: $selectedMoodID, scope: mapScope) {
            ForEach(viewModel.entries, id: \.id) { entry in
                if let moodPin = entry.moodPinLocation, let id = entry.id {
                    Marker(coordinate: moodPin) {
                        Label {
                            Text(entry.moodTitle)
                        } icon: {
                            Text(Emoji(rawValue: entry.emoji)?.rawValue ?? Emoji.content.rawValue)
                        }
                    }
                    .tint(Color(red: 0.569, green: 0.788, blue: 0.969))
                    .tag(id)
                }
            }
        }
        .mapStyle(mapStyleConfig.mapStyle)
        .mapControls {
            MapScaleView()
        }
        .ignoresSafeArea()
    }
    
    private var mapContent: some View {
        ZStack {
            markersAndControls
        }
        .navigationTitle("moodmapp")
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            //      viewModel.authViewModelVM = authViewModel
            await viewModel.loadEntries(descending: false)
        }
    }
    
    private var mapStyling: some View {
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
    
    private func selectPinAndCenterMap(moodPin: CLLocationCoordinate2D, entry: JournalEntries) {
        let camera = MapCamera(
            centerCoordinate: moodPin,
            distance: 980,
            heading: 242,
            pitch: 60
        )
        position = .camera(camera)
        selectedMoodID = entry.id
    }
}
