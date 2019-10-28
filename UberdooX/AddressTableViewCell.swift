//
//  AddressTableViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/11/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        titleLbl.font = FontBook.Medium.of(size: 17)
        addressLbl.font = FontBook.Medium.of(size: 14)

        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
