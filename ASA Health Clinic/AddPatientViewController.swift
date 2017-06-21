//
//  ViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 12/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import Eureka

protocol AddPatientDelegate {
    func addPatient(name: String, phone: String)
}

class AddPatientViewController: FormViewController {
    
    var delegate: AddPatientDelegate?
    
    var currentPatient: Patient?
    
    //gesture for tapping on background
    //var tapBGGesture: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create the input form
        self.form
            +++ Section(header: "New Patient", footer: "")
            
            <<< TextRow() { row in
                row.title = "Patient Name"
                row.placeholder = "Enter name here"
                row.tag = "name"
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
                
                $0.title = "Cancel"
                $0.tag = "cancel"
                
            } .onCellSelection() { cell, row in
                    self.dismiss(animated: true) { () -> Void in
                            NSLog("Cancel clicked")
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
                        
                        self.delegate!.addPatient(name: nameValue as! String, phone: phoneValue as! String)
                    }
                } else {
                    Alert().showAlert(msg: "Field Required", view: self)
                }
            }


        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //set up the BG tap gesture
        //setupBGTapGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func setupBGTapGesture() {
//        tapBGGesture = UITapGestureRecognizer(target: self, action: #selector(self.settingsBGTapped(_:)))
//        tapBGGesture.delegate = self
//        tapBGGesture.numberOfTapsRequired = 1
//        tapBGGesture.cancelsTouchesInView = true
//        self.view.window!.addGestureRecognizer(tapBGGesture)
//    }
    
//    func settingsBGTapped(_ recognizer: UITapGestureRecognizer){
//        if recognizer.state == UIGestureRecognizerState.ended{
//            guard let presentedView = presentedViewController?.view else {
//                return
//            }
//            
//            if !(presentedView.bounds).contains(recognizer.location(in: presentedView)) {
//                self.dismiss(animated: true, completion: { () -> Void in
//                    
//                })
//            }
//        }
//    }
    
    
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
