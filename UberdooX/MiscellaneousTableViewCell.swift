//
//  miscellaneousTableViewCell.swift
//  UberdooX
//
//  Created by Praba VJ on 26/07/19.
//  Copyright © 2019 Uberdoo. All rights reserved.
//

import UIKit

class MiscellaneousTableViewCell: UITableViewCell
{
    @IBOutlet weak var miscellaneousNameLbl: UILabel!
    @IBOutlet weak var miscellaneousValueLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
