import SwiftUI

struct ContentCoordinator: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @StateObject private var journalViewModel = JournalEntriesViewModel()
  @State private var showProfile = false
  
  var body: some View {
    ZStack {
      Group {
        if authViewModel.userSession != nil {
          TabView {
            NewMood(viewModel: journalViewModel)
              .tabItem {
                Image(systemName: "applepencil")
                Text("New Mood")
              }
            
            JournalPage(viewModel: journalViewModel)
              .tabItem {
                Image(systemName: "book")
                Text("Mood Journal")
              }
            
            MoodMap(viewModel: journalViewModel)
              .tabItem {
                Image(systemName: "map")
                Text("Mood Map")
              }
            
            MoodSwings(viewModel: journalViewModel)
              .tabItem {
                Image(systemName: "chart.pie.fill")
                Text("Mood Swings")
              }
          }
        } else {
          LoginView()
        }
      }
      if authViewModel.showToast, let message = authViewModel.toastMessage {
        ToastBanner(
          message: message,
          isSuccess: authViewModel.toastIsSuccess,
          onDismiss: { authViewModel.showToast = false }
        )
        .transition(.move(edge: .bottom))
        .padding(.bottom, 20)
      }
    }
  }
}

#Preview {
  ContentCoordinator()
}
