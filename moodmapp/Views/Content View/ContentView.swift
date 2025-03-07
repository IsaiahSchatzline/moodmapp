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
    @EnvironmentObject var viewModel: AuthViewModel
    @Query(sort: \JournalEntries.dateOfEntry, order: .reverse) var entries: [JournalEntries]
    @State private var showProfile = false
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                TabView {
                    NewMood()
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
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
