//
//  ServiceStatusTableViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 01/01/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

class ServiceStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var statusTime: UILabel!
    @IBOutlet weak var centerCircle: UIView!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var statusIdentifier: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusTime.font = FontBook.Regular.of(size: 14)
        statusIdentifier.font = FontBook.Regular.of(size: 14)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
