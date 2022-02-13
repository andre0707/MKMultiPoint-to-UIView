//
//  MainVC.swift
//  
//
//  Created by Andre Albach on 13.02.22.
//

import MapKit
import UIKit

final class MainVC: UIViewController {
    
    private var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        addButtonToCreateLayer()
        addOverlayToMap()
    }
    
    private func initMapView() {
        mapView = MKMapView()
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        mapView.delegate = self
        
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        
        mapView.mapType = .mutedStandard
        mapView.pointOfInterestFilter = .excludingAll
    }
    
    private func addButtonToCreateLayer() {
        let showStatsButton = UIButton()
        showStatsButton.layer.cornerRadius = 8
        showStatsButton.backgroundColor = .darkGray
        let image = UIImage(systemName: "wrench", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium))?.withTintColor(.white, renderingMode: .alwaysOriginal)
        showStatsButton.setImage(image, for: .normal)
        
        showStatsButton.addAction(UIAction(title: "", handler: { [weak self] _ in
            self?.addViewWithRouteShape()
        }), for: .touchUpInside)
        
        view.addSubview(showStatsButton)
        showStatsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            showStatsButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 8),
            showStatsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            showStatsButton.widthAnchor.constraint(equalToConstant: 40),
            showStatsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func addOverlayToMap() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 50.1234, longitude: 8.1234),
            CLLocationCoordinate2D(latitude: 50.1234, longitude: 8.3456),
            CLLocationCoordinate2D(latitude: 50.0000, longitude: 8.3456),
            CLLocationCoordinate2D(latitude: 50.0000, longitude: 8.1234),
            CLLocationCoordinate2D(latitude: 50.1234, longitude: 8.1234),
        ]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
    private func addViewWithRouteShape() {
        guard let workoutShape = createPolylinesLayer() else { return }
        
        let layerView = UIView(frame: CGRect(x: 50, y: 50, width: workoutShape.frame.width, height: workoutShape.frame.height))
        layerView.backgroundColor = .cyan.withAlphaComponent(0.5)
        view.addSubview(layerView)
        layerView.layer.addSublayer(workoutShape)
    }
    
    private func createPolylinesLayer() -> CAShapeLayer? {
        /// Get all the visible route polylines and make sure there are actually some
        guard let visiblePolyLines = mapView.visibleOverlays as? [MKPolyline],
              !visiblePolyLines.isEmpty
        else { return nil }
        
        /// Transform the route polylines to their paths
        let paths = visiblePolyLines.compactMap {
            $0.calculatePath(using: mapView.region, and: mapView.bounds)
        }
        /// Append all single route paths to one path, which describes all the wourkouts
        let workoutsPath = UIBezierPath()
        for path in paths {
            workoutsPath.append(path)
        }
        
        /// Create the shape layer which actually holds the route paths
        let workoutShape = CAShapeLayer()
        workoutShape.path = workoutsPath.cgPath
        workoutShape.lineWidth = 2.0
        workoutShape.fillColor = UIColor.clear.cgColor
        workoutShape.strokeColor = UIColor.orange.cgColor
        /// adapt the position
        workoutShape.frame = CGRect(x: -workoutsPath.bounds.minX,
                                    y: -workoutsPath.bounds.minY,
                                    width: workoutsPath.bounds.width,
                                    height: workoutsPath.bounds.height)
        
        return workoutShape
    }
}

extension MainVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 1
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}
