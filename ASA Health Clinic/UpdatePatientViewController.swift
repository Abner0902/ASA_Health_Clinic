//
//  UpdatePatientViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 21/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import Eureka

protocol UpdatePatientDelegate {
    func updatePatient(name: String, phone: String, patientToUpdate: Patient)
}

class UpdatePatientViewController: FormViewController {

    var delegate: UpdatePatientDelegate?
    var currentPatient: Patient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //create the input form
        self.form
            +++ Section(header: "Edit Patient", footer: "")
            
            <<< TextRow() { row in
                row.title = "Patient Name"
                row.placeholder = "Enter name here"
                row.tag = "name"
                if currentPatient != nil {
                    row.value = currentPatient?.name
                }
                //add validation rules
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< PhoneRow() { row in
                
                row.title = "Phone Number"
                row.placeholder = "Enter phone number here"
                row.tag = "phone"
                if currentPatient != nil {
                    row.value = currentPatient?.phone
                }
                //add validation rules
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
                
                } .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            +++ Section()
            
            <<< ButtonRow() {
                
                $0.title = "Done"
                $0.tag = "done"
                
                } .onCellSelection() { cell, row in
                    let nameValue = self.form.rowBy(tag: "name")?.baseValue
                    let phoneValue = self.form.rowBy(tag: "phone")?.baseValue
                    if ((nameValue != nil) && (phoneValue != nil) ) {
                        
                        self.dismiss(animated: true) { () -> Void in
                            NSLog("Done clicked")
                            
                            self.delegate!.updatePatient(name: nameValue as! String, phone: phoneValue as! String, patientToUpdate: self.currentPatient!)
                        }
                    } else {
                        Alert().showAlert(msg: "Field Required", view: self)
                    }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
