//
//  BannerCollectionViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 20/12/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bannerName: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bannerName.font = FontBook.Regular.of(size: 17)        
    }
    
}
