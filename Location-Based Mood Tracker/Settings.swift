//
//  Settings.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/21/24.
//
import SwiftUI

struct Settings: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .padding()

            Text("This is where you can change your settings.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    Settings()
}
