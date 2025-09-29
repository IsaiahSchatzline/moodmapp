import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreCombineSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var toastMessage: String?
    @Published var toastIsSuccess: Bool = false
    @Published var showToast: Bool = false
    static let shared = AuthViewModel()
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            showToastNotification(message: "Successfully signed in", isSuccess: true)
        } catch {
            let errorMessage = "Failed to sign in: \(error.localizedDescription)"
            showToastNotification(message: errorMessage, isSuccess: false)
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let userData: [String: Any] = [
                "userID": result.user.uid,
                "fullname": fullname,
                "email": email
            ]
            
            try await Firestore.firestore()
                .collection("users")
                .document(result.user.uid)
                .setData(userData, merge: true)
            
            await fetchUser()
            showToastNotification(message: "Welcome to MoodMapp!", isSuccess: true)
        } catch {
            print("DEBUG: Failed to create account with error \(error.localizedDescription)")
            showToastNotification(message: "Failed to create account. Try again.", isSuccess: false)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            showToastNotification(message: "Successfully signed out", isSuccess: true)
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
            showToastNotification(message: "Failed to sign out. Try again.", isSuccess: false)
        }
    }
    
    /// Permanently deletes the current user's data and authentication account.
    /// This requires recent authentication; if you see `ERROR_REQUIRES_RECENT_LOGIN`,
    /// reauthenticate the user before retrying.
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthViewModel", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        let uid = user.uid
        
        do {
            try await FirestoreManager.shared.deleteAllEntries(for: uid)
            try await FirestoreManager.shared.deleteUserDocument(userID: uid)
            try await user.delete()
            self.userSession = nil
            self.currentUser = nil
            showToastNotification(message: "Account successfully deleted", isSuccess: true)
        } catch {
            print("DEBUG: Failed to delete account: \(error.localizedDescription)")
            showToastNotification(message: "Failed to delete account: \(error.localizedDescription)", isSuccess: false)
            throw error
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No current user UID available")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            
            if let d = snapshot.data() {
                let user = User(
                    userID: uid,
                    fullname: d["fullname"] as? String ?? "",
                    email: d["email"] as? String ?? ""
                )
                self.currentUser = user
                print("DEBUG: Successfully fetched user: \(self.currentUser?.fullname ?? "unknown")")
            } else {
                print("DEBUG: User document does not exist for uid: \(uid)")
            }
        } catch {
            print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
        }
    }
}


extension AuthViewModel {
    /// Creates an issue document in Firestore for the current user.
    @MainActor
    func reportAnIssue(_ text: String) async -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        
        let uid = user.uid
        let db = Firestore.firestore()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let system = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let model = UIDevice.current.model
        
        let payload: [String: Any] = [
            "userID": uid,
            "email": currentUser?.email ?? user.email ?? "",
            "fullname": currentUser?.fullname ?? "",
            "issue": text,
            "createdAt": FieldValue.serverTimestamp(),
            "appVersion": appVersion,
            "build": build,
            "system": system,
            "device": model
        ]
        
        do {
            let ref = db.collection("issues").document()
            try await ref.setData(payload)
            print("DEBUG: Issue submitted as \(ref.documentID)")
            showToastNotification(message: "Issue reported successfully.\nThank you for your help!", isSuccess: true)
            return true
        } catch {
            print("DEBUG: Failed to report issue with error \(error.localizedDescription)")
            showToastNotification(message: "Failed to report issue. Try again.", isSuccess: false)
            return false
        }
    }
    
    func showToastNotification(message: String, isSuccess: Bool) {
        self.toastMessage = message
        self.toastIsSuccess = isSuccess
        self.showToast = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            self.showToast = false
        }
    }
}
