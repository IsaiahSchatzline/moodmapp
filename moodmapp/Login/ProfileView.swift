import SwiftUI

struct ProfileView: View {
  @EnvironmentObject var viewModel: AuthViewModel
  @State private var showDeleteAlert: Bool = false
  var body: some View {
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
            SettingsRowView(imageName: "gear",
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
            SettingsRowView(imageName: "arrow.left.circle.fill",
                            title: "Sign Out",
                            tintColor: .red)
          }
          
          Button {
            showDeleteAlert = true
          } label: {
            SettingsRowView(imageName: "xmark.circle.fill",
                            title: "Delete Account",
                            tintColor: .red)
          }
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
  }
}

#Preview {
  ProfileView()
}
