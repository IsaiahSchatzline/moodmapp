import SwiftUI

struct LoginView: View {
  @State private var email = ""
  @State private var password = ""
  @EnvironmentObject var authViewModel: AuthViewModel
  
  var body: some View {
    NavigationStack {
      ZStack {
        VStack {
          // image
          Image("BlackLaunchLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 250, height: 320)
            .padding(.vertical, 32)
          
          
          // form fields
          VStack(spacing: 24) {
            InputView(text: $email,
                      title: "Email Address",
                      placeholder: "name@example.com")
            .textInputAutocapitalization(.none)
            
            InputView(text: $password,
                      title: "Password",
                      placeholder: "Enter your password",
                      isSecureField: true)
          }
          .padding(.horizontal)
          .offset(x: 0, y: -100)
          
          
          // sign in button
          Button {
            Task {
              try await authViewModel.signIn(withEmail: email, password: password)
            }
          } label: {
            HStack {
              Text("Sign In")
                .fontWeight(.semibold)
              Image(systemName: "arrow.right")
            }
            .foregroundStyle(.white)
            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
          }
          .background(.blue)
          .disabled(!formIsValid)
          .opacity(formIsValid ? 1.0 : 0.5)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .offset(x: 0, y: -100)
          .padding(.top, 24)
          
          
          Spacer()
          
          //sign up button
          
          NavigationLink {
            RegistrationView()
              .navigationBarBackButtonHidden(true)
          } label: {
            HStack(spacing: 3) {
              Text("Don't have an account?")
              Text("Sign up")
                .fontWeight(.bold)
            }
            .font(.subheadline)
          }
        }
      }
    }
  }
}

extension LoginView: AuthenticationFormProtocol {
  var formIsValid: Bool {
    return !email.isEmpty
    && email.contains("@")
    && !password.isEmpty
    && password.count > 5
  }
}

#Preview {
  LoginView()
}
