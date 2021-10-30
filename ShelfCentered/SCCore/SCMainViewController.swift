//
//  SCMainViewController.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit
import CloudKit

public class SCMainViewController : UITabBarController {
    
    let myDataSource : SCListItemSource
    let sharedDataSource : SCListItemSource
    
    public init(myDataSource : SCListItemSource, sharedDataSource : SCListItemSource) {
        self.myDataSource = myDataSource
        self.sharedDataSource = sharedDataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init() {
        self.init(myDataSource: ArrayListItemSource.getTestMyItemSource(),
        sharedDataSource: ArrayListItemSource.getTestSharedItemSource())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("can't init with coder")
    }
    
    private func fetchUserRecord(recordID: CKRecord.ID) {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch Private Database
        let privateDatabase = defaultContainer.privateCloudDatabase
        
        // Fetch User Record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecord = record {
                print(userRecord)
            }
        }
    }
    
    private func fetchUserRecordID() {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch User Record
        defaultContainer.fetchUserRecordID { (recordID, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecordID = recordID {
                DispatchQueue.main.sync {
                    self.fetchUserRecord(recordID: userRecordID)
                }
            }
        }
    }
    
    public func dataSourcesNeedRefreshed() {
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUserRecordID()
        
        let myBundle = Bundle(for: SCMainViewController.self)
        let cloudImage = UIImage(named: "cloud", in: myBundle, compatibleWith: nil)
        let listImage = UIImage(named: "list", in: myBundle, compatibleWith: nil)

        view.backgroundColor = UIColor.orange
        
        let sharedListsVC = SCListsViewController(listItemSource: sharedDataSource)
        let sharedListsNavC = UINavigationController(rootViewController: sharedListsVC)
        let sharedListsCoordinator = SCNavigationCoordinator(navC: sharedListsNavC)
        sharedListsVC.navCoordinator = sharedListsCoordinator
        sharedListsVC.title = "Shared Lists"
        sharedListsNavC.tabBarItem = UITabBarItem(title: "Shared Lists", image: cloudImage, tag: 0)
        
        let myListsVC = SCListsViewController(listItemSource: myDataSource)
        let myListsNavC = UINavigationController(rootViewController: myListsVC)
        let myListsCoordinator = SCNavigationCoordinator(navC: myListsNavC)
        myListsVC.navCoordinator = myListsCoordinator
        myListsVC.title = "My Lists"
        myListsNavC.tabBarItem = UITabBarItem(title: "My Lists", image: listImage, tag: 1)
        
        viewControllers = [sharedListsNavC, myListsNavC]
    }
}

