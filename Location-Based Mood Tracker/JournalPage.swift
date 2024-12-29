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
                Text("This is where you can view or add journal entries.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()

                // Search bar
                TextField("Search moods...", text: $searchText)
                    .multilineTextAlignment(.center)
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
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("moodjournal")
            .sheet(item: $entryToEdit) { entry in ViewEntry(entry: entry) }
        }
    }
}

struct EntryCell: View {
    let entry: JournalEntries
    @ObservedObject var locationManager = LocationManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateFormatter.string(from: entry.dateOfEntry)) // Display the date
                .font(.body)
                .padding(.bottom, 5)
            Text(entry.moodTitle) // Display the thoughts
                .font(.body)
                .padding(.bottom, 5)
            HStack {
                Text(entry.emoji)
                    .font(.subheadline)
                Text("Mood: \(entry.moodRating)") // Display the mood rating
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if let latitude = entry.latitude, let longitude = entry.longitude {
                Text("Latitude: \(latitude)")
                    .font(.caption)
                    .foregroundColor(.black)
                Text("Longitude: \(longitude)")
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
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("Mood Title:")
                    Spacer()
                    TextField("", text: $entry.moodTitle)
                }
                HStack {
                    Text("Mood Date:")
                    Spacer()
                    DatePicker("", selection: $entry.dateOfEntry)
                }
                
                
                // FIX THE EMOJI CODE
                HStack {
                    Text("Mood:")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { emoji(rawValue: entry.emoji) ?? emoji.content }, // Convert emoji string to enum
                        set: { entry.emoji = $0.rawValue } // Update entry.emoji with the new value
                    )) {
                        ForEach(emoji.allCases, id: \.self) { emoji in
                            Text(emoji.rawValue)
                        }
                    }
                    
            }

            // Mood Rating - Use a Slider or Stepper instead of TextField for Int
            HStack {
                Text("Mood Rating: \(entry.moodRating)")
                Spacer()
                Stepper("", value: $entry.moodRating, in: 0...10)
            }

            // Thoughts - TextField for user input
                Section("thoughts") {
                    TextField("thoughts", text: $entry.entryThoughts, axis: .vertical)
                }
        }
            .navigationTitle("Mood Entry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss()
                         let hasUnsavedChanges =
                                 entry.moodRating != moodRating ||
                                 entry.dateOfEntry != dateOfEntry ||
                                 entry.entryThoughts != entryThoughts

                             if hasUnsavedChanges {
                                 showingCancelAlert = true
                             } else {
                                 dismiss()
                         }
                     }
                     .confirmationDialog("You have unsaved changes", isPresented: $showingCancelAlert) {
                         Button("Discard Changes", role: .destructive, action: dismiss.callAsFunction)
                     }
                     .alert("Unsaved Changes", isPresented: $showingCancelAlert) {
                                     Button("Discard Changes", role: .destructive) { dismiss() }
                                     Button("Keep Editing", role: .cancel) { }
                                 } message: {
                                     Text("You have unsaved changes. Are you sure you want to discard them?")
                                 }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") { dismiss() }
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
