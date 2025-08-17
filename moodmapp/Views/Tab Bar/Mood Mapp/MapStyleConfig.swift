import SwiftUI
import MapKit

struct MapStyleConfig {
  enum BaseMapStyle: CaseIterable {
    case standard, hybrid, imagery
    var label: String {
      switch self {
      case .standard:
        "Standard"
      case .hybrid:
        "Satellite with roads"
      case .imagery:
        "Satellite only"
      }
    }
  }
  enum MapElevation {
    case flat, realistic
    var selection: MapStyle.Elevation {
      switch self {
      case .flat:
          .flat
      case .realistic:
          .realistic
      }
    }
  }
  enum MapPOI {
    case all, excludingAll
    var selection: PointOfInterestCategories {
      switch self {
      case .all:
          .all
      case .excludingAll:
          .excludingAll
      }
    }
  }
  
  var baseStyle = BaseMapStyle.standard
  var elevation = MapElevation.flat
  var pointsOfInterest = MapPOI.excludingAll
  
  var mapStyle: MapStyle {
    switch baseStyle {
    case .standard:
      MapStyle.standard(elevation: elevation.selection, pointsOfInterest: pointsOfInterest.selection)
    case .hybrid:
      MapStyle.hybrid(elevation: elevation.selection, pointsOfInterest: pointsOfInterest.selection)
    case .imagery:
      MapStyle.imagery(elevation: elevation.selection)
    }
  }
}
