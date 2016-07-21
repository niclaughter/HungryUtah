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
import CloudKit

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
    
    init?(truckRecord: CKRecord, locationRecord: CKRecord) {
        guard let name = truckRecord["Name"] as? String,
            let imageAsset = truckRecord["Image"] as? CKAsset,
            let image = imageFromAsset(imageAsset),
            let location = locationRecord["Location"] as? CLLocation,
            let expirationDate = locationRecord["ExpireDate"] as? NSDate else { return nil }
        self.name = name
        self.image = image
        self.location = location
        self.expirationDate = expirationDate
    }
}