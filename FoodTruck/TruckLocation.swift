//
//  TruckLocation.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TruckLocation {
    let name: String
    let image: UIImage
    let expirationDate: NSDate
    let location: CLLocation
    
    init(name: String, image: UIImage, expirationDate: NSDate, location: CLLocation) {
        self.name = name
        self.image = image
        self.expirationDate = expirationDate
        self.location = location
    }
}