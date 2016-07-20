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
}

protocol SaveTruckProtocol {
    func truckFinishedSaving(record: CKRecord?)
}