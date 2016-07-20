//
//  Annotation.swift
//  FoodTruck
//
//  Created by Nicholas Laughter on 7/20/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    @objc let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(title: String, coordinate: CLLocation) {
        self.title = title
        self.coordinate = coordinate.coordinate
    }
}