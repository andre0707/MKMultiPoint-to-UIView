//
//  MKMapView.swift
//
//
//  Created by Andre Albach on 12.02.22.
//

import MapKit

extension MKMapView {
    
    /// All the current completely visible overlays
    var visibleOverlays: [MKOverlay] {
        overlays.filter { visibleMapRect.contains($0.boundingMapRect) }
    }
}
