//
//  BookingTableCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 20/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class BookingTableCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    @IBOutlet weak var buttonLbl: UILabel!
    
    @IBOutlet weak var serviceTime: UILabel!
    @IBOutlet weak var serviceDate: UILabel!
    @IBOutlet weak var subCategoryName: UILabel!
    @IBOutlet weak var subCategoryImage: UIImageView!
    @IBOutlet weak var cornerView: UIView!

    @IBOutlet weak var providerName: UILabel!
    
    @IBOutlet weak var bookingStatusImageView: UIImageView!
    @IBOutlet weak var bookingStatusLbl: UILabel!
    @IBOutlet weak var cancel: UIButton!
    
    @IBOutlet weak var track: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        providerName.font = FontBook.Medium.of(size: 16)
        subCategoryName.font = FontBook.Medium.of(size: 13)
        serviceDate.font = FontBook.Medium.of(size: 12)
        serviceTime.font = FontBook.Medium.of(size: 12)
        bookingStatusLbl.font = FontBook.Medium.of(size: 12)
        dateLbl.font = FontBook.Regular.of(size: 15)
        timeLbl.font = FontBook.Regular.of(size: 15)
        buttonLbl.font = FontBook.Regular.of(size: 12)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
