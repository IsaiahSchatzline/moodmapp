import SwiftUI

struct ButtonRow: View {
  @State var imageName: String = ""
  @State var title: String = ""
  @State var tintColor: Color = .gray
  @State var backgroundColor: Color?
  
  var body: some View {
    HStack(spacing: 12) {
      buttonIcon
      buttonText
    }
    .backgroundStyle(backgroundColor ?? .white)
  }
  
  private var buttonIcon: some View {
    Image(systemName: imageName)
      .imageScale(.small)
      .font(.title)
      .foregroundStyle(tintColor)
  }
  
  private var buttonText: some View {
    Text(title)
      .font(.subheadline)
      .foregroundStyle(.black)
  }
}

#Preview {
  ButtonRow()
}
