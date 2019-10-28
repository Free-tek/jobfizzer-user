//
//  CategoryCollectionViewCell.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 20/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var btnFavorate: UIButton!
    @IBOutlet weak var imgFaviorate: UIImageView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    var isclicked:Bool = true
    
    @IBOutlet weak var vwtheme: UIView!
    @IBAction func btnfaviorate(_ sender: Any) {
        if isclicked == false{
            imgFaviorate.image = #imageLiteral(resourceName: "unfilled")
            isclicked = true
        }
        else {
            imgFaviorate.image = #imageLiteral(resourceName: "filled")
            isclicked = false
        }
    }
    
}
