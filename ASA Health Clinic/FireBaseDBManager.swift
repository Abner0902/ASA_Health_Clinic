//
//  FireBaseDBManager.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 3/10/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import CoreData

class FireBaseDBManager: NSObject {
    
    let typeConverter = TypeConverter()
    
    let ref = Database.database().reference()
    let patientRef = Database.database().reference(withPath: "patients")
    let clinicRef = Database.database().reference(withPath: "clinics")

    //test pass
    func insertToPatient(patient: Patient) {
        
        let patientItemRef = patientRef.child(patient.name!.lowercased())
        
        var patientDic = [String : AnyObject]()
        
        patientDic["name"] = patient.name as AnyObject
        patientDic["phone"] = patient.phone as AnyObject
        patientDic["note"] = patient.note as AnyObject
        
        patientItemRef.setValue(patientDic)
    }
    
    //test pass
    func updatePatient(oldPatient: Patient, newPatient: Patient){
        //get the old node and replace it with the new one
        let patientItem = getPatientItemRef(name: oldPatient.name!).key
        
        let childUpdates = ["/patients/\(patientItem)/name": newPatient.name!, "/patients/\(patientItem)/phone": newPatient.phone!]
        ref.updateChildValues(childUpdates)
    }
    
    func getPatientItemRef(name: String) -> DatabaseReference{
        return patientRef.child(name.lowercased())
    }
    
    //test pass
    func updatePatientNote(patient: Patient, note: String) {
        let patientNoteItem = getPatientItemRef(name: patient.name!).child("note")
        
        patientNoteItem.setValue(note)
    }
    
    //test pass
    func deletePatient(patient: Patient) {
        let patientItemRef = getPatientItemRef(name: patient.name!)
        patientItemRef.removeValue()
    }
    
    //read patient from firebase only the first time launched
    func getAllPatient(completion: @escaping () -> ()) {
        
        let context = ManagedContext().getManagedObject()
        
        //let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //NSLog("\(path)")
        
        patientRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if (snapshot.value == nil) {
                NSLog("No result found")
            } else {
                for child in (snapshot.children) {
                    
                    let newPatient = NSEntityDescription.insertNewObject(forEntityName: "Patient", into: context) as? Patient

                    let snap = child as! DataSnapshot
                    
                    newPatient?.name = (snap.childSnapshot(forPath: "name").value) as? String
                    newPatient?.phone = (snap.childSnapshot(forPath: "phone").value) as? String
                    newPatient?.note = (snap.childSnapshot(forPath: "note").value) as? String

                    let bookingSnap = (snap.childSnapshot(forPath: "bookings"))
                    
                    if (bookingSnap.value != nil) {
                        for child in (bookingSnap.children) {
                            
                            let newBooking = NSEntityDescription.insertNewObject(forEntityName: "Booking", into: context) as? Booking
                            
                            let snap = child as! DataSnapshot
                            newBooking?.clinic_add = (snap.childSnapshot(forPath: "clinic_add").value) as? String
                            newBooking?.clinic_ph = (snap.childSnapshot(forPath: "clinic_ph").value) as? String
                            newBooking?.complete = (snap.childSnapshot(forPath: "complete").value) as? String
                            
                            newBooking?.doctor = (snap.childSnapshot(forPath: "doctor").value) as? String
                            let sms = (snap.childSnapshot(forPath: "sms").value) as? Int
                            let status = (snap.childSnapshot(forPath: "status").value) as? Int
                            let dateTime = (snap.childSnapshot(forPath: "date_time").value) as? String
                            
                            newBooking?.dateTime = TypeConverter().stringToDate(str: dateTime!) as NSDate
                            
                            if sms == 0 {
                                newBooking?.sms = false
                            } else {
                                newBooking?.sms = true
                            }
                            
                            if status == 0 {
                                newBooking?.status = false
                            } else {
                                newBooking?.status = true
                            }
                            
                            newPatient?.addToHas(newBooking!)
                            
                            do {
                                try context.save()
                                completion()
                                
                            } catch let error as NSError {
                                print("Could not save \(error), \(error.userInfo)")
                            }
                        }
                        
                    }
                    
                    
                    
                    //patient.name = patientDct?.value(forKey: "name") as? String
                    //NSLog("Patients: \(String(describing: patient.name!))")
                }
            }
            
            
            
        })
        
        
    }
    
    //test pass
    //add booking to patient
    func addBookingToPatient(patient: Patient, booking: Booking) {
        
        let bookingItemRef = getBookingItemRef(patient: patient, booking: booking)
        
        var bookingDic = [String: AnyObject]()
        
        bookingDic["clinic_add"] = booking.clinic_add as AnyObject
        bookingDic["clinic_ph"] = booking.clinic_ph as AnyObject
        bookingDic["complete"] = booking.complete as AnyObject
        bookingDic["date_time"] = typeConverter.dateToString(date:booking.dateTime! as Date) as AnyObject
        bookingDic["doctor"] = booking.doctor as AnyObject
        
        if booking.sms == false {
             bookingDic["sms"] = 0 as AnyObject
        } else {
            bookingDic["sms"] = 1 as AnyObject
        }
        
        if booking.status == false {
            bookingDic["status"] = 0 as AnyObject
        } else {
            bookingDic["status"] = 1 as AnyObject
        }
        //bookingDic["sms"] = booking.sms as AnyObject
        //bookingDic["status"] = booking.clinic_add as AnyObject
        
        bookingItemRef.setValue(bookingDic)
    }
    
    func getBookingItemRef(patient: Patient, booking: Booking) -> DatabaseReference{
        let bookingItemName = typeConverter.dateToString(date:booking.dateTime! as Date).replacingOccurrences(of: "/", with: "-")
        
        let bookingItemRef = patientRef.child(patient.name!.lowercased()).child("bookings").child(bookingItemName)
        
        return bookingItemRef
    }
    
    //test pass
    //update booking complete
    func updateBookingComplete(status: String, forBooking booking: Booking) {
        let bookingItemRef = getBookingItemRef(patient: booking.belongsTo!, booking: booking)
        
        let bookingCompleteRef = bookingItemRef.child("complete")
        
        bookingCompleteRef.setValue(booking.complete)
    }
    
    //test pass
    //delete booking
    func deleteBooking(booking: Booking) {
        let bookingItemRef = getBookingItemRef(patient: booking.belongsTo!, booking: booking)
        
        bookingItemRef.removeValue()
    }
    
    //read booking
    
    func insertClinic(clinic: Clinic) {
        
    }
    
    //read clinics from firebase
    
    
    
    
}
