//
//  InvoiceViewController.swift
//  SwyftX
//
//  Created by Karthik Sakthivel on 29/10/17.
//  Copyright © 2017 Swyft. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import UserNotifications

class BilingDetailsViewController: UIViewController,UNUserNotificationCenterDelegate,UITableViewDelegate,UITableViewDataSource
{
    

    @IBOutlet weak var invoiceLbl: UILabel!
    @IBOutlet weak var cnameLbl: UILabel!
    @IBOutlet weak var offAmtLbl: UILabel!
    @IBOutlet weak var pnameLbl: UILabel!
    @IBOutlet weak var billNameLbl: UILabel!
    @IBOutlet weak var bidLbl: UILabel!
    @IBOutlet weak var datLbl: UILabel!
    @IBOutlet weak var timLbl: UILabel!
    @IBOutlet weak var whoursLbl: UILabel!
    @IBOutlet weak var prLbl: UILabel!
    @IBOutlet weak var totLbl: UILabel!
    
    
    
    @IBOutlet weak var taxTableView: UITableView!
    @IBOutlet weak var taxTableHeight: NSLayoutConstraint!

    
    
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
     var isCoupon_Applied = ""
    
    @IBOutlet weak var offerLbl: UILabel!
    @IBOutlet weak var couponNameLbl: UILabel!

    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var taxNameLbl: UILabel!
    @IBOutlet weak var taxLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
   
    @IBOutlet weak var workingHoursLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var bookingIdLbl: UILabel!
    @IBOutlet weak var billingNameLbl: UILabel!
    @IBOutlet weak var providerNameLbl: UILabel!

    var bookingDetails : [String:JSON]!

    
    private var price = "0"
    
    @IBOutlet weak var confirmButton: UIButton!
    var mycolor = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        
        invoiceLbl.text = "INVOICE".localized()
        cnameLbl.text = "Coupon Name".localized()
        offAmtLbl.text = "Offer Amount".localized()
        pnameLbl.text = "Provider Name".localized()
        billNameLbl.text = "Billing Name".localized()
        bidLbl.text = "Booking ID".localized()
        datLbl.text = "Date".localized()
        timLbl.text = "Time".localized()
        whoursLbl.text = "Working Hours".localized()
        prLbl.text = "Price".localized()
        taxNameLbl.text = "Tax".localized()
        totLbl.text = "TOTAL".localized()

        couponNameLbl.text = "-Nil-".localized()

        invoiceLbl.font = FontBook.Medium.of(size: 20)
        cnameLbl.font = FontBook.Regular.of(size: 16)
        offAmtLbl.font = FontBook.Regular.of(size: 16)
        pnameLbl.font = FontBook.Regular.of(size: 16)
        billNameLbl.font = FontBook.Regular.of(size: 16)
        bidLbl.font = FontBook.Regular.of(size: 16)
        datLbl.font = FontBook.Regular.of(size: 16)
        timLbl.font = FontBook.Regular.of(size: 16)
        whoursLbl.font = FontBook.Regular.of(size: 16)
        prLbl.font = FontBook.Regular.of(size: 16)
        taxNameLbl.font = FontBook.Regular.of(size: 16)
        totLbl.font = FontBook.Regular.of(size: 16)

        
        
        offerLbl.font = FontBook.Regular.of(size: 16)
        providerNameLbl.font = FontBook.Regular.of(size: 16)
        billingNameLbl.font = FontBook.Regular.of(size: 16)
        bookingIdLbl.font = FontBook.Regular.of(size: 16)
        dateLbl.font = FontBook.Regular.of(size: 16)
        timeLbl.font = FontBook.Regular.of(size: 16)
        workingHoursLbl.font = FontBook.Regular.of(size: 16)
        priceLbl.font = FontBook.Regular.of(size: 16)
        taxLbl.font = FontBook.Regular.of(size: 16)
        totalLbl.font = FontBook.Regular.of(size: 16)

        
        
        
        print("Billing Details = ",bookingDetails)
        
        
        
        
        taxTableView.delegate = self
        taxTableView.dataSource = self
        
        taxTableHeight.constant = 0
        
        taxTableView.separatorStyle = .none
        
        
        
        

        
        isCoupon_Applied = self.bookingDetails["coupon_applied"]!.stringValue
        
        print("isCoupon_Applied = ",isCoupon_Applied)
        
        offerLbl.textColor = UIColor.red

        
        if isCoupon_Applied == ""
        {
            offerLbl.text = "-0"
            couponNameLbl.text = "-Nil-".localized()

            
        }
        else
        {
            offerLbl.text = "-" + self.bookingDetails["off"]!.stringValue
            
            couponNameLbl.text = isCoupon_Applied.uppercased()


        }
        
        
        self.totalLbl.text = "$ \(String(describing: self.bookingDetails["total_cost"]!.stringValue))"
        print("hgdvdshk = \(self.bookingDetails["total_cost"]!.stringValue)")
        print("Cost = \(self.bookingDetails["cost"]!.stringValue)")
        print("gst_cost = \(self.bookingDetails["gst_cost"]!.stringValue)")
        self.price = self.bookingDetails["total_cost"]!.stringValue
        self.taxNameLbl.text = "\(String(describing: self.bookingDetails["tax_name"]!.stringValue)) (\(self.bookingDetails["gst_percent"]!.stringValue)%)"
        self.taxLbl.text = "$ \(String(describing: self.bookingDetails["gst_cost"]!.stringValue))"
        self.priceLbl.text = "$ \(String(describing: self.bookingDetails["cost"]!.stringValue))"
        let workhrs = minutesToHoursMinutes(minutes: self.bookingDetails["worked_mins"]!.intValue)
        
        
        if(workhrs.hours > 0)
        {
            let hr = "Hr".localized()
            let mins = "mins".localized()
            self.workingHoursLbl.text = "\(workhrs.hours) \(hr) & \(workhrs.leftMinutes) \(mins)"
//            taxTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            let arr = self.bookingDetails["alltax"]!.arrayValue
            taxTableHeight.constant = CGFloat(arr.count * 33)
        }
        else{
            let mins = "mins".localized()
            self.workingHoursLbl.text = "\(workhrs.leftMinutes) \(mins)"
            if workhrs.leftMinutes <= 1
            {
                taxTableView.isHidden = true
                taxTableHeight.constant = 0
                
            }
            else {
                let arr = self.bookingDetails["alltax"]!.arrayValue
                taxTableHeight.constant = CGFloat(arr.count * 33)
//                taxTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            }
        }
        
        self.timeLbl.text = self.bookingDetails["timing"]?.stringValue
        self.dateLbl.text = self.bookingDetails["booking_date"]?.stringValue
        self.bookingIdLbl.text = self.bookingDetails["booking_order_id"]?.stringValue
        self.billingNameLbl.text = self.bookingDetails["username"]?.stringValue
        self.providerNameLbl.text = self.bookingDetails["providername"]?.stringValue
        
        
//        self.totalLbl.text = "100"
//
//        self.price = "100"
        self.taxNameLbl.text = "VAT"
//        self.taxLbl.text = "YES"
//        self.priceLbl.text = "100"
       
        
//        if(workhrs.hours > 0){
//            self.workingHoursLbl.text = "\(workhrs.hours) Hr & \(workhrs.leftMinutes) mins"
//        }
//        else{
//            self.workingHoursLbl.text = "\(workhrs.leftMinutes) mins"
//        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            confirmButton.backgroundColor = mycolor
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if let obj = object as? UITableView
        {
            taxTableHeight.constant = taxTableView.contentSize.height
        }
    }
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()

//        self.taxTableHeight.constant = self.taxTableView.contentSize.height
       
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func initiatePayment(_ sender: Any)
    {
//        presentingViewController?.dismiss(animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int)
    {
        return (minutes / 60, (minutes % 60))
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
//        taxTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
}

extension BilingDetailsViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //        print("Count = ",self.bookingDetails["status"]!["alltax"].arrayValue.count)
        print(" dffdb = \(self.bookingDetails["alltax"]!.arrayValue)")
        return self.bookingDetails["alltax"]!.arrayValue.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaxTableViewCell", for: indexPath) as! TaxTableViewCell
        
        cell.taxNameLbl.text = "\(self.bookingDetails["alltax"]!.arrayValue[indexPath.row]["taxname"].stringValue) \(self.bookingDetails["alltax"]!.arrayValue[indexPath.row]["tax_amount"].stringValue)% "
        
        cell.taxValueLbl.text = "$ \(self.bookingDetails["alltax"]!.arrayValue[indexPath.row]["tax_totalamount"].stringValue)";
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 33
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
/*        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as! TaxTableViewCell*/
        
    }
    
}


