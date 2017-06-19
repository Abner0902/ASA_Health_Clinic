//
//  Clinic+CoreDataProperties.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 19/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import CoreData


extension Clinic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Clinic> {
        return NSFetchRequest<Clinic>(entityName: "Clinic")
    }

    @NSManaged public var address: String?
    @NSManaged public var phone: String?

}
