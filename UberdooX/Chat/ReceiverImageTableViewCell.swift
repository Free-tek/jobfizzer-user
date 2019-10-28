//
//  ReceiverImageTableViewCell.swift
//  Online Connections
//
//  Created by Pyramidions on 17/12/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

protocol ReceiverImageTableViewCellDelegate
{
    func receiverImageDidTap(_ sender: ReceiverImageTableViewCell,index:IndexPath)
}

class ReceiverImageTableViewCell: UITableViewCell
{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    var delegate: ReceiverImageTableViewCellDelegate?
    var indexPath:IndexPath!

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func clickImage(_ sender: Any)
    {
        self.delegate?.receiverImageDidTap(self, index: indexPath)
    }
}
