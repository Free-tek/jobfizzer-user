//
//  TimeSlotsCollectionViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 20/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class TimeSlotsCollectionViewCell: UICollectionViewCell
{    
    @IBOutlet weak var timeSlotBtn: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        timeSlotBtn.titleLabel!.font = FontBook.Medium.of(size: 13)
    }
    
}
