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

class OverviewTableViewController: UITableViewController, SetDateDelegate, SetDoctorDelegate, UITextFieldDelegate, AddPatientDelegate, CancelAddPatientDelegate {
    
    var patientToView: Patient?
    
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
    var currentInfoButton: UIButton = UIButton()
    
    let bookingManager: BookingManager = BookingManager()
    
    var clinics = [Clinic]()
    
    let converter = TypeConverter()

    @IBOutlet var overviewTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.appFirstLaunchSetup()

        //dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        dateStr = converter.dateToStringIncludingWeekday(date: Date())
        
        overviewTable.tableFooterView = UIView()
        
        self.loadTimeSlots()
        self.setDoctor()
        
        self.loadPatient()
        NSLog("Patient count: \(patients.count)")
        clinics = bookingManager.getAllClinics()
        
        
        self.overviewTable.contentInset = UIEdgeInsetsMake(0, 0, 120, 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        
//        dateStr = dateFormatter.string(from: Date())
        patients.removeAll()
        self.loadPatient()
        view.endEditing(true)
    }
    
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
        
        var row = (Double)(currentTextField.tag) / 10
        row.round()
        let slot = (currentTextField.tag) % 10
        let indexPath = IndexPath(row: Int(row), section: 1)
        if slot == 1 {
            currentInfoButton = (overviewTable.cellForRow(at: indexPath) as! TimeSlotTableViewCell).infoButtonOne
        } else {
            currentInfoButton = (overviewTable.cellForRow(at: indexPath) as! TimeSlotTableViewCell).infoButtonTwo
        }
        
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
        
        let index = dateStr?.index((dateStr?.endIndex)!, offsetBy: -3)
        
        //add patient if the name is not in patient list
        //call add patient form
        
        let bookingName = textField.text
        
        var row = (Double)(currentTextField.tag) / 10
        row.round()
        let time = timeSlots[Int(row)]
        
        let slot = (currentTextField.tag) % 10
        
        let status: Bool
        
        if slot == 1 {
            status = false
        } else {
            status = true
        }
        
        if bookingManager.checkBookingIsAvailable(clinic: clinics[0], doctor: doctorStr!, date: (dateStr?.substring(to: index!).trimmingCharacters(in: .whitespaces))!, time: time, slot: status) {
            if bookingName != nil && bookingName?.trimmingCharacters(in: .whitespacesAndNewlines) != ""  {
                if !checkPatientName(name: bookingName!) {
                    //show add patient form
                    patientToAdd = bookingName
                    performSegue(withIdentifier: "addPatientSegueForOverview", sender: self)
                } else {
                    var status = false
                    if slot == 2 {
                        status = true
                    } else {
                        status = false
                    }
                    
                    bookingManager.addBooking(doctor: doctorStr!, clinic: clinics[0].address!, date: converter.stringToDate(str:(dateStr?.substring(to: index!).appending(time))!), clinic_ph: clinics[0].phone!, patient: PatientManager().getPatientByName(name: bookingName!)!, status: status)
                    
                    //the patient can be more than one
                    NSLog("Add booking executed")
                    currentInfoButton.isHidden = false
                }
            }
        } else {
            
            if bookingName == bookingManager.getBookingNameByTimeSlot(clinic: clinics[0].address!, doctor: doctorStr!, dateStr: (dateStr?.substring(to: index!).trimmingCharacters(in: .whitespaces))!, timeStr: time, status: status) {
                textField.resignFirstResponder()
                
                return true
            }
            
            //show dialogue to update current one if cancel update than restore the original one
            NSLog("Booking time slot is not available")
            
            let msg = "Do you want to change current booking?"
            
            let alertController = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                NSLog("Alert yes clicked")
                
                //remove current one and add new one
                
                self.bookingManager.removeBookingByTimeSlot(clinic: self.clinics[0].address!, doctor: self.doctorStr!, dateStr: (self.dateStr?.substring(to: index!).trimmingCharacters(in: .whitespaces))!, timeStr: time, status: status)
                
                if bookingName != nil && bookingName?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    self.bookingManager.addBooking(doctor: self.doctorStr!, clinic: self.clinics[0].address!, date: self.converter.stringToDate(str: (self.dateStr?.substring(to: index!).appending(time))!), clinic_ph: self.clinics[0].phone!, patient: PatientManager().getPatientByName(name: bookingName!)!, status: status)
                } else {
                    self.currentInfoButton.isHidden = true
                }
                
                textField.resignFirstResponder()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                
                textField.text = self.bookingManager.getBookingNameByTimeSlot(clinic: self.clinics[0].address!, doctor: self.doctorStr!, dateStr: (self.dateStr?.substring(to: index!).trimmingCharacters(in: .whitespaces))!, timeStr: time, status: status)
                
                textField.resignFirstResponder()
                
                self.dismiss(animated: true) { () -> Void in
                    NSLog("Alert Cancel clicked")
                    
                    
                }
            }
            
            alertController.addAction(yesAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        return true
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
            let screenWidth = self.getScreenSize()
            
            //NSLog("Screen width: \(screenWidth)")
            for subview in cell.subviews as [UIView] {
                for constraint in subview.constraints as [NSLayoutConstraint] {
                    if constraint.identifier == "constraintsForDateButton" {
                        
                        if screenWidth == 1366.0 {
                            constraint.constant = 535
                        } else if screenWidth == 1024.0 {
                            constraint.constant = 365
                        }
                        
                    }
                }
            }
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
            
            cell.bookingOneText.tag = (indexPath.row) * 10 + 1
            cell.bookingTwoText.tag = (indexPath.row) * 10 + 2
            
            //need to pass clinic address to check
            self.loadBooking(cell: cell)
            
            cell.infoButtonOne.tag = indexPath.row
            cell.infoButtonTwo.tag = indexPath.row
            
            cell.infoButtonOne.addTarget(self, action: #selector(infoButtonOneClicked(sender:)), for: .touchUpInside)
            cell.infoButtonTwo.addTarget(self, action: #selector(infoButtonTwoClicked(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    func loadBooking(cell: TimeSlotTableViewCell) {
        let index = dateStr?.index((dateStr?.endIndex)!, offsetBy: -3)
        cell.bookingOneText.text = ""
        cell.bookingTwoText.text = ""
        let bookingManager: BookingManager = BookingManager()
        
        let bookings = bookingManager.getAllBookings()

        for booking in bookings {
            //need to check clinic address
            if(booking.doctor == doctorStr) {
                let comparingStr = dateStr?.substring(to: index!).appending(cell.timeLabel.text!)
                if (bookingManager.getDateFormatter().string(from: booking.dateTime! as Date) == comparingStr){
                    if (booking.status == false){
                        cell.bookingOneText.text = booking.belongsTo?.name
                        cell.infoButtonOne.isHidden = false
                        cell.infoButtonTwo.isHidden = true
                        NSLog("booking cell set executed")
                    } else {
                        cell.bookingTwoText.text = booking.belongsTo?.name
                        cell.infoButtonTwo.isHidden = false
                        cell.infoButtonOne.isHidden = true
                    }
                    
                    return
                }
            }
        }
        
        cell.infoButtonOne.isHidden = true
        cell.infoButtonTwo.isHidden = true
    }
    
    func infoButtonOneClicked(sender: UIButton) {
        let touchPoint = sender.convert(CGPoint.zero, to: self.overviewTable)
        
        let clickedButtonIndexPath = overviewTable.indexPathForRow(at: touchPoint)
        
        let cell = overviewTable.cellForRow(at: clickedButtonIndexPath!) as! TimeSlotTableViewCell
        
        self.patientToView = PatientManager().getPatientByName(name: cell.bookingOneText.text!)
        
        tabBarController?.selectedIndex = 0
    }
    
    func infoButtonTwoClicked(sender: UIButton) {
        let touchPoint = sender.convert(CGPoint.zero, to: self.overviewTable)
        
        let clickedButtonIndexPath = overviewTable.indexPathForRow(at: touchPoint)
        
        let cell = overviewTable.cellForRow(at: clickedButtonIndexPath!) as! TimeSlotTableViewCell
        
        self.patientToView = PatientManager().getPatientByName(name: cell.bookingTwoText.text!)
        
        tabBarController?.selectedIndex = 0
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 30
        } else {
            return 80
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
        
        let screenWidth = getScreenSize()
        
        if(segue.identifier == "selectDateSegue") {
            let destination = segue.destination as? DatePickerViewController
            
            
            
            if let popoverPresentationController = segue.destination.popoverPresentationController{
                
                if screenWidth == 1366.0 {
                    popoverPresentationController.sourceRect = CGRect(x: 425, y: -220, width: 368, height: 280)
                } else {
                    popoverPresentationController.sourceRect = CGRect(x: 260, y: -220, width: 368, height: 280)
                }
                
            }

            if let button:UIButton = sender as! UIButton? {
                print(button.tag) //optional
                destination?.delegate = self
                
                destination?.dateStr = self.dateStr
            }
        } else if (segue.identifier == "selectDoctorSegue") {
            let destination = segue .destination as? DoctorPickerViewController
            
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                
                if screenWidth == 1366.0 {
                    popoverPresentationController.sourceRect = CGRect(x: 575, y: -125, width: 368, height: 180)
                } else {
                    popoverPresentationController.sourceRect = CGRect(x: 410, y: -125, width: 368, height: 180)
                }
                
            }
            
            if let button: UIButton = sender as! UIButton? {
                print(button.tag) //optional
                destination?.delegate = self
            }
        } else if (segue.identifier == "addPatientSegueForOverview") {
            let destination = segue .destination as? AddPatientViewController
            destination?.delegate = self
            destination?.cancelDelegate = self
            destination?.patientName = patientToAdd
        }
    }
    
    func setDate(date: String) {
        self.dateStr = date
        overviewTable.reloadData()
        view.endEditing(true)
    }
    
    func setDoctor(doctor: String) {
        self.doctorStr = doctor
        overviewTable.reloadData()
        view.endEditing(true)
    }
    
    func clearText() {
        DispatchQueue.main.async {
            self.currentTextField.text = ""
        }
        
    }
    
    func appFirstLaunchSetup() {
        
        let defaults = UserDefaults.standard
        
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            NSLog("App already launched : \(isAppAlreadyLaunchedOnce)")
        }else{
            //app launch first time
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            
            setupClinicAndDoctorTable()
            FireBaseDBManager().getAllPatient(completion: { _ in
                self.overviewTable.reloadData()
            })
            NSLog("get patient from firebase executed")
            
        }
    }
    
    func setupClinicAndDoctorTable() {
        
        //all the clinics and doctors should get from firebase
        //and then add to core data
        //the clinics and doctors should fetch here only once
        
        let context = ManagedContext().getManagedObject()
        let clinic1 = NSEntityDescription.insertNewObject(forEntityName: "Clinic", into: context) as? Clinic
        
        clinic1?.address = "Room 1402, Chuang’s Tower, 30-32 Connaught Road, Central, Hong Kong"
        clinic1?.phone = "85228269261"
        
        //        let clinic2 = NSEntityDescription.insertNewObject(forEntityName: "Clinic", into: context) as? Clinic
        //
        //        clinic2?.address = "Clinic2"
        //        clinic2?.phone = "0431739405"
        //
        //        let clinic3 = NSEntityDescription.insertNewObject(forEntityName: "Clinic", into: context) as? Clinic
        //
        //        clinic3?.address = "Clinic3"
        //        clinic3?.phone = "0431739405"
        
        let doctor1 = NSEntityDescription.insertNewObject(forEntityName: "Doctor", into: context) as? Doctor
        
        doctor1?.name = "Andy Kwok"
        
        let doctor2 = NSEntityDescription.insertNewObject(forEntityName: "Doctor", into: context) as? Doctor
        
        doctor2?.name = "Stephen Wong"
        
        //        let doctor3 = NSEntityDescription.insertNewObject(forEntityName: "Doctor", into: context) as? Doctor
        //
        //        doctor3?.name = "Doctor3"
        
        clinic1?.addDoctor(doctor1!)
        clinic1?.addDoctor(doctor2!)
        //        clinic3?.addDoctor(doctor3!)
        
        //Save the ManagedObjectContext
        do {
            
            //add clinics to firebase
            FireBaseDBManager().insertClinic(clinic: clinic1!)
            
            try context.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func getScreenSize() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        return screenWidth
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
