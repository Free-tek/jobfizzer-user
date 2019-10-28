//
//  BookingRequestViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 27/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class BookingRequestViewController: UIViewController {

    
    @IBOutlet weak var thankLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    
    
    @IBOutlet weak var imgok: UIImageView!
    @IBOutlet weak var btnOkay: UIButton!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thankLbl.text = "THANK YOU".localized()
        desLbl.text = "Your request is sent to the provider. Provider will confirm soon.".localized()
        btnOkay.setTitle("OKAY".localized(),for: .normal)
        
        thankLbl.font = FontBook.Medium.of(size: 20)
        desLbl.font = FontBook.Medium.of(size: 17)
        btnOkay.titleLabel!.font = FontBook.Medium.of(size: 17)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            btnOkay.backgroundColor = mycolor
            changeTintColor(imgok, arg: mycolor)
        }
    }
    func changeTintColor(_ img: UIImageView?, arg color: UIColor?) {
        if let aColor = color {
            img?.tintColor = aColor
        }
        var newImage: UIImage? = img?.image?.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions((img?.image?.size)!, false, (img?.image?.scale)!)
        color?.set()
        newImage?.draw(in: CGRect(x: 0, y: 0, width: img?.image?.size.width ?? 0.0, height: img?.image?.size.height ?? 0.0))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        img?.image = newImage
    }
    @IBAction func goToHomePage(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(vc, animated: true, completion: nil)
    }
    
}
