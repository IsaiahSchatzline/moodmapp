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
      let user = User(userID: result.user.uid, fullname: fullname, email: email)
      let encodedUser = try Firestore.Encoder().encode(user)
      try await Firestore.firestore().collection("users").document(user.userID).setData(encodedUser)
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
  
  func deleteAccount() {
    
  }
  
  func fetchUser() async {
    guard let uid = Auth.auth().currentUser?.uid else {
      print("DEBUG: No current user UID available")
      return
    }
    
    do {
      let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
      if snapshot.exists {
        self.currentUser = try snapshot.data(as: User.self)
        print("DEBUG: Successfully fetched user: \(self.currentUser?.fullname ?? "unknown")")
      } else {
        print("DEBUG: User document does not exist for uid: \(uid)")
      }
    } catch {
      print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
    }
  }
}
