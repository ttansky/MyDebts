//
//  NSCustomPersistentContainer.swift
//  TodayExtension
//
//  Created by Тарас on 4/17/19.
//  Copyright © 2019 Taras. All rights reserved.
//

import Foundation
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.myDebtsExtension")
        storeURL = storeURL?.appendingPathComponent("MyDebts.sqlite")
        return storeURL!
    }
    
}

