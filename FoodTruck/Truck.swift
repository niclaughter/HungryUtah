//
//  Truck.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CloudKit

struct Truck {
    let name: String
    let reference: CKReference
    let id: String
    
    init?(record: CKRecord) {
        guard let name = record["Name"] as? String else { return nil }
        self.name = name
        self.id = record.recordID.recordName
        self.reference = CKReference(record: record, action: .DeleteSelf)
    }
}