//
//  BookingContainerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 16/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import CoreData

class BookingContainerViewController: UIViewController, UITableViewDataSource, AddBookingDelegate, UpdateBookingDelegate {
    
    @IBOutlet weak var addBookingButton: UIButton!
    
    var appDelegate: AppDelegate!
    var managedObjectContext: NSManagedObjectContext
    var bookings: NSMutableArray
    
    @IBOutlet weak var bookingTableView: UITableView!
    
    //initializer
    required init?(coder aDecoder: NSCoder) {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        bookings = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
        
        bookingTableView.tableFooterView = UIView()
        bookingTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if detailItem != nil {
            //fetch all bookings in the array
            bookings.addObjects(from: (detailItem?.has?.allObjects)!)
            //sort the array
            let sortDescriptor = NSSortDescriptor (key: "dateTime" , ascending: true)
            bookings.sort(using: [sortDescriptor])
            //enable the add button
            addBookingButton.isEnabled = true
        } else {
            addBookingButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: Patient? {
        didSet {
            // Update the view.
            //configureView()
        }
    }
    // Mark: Delegate Methods
    //Update booking method
    func updateBooking(doctor: String, clinic: String, date: Date, clinic_ph: String, bookingToUpdate: Booking, rowToUpdate: IndexPath) {
        
        bookingToUpdate.setValue(doctor, forKey: "doctor")
        bookingToUpdate.setValue(clinic, forKey: "clinic_add")
        bookingToUpdate.setValue(date as NSDate, forKey: "dateTime")
        bookingToUpdate.setValue(clinic_ph, forKey: "clinic_ph")
        
        //Save the ManagedObjectContext
        do {
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        //set up the sms reminder
        updateSMSReminder()
        configureCell(bookingTableView.cellForRow(at: rowToUpdate) as! BookingTableViewCell, withBooking: bookingToUpdate)
    }
    
    // AddBooking delegate method
    func addBooking(doctor: String, clinic: String, date: Date, clinic_ph: String) {
        //add booking to core data here
        let newBooking = NSEntityDescription.insertNewObject(forEntityName: "Booking", into: managedObjectContext) as? Booking
        //configure the new booking
        newBooking?.dateTime = date as NSDate
        newBooking?.clinic_add = clinic
        newBooking?.doctor = doctor
        newBooking?.clinic_ph = clinic_ph.substring(to: clinic_ph.index(clinic_ph.startIndex, offsetBy: 10))
        newBooking?.status = false
        newBooking?.sms = false
        
        self.detailItem?.addToHas(newBooking!)
        
        //Save the ManagedObjectContext
        do {
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        //set up the sms reminder
        setupSMSReminder()
        
        //add booking to table view
        bookings.add(newBooking!)
        let indexPath = IndexPath(row: bookings.count - 1, section: 1)
        bookingTableView.insertRows(at: [indexPath], with: .fade)
    }
    
//    func getCellIndexPaths() -> [IndexPath] {
//        return (0..<bookingTableView.numberOfRows(inSection: 1)).map{IndexPath(row: $0, section: 1)}
//    }
    
    // Mark: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBookingSegue" {
                
            let destinationVC: AddBookingViewController = segue.destination as! AddBookingViewController
            destinationVC.delegate = self
        } else if segue.identifier == "editBookingSegue" {
            let destinationVC: UpdateBookingDetailViewController = segue.destination as! UpdateBookingDetailViewController
            destinationVC.delegate = self
            if let indexPath = bookingTableView.indexPathForSelectedRow {
                destinationVC.currentBooking = bookings.object(at: indexPath.row) as? Booking
                destinationVC.selectedRow = indexPath
            }
            
        }
    }
    
    // Mark: - Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if detailItem == nil {
                return 0
            } else {
                if detailItem?.has?.count != 0 {
                    
                    return (detailItem?.has?.count)!
                } else {
                    return 0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientBookingCell", for: indexPath) as! BookingTableViewCell
        if indexPath.section == 0 {
            cell.dateLabel.text = "Date"
            cell.doctorLabel.text = "Doctor"
            cell.addressLabel.text = "Clinic"
            cell.StatusLabel.text = "Status"
            return cell
        } else {
            let booking = bookings[indexPath.row]
            configureCell(cell, withBooking: booking as! Booking)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookingToRemove = bookings[indexPath.row]
            managedObjectContext.delete(bookingToRemove as! NSManagedObject)
            do {
                try managedObjectContext.save()
                bookings.remove(bookingToRemove)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: BookingTableViewCell, withBooking booking: Booking) {
        let dateString = (booking.dateTime! as Date).description
        cell.dateLabel.text = dateString.substring(to: dateString.index(dateString.endIndex, offsetBy: -9))
        
        let doctorString = booking.doctor!
        cell.doctorLabel.text = doctorString
        cell.addressLabel.text = booking.clinic_add
        
        if !booking.status {
            cell.StatusLabel.text = "Not Completed"
        } else {
            cell.StatusLabel.text = "Completed"
        }
    }
    
    //Mark: - SMS Reminder
    
    func setupSMSReminder() {
        
    }
    
    func updateSMSReminder() {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
