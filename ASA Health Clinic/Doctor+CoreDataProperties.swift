//
//  Doctor+CoreDataProperties.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 19/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import CoreData


extension Doctor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Doctor> {
        return NSFetchRequest<Doctor>(entityName: "Doctor")
    }

    @NSManaged public var name: String?
    @NSManaged public var belongsTo: Clinic?

}
