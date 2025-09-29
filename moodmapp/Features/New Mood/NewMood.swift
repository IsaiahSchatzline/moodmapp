import SwiftUI
import MapKit

struct NewMood: View {
    @ObservedObject var viewModel: JournalEntriesViewModel
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
    @State private var isEmojiSheetPresented = false
    let titleCharacterLimt = 50
    let pickerWidth: CGFloat = 130
    let pickerHeight: CGFloat = 55
    
    var body: some View {
        ZStack {
            NavigationView {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#7FAAD2"), Color(hex: "#7FAAD2"), Color(white: 0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .navigationTitle("moodmapp")
            }
            
            moodTitleTextField
            
            VStack {
                moodBarTextAndSlider
                thoughtsButton
                emojiSheetOptions
                
                //Submit Button
                ButtonSlider(
                    viewModel: viewModel,
                    locationManager: locationManager,
                    moodTitle: $moodTitle,
                    selectedEmoji: $selectedEmoji,
                    moodBar: $moodBar,
                    entry: $entry
                )
                .offset(x: 0, y: -25)
                
            }
            .sheet(isPresented: $isShowing) {
                NavigationStack {
                    VStack {
                        Form {
                            TextField("thoughts...", text: $entry, axis: .vertical)
                                .lineLimit(14, reservesSpace: true)
                        }
                    }
                    .navigationTitle("mood thoughts")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isShowing = false
                            } label: {
                                Text("Close")
                                    .font(.body.weight(.semibold))
                            }
                            .tint(.black)
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.9)])
            .presentationDragIndicator(.visible)
        }
        .ignoresSafeArea()
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
    
    private var moodTitleTextField: some View {
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
    }
    
    private var moodBarTextAndSlider: some View {
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
        }
    }
    
    private var thoughtsButton: some View {
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
    }
    
    private var emojiSheetOptions: some View {
        Button(action: { isEmojiSheetPresented = true }) {
            selectedEmoji.stackedEmojiDisplay
                .foregroundStyle(.black)
        }
        .buttonStyle(EmojiTileStyle(isSelected: false))
        .frame(width: pickerWidth)
        .offset(x: 90, y: 35)
        .sheet(isPresented: $isEmojiSheetPresented) {
            EmojiGridSheet(
                allEmojis: Array(Emoji.allCases),
                selected: selectedEmoji,
                onSelect: { emoji in
                    selectedEmoji = emoji
                    isEmojiSheetPresented = false
                }
            )
            .presentationDetents([.large])
        }
    }
}

// MARK: - Shared Emoji Tile Style
private struct EmojiTileStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: isSelected ? 5 : 2)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            
            configuration.label
                .frame(maxWidth: .infinity)
                .bold()
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
        .frame(height: 70) // unify height across all emoji buttons
    }
}

// MARK: - Emoji Grid Sheet
private struct EmojiGridSheet: View {
    let allEmojis: [Emoji]
    let selected: Emoji
    let onSelect: (Emoji) -> Void
    private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 3) }
    private var positiveColumn: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 1) }
    private var neutralColumn: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 1) }
    private var negativeColumn: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 1) }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.verticalRainbow
                    .ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(allEmojis, id: \.self) { emoji in
                            Button(action: { onSelect(emoji) }) {
                                emoji.stackedEmojiDisplay
                            }
                            .buttonStyle(EmojiTileStyle(isSelected: emoji == selected))
                        }
                    }
                    .padding(16)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("How are you feeling?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
