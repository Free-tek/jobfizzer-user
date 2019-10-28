//
//  ReceiverPDFTableViewCell.swift
//  Online Connections
//
//  Created by Pyramidions on 17/12/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

protocol ReceiverPDFTableViewCellDelegate
{
    func receiverPDFDidTap(_ sender: ReceiverPDFTableViewCell,index:IndexPath)
}


class ReceiverPDFTableViewCell: UITableViewCell {
    
    var delegate: ReceiverPDFTableViewCellDelegate?
    @IBOutlet weak var fileNameLbl: UILabel!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    var indexPath:IndexPath!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickAtn(_ sender: Any)
    {
        self.delegate?.receiverPDFDidTap(self, index: indexPath)
    }
    
    
}
