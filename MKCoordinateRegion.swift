//
//  MKCoordinateRegion.swift
//  Workout Map
//
//  Created by Andre Albach on 13.02.22.
//

import MapKit

extension MKCoordinateRegion {
    
    /// The minimum latitude for this region.
    var minLat: CLLocationDegrees {
        center.latitude - span.latitudeDelta / 2
    }
    
    /// The maximum latitude for this region.
    var maxLat: CLLocationDegrees {
        center.latitude + span.latitudeDelta / 2
    }
    
    /// The minimum longitude for this region.
    var minLon: CLLocationDegrees {
        center.longitude - span.longitudeDelta / 2
    }
    
    /// The maximum longitude for this region.
    var maxLon: CLLocationDegrees {
        center.longitude + span.longitudeDelta / 2
    }
    
    /// The coordinates for the top left point of the region
    var topLeft: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: minLat,
                               longitude: maxLon)
    }
    
    /// The coordinates for the top right point of the region
    var topRight: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: maxLat,
                               longitude: maxLon)
    }
    
    /// The coordinates for the bottom left point of the region
    var bottomLeft: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: minLat,
                               longitude: minLon)
    }
    
    /// The coordinates for the bottom right point of the region
    var bottomRight: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: maxLat,
                               longitude: minLon)
    }
}
