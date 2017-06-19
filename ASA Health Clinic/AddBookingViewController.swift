//
//  BookingContainerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 16/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

protocol AddBookingDelegate {
    func addBooking(doctor: String, clinic: String, date: Date)
}

class AddBookingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var doctorPicker: UIPickerView!
    
    @IBOutlet weak var clinicPicker: UIPickerView!

    @IBOutlet weak var dateTimePicker: UIDatePicker!
    
    var doctorPickerDataSource = ["doctor1", "Doctor2", "Doctor3"]
    var clinicDataSource = ["Clinic1", "Clinic2", "Clinic3"]
    
    var delegate: AddBookingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureDoctorPickerView()
        configureClinicPickerView()
        configureDatePickerView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true) { () -> Void in
            NSLog("Cancel clicked")
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true) { () -> Void in
            NSLog("Done clicked")
            //pass booking information here
            let doctor = self.doctorPickerDataSource[self.doctorPicker.selectedRow(inComponent: 0)]
            let clinic = self.clinicDataSource[self.clinicPicker.selectedRow(inComponent: 0)]
            
            let date = self.dateTimePicker.date
            
            self.delegate?.addBooking(doctor: doctor, clinic: clinic, date: date)
        }
    }
    
    //Configure the doctor picker view
    //Hard code the doctor name in this stage
    func configureDoctorPickerView() {
        doctorPicker.dataSource = self
        doctorPicker.delegate = self
    }
    
    //Configure the clinic picker view
    //Hard code the clinic address in this stage
    func configureClinicPickerView() {
        clinicPicker.dataSource = self
        clinicPicker.delegate = self
    }
    
    func configureDatePickerView() {
        let currentDate = Date()
        dateTimePicker.minimumDate = currentDate
    }
    
    // MARK: - Picker view methods
    
    func numberOfComponents(in pickerView:UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == doctorPicker {
            return doctorPickerDataSource.count
        } else {
            return clinicDataSource.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == doctorPicker {
            return doctorPickerDataSource[row]
        } else {
            return clinicDataSource[row]
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
