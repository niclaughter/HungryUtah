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
    var truckInfos: [TruckLocation] = []
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
            }
            dispatch_async(dispatch_get_main_queue(), { 
                self.delegate?.truckFinishedSaving()
            })
        }
    }
    
    func fetchTruckLocations() {
        CloudKitManager.sharedManager.fetchRecordsWithType(CloudKitManager.RecordTypes.location.rawValue, recordFetchedBlock: { (locationRecord) in
            guard let truckReference = locationRecord["Truck"] as? CKReference else { return }
            CloudKitManager.sharedManager.fetchRecordWithID(truckReference.recordID, completion: { (record, error) in
                guard let truckRecord = record,
                    name = truckRecord["Name"] as? String,
                    imageAsset = truckRecord["Image"] as? CKAsset,
                    image = imageFromAsset(imageAsset),
                    location = locationRecord["Location"] as? CLLocation,
                    expirationDate = locationRecord["ExpireDate"] as? NSDate else { return }
                let truckLocation = TruckLocation(name: name, image: image, expirationDate: expirationDate, location: location)
                self.truckInfos.append(truckLocation)
            })
            }, completion: nil)
    }
}

func imageFromAsset(asset: CKAsset) -> UIImage? {
    if let data = NSData(contentsOfURL: asset.fileURL) {
        return UIImage(data: data)
    }
    return nil
}

protocol SaveTruckProtocol {
    func truckFinishedSaving()
}