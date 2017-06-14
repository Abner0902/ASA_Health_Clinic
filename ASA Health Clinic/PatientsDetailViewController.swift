//
//  DetailViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 31/5/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

class PatientsDetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet var patientPhoneLabel: UILabel!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                //label.text = detail.timestamp!.description
                label.text = "Name: " + detail.name!
                patientPhoneLabel.text = "Phone: " + detail.phone!
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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


}

