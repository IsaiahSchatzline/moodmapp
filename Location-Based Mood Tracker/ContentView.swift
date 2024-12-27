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

enum emoji: String, CaseIterable {
    case 🥰, 😂, 🤪, 😀, 😎, 😕, 😔, 🥺, 😓, 😡
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
            
            Settings()
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
    @State var selectedEmoji: emoji = .😀
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
                    .font(.title)
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
                
                
                
                Picker("emoji", selection: $selectedEmoji) {
                    ForEach(emoji.allCases, id: \.self) { emoji in
                        Text(emoji.rawValue)
                    }
                }
                .scaleEffect(2)
                .offset(x: 100, y: 50)
                    
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
        print((latitude: locationManager.currentLocation?.coordinate.latitude, longitude: locationManager.currentLocation?.coordinate.longitude))
        }
}

#Preview {
    ContentView()
}
