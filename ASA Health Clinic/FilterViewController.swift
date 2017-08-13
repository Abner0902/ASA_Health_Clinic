//
//  FilterViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 13/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

protocol SetFilterDelegate {
    func setFilter(option: String)
}

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var filterPicker: UIPickerView!
    
    let pickerViewData = ["One Week Ago", "One Month Ago", "All", "Today", "Within One Week", "Within One Month"]

    var delegate: SetFilterDelegate?
    var option: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterPicker.delegate = self
        filterPicker.dataSource = self
        
        filterPicker.selectRow(option!, inComponent: 0, animated: false)
        // Do any additional setup after loading the view.
        
        //self.view.frame = CGRect(x: 10, y: 30, width: 300, height: 150)
        //NSLog("\(FilterViewController.accessibilityFrame().origin.x) \(FilterViewController.accessibilityFrame().origin.y)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.delegate?.setFilter(option: pickerViewData[pickerView.selectedRow(inComponent: 0)])
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
