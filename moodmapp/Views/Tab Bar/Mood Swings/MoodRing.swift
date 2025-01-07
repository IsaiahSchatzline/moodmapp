//
//  MoodRing.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/31/24.
//

import SwiftUI
import SwiftData
import Charts

struct MoodRing: View {
    var journalEntries: [JournalEntries]
    var moodTypes: Set<String> {
        Set(journalEntries.map { $0.emoji })
    }
    
    // Change the selectedMoodType to String?
    @State private var selectedMoodType: String?
    @State private var selectedMoodPercentage: Double?

    var body: some View {
        VStack {
            Label("Mood Ring", systemImage: "face.smiling")
                .font(.title)
                .bold()

            if let chartData = prepareChartData(from: journalEntries) {

                Chart {
                    ForEach(chartData.keys.sorted(), id: \.self) { moodType in
                        let count = chartData[moodType] ?? 0

                        SectorMark(
                            angle: .value("count", count),
                            innerRadius: .ratio(0.618),
                            outerRadius: selectedMoodType == moodType ? 175 : 150,
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("mood", moodType))
                        .cornerRadius(5)
                        .annotation(position: .overlay, alignment: .center) {
                            Text("\(moodType) \(count)")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .scaleEffect(1.15)
                .chartAngleSelection(value: $selectedMoodType) // Selection binding
                .onChange(of: selectedMoodType) { newValue, oldValue in
                    if let newMoodType = newValue {
                        updateSelectedMood(moodType: newMoodType)
                    }
                }
                .chartBackground { chartProxy in
                    MoodRingBackground(selectedMood: selectedMoodType, selectedMoodPercentage: selectedMoodPercentage, journalEntries: journalEntries)
                }
                .frame(height: 300)
                .padding()
                .chartLegend(.hidden)

                if let selectedMoodType = selectedMoodType, let selectedMoodPercentage = selectedMoodPercentage {
                    Text("mood: \(selectedMoodType)")
                        .font(.title)
                    Text("percentage: \(String(format: "%.2f", selectedMoodPercentage))%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func updateSelectedMood(moodType: String) {
        let moodEntries = journalEntries.filter { $0.emoji == moodType }
        let count = moodEntries.count
        let totalCount = journalEntries.count

        selectedMoodPercentage = Double(count) / Double(totalCount) * 100
    }

    private func prepareChartData(from entries: [JournalEntries]) -> [String: Int]? {
        guard !entries.isEmpty else { return nil }
        return entries.reduce(into: [String: Int]()) { counts, entry in
            counts[entry.emoji, default: 0] += 1
        }
    }
}
