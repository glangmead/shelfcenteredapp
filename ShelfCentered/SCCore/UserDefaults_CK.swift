//
//  UserDefaults_CK.swift
//  SCCore
//
//  Created by Greg Langmead on 10/7/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import Foundation
import CloudKit

public extension UserDefaults {
    
    public var serverDatabaseChangeToken: CKServerChangeToken? {
        get {
            guard let data = self.value(forKey: "DBChangeToken") as? Data else {
                return nil
            }
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
            } catch {
                return nil
            }
        }
        set {
            if let token = newValue {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false)
                    self.set(data, forKey: "DBChangeToken")
                } catch {
                    // who cares
                }
            } else {
                self.removeObject(forKey: "DBChangeToken")
            }
        }
    }
    public var serverZoneChangeToken: CKServerChangeToken? {
        get {
            guard let data = self.value(forKey: "ZoneChangeToken") as? Data else {
                return nil
            }
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
            } catch {
                return nil
            }
        }
        set {
            if let token = newValue {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false)
                    self.set(data, forKey: "ZoneChangeToken")
                } catch {
                    // who cares
                }
            } else {
                self.removeObject(forKey: "ZoneChangeToken")
            }
        }
    }
}
