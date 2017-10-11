//
//  DatePickerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 17/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import JBDatePicker

protocol SetDateDelegate {
    func setDate(date: String)
}

class DatePickerViewController: UIViewController, JBDatePickerViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    
    @IBOutlet var datePicker: JBDatePickerView!
    
    
    var dateStr: String!
    var delegate: SetDateDelegate?
    
    var dateToSelect: Date?
    
    let converter = TypeConverter()
    
    
    
    var weekDaysViewHeightRatio: CGFloat {
        return 0.15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.delegate = self
        
        //get presented month
        navigationBar.topItem?.title = datePicker.presentedMonthView?.monthDescription
        
        //set title color
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        //remove hairline under navigationbar
        navigationBar.setBackgroundImage(UIImage(named: "GreenPixel"), for: .default)
        navigationBar.shadowImage = UIImage(named: "TransparentPixel")
        
//        datePicker
//        datePicker.addTarget(self, action: #selector(DatePickerViewController.datePickerChanged(_:)), for: .valueChanged)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var dateToShow: Date {
        
        dateToSelect = converter.stringToDateIncludingWeekday(str: dateStr)
        
        if let date = dateToSelect {
            return date
        }
        else{
            return Date()
        }
    }

    
    // MARK: - JBDatePickerViewDelegate implementation
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        print("date selected: \(String(describing: dayView.date))")
        
        self.dismiss(animated: true) { () -> Void in
            self.delegate?.setDate(date: self.converter.dateToStringIncludingWeekday(date: self.datePicker.selectedDateView.date!))
        }
    }
    
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
        self.navigationBar.topItem?.title = datePicker.presentedMonthView.monthDescription
        
    }
    
//    func shouldAllowSelectionOfDay(_ date: Date?) -> Bool {
//        
//        guard let date = date else {return true}
//        let comparison = NSCalendar.current.compare(date, to: Date(), toGranularity: .day)
//        
//            if comparison == .orderedAscending {
//                return false
//            }
//        return true
//         
//    }

    @IBAction func nextMonth(_ sender: Any) {
        
        datePicker.loadNextView()
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        datePicker.loadPreviousView()
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
