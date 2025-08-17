import Foundation
import SwiftUI

class User: ObservableObject, Identifiable, Codable {
  @Published var userID: String  // Unique identifier for the user
  @Published var fullname: String
  @Published var email: String
  
  // Computed property to generate initials from the user's full name
  var initials: String {
    let formatter = PersonNameComponentsFormatter()
    if let components = formatter.personNameComponents(from: fullname) {
      formatter.style = .abbreviated
      return formatter.string(from: components)
    }
    return ""
  }
  
  init(userID: String = "", fullname: String = "", email: String = "") {
    self.userID = userID
    self.fullname = fullname
    self.email = email
  }
  
  // CodingKeys to map properties for Codable
  enum CodingKeys: String, CodingKey {
    case userID, fullname, email
  }
  
  // Decodable conformance
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.userID = try container.decode(String.self, forKey: .userID)
    self.fullname = try container.decode(String.self, forKey: .fullname)
    self.email = try container.decode(String.self, forKey: .email)
  }
  
  // Encodable conformance
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userID, forKey: .userID)
    try container.encode(fullname, forKey: .fullname)
    try container.encode(email, forKey: .email)
  }
}

extension User {
  static var MOCK_USER = User(userID: NSUUID().uuidString, fullname: "Kobe Bryant", email: "test@gmail.com")
}
