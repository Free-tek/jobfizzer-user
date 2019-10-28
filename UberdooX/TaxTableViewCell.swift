//
//  TaxTableViewCell.swift
//  Zumpii
//
//  Created by Pyramidions on 03/12/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

class TaxTableViewCell: UITableViewCell {

    @IBOutlet weak var taxNameLbl: UILabel!
    @IBOutlet weak var taxValueLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
