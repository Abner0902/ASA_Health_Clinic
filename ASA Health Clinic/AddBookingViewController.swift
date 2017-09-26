//
//  BookingContainerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 16/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import Eureka
import CoreData

protocol AddBookingDelegate {
    func addBooking(doctor: String, clinic: String, date: Date, clinic_ph: String)
}

class AddBookingViewController: FormViewController{
    
    var delegate: AddBookingDelegate?
    
    var clinics: [Clinic] = []
    var filteredDoctors: [Doctor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //create the input form
        form
            
        +++ SelectableSection<ListCheckRow<String>>("Clinic", selectionType: .singleSelection(enableDeselection: true))
    
        clinics = BookingManager().getAllClinics()
        for option in clinics {
            form.last! <<< ListCheckRow<String>(option.address){ listRow in
                listRow.title = option.address
                listRow.tag = option.phone! + option.address!
                listRow.selectableValue = option.address
                listRow.value = nil
                listRow.cell.textLabel?.numberOfLines = 0
            }
        }
        
        form +++ SelectableSection<ListCheckRow<String>>("Doctor", selectionType: .singleSelection(enableDeselection: true))
        
        form +++ Section("Date and Time")
        
        <<< DateTimeRow("Booking Date") {
            $0.title = "Booking Date"
            $0.tag = "Booking Date"
            $0.minimumDate = Date()
            $0.minuteInterval = 15
            $0.value = Date()
            $0.dateFormatter?.dateFormat = "dd/MM/yyyy HH:mm"
        }
        
        form +++ Section()
        
        <<< ButtonRow() {
                
            $0.title = "Cancel"
            $0.tag = "cancel"
            
            } .onCellSelection() { cell, row in
                self.dismiss(animated: true) { () -> Void in
                    NSLog("Cancel clicked")
                    
                }
        }

        
        form +++ Section()
            
        <<< ButtonRow() {
                
            $0.title = "Done"
            $0.tag = "done"
                
        } .onCellSelection() { cell, row in
            let alert = Alert()
            
            // pass all selected value to the booking container view
            let clinic = (self.form[0] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue
            let clinic_ph = (self.form[0] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.tag
            
            if clinic != nil {
                let doctor = (self.form[1] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue
                
                if doctor != nil {
                    let date = self.form.rowBy(tag: "Booking Date")?.baseValue
                    self.dismiss(animated: true) { () -> Void in
                        NSLog("Done clicked")
                        self.delegate?.addBooking(doctor: doctor as! String, clinic: clinic as! String, date: date as! Date, clinic_ph: clinic_ph!)
                    }
                } else {
                   alert.showAlert(msg: "Field Required!", view: self)
                }
            } else {
                alert.showAlert(msg: "Field Required!", view: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        if row.section === form[0] {
            filteredDoctors.removeAll()
            form[1].removeAll()
            //get the selected clinic
            let selectedClinic = (row.section as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue
            
            self.fetchDoctors(selectedClinic: selectedClinic ?? "")
                
            if filteredDoctors.count != 0 {
                for option in filteredDoctors {
                    form[1] <<< ListCheckRow<String>(option.name){ listRow in
                        listRow.title = option.name
                        listRow.selectableValue = option.name
                        listRow.value = nil
                    }
                }
            }
        }
    }

    func fetchDoctors(selectedClinic: Any) {
        let context = ManagedContext().getManagedObject()
        
        let doctorFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Doctor")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        doctorFetch.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedResults = try context.fetch(doctorFetch) as? [NSManagedObject]
            if let results = fetchedResults {

                for doctor in (results as! [Doctor] ){
                    if doctor.belongsTo?.address == selectedClinic as? String {
                        filteredDoctors.append(doctor)
                    }
                }
                
            }
        } catch {
            print(error)
        }
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
