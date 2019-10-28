//
//  OfflineViewController.swift
//  reachability-playground
//
//  Created by Neo Ighodaro on 28/10/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

protocol OfflineViewControllerDelegate
{
    func tryAgain()
}

class OfflineViewController: UIViewController
{
    var delegate : OfflineViewControllerDelegate!
    
    @IBOutlet weak var desLblY: NSLayoutConstraint!
    @IBOutlet weak var errorLblY: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var wifiImageY: NSLayoutConstraint!
    @IBOutlet weak var middleImageY: NSLayoutConstraint!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var roundImgView: UIImageView!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        errorLbl.font = UIFont.appMediumFontWith(size: 16)
//        tryAgainBtn.titleLabel?.font = UIFont.appHeavyFontWith(size: 16)
//        tryAgainBtn.setTitle(CONSTANT.TRY_AGAIN,for: .normal)
//        desLbl.font = UIFont.appMediumFontWith(size: 16)
//        errorLbl.text = CONSTANT.YOU_ARE_OFFLINE
//        desLbl.text = CONSTANT.PLEASE_TRY_IN_A_WHILE
        setView()
        checkView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        showView()
    }

    func setView()
    {
        tryAgainBtn.alpha = 0.0
        bottomView.alpha = 0.0
        wifiImageY.constant -= view.bounds.height
        middleImageY.constant += view.bounds.height
        errorLblY.constant += view.bounds.height
        desLblY.constant += view.bounds.height
        roundImgView.transform = CGAffineTransform(scaleX: 0.0,y: 0.0);
        self.view.layoutIfNeeded()
    }
    
    func showView()
    {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations:
        {
                self.roundImgView.transform = CGAffineTransform(scaleX: 1.0,y: 1.0);
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations:
        {
                self.middleImageY.constant = 0
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations:
        {
                self.wifiImageY.constant = 0
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 3, animations:
        {
                self.bottomView.alpha = 1.0
        })
        
        UIView.animate(withDuration: 1.3, delay: 0.0, options: .curveEaseOut, animations:
        {
                self.errorLblY.constant = 0
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 1.3, delay: 0.2, options: .curveEaseOut, animations:
        {
                self.desLblY.constant = 0
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 1.3, animations:
        {
                self.tryAgainBtn.alpha = 1.0
        })

    }
    
    @IBAction func tryAgainAtn(_ sender: Any)
    {
        if Reachability.isConnectedToNetwork()
        {
            delegate.tryAgain()
        }
        else
        {
            errorLbl.shake()
            desLbl.shake()
        }
    }
    
}
extension UIView {
    func shake()
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.5
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

