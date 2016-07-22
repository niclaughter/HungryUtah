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
                removeLocationObjectFromCK(truckReference.recordID)
                let newID = NSUUID().UUIDString
                let newRecordID = CKRecordID(recordName: newID)
                let newRecord = CKRecord(recordType: "Location", recordID: newRecordID)
                newRecord["Truck"] = truckReference
                newRecord["Location"] = location
                newRecord["DateCreated"] = dateCreated
                newRecord["ExpireDate"] = expirationDate
                newRecord["CreatedBy"] = CKReference(record: record, action: .DeleteSelf)
                CloudKitManager.sharedManager.saveRecord(newRecord, completion: { (record, error) in
                    if let error = error {
                        print("An error occured while trying to save a new Location Object to CK \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    
    static func removeLocationObjectFromCK(truckRecordID: CKRecordID) {
        let predicate = NSPredicate(format: "Truck == %@", argumentArray: [truckRecordID])
        CloudKitManager.sharedManager.fetchRecordsWithType("Location", predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let records = records, record = records.first {
                CloudKitManager.sharedManager.deleteRecordWithID(record.recordID, completion: { (recordID, error) in
                    if let error = error {
                        print("An error occured while trying to remove a truck's previous location object from CK = \(error.localizedDescription)")
                    }
                })
            } else if let error = error {
                print("Either there wasn't a previous location record to delete (which is fine), or an error occured - \(error.localizedDescription)")
            }
        }
    }
    
    static func createSubscription() {
        CloudKitManager.sharedManager.fetchSubscriptions { (subscriptions, error) in
            if subscriptions?.count > 0 {} else {
                let predicate = NSPredicate(value: true)
                CloudKitManager.sharedManager.subscribe("Location", predicate: predicate, identifier: NSUUID().UUIDString, contentAvailable: true, options: .FiresOnRecordCreation, completion: { (subscription, error) in
                    if let error = error {
                        print("Error subscribing to locations - \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    
}