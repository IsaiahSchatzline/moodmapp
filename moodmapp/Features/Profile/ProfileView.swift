import SwiftUI

struct ProfileView: View {
  @EnvironmentObject var viewModel: AuthViewModel
  @State private var showDeleteSheet: Bool = false
  @State private var showSignOutAlert: Bool = false
  @State private var showReportIssueSheet: Bool = false
  @State private var deleteConfirmationText: String = ""
  
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
              showSignOutAlert = true
            } label: {
              ButtonRow(imageName: "arrow.left.circle.fill",
                              title: "Sign Out",
                              tintColor: .red)
            }
            .alert("Did you mean to sign out?", isPresented: $showSignOutAlert) {
              Button("Cancel", role: .cancel) { }
              Button("Yes, sign out", role: .destructive) { viewModel.signOut() }
            } message: {
              Text("Are you sure you want to sign out?")
            }
            
            Button {
              showDeleteSheet = true
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
          ReportIssueView(viewModel: viewModel)
        }
        .sheet(isPresented: $showDeleteSheet) {
          ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 20) {
              Image(systemName: "exclamationmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
              
              Text("Warning")
                .font(.title2)
                .fontWeight(.bold)
              
              Text("This action will permanently delete your account, including all user data and journal entries. To confirm, type \"DELETE\" below.")
                .multilineTextAlignment(.center)
              
              TextField("Type 'DELETE' to confirm", text: $deleteConfirmationText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .submitLabel(.done)
                .onSubmit {
                  // Don't do anything when enter is pressed
                }
              
              HStack(spacing: 20) {
                Button("Cancel") {
                  deleteConfirmationText = ""
                  showDeleteSheet = false
                }
                .buttonStyle(.bordered)
                
                Button("Delete Account") {
                  Task {
                    if deleteConfirmationText == "DELETE" {
                      try? await viewModel.deleteAccount()
                    }
                    deleteConfirmationText = ""
                  }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(deleteConfirmationText != "DELETE")
              }
              .padding(.top)
            }
            .padding()
            .frame(maxWidth: 350)
          }
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
}

#Preview {
  ProfileView()
}
