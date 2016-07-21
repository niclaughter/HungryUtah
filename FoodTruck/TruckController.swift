//
//  TruckController.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


class TruckController {
    
    static let sharedController = TruckController()
    var delegate: SaveTruckProtocol?
    
    func saveTruck(name: String, image: NSData) {
        let id = NSUUID().UUIDString
        let recordID = CKRecordID(recordName: id)
        let record = CKRecord(recordType: "Truck", recordID: recordID)
        record["Name"] = name
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(id).URLByAppendingPathExtension("jpg")
        image.writeToURL(fileURL, atomically: true)
        record["Image"] = CKAsset(fileURL: fileURL)
        record["TruckID"] = id
        
        CloudKitManager.sharedManager.saveRecord(record) { (record, error) in
            if let error = error {
                print("Error saving truck to CloudKit - \(error.localizedDescription)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.truckFinishedSaving(nil)
                })
            } else if let record = record {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.truckFinishedSaving(record)
                })
            }
        }
    }
    
    static func fetchAllTruckLocationRecords(completion: (trucks: [TruckLocation]) -> Void) {
        let timePredicate = NSPredicate(format: "ExpireDate >= %@", argumentArray: [NSDate()])
        CloudKitManager.sharedManager.fetchRecordsWithType("Location", predicate: timePredicate, recordFetchedBlock: nil) { (records, error) in
            if let records = records {
                var truckLocation = [TruckLocation]()
                let group = dispatch_group_create()
                for locationRecord in records {
                    dispatch_group_enter(group)
                    if let truckReference = locationRecord["Truck"] as? CKReference {
                        let predicate = NSPredicate(format: "TruckID == %@", argumentArray: [truckReference.recordID.recordName])
                        CloudKitManager.sharedManager.fetchRecordsWithType("Truck", predicate: predicate, recordFetchedBlock: { (truckRecord) in
                            let truck = TruckLocation(truckRecord: truckRecord, locationRecord: locationRecord)
                            if let truck = truck {
                                truckLocation.append(truck)
                            }
                            dispatch_group_leave(group)
                            }, completion: nil)
                    } else {
                        dispatch_group_leave(group)
                    }
                }
                
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    completion(trucks: truckLocation)
                })
            } else if let error = error {
                print("Error fetching all Truck Location Objects from CK - \(error.localizedDescription)")
            }
        }
    }

}

func imageFromAsset(asset: CKAsset) -> UIImage? {
    if let data = NSData(contentsOfURL: asset.fileURL) {
        return UIImage(data: data)
    }
    return nil
}

protocol SaveTruckProtocol {
    func truckFinishedSaving(record: CKRecord?)
}