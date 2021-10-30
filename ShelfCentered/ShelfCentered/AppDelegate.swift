//
//  AppDelegate.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 8/31/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit
import SCCore
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    let window = UIWindow()

    let container = CKContainer.default()
    lazy var privateDB = container.privateCloudDatabase
    lazy var sharedDB = container.sharedCloudDatabase
    var zoneID = CKRecordZone.ID(zoneName: "ShelfCentered", ownerName: CKCurrentUserDefaultName)
    var createdCustomZone = false
    var subscribedToPrivateChanges = false
    var subscribedToSharedChanges = false
    var inFlightDatabaseChangeToken : CKServerChangeToken?
    var inFlightZoneChangeToken : CKServerChangeToken?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCloudKitIfNecessary(application)
        self.window.rootViewController = SCMainViewController(myDataSource: CKListItemSource(db: privateDB, zoneID: self.zoneID, isMe: true), sharedDataSource: CKListItemSource(db: sharedDB, zoneID: self.zoneID, isMe: false))
        self.window.makeKeyAndVisible()
        return true
    }
    
    func setupCloudKitIfNecessary(_ application: UIApplication) {
        // Use a consistent zone ID across the user's devices
        // CKCurrentUserDefaultName specifies the current user's ID when creating a zone ID
        
        createdCustomZone = UserDefaults.standard.bool(forKey: "createdCustomZone")
        subscribedToPrivateChanges = UserDefaults.standard.bool(forKey: "subscribedToPrivateChanges")
        subscribedToSharedChanges = UserDefaults.standard.bool(forKey: "subscribedToSharedChanges")
        
        let privateSubscriptionId = "private-changes"
        let sharedSubscriptionId = "shared-changes"
        
        let createZoneGroup = DispatchGroup()
        
        if !self.createdCustomZone {
            createZoneGroup.enter()
            
            let customZone = CKRecordZone(zoneID: zoneID)
            
            let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [] )
            
            createZoneOperation.modifyRecordZonesCompletionBlock = { (saved, deleted, error) in
                if (error == nil) { self.createdCustomZone = true }
                // else custom error handling
                createZoneGroup.leave()
            }
            createZoneOperation.qualityOfService = .userInitiated
            
            privateDB.add(createZoneOperation)
        }
        
        if !subscribedToPrivateChanges {
            let createSubscriptionOperation = self.createDatabaseSubscriptionOperation(subscriptionId: privateSubscriptionId)
            createSubscriptionOperation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIds, error) in
                if error == nil { self.subscribedToPrivateChanges = true }
                // else custom error handling
            }
            self.privateDB.add(createSubscriptionOperation)
        }
        
        if !subscribedToSharedChanges {
            let createSubscriptionOperation = self.createDatabaseSubscriptionOperation(subscriptionId: sharedSubscriptionId)
            createSubscriptionOperation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIds, error) in
                if error == nil { self.subscribedToSharedChanges = true }
                // else custom error handling
            }
            self.sharedDB.add(createSubscriptionOperation)
        }
        
        // Fetch any changes from the server that happened while the app wasn't running
        createZoneGroup.notify(queue: DispatchQueue.global()) {
            if self.createdCustomZone {
                self.fetchChanges(in: .private) {}
                self.fetchChanges(in: .shared) {}
            }
        }
        
        application.registerForRemoteNotifications()
    }
    
    func createDatabaseSubscriptionOperation(subscriptionId: String) -> CKModifySubscriptionsOperation {
        let subscription = CKDatabaseSubscription.init(subscriptionID: subscriptionId)
        let notificationInfo = CKSubscription.NotificationInfo()
        // send a silent notification
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.qualityOfService = .utility
        return operation
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received notification!")
        let dict = userInfo as! [String: NSObject]
        guard let notification:CKDatabaseNotification = CKNotification(fromRemoteNotificationDictionary:dict) as? CKDatabaseNotification else { return }
        self.fetchChanges(in: notification.databaseScope) {
            completionHandler(.newData)
        }
    }
    
    func fetchChanges(in databaseScope: CKDatabase.Scope, completion: @escaping () -> Void) {
        switch databaseScope {
        case .private:
            fetchDatabaseChanges(database: self.privateDB, databaseTokenKey: "private", completion: completion)
        case .shared:
            fetchDatabaseChanges(database: self.sharedDB, databaseTokenKey: "shared", completion: completion)
        case .public:
            fatalError()
        }
    }
    
    func fetchDatabaseChanges(database: CKDatabase, databaseTokenKey: String, completion: @escaping () -> Void) {
        var changedZoneIDs: [CKRecordZone.ID] = []
        
        let changeToken = UserDefaults.standard.serverDatabaseChangeToken
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: changeToken)
        operation.fetchAllChanges = true
        operation.recordZoneWithIDChangedBlock = { (zoneID) in
            changedZoneIDs.append(zoneID)
        }
        
        operation.recordZoneWithIDWasDeletedBlock = { (zoneID) in
            // Write this zone deletion to memory
        }
        
        operation.changeTokenUpdatedBlock = { (token) in
            // Flush zone deletions for this database to disk
            self.inFlightDatabaseChangeToken = token
        }
        
        operation.fetchDatabaseChangesCompletionBlock = { (token, moreComing, error) in
            if let error = error {
                print("Error during fetch shared database changes operation", error)
                completion()
                return
            }
            // Flush zone deletions for this database to disk
            self.inFlightDatabaseChangeToken = token
            
            self.fetchZoneChanges(database: database, databaseTokenKey: databaseTokenKey, zoneIDs: changedZoneIDs) {
                UserDefaults.standard.serverDatabaseChangeToken = self.inFlightDatabaseChangeToken
                self.inFlightDatabaseChangeToken = nil
                completion()
            }
        }
        operation.qualityOfService = .userInitiated
        
        database.add(operation)
    }
    
    func fetchZoneChanges(database: CKDatabase, databaseTokenKey: String, zoneIDs: [CKRecordZone.ID], completion: @escaping () -> Void) {
        if (!zoneIDs.isEmpty) {
            // Look up the previous change token for each zone
            var optionsByRecordZoneID = [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneOptions]()
            for zoneID in zoneIDs {
                let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
                options.previousServerChangeToken = UserDefaults.standard.serverZoneChangeToken
                optionsByRecordZoneID[zoneID] = options
            }
            let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneIDs, optionsByRecordZoneID: optionsByRecordZoneID)
            operation.fetchAllChanges = true
            operation.recordChangedBlock = { (record) in
                print("Record changed:", record)
                // Write this record change to memory
            }
            
            operation.recordWithIDWasDeletedBlock = { (recordId, recordType) in
                print("Record deleted:", recordId)
                // Write this record deletion to memory
            }
            
            operation.recordZoneChangeTokensUpdatedBlock = { (zoneId, token, data) in
                // Flush record changes and deletions for this zone to disk
                UserDefaults.standard.serverZoneChangeToken = token
            }
            
            operation.recordZoneFetchCompletionBlock = { (zoneId, changeToken, _, _, error) in
                if let error = error {
                    print("Error fetching zone changes for \(databaseTokenKey) database:", error)
                    return
                }
                // Flush record changes and deletions for this zone to disk
                UserDefaults.standard.serverZoneChangeToken = changeToken
            }
            
            operation.fetchRecordZoneChangesCompletionBlock = { (error) in
                if let error = error {
                    print("Error fetching zone changes for \(databaseTokenKey) database:", error)
                }
                completion()
            }
            
            database.add(operation)
        }
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        let acceptSharing: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        
        acceptSharing.qualityOfService = .userInteractive
        acceptSharing.perShareCompletionBlock = {meta, share, error in
            print("successfully shared")
        }
        acceptSharing.acceptSharesCompletionBlock = {
            error in
            guard (error == nil) else{
                print("Error \(error?.localizedDescription ?? "")")
                return
            }
            
//            let viewController: AddItemViewController =
//                self.window?.rootViewController as! AddItemViewController
//            viewController.fetchShare(cloudKitShareMetadata)
            
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptSharing)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

}

