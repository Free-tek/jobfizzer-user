//
//  ReceiverDOCTableViewCell.swift
//  Online Connections
//
//  Created by Pyramidions on 17/12/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

class ReceiverDOCTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLbl: UILabel!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
