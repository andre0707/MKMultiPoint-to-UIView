//
//  MKMultiPoint.swift
//  
//
//  Created by Andre Albach on 13.02.22.
//

import MapKit

extension MKMultiPoint {
    
    /// A simple wrapper variable to get all points as coordinates
    /// This variable will internally use the `getCoordinates` function.
    var allPoints: [CLLocationCoordinate2D] {
        var pointsArray = Array(repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&pointsArray, range: NSRange(location: 0, length: pointCount))
        
        return pointsArray
    }
}

/// Transforming the path `self` describes from a MKMapView to a UIView
extension MKMultiPoint {
    /// This function will transform the points of self into a bezier path when `self` is displayed in a `MKMapView`.
    /// In order to match the sizes correctly, this function needs the `coordinateRegion` in which self is displayed within the `viewSize` which is displaying the map in which `self` is in.
    /// - Parameters:
    ///   - coordinateRegion: The coordinate region of the `MKMapView` in which `self` is displayed
    ///   - viewSize: The `MKMapView` size in which `self` is displayed
    /// - Returns: The resulting bezier path from the points of self
    func calculatePath(using coordinateRegion: MKCoordinateRegion, and viewSize: CGRect) -> UIBezierPath? {
        /// Make sure this is actually a valid path. So it needs at least 2 points.
        guard allPoints.count >= 2 else { return nil }
        
        /// The problem with coordinates is, that the length for longitude and latitude are not equal.
        /// Also, the range for longitude goes from -180° to 180°, while the latitude range only goes from 90° to -90°.
        /// This means converting degrees to meter is not equal.
        /// While 1° in latitude is about 111.32km, 1° in longitude highly depends on the latitude.
        /// At the poles, so at 90° latitude, the length is 0, while at the equator, is the full ~40.000km.
        /// So for convertion we can always use N/S 1° == 111.32km. Equivalent to 0.000001° == 1m.
        /// For E/W 1° == 40075 km * cos( latitude ) / 360 is a pretty good approximation.
        ///
        /// So now that we know there is a difference, we can calculate the factor we need to multiply on the horizontal width to get
        /// a vertical height to it. Since the actual length in meter does not really matter, and because 40075 / 360 ~ 111.32 the length just
        /// devides out when calculating latitude / longitude.
        /// What remains is the following factor. (cosinus function uses radians, while coordinates are degree, so convert them)
        let factor = 1 / cos(coordinateRegion.center.latitude * .pi / 180)
        /// Get the height which depends on the span and convertion factor
        let rectHeight: CGFloat = (viewSize.width * coordinateRegion.span.latitudeDelta / coordinateRegion.span.longitudeDelta) * factor
        
        let longitudeMappingFactor = viewSize.width / coordinateRegion.span.longitudeDelta
        let latitudeMappingFactor = rectHeight / coordinateRegion.span.latitudeDelta
        
        /// Map the points from CLLocationCoordinate2D to CGPoint
        var mappedPoints = allPoints.map { point -> CGPoint in
            
            let x: CGFloat = (point.longitude - coordinateRegion.minLon) * longitudeMappingFactor
            let y: CGFloat = abs((point.latitude - coordinateRegion.minLat) * latitudeMappingFactor - rectHeight)
            
            return CGPoint(x: x, y: y)
        }
        
        /// Create the UIBezierPath from the mapped points
        let path = UIBezierPath()
        path.move(to: mappedPoints.removeFirst())
        
        for point in mappedPoints {
            path.addLine(to: point)
        }
        return path
    }
}
