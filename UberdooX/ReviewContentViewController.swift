//
//  ReviewContentViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import SwiftyJSON
class ReviewContentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var reviewTableView: UITableView!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()

        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
        let reviews = ProviderProfileViewController.providerDetails["reviews"]!.arrayValue
        cell.userName.text = reviews[indexPath.row]["username"].stringValue
        cell.ratingView.rating = reviews[indexPath.row]["rating"].doubleValue
        cell.review.text = reviews[indexPath.row]["feedback"].stringValue
        cell.review.numberOfLines = 0
        cell.review.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProviderProfileViewController.providerDetails["reviews"]!.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
