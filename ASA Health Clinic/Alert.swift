//
//  Alert.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 20/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

class Alert: NSObject {

    //show alert view
    func showAlert(msg: String, view: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            NSLog("Alert ok clicked")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            view.dismiss(animated: true) { () -> Void in
                NSLog("Alert Cancel clicked")
                
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        view.present(alertController, animated: true, completion: nil)
    }

}
