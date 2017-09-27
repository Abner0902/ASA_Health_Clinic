//
//  Patient+CoreDataProperties.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 26/9/17.
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
    @NSManaged public var note: String?
    @NSManaged public var has: NSSet?

}

// MARK: Generated accessors for has
extension Patient {

    @objc(addHasObject:)
    @NSManaged public func addToHas(_ value: Booking)

    @objc(removeHasObject:)
    @NSManaged public func removeFromHas(_ value: Booking)

    @objc(addHas:)
    @NSManaged public func addToHas(_ values: NSSet)

    @objc(removeHas:)
    @NSManaged public func removeFromHas(_ values: NSSet)

}
