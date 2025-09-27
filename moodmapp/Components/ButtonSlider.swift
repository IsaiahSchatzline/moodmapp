import SwiftUI

struct ButtonSlider: View {
  @ObservedObject var viewModel: JournalEntriesViewModel
  @ObservedObject var locationManager: LocationManager
  
  @Binding var moodTitle: String
  @Binding var selectedEmoji: Emoji
  @Binding var moodBar: Double
  @Binding var entry: String
  
  @State private var dragOffset: CGFloat = 0
  @State private var showBlueRing: Bool = false
  
  let buttonWidth: CGFloat = 325
  let buttonHeight: CGFloat = 60
  let circleDiameter: CGFloat = 60
  let threshold: CGFloat = 250
  
  init(viewModel: JournalEntriesViewModel, locationManager: LocationManager, moodTitle: Binding<String>, selectedEmoji: Binding<Emoji>, moodBar: Binding<Double>, entry: Binding<String>) {
    self.locationManager = locationManager
    self._moodTitle = moodTitle
    self._selectedEmoji = selectedEmoji
    self._moodBar = moodBar
    self._entry = entry
    self.viewModel = viewModel
  }
  
  var body: some View {
    ZStack {
      backgroundCapsule
      if showBlueRing {
        animatedRing
      }
      draggableCircle
        .offset(x: dragOffset - (buttonWidth / 2) + 30, y: 175)
        .gesture(dragGesture)
    }
  }
  
  // MARK: - UI Components
  
  private var backgroundCapsule: some View {
    Capsule()
      .stroke(Color.white, lineWidth: 7)
      .fill(LinearGradient.horizontalRainbow)
      .frame(width: buttonWidth, height: buttonHeight)
      .offset(y: 175)
      .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
      .overlay(
        Text("Slide to submit")
          .blendMode(.overlay)
          .bold()
          .foregroundStyle(.white)
          .opacity(0.5)
          .offset(x: 0, y: 175)
      )
  }
  
  private var animatedRing: some View {
    Circle()
      .stroke(Color.green, lineWidth: 7)
      .frame(width: circleDiameter, height: circleDiameter)
      .opacity(showBlueRing ? 1 : 0)
      .animation(.easeOut(duration: 2.0), value: showBlueRing)
      .offset(x: dragOffset - (buttonWidth / 2) + 30, y: 175)
  }
  
  private var draggableCircle: some View {
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
  }
  
  // MARK: - Gesture and Actions
  
  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        if value.translation.width > 0 {
          dragOffset = min(value.translation.width, buttonWidth - circleDiameter)
        } else {
          dragOffset = 0
        }
      }
      .onEnded { value in
        handleDragEnded(value)
      }
  }
  
  private func handleDragEnded(_ value: DragGesture.Value) {
    if dragOffset > threshold {
      handleSubmission()
    } else {
      resetSliderWithAnimation()
    }
  }
  
  private func handleSubmission() {
    guard let userID = viewModel.authVM.userSession?.uid, !userID.isEmpty else {
      print("No authenticated user; aborting submit.")
      return
    }
    
    let newEntry = JournalEntries(
      id: UUID().uuidString,
      userID: userID,
      moodTitle: moodTitle,
      moodRating: Int(moodBar),
      entryThoughts: entry,
      emoji: selectedEmoji.rawValue,
      dateOfEntry: Date(),
      latitude: locationManager.currentLocation?.coordinate.latitude,
      longitude: locationManager.currentLocation?.coordinate.longitude
    )
    
    // Start a Task for the async operation
    Task { @MainActor in
      await viewModel.addEntry(newEntry)
    }
    
    // Update UI immediately
    withAnimation {
      showBlueRing = true
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      resetForm()
      resetSlider()
    }
  }
  
  private func resetSliderWithAnimation() {
    withAnimation {
      dragOffset = 0
      showBlueRing = false
    }
  }
  
  private func resetForm() {
    moodTitle = ""
    entry = ""
    moodBar = 5.0
    selectedEmoji = .happy
  }
  
  private func resetSlider() {
    withAnimation {
      dragOffset = 0
      showBlueRing = false
    }
  }
}
