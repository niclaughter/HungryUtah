//
//  PostController.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/20/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import MapKit
import CloudKit

class PostController {
    static func postLocation(location: CLLocation, expirationDate: NSDate, dateCreated: NSDate = NSDate()) {
        guard let id = UserController.getUserID() else { return }
        let recordID = CKRecordID(recordName: id)
        CloudKitManager.sharedManager.fetchRecordWithID(recordID) { (record, error) in
            if let error = error {
                print("Error fetching User \(error.localizedDescription)")
            } else if let record = record,
                let truckReference = record["Truck"] as? CKReference {
                let newID = NSUUID().UUIDString
                let newRecordID = CKRecordID(recordName: newID)
                let newRecord = CKRecord(recordType: "Location", recordID: newRecordID)
                newRecord["Truck"] = truckReference
                newRecord["Location"] = location
                newRecord["DateCreated"] = dateCreated
                newRecord["ExpireDate"] = expirationDate
                newRecord["CreatedBy"] = CKReference(record: record, action: .DeleteSelf)
            }
        }
    }
}