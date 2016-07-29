
//
//  AppDelegate.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        guard let notificationInfo = userInfo as? [String: NSObject] else { return }
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: notificationInfo)
        guard let recordID = notification.recordID else { return }
        
        CloudKitManager.sharedManager.fetchRecordWithID(recordID) { (locationRecord, error) in
            if let locationRecord = locationRecord,
                let truckReference = locationRecord["Truck"] as? CKReference {
                CloudKitManager.sharedManager.fetchRecordWithID(truckReference.recordID, completion: { (truckRecord, error) in
                    if let truckRecord = truckRecord {
                        let truck = TruckLocation(truckRecord: truckRecord, locationRecord: locationRecord)
                        if let truck = truck {
                            if let view = self.window?.rootViewController as? MapViewController {
                                view.truckLocations.append(truck)
                            }
                        }
                    } else if let error = error {
                        print("Error fetching truck record from subscription \(error.localizedDescription)")
                    }
                })
            } else if let error = error {
                print("Error fetching subscription location - \(error.localizedDescription)")
            }
        }
        
        completionHandler(UIBackgroundFetchResult.NewData)
    }
}

