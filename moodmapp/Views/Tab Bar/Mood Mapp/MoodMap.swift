import SwiftUI
import MapKit
//import SwiftData

extension String: @retroactive Identifiable {
  public var id: String { self }
}

struct MoodMap: View {
  //  @Environment(\.modelContext) private var modelContext
  @StateObject private var viewModel = JournalEntriesViewModel()
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
  @State private var selectedMoodID: String?
  @State private var mapStyleConfig = MapStyleConfig()
  @State private var pickMapStyle = false
  @State private var mapScope = Namespace().wrappedValue
  
  var body: some View {
    NavigationStack {
      ZStack {
        mapContent
      }
      .safeAreaInset(edge: .bottom) {
        mapStyling
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
  }
  
  // 4. Create a separate sheet view
  private var entrySheet: some View {
    EmptyView()
      .sheet(item: $selectedMoodID) { moodID in
        if let selectedEntry = viewModel.entries.first(where: { $0.id == moodID.id }) {
          ViewEntry(entry: selectedEntry, hideMapButton: true)
            .presentationDetents([.height(450)])
        }
      }
  }
  
  // 5. Simplified moodPins view
  private var mapContent: some View {
    ZStack {
      markersAndControls
      entrySheet
    }
    .navigationTitle("moodmapp")
    .toolbarBackground(.hidden, for: .navigationBar)
    .task {
      viewModel.authVM = authViewModel
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

#Preview {
  MoodMap()
}
