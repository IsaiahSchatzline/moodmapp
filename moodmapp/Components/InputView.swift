import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    let isSecureField: Bool
    
    init(text: Binding<String>,
             title: String,
             placeholder: String,
             isSecureField: Bool = false) {
            self._text = text
            self.title = title
            self.placeholder = placeholder
            self.isSecureField = isSecureField
        }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
            Divider()
        }
    }
}
#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
    }

