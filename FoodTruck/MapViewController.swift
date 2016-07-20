//
//  MapViewController.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func centerMapOnUserLocationButtonTapped(sender: AnyObject) {
        guard let location = locationManager.location else { return }
        mapView.centerCoordinate = location.coordinate
        mapView.userTrackingMode = .Follow
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        LocationManager.shared.setUpMapView(mapView, locationManager: locationManager)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let timestamp = location.timestamp
        let howRecent = timestamp.timeIntervalSinceNow
        if abs(howRecent) > 15.0 {
            LocationManager.shared.updateMap(mapView, location: location, region: MKCoordinateRegionMakeWithDistance(location.coordinate, 50, 50))
        }
    }
}