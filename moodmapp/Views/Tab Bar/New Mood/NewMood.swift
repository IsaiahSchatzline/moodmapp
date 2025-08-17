import SwiftUI
import SwiftData
import HalfASheet
import MapKit

struct NewMood: View {
  
  @Environment(\.modelContext) private var context
  
  @Query(sort: \JournalEntries.dateOfEntry) var entries: [JournalEntries]
  @ObservedObject var locationManager = LocationManager()
  @State var animateGradient: Bool = false
  @State var moodTitle: String = ""
  @State var selectedEmoji: Emoji = .happy
  @State var moodBar: Double = 5.0
  @State var entry: String = ""
  @State private var isShowing = false
  @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
  @State var latitude: CLLocationDegrees? = 0.0
  @State var longitude: CLLocationDegrees? = 0.0
  let titleCharacterLimt = 50
  let pickerWidth: CGFloat = 130
  let pickerHeight: CGFloat = 55
  
  var body: some View {
    ZStack {
      // Background Gradient
      NavigationView {
        LinearGradient(
          gradient: Gradient(colors: [Color(hex: "#7FAAD2"), Color(hex: "#7FAAD2"), Color(white: 0.9)]),
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea(.container, edges: [.top, .leading, .trailing])
        
        // Nav Bar
        .navigationTitle("moodmapp")
      }
      // Question
      ZStack {
        VStack {
          TextField("Mood Title", text: $moodTitle)
            .multilineTextAlignment(.center)
            .font(.title2)
            .bold()
            .padding()
            .frame(maxWidth: 300)
            .background(.white)
            .clipShape(Capsule())
            .overlay(
              Capsule()
                .stroke(Color.black, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
            .padding()
            .offset(x: 0, y: -175)
            .onChange(of: moodTitle, initial: false) { oldValue, newValue in
              if newValue.count > titleCharacterLimt {
                moodTitle = String(newValue.prefix(titleCharacterLimt))
              }
            }
            .lineLimit(1)
            .truncationMode(.tail)
        }
        
        Spacer()
        Spacer()
        
        
      }
      //Mood Slider
      VStack {
        Text("Mood: \(Int(moodBar))")
          .font(.system(size: 24))
          .bold()
          .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
          .offset(x: 0, y: 75)
        Slider(value: $moodBar, in: 1...10, step: 1)
          .accentColor(.white)
          .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
          .offset(x: 0, y: 75)
          .padding(.horizontal, 35)
        
        
        VStack {
          
          Button(action: {
            isShowing.toggle()
          }) {
            Text("Thoughts...")
              .italic()
              .font(.headline)
              .foregroundColor(Color(UIColor.lightGray))
              .padding()
          }
          .background(
            Circle()
              .stroke(Color.black, lineWidth: 2)
              .fill(Color.white)
              .frame(width: 120, height: 120)
              .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 5)
          )
          .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
          .offset(x: -100, y: 145)
          
          Circle()
            .stroke(Color.black, lineWidth: 2)
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 5)
            .offset(x: -135, y: 170)
          
          Circle()
            .stroke(Color.black, lineWidth: 2)
            .fill(Color.white)
            .frame(width: 12, height: 12)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 5)
            .offset(x: -150, y: 170)
        }
        
        
        ZStack {
          
          Picker("emoji picker", selection: $selectedEmoji) {
            ForEach(Emoji.allCases, id: \.self) { moodEmoji in
              HStack {
                Text(moodEmoji.combinedEmojiDisplay)                            }
            }
          }
          .padding(10)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.black, lineWidth: 2)
              .fill(Color.white)
              .frame(width: pickerWidth, height: pickerHeight)
              .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 5)
          )
          .scaleEffect(1.3)
          .bold()
          .offset(x: 90, y: 35)
          .accentColor(.black)
        }
        
        //Submit Button
        SwipableButtonView(moodTitle: $moodTitle, selectedEmoji: $selectedEmoji, moodBar: $moodBar, entry: $entry)
          .offset(x: 0, y: -25)
        
      }
      HalfASheet(isPresented: $isShowing, title: "mood thoughts") {
        VStack {
          Form {
            TextField("thoughts...", text: $entry, axis: .vertical)
              .lineLimit(14, reservesSpace: true)
          }
          
        }
      }
      .height(.proportional(0.90))
      .closeButtonColor(UIColor.black)
      .contentInsets(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
      
    }
    .ignoresSafeArea()
  }
}

#Preview {
  NewMood()
}
