//
//  DatePickerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 17/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

protocol SetDateDelegate {
    func setDate(date: String)
}

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: SetDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.addTarget(self, action: #selector(DatePickerViewController.datePickerChanged(_:)), for: .valueChanged)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerChanged(_ sender: UIDatePicker) {
        //get selected date
        let selectedDate = datePicker.date
        
        //format date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateStr = dateFormatter.string(from: selectedDate)
        
        self.delegate?.setDate(date: dateStr)
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
