//
//  CurvedText.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 1/2/25.
//

import SwiftUI

struct CurvedText: View {
    @State var letterWidths: [Int: Double] = [:]
    @State var title: String
    
    var lettersOffset: [(offset: Int, element: Character)] {
        Array(title.enumerated())
    }
    var radius: Double

    var body: some View {
        ZStack {
            ForEach(lettersOffset, id: \.offset) { index, letter in
                Text(String(letter))
                    .font(.system(size: 13, design: .monospaced))
                    .kerning(5)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    // Capture the width of the letter
                                    letterWidths[index] = geometry.size.width
                                }
                        }
                    )
                    .rotationEffect(fetchAngle(at: index))
                    .offset(y: -radius) // Move each letter upward to the circle's radius
            }
        }
        .frame(width: radius * 2, height: radius)
    }

    func fetchAngle(at letterPosition: Int) -> Angle {
        let totalLetters = title.count
        let anglePerLetter = 180.0 / Double(totalLetters - 1) // Spread letters across 180° (-90° to +90°)
        let angle = -90.0 + anglePerLetter * Double(letterPosition) // Start at -90° and progress
        return .degrees(angle)
    }
}
