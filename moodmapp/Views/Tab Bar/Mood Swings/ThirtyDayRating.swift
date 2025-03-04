//
//  ThirtyDayRating.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/31/24.
//

import SwiftUI
import SwiftData
import Charts

struct ThirtyDayRating: View {
    
    var journalEntries: [JournalEntries]
    
    var body: some View {
        VStack {
            
            let average = calculateAverageMoodRating(for: journalEntries)
        
            Label("Mood Rating", systemImage: "chart.xyaxis.line")
                .font(.title)
                .bold()
            Text("30 Day Average: \(String(format: "%.1f", average))")
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.gray)
                
                
                // Filter entries for the last 30 days beforehand
                let filteredEntries = filterEntriesWithin30Days(entries: journalEntries)
                
                if filteredEntries.isEmpty {
                    Text("No mood data available in the last 30 days.")
                        .foregroundColor(.gray)
                } else {
                    // Line chart displaying mood ratings over the past 30 days
                    Chart {
                        ForEach(Array(zip(filteredEntries, filteredEntries.indices)), id: \.0) { entry, index in
                            LineMark(
                                x: .value("Date", entry.dateOfEntry),
                                y: .value("Mood Rating", entry.moodRating)
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 5))
                            .symbol {
                                Circle()
                                    .fill(.yellow)
                                    .frame(width: 10)
                                    .shadow(radius: 2)
                            }
                            
                            // PointMark with annotation for the value
                            PointMark(
                                x: .value("Date", entry.dateOfEntry),
                                y: .value("Mood Rating", entry.moodRating)
                            )
                            .opacity(0) // Ensures PointMark doesn't visually overlap with LineMark
                            .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                Text("\(entry.moodRating)")
                                    .font(.headline)
                            }
                        }
                    }
                    .chartYScale(domain: 0...11) // Set the y-axis range for mood ratings
                    .chartScrollableAxes(.horizontal)
                    .chartXVisibleDomain(length: 3600 * 24 * 7)
                    .chartYAxis {
                        AxisMarks(values: .stride(by: 1))
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 1)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(date, format: Date.FormatStyle().month(.twoDigits).day(.twoDigits)) // Custom format "MM/dd"
                                        .font(.caption)
                                }
                                AxisGridLine()
                        }
                    }
                }
                .frame(height: 300)
            }
        }
    }
}


func calculateAverageMoodRating(for entries: [JournalEntries]) -> Double {
    let totalMoodRating = entries.reduce(0) { $0 + $1.moodRating }
    return entries.isEmpty ? 0 : Double(totalMoodRating) / Double(entries.count)
}
