//
//  ProfileDetailsContentViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileDetailsContentViewController: UIViewController {
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var summaryLbl: UILabel!
    @IBOutlet weak var experienceLbl: UILabel!
    var providerDetails : [String:JSON]!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()

        let price = "₦\(ProviderProfileViewController.providerDetails["priceperhour"]!.stringValue)/HR"
        priceLbl.text = price
        
        let summary = ProviderProfileViewController.providerDetails["about"]!.stringValue
        summaryLbl.text = summary
        summaryLbl.sizeToFit()
        summaryLbl.numberOfLines = 0
        
        let experience = "\(ProviderProfileViewController.providerDetails["experience"]!.stringValue) years of experience"
        experienceLbl.text = experience
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
