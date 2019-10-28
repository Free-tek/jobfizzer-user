//
//  SearchMapCell.swift
//  UberdooX
//
//  Created by admin on 2/13/19.
//  Copyright © 2019 Uberdoo. All rights reserved.
//

import UIKit

class SearchMapCell: UITableViewCell {

    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        locationLbl.text = ""
        detailLbl.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
