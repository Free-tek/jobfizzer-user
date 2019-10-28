//
//  OtherServicesTableViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 28/12/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class OtherServicesTableViewCell: UITableViewCell {

    @IBOutlet weak var vwdot: UIView!
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var serviceName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        servicePrice.font = FontBook.Regular.of(size: 14)
        serviceName.font = FontBook.Regular.of(size: 14)

        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
