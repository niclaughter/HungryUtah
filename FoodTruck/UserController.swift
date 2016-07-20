//
//  UserController.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class UserController {
    
    static let keyLoggedInUser = "loggedInUserID"
    
    static func saveUserID(id: String) {
        NSUserDefaults.standardUserDefaults().setObject(id, forKey: keyLoggedInUser)
    }
    
    static func getUserID() -> String? {
        guard let loggedInUser = NSUserDefaults.standardUserDefaults().objectForKey(keyLoggedInUser) as? String else { return nil }
        return loggedInUser
    }
    
    static func removeUser() {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: keyLoggedInUser)
    }
    
    
    static func saveUserToCloudKit(firstName: String, lastName: String, email: String?, truckReference: CKReference?, dateCreated: NSDate = NSDate()) {
        let id = NSUUID().UUIDString
        let recordID = CKRecordID(recordName: id)
        let record = CKRecord(recordType: "User", recordID: recordID)
        record["FirstName"] = firstName
        record["LastName"] = lastName
        record["Email"] = email
        record["Truck"] = truckReference
        record["Badge"] = false
        record["Blocked"] = false
        record["DateCreated"] = dateCreated
        
        saveUserID(id)
        
        CloudKitManager.sharedManager.saveRecord(record) { (record, error) in
            if let error = error {
                print("Error saving User to CloudKit - \(error.localizedDescription)")
            }
        }
    }
}
