//
//  JournalPage.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/21/24.
//

import SwiftUI
import SwiftData
import MapKit

struct JournalPage: View {
    @Environment(\.modelContext) var context
    @Query(sort: \JournalEntries.dateOfEntry, order: .reverse) var entries: [JournalEntries]
    @State private var entryToEdit: JournalEntries?
    @State private var searchText: String = ""

    var filteredEntries: [JournalEntries] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.moodTitle.lowercased().contains(searchText.lowercased()) ||
                entry.emoji.contains(searchText) ||
                "\(entry.moodRating)".contains(searchText) ||
                dateFormatter.string(from: entry.dateOfEntry).contains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("search by title, emoji, rating, date, or time.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()

                // Search bar
                TextField("search moods...", text: $searchText)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: 300)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 10)
                    .padding()

                // List of Journal Entries
                List {
                    ForEach(filteredEntries) { entry in
                        EntryCell(entry: entry)
                            .onTapGesture {
                                entryToEdit = entry
                            }
                            .padding()
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            context.delete(entries[index])
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(white: 1, opacity: 0.8))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 20)
                    )
                    .listRowSeparator(.hidden)
                }
                .listRowInsets(.init(top: 0, leading: 40, bottom: 0, trailing: 40))
                
            }
            .navigationTitle("moodjournal")
            .sheet(item: $entryToEdit) { entry in ViewEntry(entry: entry, hideMapButton: false) }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.953, green: 0.506, blue: 0.506), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                )
        }
    }
}

struct EntryCell: View {
    let entry: JournalEntries
    @ObservedObject var locationManager = LocationManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.moodTitle) // Display the thoughts
                .font(.title.bold())
                .padding(.bottom, 5)
            HStack {
                Text(entry.emoji)
                    .font(.title2)
                Text("\(entry.moodRating)") // Display the mood rating
                    .font(.title2)
                    .foregroundStyle(.black)
            }
            .padding(.bottom, 5)
            Text(dateFormatter.string(from: entry.dateOfEntry)) // Display the date
                .font(.subheadline)
                .foregroundStyle(.black)
            
            if let latitude = entry.latitude, let longitude = entry.longitude {
                Text("latitude: \(latitude)")
                    .font(.caption)
                    .foregroundColor(.black)
                Text("longitude: \(longitude)")
                    .font(.caption)
                    .foregroundColor(.black)
            } else {
                Text("Location: Not available")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
        }
    }
}

struct ViewEntry: View {
    
    enum emoji: String, CaseIterable {
        case happy = "😊", joyful = "😄", excited = "🤩", content = "🙂", calm = "😌", relaxed = "🧘‍♀️", proud = "😎", hopeful = "🌟", grateful = "🙏", cheerful = "😁"
        case sad = "😢", anxious = "😰", angry = "😡", irritable = "😤", depressed = "😞", frustrated = "😩", guilty = "😔", ashamed = "😳", lonely = "😕", hopeless = "😖"
        case indifferent = "😐", confused = "🤔", nostalgic = "🥺", curious = "🤨", reflective = "🤯", tense = "😬", tired = "😴", bored = "😒", distracted = "😵", stressed = "😫"
    }
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: JournalEntries
    @State var moodRating: Int = 5
    @State var dateOfEntry: Date = .now
    @State var entryThoughts: String = ""
    @State var moodTitle: String = ""
    @State var updatedThoughts: String = ""
    @State var moodBar: Double = 5.0
    @State var showingCancelAlert: Bool = false
    @State var selectedEmoji: emoji = emoji.content
    @State private var showingMap = false
    var hideMapButton: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("mood title:")
                    Spacer()
                    TextField("", text: $entry.moodTitle)
                }
                HStack {
                    Text("mood date:")
                    Spacer()
                    DatePicker("", selection: $entry.dateOfEntry)
                }
                
                
                
                HStack {
                    Text("mood:")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { Emoji(rawValue: entry.emoji) ?? .happy },
                        set: { entry.emoji = $0.rawValue }
                    )) {
                        ForEach(Emoji.allCases, id: \.self) { moodEmoji in
                            Text(moodEmoji.combinedEmojiDisplay)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Compact display
                    .accentColor(.black)
                }
                
                
                
                // Mood Rating - Use a Slider or Stepper instead of TextField for Int
                HStack {
                    Text("mood rating: \(entry.moodRating)")
                    Spacer()
                    Stepper("", value: $entry.moodRating, in: 1...10)
                }
                
                // Thoughts - TextField for user input
                Section("thoughts") {
                    TextField("thoughts", text: $entry.entryThoughts, axis: .vertical)
                }
            }
            VStack {
                if !hideMapButton {
                    // NavigationLink to navigate directly to MoodMap
                    NavigationLink(destination: MoodMap(journalEntry: entry)) {
                        Text("view on map")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("mood entry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("close") { dismiss() }
                }
            }
        }
    }
}





var dateFormatter: DateFormatter {
    let stringToDateformatter = DateFormatter()
    stringToDateformatter.dateFormat = "yyyy/MM/dd HH:mm"

    let dateToStringFormatter = DateFormatter()
    dateToStringFormatter.timeStyle = .short
    dateToStringFormatter.dateStyle = .short
    dateToStringFormatter.locale = Locale(identifier: "en_US")
    return dateToStringFormatter // 5/1/19, 10:30 PM
}




#Preview {
    JournalPage()
}
