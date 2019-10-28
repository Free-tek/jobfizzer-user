//
//  TextTableViewCell.swift
//  Tindo
//
//  Created by Karthik Sakthivel on 05/12/17.
//  Copyright © 2017 Pyramidions. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var emojiActionBtn: UIButton!
    @IBOutlet weak var myViewBg: UIView!
    @IBOutlet weak var messageContent: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
