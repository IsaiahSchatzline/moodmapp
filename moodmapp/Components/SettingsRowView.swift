import SwiftUI

struct SettingsRowView: View {
    @State var imageName: String = ""
    @State var title: String = ""
    @State var tintColor: Color = .gray
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundStyle(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    SettingsRowView()
}
