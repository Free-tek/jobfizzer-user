//
//  ReviewTableViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 25/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Cosmos
class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var review: UILabel!
    @IBOutlet weak var userName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        userName.font = FontBook.Regular.of(size: 15)
        review.font = FontBook.Regular.of(size: 14)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
