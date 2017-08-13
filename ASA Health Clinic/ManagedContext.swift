//
//  ManagedContext.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 9/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import CoreData

class ManagedContext: NSObject {
    func getManagedObject() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
       
        if #available(iOS 10.0, *) {
            let context = appDelegate.persistentContainer.viewContext
            return context
        } else {
            let context = appDelegate.managedObjectContext
            return context
        }
    }
}
