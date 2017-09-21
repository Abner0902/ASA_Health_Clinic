//
//  OverviewTableViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 17/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import CoreData
import SearchTextField

class OverviewTableViewController: UITableViewController, SetDateDelegate, SetDoctorDelegate, UITextFieldDelegate, AddPatientDelegate {
    
    var timeSlots = [String]()
    
    var dateStr: String?
    var doctorStr: String?
    
    //detect date is selected or not
    var dateSelected = false
    //detect doctor is selected or not
    var doctorSelected = false
    
    //patient list
    var patients = [String]()
    
    var patientToAdd: String?
    
    var currentTextField: UITextField = UITextField()

    @IBOutlet var overviewTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        dateStr = dateFormatter.string(from: Date())
        
        overviewTable.tableFooterView = UIView()
        
        self.loadTimeSlots()
        self.setDoctor()
        
        self.loadPatient()
        
        
        self.overviewTable.contentInset = UIEdgeInsetsMake(0, 0, 120, 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        patients.removeAll()
//        self.loadPatient()
//        
//        for textField in self.view.subviews where textField is UITextField {
//            textField.resignFirstResponder()
//            textField.endEditing(true)
//        }
//        
//    }
    
    func loadTimeSlots() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        var date = dateFormatter.date(from: "09:00")
        
        timeSlots.append("09:00")
        repeat {
            date = date?.addingTimeInterval(60*15)
            timeSlots.append(dateFormatter.string(from: date!))
        } while timeSlots[timeSlots.count - 1] != "18:00"

    }
    
    //fetch patients
    func loadPatient() {
        
        let patientManager = PatientManager()
        
        for patient in patientManager.getAllPatient() {

            patients.append(patient.name!)

        }
    }
    
    func setDoctor() {
        doctorStr = "Andy Kwok"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text field methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print("TextField did begin editing method called")
        
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("TextField did end editing method called\(String(describing: textField.text))")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        print("TextField should begin editing method called")
        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        print("TextField should clear method called")
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("TextField should end editing method called")
        textField.resignFirstResponder()
        
        //add patient if the name is not in patient list
        //call add patient form
        let bookingName = textField.text
        
        if !checkPatientName(name: bookingName!) && bookingName != nil && bookingName?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            //show add patient form
            patientToAdd = bookingName
            performSegue(withIdentifier: "addPatientSegueForOverview", sender: self)
            
            
            //add booking after adding the patient
        } else if checkPatientName(name: bookingName!) {
            //add booking for exist patient
            
        }
        
        return true;
    }
    
    func checkPatientName(name: String) -> Bool{
        for patient in patients {
            if patient.lowercased() == name.lowercased() {
                return true
            }
        }
        
        return false
    }
    
    func addPatient(name: String, phone: String) {
        
        //create patient manager to add patient
        let patientManager: PatientManager = PatientManager()
        
        patientManager.addPatient(name: name, phone: phone)
        
        //currentTextField.resignFirstResponder()
        
        patients.removeAll()
        self.loadPatient()
        
        NSLog("Overview controller: addPatient called, \(name), \(phone)")
        self.view.endEditing(true)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true;
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        print("TextField should return method called")
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
            textField.endEditing(true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
            return timeSlots.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Configure the cell...
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! DateTableViewCell
            
            //can be rewrite to configureCell
            cell.dateButton.setTitle(dateStr, for: .normal)
            cell.doctorButton.setTitle(doctorStr, for: .normal)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! TimeSlotTableViewCell
            
            //can be rewrite to configureCell
            cell.timeLabel.text = timeSlots[indexPath.row]
            
            //set cleat button mode
            cell.bookingOneText.clearButtonMode = .whileEditing
            cell.bookingTwoText.clearButtonMode = .whileEditing
            
            //set auto complete text
            cell.bookingOneText.filterStrings(patients)
            cell.bookingTwoText.filterStrings(patients)
//            cell.bookingOneText.inlineMode = true
//            cell.bookingTwoText.inlineMode = true
            
            cell.bookingOneText.delegate = self
            cell.bookingTwoText.delegate = self
            self.loadBooking(cell: cell)
            return cell
        }
    }
    
    func loadBooking(cell: UITableViewCell) {
        if doctorSelected && dateSelected {
            
        } else if doctorSelected && !dateSelected{
            
        } else if !doctorSelected && dateSelected {
            
        } else {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 30
        } else {
            return 90
        }
    }
    
    func selectDate(_ sender:UIButton!) {
        self.performSegue(withIdentifier: "selectDateSegue", sender: sender)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectDateSegue") {
            let destination = segue.destination as? DatePickerViewController
            
            if let popoverPresentationController = segue.destination.popoverPresentationController{
                popoverPresentationController.sourceRect = CGRect(x: 150, y: -220, width: 368, height: 280)
            }

            if let button:UIButton = sender as! UIButton? {
                print(button.tag) //optional
                destination?.delegate = self
            }
        } else if (segue.identifier == "selectDoctorSegue") {
            let destination = segue .destination as? DoctorPickerViewController
            
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                popoverPresentationController.sourceRect = CGRect(x: 470, y: -125, width: 368, height: 180)
            }
            
            if let button: UIButton = sender as! UIButton? {
                print(button.tag) //optional
                destination?.delegate = self
            }
        } else if (segue.identifier == "addPatientSegueForOverview") {
            let destination = segue .destination as? AddPatientViewController
            destination?.delegate = self
            destination?.patientName = patientToAdd
        }
    }
    
    func setDate(date: String) {
        self.dateStr = date
        overviewTable.reloadData()
    }
    
    func setDoctor(doctor: String) {
        self.doctorStr = doctor
        overviewTable.reloadData()
    }
}
