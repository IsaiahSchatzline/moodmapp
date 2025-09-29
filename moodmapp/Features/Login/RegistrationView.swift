import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var emailMessage: String = ""
    @State private var showEmailError: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        ZStack {
            VStack {
                Image("BlackLaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 320)
                    .padding(.vertical, 32)
                
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .textInputAutocapitalization(.never)
                    .onChange(of: email) { validateEmail() }
                    if showEmailError {
                        Text(emailMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    InputView(text: $fullname,
                              title: "Full Name",
                              placeholder: "Enter your name")
                    .textInputAutocapitalization(.words)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                    .textInputAutocapitalization(.never)
                    VStack(alignment: .leading, spacing: 2) {
                        lengthRequirement
                        numberRequirement
                    }
                    
                    ZStack(alignment: .trailing) {
                        InputView(text: $confirmPassword,
                                  title: "Confirm Password",
                                  placeholder: "Confirm your password",
                                  isSecureField: true)
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                passwordMatchSuccess
                            } else {
                                passwordMatchFailure
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .offset(x: 0, y: -100)
                
                Button {
                    Task {
                        try await viewModel.createUser(withEmail: email,
                                                       password: password,
                                                       fullname: fullname)
                    }
                } label: {
                    HStack {
                        Text("Sign Up")
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
                
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Text("Already have an account?")
                        Text("Sign in")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .offset(x: 0, y: -20)
                }
            }
        }
    }
    
    private var lengthRequirement: some View {
        HStack {
            Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(password.count >= 8 ? .green : .gray)
            Text("Password must be at least 8 characters")
        }
        .font(.caption)
        .foregroundColor(password.count >= 8 ? .green : .gray)
    }
    
    private var numberRequirement: some View {
        HStack {
            Image(systemName: isValidPassword(password) ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValidPassword(password) ? .green : .gray)
            Text("Password must contain at least one letter and one number")
        }
        .font(.caption)
        .foregroundColor(isValidPassword(password) ? .green : .gray)
    }
    
    private func validateEmail() {
        if email.isEmpty {
            emailMessage = "Email cannot be empty"
            showEmailError = true
        } else if !isValidEmail(email) {
            emailMessage = "Please enter a valid email address"
            showEmailError = true
        } else {
            showEmailError = false
        }
    }
    
    private var passwordMatchSuccess: some View {
        Image(systemName: "checkmark.circle.fill")
            .imageScale(.large)
            .fontWeight(.bold)
            .foregroundStyle(.green)
    }
    
    private var passwordMatchFailure: some View {
        Image(systemName: "xmark.circle.fill")
            .imageScale(.large)
            .fontWeight(.bold)
            .foregroundStyle(.red)
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return isValidEmail(email) &&
               isValidPassword(password) &&
               confirmPassword == password &&
               isValidName(fullname)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return !email.isEmpty && emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Password requirements: minimum 8 characters with at least one letter and one number
        let passwordRegex = #"^(?=.*[A-Za-z])(?=.*\d).{8,}$"#
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return !password.isEmpty && passwordPredicate.evaluate(with: password)
    }
    
    private func isValidName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    RegistrationView()
}
