//
//  MessagesTableViewCell.swift
//  UberdooXP
//
//  Created by admin on 7/30/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var onlineStatus: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userNameLbl.font = FontBook.Regular.of(size: 17)

        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.height/2
        self.profilePic.clipsToBounds = true
        
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
