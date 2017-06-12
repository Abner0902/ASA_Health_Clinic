//
//  ViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 12/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

protocol AddPatientDelegate {
    func addPatient(name: String, phone: String)
}

class AddPatientViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    
    @IBOutlet var doneButton: UIButton!
    var delegate: AddPatientDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupAddTargetIsNotEmptyTextFields()
        
        //disable the done button when text field is empty
        if (nameField.text?.isEmpty)! {
            self.disableButton()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true) { () -> Void in
            NSLog("Cancel clicked")
        }
    }
    
    @IBAction func Done(_ sender: Any) {
        self.dismiss(animated: true) { () -> Void in
            NSLog("Done clicked")
            
            if let name = self.nameField.text, let phone = self.phoneField.text {
                self.delegate!.addPatient(name: name, phone: phone)
            }
        }
    }
    
    func disableButton() {
        doneButton.isUserInteractionEnabled = false
        doneButton.tintColor = .gray
    }
    
    func enableButton() {
        doneButton.isUserInteractionEnabled = true
        doneButton.tintColor = .blue
    }
    
    //add targets to check all text fields is not empty
    func setupAddTargetIsNotEmptyTextFields() {
        
        nameField.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                    for: .editingChanged)
        phoneField.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                     for: .editingChanged)
    }
    
    func textFieldsIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let name = nameField.text, !name.isEmpty,
            let phone = phoneField.text, !phone.isEmpty
        else {
            disableButton()
            return
        }
        // enable done button if all conditions are met
        enableButton()
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
