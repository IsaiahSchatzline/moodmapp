import SwiftUI

struct ToastBanner: View {
  let message: String
  let isSuccess: Bool
  var duration: TimeInterval = 5
  var onDismiss: () -> Void = {}
  @State private var isVisible: Bool = true
  
  var body: some View {
    VStack {
      Spacer()
      HStack(spacing: 16) {
        Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
        Text(message)
      }
      .foregroundColor(.white)
      .padding()
      .background(isSuccess ? Color.green : Color.red)
      .cornerRadius(16)
      .padding(.bottom, 40)
    }
    .opacity(isVisible ? 1 : 0)
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        withAnimation {
          isVisible = false
        }
        onDismiss()
      }
    }
  }
}
