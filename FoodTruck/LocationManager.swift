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
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        
        guard let location = locationManager.location else { return }
        
        updateMap(mapView, location: location)
    }
    
    func updateMap(mapView: MKMapView, location: CLLocation) {
        mapView.centerCoordinate = location.coordinate
        mapView.userTrackingMode = .Follow
        mapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 50, 50)
    }        
}