//
//  SubCategoryCollectionViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 20/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class SubCategoryCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var subCategoryImage: UIImageView!
    @IBOutlet weak var subCategoryName: UILabel!
    @IBOutlet weak var btnfav: UIButton!
    @IBOutlet weak var imgfav: UIImageView!
    @IBOutlet weak var vwfav: UIView!
    var isclicked:Bool = true
    override func awakeFromNib()
    {
        super.awakeFromNib()
        subCategoryName.font = FontBook.Medium.of(size: 15)
    }
    
    @IBAction func btnfavoirate(_ sender: Any)
    {
        print("isclicked =\(isclicked)")
        if isclicked == false{
            imgfav.image = #imageLiteral(resourceName: "unfilled")
            isclicked = true
        }
        else {
            imgfav.image = #imageLiteral(resourceName: "filled")
            isclicked = false
        }
    }
}
