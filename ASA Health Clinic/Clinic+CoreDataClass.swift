//
//  Clinic+CoreDataClass.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 19/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Clinic)
public class Clinic: NSManagedObject {
    func addDoctor(_ value: Doctor)
    {
        let doctors = self.mutableSetValue(forKey: "has")
        doctors.add(value)
    }
}
