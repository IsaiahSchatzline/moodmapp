import SwiftUI
import CoreLocation

struct ContentCoordinator: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var journalViewModel: JournalEntriesViewModel
    
    init() {
        _journalViewModel = StateObject(wrappedValue: JournalEntriesViewModel(authViewModel: AuthViewModel.shared))
    }
    
    var body: some View {
        ZStack {
            mainContent
            toastOverlay
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - Content Views
    
    private var mainContent: some View {
        Group {
            if authViewModel.userSession != nil {
                tabView
            } else {
                LoginView()
            }
        }
    }
    
    private var tabView: some View {
        TabView {
            NewMood(viewModel: journalViewModel)
                .tabItem {
                    Label("New Mood", systemImage: "applepencil")
                }
            
            JournalPage(viewModel: journalViewModel)
                .tabItem {
                    Label("Mood Journal", systemImage: "book")
                }
            
            MoodMap(viewModel: journalViewModel)
                .tabItem {
                    Label("Mood Map", systemImage: "map")
                }
            
            MoodSwings(viewModel: journalViewModel)
                .tabItem {
                    Label("Mood Swings", systemImage: "chart.pie.fill")
                }
        }
    }
    
    // MARK: - Toast Overlay
    
    private var toastOverlay: some View {
        Group {
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
