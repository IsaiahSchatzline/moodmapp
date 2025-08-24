import SwiftUI
//import SwiftData
import MapKit

struct JournalPage: View {
//  @Environment(\.modelContext) var context
//  @Query(sort: \JournalEntries.dateOfEntry, order: .reverse) var entries: [JournalEntries]
  @State private var entryToEdit: JournalEntries?
  @State private var searchText: String = ""
  @StateObject private var viewModel = JournalEntriesViewModel()
  @EnvironmentObject var authViewModel: AuthViewModel
  
  var filteredEntries: [JournalEntries] {
    if searchText.isEmpty {
      return viewModel.entries
    } else {
      return viewModel.entries.filter { entry in
        entry.moodTitle.lowercased().contains(searchText.lowercased()) ||
        entry.emoji.contains(searchText) ||
        "\(entry.moodRating)".contains(searchText) ||
        dateFormatter.string(from: entry.dateOfEntry).contains(searchText)
      }
    }
  }
  
  var body: some View {
    
    let filterWidth: CGFloat = 275
    let filterHeight: CGFloat = 30
    
    NavigationView {
      VStack {
        VStack {
          ZStack {
            Capsule()
              .stroke(Color.black, lineWidth: 2)
              .fill(Color.white)
              .frame(width: filterWidth, height: filterHeight)
              .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 5)
              .offset(x: 0, y: 12)
            Text("Title | Emoji | Rating | Date | Time")
              .font(.headline)
              .foregroundStyle(.black)
              .offset(x: 0, y: 10)
          }
          
          // Search bar
          TextField("Search Moods...", text: $searchText)
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
        }
        .padding(.bottom, 10)
        .offset(x: 0, y: 25)
        
        // List of Journal Entries
        entryList
        
      }
      .navigationTitle("moodjournal")
      .sheet(item: $entryToEdit, onDismiss: {
        Task {
          viewModel.authVM = authViewModel
          await viewModel.loadEntries(descending: true)
        }
      }) { entry in
        ViewEntry(entry: entry, hideMapButton: false)
          .environmentObject(authViewModel)
      }
      .scrollContentBackground(.hidden)
      .background(
        LinearGradient(
          gradient: Gradient(colors: [Color(hex: "#D2C878"), Color(hex: "#D2C878"), Color(white: 0.9)]),
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
      )
      .task {
        viewModel.authVM = authViewModel
        await viewModel.loadEntries(descending: true)
      }
    }
  }
  
  private var entryList: some View {
    List {
      ForEach(filteredEntries) { entry in
        EntryCell(entryModel: entry)
          .onTapGesture {
            entryToEdit = entry
          }
          .padding()
      }
      .onDelete { indexSet in
        deleteEntry(at: indexSet)
      }
      .listRowBackground(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(white: 1, opacity: 0.8))
          .padding(.vertical, 5)
          .padding(.horizontal, 20)
          .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color.black, lineWidth: 2)
            .padding(.vertical, 5)
            .padding(.horizontal, 20)
          )
      )
      .listRowSeparator(.hidden)
    }
    .listRowInsets(.init(top: 0, leading: 40, bottom: 0, trailing: 40))
  }
  
  func deleteEntry(at offsets: IndexSet) {
    Task {
      viewModel.authVM = authViewModel
      for index in offsets {
        let entry = filteredEntries[index]
        await viewModel.deleteEntry(entry)
      }
    }
  }
}


struct EntryCell: View {
  let entryModel: JournalEntries
  @ObservedObject var locationManager = LocationManager()
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(entryModel.moodTitle) // Display the thoughts
        .font(.title.bold())
        .padding(.bottom, 5)
      HStack {
        Text(entryModel.emoji)
          .font(.title2)
        Text("\(entryModel.moodRating)") // Display the mood rating
          .font(.title2)
          .foregroundStyle(.black)
      }
      .padding(.bottom, 5)
      Text(dateFormatter.string(from: entryModel.dateOfEntry)) // Display the date
        .font(.subheadline)
        .foregroundStyle(.black)
      
      if let latitude = entryModel.latitude, let longitude = entryModel.longitude {
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
  
//  @Environment(\.modelContext) var context
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var authViewModel: AuthViewModel
  @State var moodRating: Int = 5
  @State var dateOfEntry: Date = .now
  @State var entryThoughts: String = ""
  @State var moodTitle: String = ""
  @State var updatedThoughts: String = ""
  @State var moodBar: Double = 5.0
  @State var showingCancelAlert: Bool = false
  @State var selectedEmoji: Emoji = .happy
  @State private var showingMap = false
  var entry: JournalEntries
  var hideMapButton: Bool
  
  init(entry: JournalEntries, hideMapButton: Bool) {
    self.entry = entry
    self.hideMapButton = hideMapButton
    _moodTitle = State(initialValue: entry.moodTitle)
    _entryThoughts = State(initialValue: entry.entryThoughts)
    _moodRating = State(initialValue: entry.moodRating)
    _dateOfEntry = State(initialValue: entry.dateOfEntry)
    _selectedEmoji = State(initialValue: Emoji(rawValue: entry.emoji) ?? .happy)
  }
  
  var body: some View {
    NavigationStack {
      Form {
        HStack {
          Text("Mood Title:")
          Spacer()
          TextField("", text: $moodTitle)
        }
        HStack {
          Text("Mood Date:")
          Spacer()
          DatePicker("", selection: $dateOfEntry)
        }
        
        
        
        HStack {
          Text("Mood:")
          Spacer()
          Picker("", selection: $selectedEmoji) {
            ForEach(Emoji.allCases, id: \.self) { moodEmoji in
              Text(moodEmoji.combinedEmojiDisplay)
            }
          }
          .onChange(of: selectedEmoji) { newValue in
            // keep local entry text fields in sync if needed
          }
          .pickerStyle(MenuPickerStyle()) // Compact display
          .accentColor(.black)
        }
        
        
        
        // Mood Rating - Use a Slider or Stepper instead of TextField for Int
        HStack {
          Text("Mood Rating: \(moodRating)")
          Spacer()
          Stepper("", value: $moodRating, in: 1...10)
        }
        
        // Thoughts - TextField for user input
        Section("Thoughts") {
          TextField("Thoughts", text: $entryThoughts, axis: .vertical)
        }
      }
      VStack {
        if !hideMapButton {
          // NavigationLink to navigate directly to MoodMap
          NavigationLink(destination: MoodMap()) {
            Text("View On Map")
              .font(.headline)
              .foregroundStyle(.blue)
          }
        }
      }
      .navigationTitle("Mood Entry")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItemGroup(placement: .topBarTrailing) {
          Button("close") { dismiss() }
        }
      }
    }
  }
  
  private func buildUpdatedEntry() -> JournalEntries {
    JournalEntries(
      id: entry.id,
      userID: entry.userID,
      moodTitle: moodTitle,
      moodRating: moodRating,
      entryThoughts: entryThoughts,
      emoji: selectedEmoji.rawValue,
      dateOfEntry: dateOfEntry,
      latitude: entry.latitude,
      longitude: entry.longitude
    )
  }
  
  private func saveChanges() async {
    guard let uid = authViewModel.userSession?.uid else {
      print("DEBUG: No authenticated user; cannot save changes.")
      return
    }
    let updated = buildUpdatedEntry()
    do {
      try await FirestoreManager.shared.saveEntry(updated, for: uid)
      await MainActor.run { dismiss() }
    } catch {
      print("DEBUG: Failed to save entry:", error.localizedDescription)
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
