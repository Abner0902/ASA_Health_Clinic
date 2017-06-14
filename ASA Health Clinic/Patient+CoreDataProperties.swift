//
//  Patient+CoreDataProperties.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 13/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import CoreData


extension Patient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patient> {
        return NSFetchRequest<Patient>(entityName: "Patient")
    }

    @NSManaged public var name: String?
    @NSManaged public var phone: String?

}
