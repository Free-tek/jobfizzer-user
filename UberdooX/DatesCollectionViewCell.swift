//
//  DatesCollectionViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 20/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class DatesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateBg: UIView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayLbl.font = FontBook.Medium.of(size: 15)
        dateLbl.font = FontBook.Medium.of(size: 17)
        
    }
    
    
}
