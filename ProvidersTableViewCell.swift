//
//  ProvidersTableViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 23/12/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Cosmos

class ProvidersTableViewCell: UITableViewCell {

    @IBOutlet weak var distancelabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var providerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        providerName.font = FontBook.Medium.of(size: 17)
        distancelabel.font = FontBook.Medium.of(size: 13)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
