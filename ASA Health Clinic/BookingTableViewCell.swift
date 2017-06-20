//
//  BookingTableViewCell.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 18/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

class BookingTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
