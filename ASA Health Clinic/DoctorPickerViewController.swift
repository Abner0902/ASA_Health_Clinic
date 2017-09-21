//
//  DoctorPickerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 31/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

protocol SetDoctorDelegate {
    func setDoctor(doctor: String)
}

class DoctorPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var doctorPicker: UIPickerView!
    var delegate: SetDoctorDelegate?
    var doctors = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadDoctors()
        
        doctorPicker.dataSource = self
        doctorPicker.delegate = self

        // Do any additional setup after loading the view.
    }

    func loadDoctors() {
        // need to change to loaf from database
        doctors = ["Andy Kwok", "Stephen Wong"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doctorPickerChanged(_ sender: UIPickerView) {
        //get selected date
        let selectedDoctor = doctors[doctorPicker.selectedRow(inComponent: 0)]
        
        self.delegate?.setDoctor(doctor: selectedDoctor)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return doctors.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return doctors[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            //get selected doctor
            let selectedDoctor = doctors[row]
            
            self.delegate?.setDoctor(doctor: selectedDoctor)
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
