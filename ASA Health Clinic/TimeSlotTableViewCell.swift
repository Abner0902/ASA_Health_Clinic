//
//  TimeSlotTableViewCell.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 17/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import SearchTextField

class TimeSlotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var bookingOneText: SearchTextField!
    
    @IBOutlet weak var bookingTwoText: SearchTextField!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
