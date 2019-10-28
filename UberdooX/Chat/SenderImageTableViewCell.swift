//
//  SenderImageTableViewCell.swift
//  Online Connections
//
//  Created by Pyramidions on 17/12/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

protocol SenderImageTableViewCellDelegate
{
    func senderImageDidTap(_ sender: SenderImageTableViewCell,index:IndexPath)
}

class SenderImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    var indexPath:IndexPath!
    var delegate: SenderImageTableViewCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickImage(_ sender: Any)
    {
        self.delegate?.senderImageDidTap(self, index: indexPath)
    }
    
    
}
