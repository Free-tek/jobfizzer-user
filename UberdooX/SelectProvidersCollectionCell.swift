//
//  SelectProvidersCollectionCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 16/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Cosmos

class SelectProvidersCollectionCell: UICollectionViewCell
{
    
    @IBOutlet weak var mainView: CardView!
    @IBOutlet weak var distancelabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var providerImage: UIImageView!
    
    @IBOutlet weak var VWTOP: UIView!
    @IBOutlet weak var vwbottom: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        distancelabel.font = FontBook.Regular.of(size: 16)
        providerName.font = FontBook.Regular.of(size: 16)
    }
    
}
