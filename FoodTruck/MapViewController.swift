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
    
    var trucks: [Truck] = []
    
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
//        UserController.removeUser()
        postButtonEnableDisable()
        
        LocationManager.shared.setUpMapView(mapView, locationManager: locationManager)
        
        for truckInfo in TruckController.sharedController.truckInfos {
            let annotation = Annotation(title: truckInfo.name, coordinate: truckInfo.location)
            mapView.addAnnotation(annotation)
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


