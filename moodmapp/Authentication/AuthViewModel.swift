import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreCombineSwift
import FirebaseAuthCombineSwift
import FirebaseCore
import FirebaseCoreInternal

protocol AuthenticationFormProtocol {
  var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
  @Published var userSession: FirebaseAuth.User?
  @Published var currentUser: User?
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
    } catch {
      print("DEBUG: Failed to log in with error \(error.localizedDescription)")
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
    } catch {
      print("DEBUG: Faield to create user with error \(error.localizedDescription)")
      throw error
    }
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
      self.userSession = nil
      self.currentUser = nil
    } catch {
      print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
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
      // 1) Delete Firestore data (subcollection first, then user doc)
      try await FirestoreManager.shared.deleteAllEntries(for: uid)
      try await FirestoreManager.shared.deleteUserDocument(uid: uid)
      
      // 2) Delete the Firebase Auth user (may throw requires-recent-login)
      try await user.delete()
      
      // 3) Clear local session state
      self.userSession = nil
      self.currentUser = nil
    } catch {
      print("DEBUG: Failed to delete account: \(error.localizedDescription)")
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
      return true
    } catch {
      print("DEBUG: Failed to submit issue: \(error.localizedDescription)")
      return false
    }
  }
}
