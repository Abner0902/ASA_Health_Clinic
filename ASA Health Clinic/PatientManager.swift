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
        newPatient?.note = ""
        
        //Save the ManagedObjectContext
        do {
            FireBaseDBManager().insertToPatient(patient: newPatient!)
            try context.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func addPatient(patient: Patient) {
        
        let context = managedContext.getManagedObject()
        var newPatient = NSEntityDescription.insertNewObject(forEntityName: "Patient", into: context) as? Patient
        
        newPatient = patient
        
        do {
            
            try context.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func updatePatient(name: String, phone: String, patientToUpdate: Patient) {
        let context = managedContext.getManagedObject()
        let oldPaitient = patientToUpdate
        patientToUpdate.setValue(name, forKey: "name")
        patientToUpdate.setValue(phone, forKey: "phone")
        
        //Save the ManagedObjectContext
        do {
            //update patient in firebase
            FireBaseDBManager().updatePatient(oldPatient: oldPaitient, newPatient: patientToUpdate)
            try context.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deletePatient(patientToDelete: Patient, context: NSManagedObjectContext) {
        context.delete(patientToDelete)
        
        do {
            
            //delete patient in Firebase
            FireBaseDBManager().deletePatient(patient: patientToDelete)
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
    
    func updatePatientNote(patient: Patient, note: String) {
        let context = ManagedContext().getManagedObject()
        
        patient.setValue(note, forKey: "note")
        
        do {
            FireBaseDBManager().updatePatientNote(patient: patient, note: note)
            try context.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }

    }
    
    func getPatientByName(name: String) -> Patient?{
        let patients = getAllPatient()
        
        for patient in patients {
            if patient.name == name {
                return patient
            }
        }
        
        return nil
    }
    
    func isSamePatient(name: String, phone: String) -> Bool{
        let patient = getPatientByName(name: name)
        
        if patient != nil {
            return true
        } else {
            return false
        }
    }
}
