//
//  MapStyleView.swift
//  Location-Based Mood Tracker
//
//  Created by Isaiah Schatzline on 12/27/24.
//

import SwiftUI

struct MapStyleView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mapStyleConfig: MapStyleConfig
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                LabeledContent("Base Style") {
                    Picker("Base Style", selection: $mapStyleConfig.baseStyle) {
                        ForEach(MapStyleConfig.BaseMapStyle.allCases, id: \.self) { type in
                            Text(type.label)
                        }
                    }
                }
                LabeledContent("Elevation") {
                    Picker("Elevation", selection: $mapStyleConfig.elevation) {
                        Text("Flat").tag(MapStyleConfig.MapElevation.flat)
                        Text("Realistic").tag(MapStyleConfig.MapElevation.realistic)
                    }
                }
                if mapStyleConfig.baseStyle != .imagery {
                    LabeledContent("Points of Interest") {
                        Picker("Points of Interest", selection: $mapStyleConfig.pointsOfInterest) {
                            Text("None").tag(MapStyleConfig.MapPOI.excludingAll)
                            Text("All").tag(MapStyleConfig.MapPOI.all)
                        }
                    }
                }
                Button("Ok") {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Map Style")
            .navigationBarTitleDisplayMode(.inline)
            Spacer()
        }
    }
}

#Preview {
    MapStyleView(mapStyleConfig: .constant(MapStyleConfig.init()))
}
