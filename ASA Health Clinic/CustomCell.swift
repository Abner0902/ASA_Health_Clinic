//
//  CustomCell.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 26/9/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation
import Eureka

public class CustomCell: Cell<Bool>, CellType {
    
    @IBOutlet weak var bookingDateButton: UIButton!
    
    @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var choiceTwo: UIButton!
    
    @IBOutlet weak var choiceOne: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var booking: Booking!
    
    var statusString: String! {
        willSet(newValue) {
            guard let oldValue = statusString, let new = newValue else { return }
            if oldValue != new {
                //value changed
                BookingManager().updateBookingByStatus(status: new,booking: booking)
            }
        }
    }
        
    public override func setup() {
        super.setup()
        bookingDateButton.addTarget(self, action: #selector(CustomCell.bookingDateButtonClicked), for: .touchUpInside)
        statusButton.addTarget(self, action: #selector(CustomCell.statusButtonOnClicked), for: .touchUpInside)
        choiceOne.addTarget(self, action: #selector(CustomCell.choiceOneButtonClicked), for: .touchUpInside)
        choiceTwo.addTarget(self, action: #selector(CustomCell.choiceTwoButtonClicked), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(CustomCell.cancelButtonClicked), for: .touchUpInside)
        
        statusString = statusButton.currentTitle
    }
    
    func bookingDateButtonClicked() {
        //change date here?
        
    }
    
    func statusButtonOnClicked() {
        
        setChoiceVisibility(visible: false)
        
        let status = statusButton.currentTitle!
        switch (status) {
        case "?":
            configureChoiceButton(t1: "√", t2: "X", t3: "Cancel")
            break
        case "√":
            configureChoiceButton(t1: "X", t2: "Cancel", t3: "")
            break
        default:
            configureChoiceButton(t1: "√", t2: "Cancel", t3: "")
            break
        }
    }
    
    func choiceOneButtonClicked() {
        let text = choiceOne.currentTitle!
        
        if text != "Cancel" {
            statusButton.setTitle(text, for: .normal)
            statusString = text
        }
        
        setChoiceVisibility(visible: true)
    }
    
    func choiceTwoButtonClicked() {
        let text = choiceTwo.currentTitle!
        
        if text != "Cancel" {
            statusButton.setTitle(text, for: .normal)
            statusString = text
        }
        setChoiceVisibility(visible: true)
    }
    
    func cancelButtonClicked() {
        setChoiceVisibility(visible: true)
    }
    
    public override func update() {
        super.update()
        //backgroundColor = (row.value ?? false) ? .white : .black
    }
    
    func configureChoiceButton(t1: String, t2: String, t3: String) {
        choiceOne.setTitle(t1, for: .normal)
        choiceTwo.setTitle(t2, for: .normal)
        cancelButton.setTitle(t3, for: .normal)
    }
    
    func setChoiceVisibility(visible: Bool) {
        choiceOne.isHidden = visible
        choiceTwo.isHidden = visible
        cancelButton.isHidden = visible
        choiceOne.setTitle("", for: .normal)
        choiceTwo.setTitle("", for: .normal)
        cancelButton.setTitle("", for: .normal)
    }
    
}



public final class CustomRow: Row<CustomCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CustomCell>(nibName: "BookingCustomCell")
    }
}
