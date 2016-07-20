//
//  LocationManager.swift
//  FoodTruck
//
//  Created by Nicholas Laughter on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager {
    
    static let shared = LocationManager()
    
    func setUpMapView(mapView: MKMapView, locationManager: CLLocationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        guard let location = locationManager.location else { return }
        let coordinateRegionWithMeters = MKCoordinateRegionMakeWithDistance(location.coordinate, 50, 50)
        
        updateMap(mapView, location: location, region: coordinateRegionWithMeters)
    }
    
    func updateMap(mapView: MKMapView, location: CLLocation, region: MKCoordinateRegion) {
        mapView.centerCoordinate = location.coordinate
        mapView.userTrackingMode = .Follow
        mapView.region = region
    }        
}