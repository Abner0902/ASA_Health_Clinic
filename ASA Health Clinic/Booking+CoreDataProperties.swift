//
//  Booking+CoreDataProperties.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 26/9/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import CoreData


extension Booking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Booking> {
        return NSFetchRequest<Booking>(entityName: "Booking")
    }

    @NSManaged public var clinic_add: String?
    @NSManaged public var clinic_ph: String?
    @NSManaged public var dateTime: NSDate?
    @NSManaged public var doctor: String?
    @NSManaged public var sms: Bool
    @NSManaged public var status: Bool
    @NSManaged public var complete: String?
    @NSManaged public var belongsTo: Patient?

}
