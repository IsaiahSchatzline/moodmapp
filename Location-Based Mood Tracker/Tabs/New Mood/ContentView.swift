//
//  ContentView.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/20/24.
//

import SwiftUI
import SwiftData
import HalfASheet
import MapKit

enum Emoji: String, CaseIterable {
    case happy = "😊", joyful = "😄", excited = "🤩", content = "🙂", calm = "😌", relaxed = "🧘‍♀️", proud = "😎", hopeful = "🌟", grateful = "🙏", cheerful = "😁"
    case sad = "😢", anxious = "😰", angry = "😡", irritable = "😤", depressed = "😞", frustrated = "😩", guilty = "😔", ashamed = "😳", lonely = "😕", hopeless = "😖"
    case indifferent = "😐", confused = "🤔", nostalgic = "🥺", curious = "🤨", reflective = "🤯", tense = "😬", tired = "😴", bored = "😒", distracted = "😵", stressed = "😫"
    
    var moodWord: String {
        switch self {
        case .happy: return "happy"
        case .joyful: return "joyful"
        case .excited: return "excited"
        case .content: return "content"
        case .calm: return "calm"
        case .relaxed: return "relaxed"
        case .proud: return "proud"
        case .hopeful: return "hopeful"
        case .grateful: return "grateful"
        case .cheerful: return "cheerful"
        case .sad: return "sad"
        case .anxious: return "anxious"
        case .angry: return "angry"
        case .irritable: return "irritable"
        case .depressed: return "depressed"
        case .frustrated: return "frustrated"
        case .guilty: return "guilty"
        case .ashamed: return "ashamed"
        case .lonely: return "lonely"
        case .hopeless: return "hopeless"
        case .indifferent: return "indifferent"
        case .confused: return "confused"
        case .nostalgic: return "nostalgic"
        case .curious: return "curious"
        case .reflective: return "reflective"
        case .tense: return "tense"
        case .tired: return "tired"
        case .bored: return "bored"
        case .distracted: return "distracted"
        case .stressed: return "stressed"
        }
    }
    var combinedEmojiDisplay: String {
        return "\(self.rawValue) \(self.moodWord)"
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntries.dateOfEntry, order: .reverse) var entries: [JournalEntries]
    
    var body: some View {
        TabView {
            newMood()
                .tabItem {
                    Image(systemName: "applepencil")
                    Text("New Mood")
                }
            
            JournalPage()
                .tabItem {
                    Image(systemName: "book")
                    Text("Mood Journal")
                }
            
            MoodMap()
                .tabItem {
                    Image(systemName: "map")
                    Text("Mood Map")
                }
            
            MoodSwings()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Mood Swings")
                }
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
}

struct newMood: View {
    
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
    
    var body: some View {
        ZStack {
            // Background Gradient
            NavigationView {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.569, green: 0.788, blue: 0.969), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                    
                // Nav Bar
                .navigationTitle("moodmapp")
            }
            // Question
            VStack {
                TextField("mood title", text: $moodTitle)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: 300)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .padding()
                    .offset(x: 0, y: 175)
                    .onChange(of: moodTitle) { newValue in
                        if newValue.count > titleCharacterLimt {
                            moodTitle = String(newValue.prefix(titleCharacterLimt))
                        }
                    }
                    .lineLimit(1)
                    .truncationMode(.tail)
                    
                Spacer()
                Spacer()

                    
            }
            //Mood Slider
            VStack {
                Text("mood: \(Int(moodBar))")
                    .font(.system(size:24))
                    .bold()
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .offset(x: 0, y: 25)
                Slider(value: $moodBar, in: 1...10, step: 1)
                    .accentColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .offset(x: 0, y: 50)
                
                Button(action: {
                    isShowing.toggle()
                }) {
                    Text("thoughts...")
                        .italic()
                        .font(.headline)
                        .foregroundColor(Color(UIColor.lightGray))
                        .padding()
                }
                .background(
                    Image(systemName: "bubble.fill") // SF Symbol
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 125, height: 100) // Size of the background symbol
                        .foregroundColor(.white) // Color of the SF Symbol
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                .offset(x: -100, y: 125)
                
                
                
                Picker("emoji picker", selection: $selectedEmoji) {
                    ForEach(Emoji.allCases, id: \.self) { moodEmoji in
                        HStack {
                            Text(moodEmoji.combinedEmojiDisplay)
                        }
                    }
                }
                .scaleEffect(1.5)
                .bold()
                .offset(x: 100, y: 75)
                .accentColor(.black)
                
                //Submit Button
                SwipableButtonView(moodTitle: $moodTitle, selectedEmoji: $selectedEmoji, moodBar: $moodBar, entry: $entry)
                
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
    ContentView()
}
