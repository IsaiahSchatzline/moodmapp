import SwiftUI

struct ProfileView: View {
  @EnvironmentObject var viewModel: AuthViewModel
  @State private var showDeleteAlert: Bool = false
  @State private var showReportIssueSheet: Bool = false
  @State private var isIssueReported = false
  @State private var toastMessage: String = ""
  var body: some View {
    ZStack {
      if let user = viewModel.currentUser {
        List {
          Section {
            HStack {
              Text(user.initials)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Color(.systemGray3))
                .clipShape(Circle())
              
              VStack(alignment: .leading, spacing: 4) {
                Text(user.fullname)
                  .font(.subheadline)
                  .fontWeight(.semibold)
                  .padding(.top, 4)
                
                Text(user.email)
                  .font(.footnote)
                  .foregroundStyle(.gray)
              }
            }
          }
          Section("General") {
            HStack {
              ButtonRow(imageName: "gear",
                              title: "Version",
                              tintColor: Color.gray)
              
              Spacer()
              
              Text("1.0.0")
                .font(.subheadline)
                .foregroundStyle(.gray)
            }
          }
          Section("Account") {
            Button {
              viewModel.signOut()
            } label: {
              ButtonRow(imageName: "arrow.left.circle.fill",
                              title: "Sign Out",
                              tintColor: .red)
            }
            
            Button {
              showDeleteAlert = true
            } label: {
              ButtonRow(imageName: "xmark.circle.fill",
                              title: "Delete Account",
                              tintColor: .red)
            }
          }
          
          Section("Contact Us") {
            Button {
              showReportIssueSheet = true
            } label: {
              ButtonRow(imageName: "exclamationmark.circle.fill",
                              title: "Report An Issue",
                              tintColor: .red)
            }
          }
        }
        .sheet(isPresented: $showReportIssueSheet) {
          ReportIssueView(viewModel: viewModel) { success in
            toastMessage = success ? "Success! Issue reported." : "Failed to report issue."
            isIssueReported = true
          }
        }
        .alert("Warning",
               isPresented: $showDeleteAlert) {
          Button("Cancel", role: .cancel) { }
          Button("Yes, delete my account", role: .destructive) {
            Task {
              try? await viewModel.deleteAccount()
            }
          }
        } message: {
          Text("This action will permanently delete your account, including all user data and journal entries. Are you sure you want to do this?")
        }
      } else {
        VStack(spacing: 12) {
          ProgressView()
          Text("Loading profile…").font(.footnote).foregroundStyle(.secondary)
        }
        .task {
          await viewModel.fetchUser()
        }
      }
      if isIssueReported {
        ToastBanner(message: toastMessage,
                    isSuccess: toastMessage.contains("Success"),
                    duration: 5) {
          withAnimation {
            isIssueReported = false
          }
        }
                    .zIndex(1)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .animation(.spring(), value: isIssueReported)
  }
}

#Preview {
  ProfileView()
}
