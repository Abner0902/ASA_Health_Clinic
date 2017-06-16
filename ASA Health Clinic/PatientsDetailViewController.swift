//
//  DetailViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 31/5/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

class PatientsDetailViewController: UIViewController {

    @IBOutlet var patientDetailContainer: UIView!
    
    @IBOutlet var patientBookingContainer: UIView!

    @IBOutlet var segmentControl: UISegmentedControl!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        patientBookingContainer.isHidden = true
        //configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Patient? {
        didSet {
            // Update the view.
            //configureView()
        }
    }

    @IBAction func indexSelected(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            patientDetailContainer.isHidden = false
            patientBookingContainer.isHidden = true
        case 1:
            patientDetailContainer.isHidden = true
            patientBookingContainer.isHidden = false
        default:
            break; 
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller
        if segue.identifier == "patientDetailSegue" {
            // Pass the selected object to the new view controller.
            let controller: DetailContainerViewController = segue.destination as! DetailContainerViewController
            controller.detailItem = self.detailItem
            
        } else if segue.identifier == "patientBookingSegue" {
            //pass patient information to patient booking container view if needed
            // Pass the selected object to the new view controller.
            let controller: BookingContainerViewController = segue.destination as! BookingContainerViewController
            controller.detailItem = self.detailItem

        }
    }
    
    
}

