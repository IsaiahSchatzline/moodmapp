import SwiftUI
import Firebase

@main
struct Location_Based_Mood_TrackerApp: App {
  @StateObject var authViewModel = AuthViewModel()
  init() {
    FirebaseApp.configure()
  }
  var body: some Scene {
    WindowGroup {
      ContentCoordinator()
        .environmentObject(authViewModel)
    }
  }
}
