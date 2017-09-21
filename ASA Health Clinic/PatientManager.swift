//
//  PatientManager.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 6/9/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import CoreData

class PatientManager: NSObject {
    
    var managedContext = ManagedContext()
    
    //add patient to core data
    func addPatient(name: String, phone: String) {
        let context = managedContext.getManagedObject()
        let newPatient = NSEntityDescription.insertNewObject(forEntityName: "Patient", into: context) as? Patient
        
        newPatient?.name = name
        newPatient?.phone = phone
        
        //Save the ManagedObjectContext
        do {
            //addPatientToFireBase(patient: newPatient!)
            try context.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //fetch all patients
    func getAllPatient() -> [Patient]{
        let context = managedContext.getManagedObject()
        var patients = [Patient]()
        
        let patientFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Patient")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        patientFetch.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedResults = try context.fetch(patientFetch) as? [NSManagedObject]
            if let results = fetchedResults {
                patients = results as! [Patient]
                return patients

            }
        
        } catch {
            print(error)
        }
        
        return [Patient]()
    }
}
