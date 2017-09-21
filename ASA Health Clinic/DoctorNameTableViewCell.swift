//
//  DoctorNameTableViewCell.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 17/8/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit

class DoctorNameTableViewCell: UITableViewCell {

    @IBOutlet weak var doctorLabelOne: UILabel!
    
    @IBOutlet weak var doctorLabelTwo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
