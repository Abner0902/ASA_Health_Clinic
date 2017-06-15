//
//  DetainContainerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 15/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

class DetailContainerViewController: UIViewController {
    
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var phoneLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: Patient? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailLabel {
                label.text = "Name: " + detail.name!
            }
            
            if let label = phoneLabel {
                label.text = "Phone: " + detail.phone!
            }
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
