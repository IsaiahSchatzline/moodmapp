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
        case .happy: return "Happy"
        case .joyful: return "Joyful"
        case .excited: return "Excited"
        case .content: return "Content"
        case .calm: return "Calm"
        case .relaxed: return "Relaxed"
        case .proud: return "Proud"
        case .hopeful: return "Hopeful"
        case .grateful: return "Grateful"
        case .cheerful: return "Cheerful"
        case .sad: return "Sad"
        case .anxious: return "Anxious"
        case .angry: return "Angry"
        case .irritable: return "Irritable"
        case .depressed: return "Depressed"
        case .frustrated: return "Frustrated"
        case .guilty: return "Guilty"
        case .ashamed: return "Ashamed"
        case .lonely: return "Lonely"
        case .hopeless: return "Hopeless"
        case .indifferent: return "Indifferent"
        case .confused: return "Confused"
        case .nostalgic: return "Nostalgic"
        case .curious: return "Curious"
        case .reflective: return "Reflective"
        case .tense: return "Tense"
        case .tired: return "Tired"
        case .bored: return "Bored"
        case .distracted: return "Distracted"
        case .stressed: return "Stressed"
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
                    Image(systemName: "pencil")
                    Text("new mood")
                }
            
            JournalPage()
                .tabItem {
                    Image(systemName: "book")
                    Text("mood journal")
                }
            
            MoodMap()
                .tabItem {
                    Image(systemName: "map")
                    Text("mood mapp")
                }
            
            MoodSwings()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("mood swings")
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
    
    var body: some View {
        ZStack {
            // Background Gradient
            NavigationView {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.58, green: 0.86, blue: 0.97), Color.white
                                                   ]),
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
                    .padding()
                    .frame(maxWidth: 300)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .padding()
                    .offset(x: 0, y: 175)
                    
                Spacer()
                Spacer()

                    
            }
            //Mood Slider
            VStack {
                Text("mood: \(Int(moodBar))")
                    .font(.system(size:24))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .offset(x: 0, y: 25)
                Slider(value: $moodBar, in: 0...10, step: 1)
                    .accentColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .offset(x: 0, y: 50)
                
                
                Button("thoughts...") {
                    isShowing.toggle()
                }
                .padding(40)
                .foregroundColor(.black)
                .background(Color.white)
                .clipShape(Circle())
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
                .offset(x: 75, y: 50)
                .accentColor(.black)
                
                
                    
                // Thoughts
                        
                /*TextField("thoughts...", text: $entry)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .padding()
                    .offset(x: 0, y: 175)*/
                
                    //Submit Button
                Button("submit") {
                    submitEntry()
                }
                    .padding(25)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .offset(x: 130, y: 175)
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
    
    func submitEntry() { // PREVIEW CRASH?
    
        let newEntry = JournalEntries(moodTitle: moodTitle, entryThoughts: entry, emoji: selectedEmoji.rawValue, dateOfEntry: Date(), moodRating: Int(moodBar), latitude: locationManager.currentLocation?.coordinate.latitude, longitude: locationManager.currentLocation?.coordinate.longitude)
        do {
                context.insert(newEntry) // Add the entry to the context
                try context.save()       // Save the context to persist data
            } catch {
                print("Failed to save entry: \(error.localizedDescription)")
            }
        
        moodTitle = ""
        entry = ""
        moodBar = 5.0
        selectedEmoji = .content
        print((latitude: locationManager.currentLocation?.coordinate.latitude, longitude: locationManager.currentLocation?.coordinate.longitude))
        }
}

#Preview {
    ContentView()
}
