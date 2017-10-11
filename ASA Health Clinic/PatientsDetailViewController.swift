//
//  DetailViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 31/5/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import Eureka

class PatientsDetailViewController: FormViewController {

//    @IBOutlet var patientDetailContainer: UIView!
//    
//    @IBOutlet var patientBookingContainer: UIView!
//
//    @IBOutlet var segmentControl: UISegmentedControl!
    
    let bookingManager = BookingManager()
    let patientManager = PatientManager()
    
    let UPCOMING_BOOKING_STR = "Upcoming Booking"
    let COMPLETE_SIGN = "√"
    let INCOMPLETE_SIGN = "X"
    let DEFAULT = "?"

    var bookings = [Booking]()
    var upcomingBooking: Booking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //patientBookingContainer.isHidden = true
        //configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Patient? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        
        bookings = self.patientManager.getPatientByName(name: (detailItem?.name)!)?.has?.allObjects as! [Booking]
        
        bookings.sort{ (b1, b2) -> Bool in
            return b1.dateTime?.compare(b2.dateTime! as Date) == .orderedAscending
        }
        
        form +++ Section()
            <<< LabelRow() { row in
                row.title = "Name: "
                row.value = detailItem?.name
                
                }.cellUpdate { cell, row in
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            <<< LabelRow() { row in
                row.title = "Phone: "
                row.value = detailItem?.phone
                }.cellUpdate { cell, row in
                    cell.detailTextLabel?.textColor = UIColor.black
                    
                }
        
        
            
        var text: String = "No Booking upcoming"
        if bookings.count != 0 && self.getUpcomingBooking(){
            
            text = bookingManager.getDateFormatter().string(from: upcomingBooking!.dateTime! as Date)
                form +++ Section(UPCOMING_BOOKING_STR)

                <<< CustomRow() { row in
                    row.cell.bookingDateButton.setTitle(text, for: .normal)
                    
                    row.cell.statusButton.setTitle(upcomingBooking?.complete!, for: .normal)
                    
                    row.cell.choiceOne.isHidden = true
                    row.cell.choiceTwo.isHidden = true
                    row.tag = UPCOMING_BOOKING_STR
                    
                    row.cell.booking = upcomingBooking
                }
        } else {
            form +++ Section(UPCOMING_BOOKING_STR)
            
                <<< LabelRow() {
                    $0.title = text
                    $0.tag = UPCOMING_BOOKING_STR
                }
        }
    
        form +++ Section("History")
            
            for booking in bookings {
                form.last! <<< CustomRow() { row in
                    
                }.cellSetup{cell, row in
                    row.cell.bookingDateButton.setTitle(self.bookingManager.getDateFormatter().string(from: booking.dateTime! as Date), for: .normal)
                    row.cell.statusButton.setTitle(booking.complete!, for: .normal)
                    
                    row.cell.choiceOne.isHidden = true
                    row.cell.choiceTwo.isHidden = true
                    row.cell.bookingDateButton.isEnabled = false
                    row.cell.statusButton.isEnabled = false
                }
            }
        
        
        
        form +++ Section("Note")
            <<< TextAreaRow() {
                $0.placeholder = "Additional note"
                $0.value = detailItem?.note
            }.onCellHighlightChanged { cell, row in
                self.patientManager.updatePatientNote(patient: self.detailItem!, note: row.value!)
        }
    }

//    @IBAction func indexSelected(_ sender: Any) {
//        switch segmentControl.selectedSegmentIndex
//        {
//        case 0:
//            patientDetailContainer.isHidden = false
//            patientBookingContainer.isHidden = true
//        case 1:
//            patientDetailContainer.isHidden = true
//            patientBookingContainer.isHidden = false
//        default:
//            break; 
//        }
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller
//        if segue.identifier == "patientDetailSegue" {
//            // Pass the selected object to the new view controller.
//            let controller: DetailContainerViewController = segue.destination as! DetailContainerViewController
//            controller.detailItem = self.detailItem
//            
//        } else if segue.identifier == "patientBookingSegue" {
//            //pass patient information to patient booking container view if needed
//            // Pass the selected object to the new view controller.
//            let controller: BookingContainerViewController = segue.destination as! BookingContainerViewController
//            controller.detailItem = self.detailItem
//
//        }
    }
    
    func addObservers() {
        let observerKeyLocation = "pickedConuntry"
        self.addObserver(self, forKeyPath: observerKeyLocation, options: .new, context: nil)
    }
    
    func getUpcomingBooking() -> Bool{
        let currentDate = Date()
        
        for booking in bookings {
            if (booking.dateTime! as Date) > currentDate {
                
                NSLog("\(booking)")
                
                upcomingBooking = booking
                
                return true
            }
        }
        
        return false
    }
}

