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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var truckLocations: [TruckLocation] = [] {
        didSet {
            addAnnotationsForTrucksWhenSet()
        }
    }
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet var timePicker: UIDatePicker!
    
    @IBAction func centerMapOnUserLocationButtonTapped(sender: AnyObject) {
        guard let location = locationManager.location else { return }
        mapView.centerCoordinate = location.coordinate
        mapView.userTrackingMode = .Follow
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
//        UserController.removeUser()
        postButtonEnableDisable()
        PostController.createSubscription()
        
        LocationManager.shared.setUpMapView(mapView, locationManager: locationManager)
        
        TruckController.fetchAllTruckLocationRecords { (trucks) in
            dispatch_async(dispatch_get_main_queue(), { 
                self.truckLocations = trucks
            })
        }
    }
    
    func addAnnotationsForTrucksWhenSet() {
        for truckLocation in truckLocations {
            let info = CustomPointAnnotation()
            info.coordinate = truckLocation.location.coordinate
            info.title = truckLocation.name
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            info.subtitle = "Here until \(dateFormatter.stringFromDate(truckLocation.expirationDate))"
            info.image = truckLocation.image
            
            
            mapView.addAnnotation(info)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let signupViewController = storyboard?.instantiateViewControllerWithIdentifier("navigationController") else { return }
        guard (UserController.getUserID() != nil) else { presentViewController(signupViewController, animated: true, completion: nil); return }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func postButtonEnableDisable() {
        UserController.checkIfUserHasTruck { (result) in
            dispatch_async(dispatch_get_main_queue(), {
                self.postButton.hidden = !result
            })
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !annotation.isKindOfClass(CustomPointAnnotation) else { return nil }
        
        let reuseID = "customAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        if let annotationView = annotationView {
            annotationView.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView?.canShowCallout = true
            let button = UIButton.init(type: .Custom)
            button.setImage(UIImage(named: "car"), forState: .Normal)
            button.frame = CGRectMake(0, 0, 44, 44)
            annotationView?.rightCalloutAccessoryView = button
        }
        
        guard let cpa = annotation as? CustomPointAnnotation else { return nil }
        annotationView?.image = cpa.image
        annotationView?.contentMode = .ScaleAspectFill
        annotationView?.frame = CGRectMake(0, 0, 22, 22)
        annotationView?.backgroundColor = UIColor.whiteColor()
        
        return annotationView
    }
    
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let selectedLocation = view.annotation
        let currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()
        if let coordinate = selectedLocation?.coordinate {
            let selectedPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let selectedMapItem = MKMapItem(placemark: selectedPlacemark)
            let mapItems = [selectedMapItem, currentLocationMapItem]
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMapsWithItems(mapItems, launchOptions: launchOptions)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let timestamp = location.timestamp
        let howRecent = timestamp.timeIntervalSinceNow
        if abs(howRecent) > 15.0 {
            LocationManager.shared.updateMap(mapView, location: location, region: MKCoordinateRegionMakeWithDistance(location.coordinate, 50, 50))
        }
    }
    
    var dateTextField: UITextField?
    
    @IBAction func postButtonTapped(sender: UIButton) {
        let alert = UIAlertController(title: "Select Departure Time", message: "What time do you plan on packing up and leaving this area?", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Departure Time"
            textField.inputView = self.timePicker
            self.timePicker.minimumDate = NSDate()
            self.dateTextField = textField
        }
        let doneAction = UIAlertAction(title: "Done", style: .Default) { (_) in
            guard let textFields = alert.textFields,
                let textField = textFields.first,
                let location = self.locationManager.location,
                let text = textField.text where text.characters.count > 0 else { self.showAlert("Error Saving Post", message: "You either didn't provide a date, or we couldn't find your current location."); return }
            PostController.postLocation(location, expirationDate: self.timePicker.date)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func timePickerChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateTextField?.text = dateFormatter.stringFromDate(timePicker.date)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}


class CustomPointAnnotation: MKPointAnnotation {
    var image: UIImage!
}