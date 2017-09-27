//
//  BookingManager.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 3/9/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import CoreData

class BookingManager: NSObject {
    var managedContext = ManagedContext()
    
    //add booking to core data
    func addBooking(doctor: String, clinic: String, date: Date, clinic_ph: String, patient: Patient, status: Bool) {
        let managedObjectContext = managedContext.getManagedObject()
        //add booking to core data here
        let newBooking = NSEntityDescription.insertNewObject(forEntityName: "Booking", into: managedObjectContext) as? Booking
        //configure the new booking
        newBooking?.dateTime = date as NSDate
        newBooking?.clinic_add = clinic
        newBooking?.doctor = doctor
        newBooking?.clinic_ph = clinic_ph.substring(to: clinic_ph.index(clinic_ph.startIndex, offsetBy: 10))
        newBooking?.status = status
        newBooking?.sms = false
        newBooking?.complete = "?"
        
        patient.addToHas(newBooking!)
        
        //Save the ManagedObjectContext
        do {
            //addBookingInFireBase()
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        //set up the sms reminder
        //setupSMSReminder(booking: newBooking!, patient: patient)
        
    }
    
    func getAllClinics() -> [Clinic]{
        let context = managedContext.getManagedObject()
        
        let clinicFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Clinic")
        let sortDescriptor = NSSortDescriptor(key: "address", ascending: true)
        
        clinicFetch.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedResults = try context.fetch(clinicFetch) as? [NSManagedObject]
            if let results = fetchedResults {
                return results as! [Clinic]
            }
        } catch {
            print(error)
        }
        return []
    }
    
    func getAllBookings() -> [Booking] {
        let context = managedContext.getManagedObject()
        
        let bookingFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Booking")
        let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)
        
        bookingFetch.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedResults = try context.fetch(bookingFetch) as? [NSManagedObject]
            if let results = fetchedResults {
                return results as! [Booking]
            }
        } catch {
            print(error)
        }
        return []
    }
    
    func checkBookingIsAvailable(clinic: Clinic, doctor: String, date: String, time: String, slot: Bool) -> Bool {
        let bookings = getAllBookings()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateTimeStr = date.appending(" ").appending(time)
        
        for booking in bookings {
            if (booking.clinic_add! == clinic.address! && booking.doctor! == doctor && dateTimeStr == dateFormatter.string(from: booking.dateTime! as Date) && booking.status == slot) {
                return false
            }
        }
        return true
    }
    
    //Mark: - SMS Reminder
    
    func setupSMSReminder(booking: Booking, patient: Patient) {
        
        let message = self.createMessageContent(booking: booking)
        
        self.scheduleSMS(message: message, patient: patient)
    }
    
    func scheduleSMS(message: String, patient: Patient) {
        let phoneStr = patient.phone
        var todoEndpoint = ""
        if phoneStr?.substring(to: (phoneStr?.index((phoneStr?.startIndex)!, offsetBy: 3))!) == "852" {
            todoEndpoint = "https://api3.hksmspro.com/service/smsapi.asmx/SendSMS?Username=quadrinity&Password=quadrinity&Message=test&Hex=&Telephone=" + "\(patient.phone ?? "")" + "&UserDefineNo=&Sender=&Subject=&Base64Attachments=&Filename=&MessageAt=0"
        } else {
            todoEndpoint = "https://api3.hksmspro.com/service/smsapi.asmx/SendSMS?Username=quadrinity&Password=quadrinity&Message=test&Hex=&Telephone=852" + "\(patient.phone ?? "")" + "&UserDefineNo=&Sender=&Subject=&Base64Attachments=&Filename=&MessageAt=0"
        }
        
        
        let escapedURL = todoEndpoint.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        
        
        guard let url = URL(string: escapedURL!) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        // make the request
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            print(error as Any)
            print(response as Any)
            
            //            let xmlParser = XMLParser()
            
            
        })
        task.resume()
    }
    
    func createMessageContent(booking: Booking) -> String {
        
        let bookingTime = booking.dateTime
        let doctorName = booking.doctor
        let clinicAddress = booking.clinic_add
        let clinicPhone = booking.clinic_ph
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-mm-dd HH:mm"
        
        let message = "你好! 我們是ASA物理治療中心。你的預約詳情如下：預約時間：\(dateFormater.string(from: bookingTime! as Date)) 醫生：\(doctorName ?? "") 診所地址：\(clinicAddress ?? "") 如想更改預約時間或有任何查詢，請電：\(String(describing: clinicPhone!))."
        
        
        NSLog("\(message)")
        return message
    }
    
    func getDateFormatter() -> DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dateFormatter
    }

    func getBookingNameByTimeSlot(clinic: String, doctor: String, dateStr: String, timeStr: String, status: Bool) -> String{
        let bookings = getAllBookings()
        let dateFormatter = getDateFormatter()
        let compareDate = dateStr.appending(" ").appending(timeStr)
        for booking in bookings {
            let date = dateFormatter.string(from: booking.dateTime! as Date)
            if (date == compareDate && booking.clinic_add == clinic && booking.doctor == doctor && booking.status == status) {
            
                return (booking.belongsTo?.name)!
            }
            
        }
        
        return ""
    }
    
    func removeBookingByTimeSlot(clinic: String, doctor: String, dateStr: String, timeStr: String, status: Bool) {
        
        let context = managedContext.getManagedObject()
        
        let bookings = getAllBookings()
        let dateFormatter = getDateFormatter()
        let compareDate = dateStr.appending(" ").appending(timeStr)
        
        for booking in bookings {
            let date = dateFormatter.string(from: booking.dateTime! as Date)
            if (date == compareDate && booking.clinic_add == clinic && booking.doctor == doctor && booking.status == status) {
                
                context.delete(booking as NSManagedObject)
            }
        }
        
        do {
           try context.save()
        } catch {
            NSLog("Delete booking failed")
        }

    }
    
    func updateBookingByStatus(status: String, booking: Booking) {
        let context = managedContext.getManagedObject()
        
        booking.setValue(status, forKey: "complete")
        
        do {
            try context.save()
        } catch {
            NSLog("update booking failed")
        }
    }
}
