//
//  BookingDetailViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 29/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Nuke
import Alamofire
import SwiftSpinner
import RZTransitions
import Floaty

class BookingDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    
    

    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var floatingView: UIView!
    
    @IBOutlet weak var billingDetailsBtn: UIButton!
    
    
    var bookingDetails : [String:JSON]!
    
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bookingStatus: UILabel!
    @IBOutlet weak var serviceStatusTableConstraintConstant: NSLayoutConstraint!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var workingHours: UILabel!
    @IBOutlet weak var bookingAddress: UILabel!
    @IBOutlet weak var bookingTime: UILabel!
    @IBOutlet weak var bookingDate: UILabel!
    @IBOutlet weak var bookingId: UILabel!
    @IBOutlet weak var bookingName: UILabel!
    @IBOutlet weak var subCategoryName: UILabel!
    @IBOutlet weak var serviceStatusTableView: UITableView!
    @IBOutlet weak var trackProviderBtn: UIButton!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var taxLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var workingHoursLbl: UILabel!
    @IBOutlet weak var bookingAddressLbl: UILabel!
    @IBOutlet weak var bookingDateLbl: UILabel!
    @IBOutlet weak var bookingIdLbl: UILabel!
    @IBOutlet weak var bookingNameLbl: UILabel!
    @IBOutlet weak var vwchat: UIView!
    @IBOutlet weak var bookingStatusLbl: UILabel!
    @IBOutlet weak var imgbilling: UIImageView!
    @IBOutlet weak var cancelLbl: UILabel!
    @IBOutlet weak var serviceStatusLbl: UILabel!
    @IBOutlet weak var imgchat: UIImageView!
    var statusArray : [String] = []
    var timeStampArray : [String] = []
    var mycolor = UIColor()
    let service_Requested = "Service Requested".localized()
    let service_Accepted = "Service Accepted".localized()
    let provider_Started_to_Place = "Provider Started to Place".localized()
    let provider_Started_Job = "Provider Started Job".localized()
    let provider_Completed_Job = "Provider Completed Job".localized()
    let service_Rejected = "Service Rejected".localized()
    let service_Cancelled_by_Provider = "Service Cancelled by Provider".localized()
    let service_Cancelled_by_User = "Service Cancelled by User".localized()
    
    
    func layoutFAB()
    {
        let floaty = Floaty()
        
        floaty.hasShadow = false
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            floaty.buttonColor = mycolor
            floaty.itemButtonColor = mycolor
        }
        floaty.addItem("Cancel", icon: UIImage(named: "new_cancelled"))
        {
            item in
            
            let bookingId = self.bookingDetails["booking_order_id"]!.stringValue
            let alert = UIAlertController(title: "Confirm".localized(), message: "Are you sure you want to cancel this booking?".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                print ("YES. CANCEL BOOKING ID :\(bookingId)")
                let bookingId = self.bookingDetails["id"]?.stringValue
                print("BookingID",bookingId!)
                self.cancelBooking(bookingId: bookingId!)
            }))
            
            
            alert.addAction(UIAlertAction(title: "No".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                print ("NO.DONT CANCEL BOOKING ID :\(bookingId)")
            }))
            
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
//        floaty.addItem("Track", icon: UIImage(named: "maps-and-flags")){
//            item in
//              let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
//            let vc = stoaryboard.instantiateViewController(withIdentifier: "TrackingViewController") as! TrackingViewController
//            vc.bookingDetails = self.bookingDetails
//            self.present(vc, animated: true, completion: nil)
//
//        }
        floaty.addItem("Chat", icon: UIImage(named: "chat (1)")){
            item in
            let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let dvc = stoaryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
            dvc.receiverId = self.bookingDetails["provider_id"]!.stringValue
            dvc.bookingId = self.bookingDetails["id"]!.stringValue
            dvc.modalTransitionStyle = .crossDissolve
            
            self.present(dvc, animated: true, completion: nil)
        }
       
//        floaty.addItem("Bill", icon: UIImage(named: "payment"))
        floaty.paddingX = self.floatingView.frame.width/1.5 - floaty.frame.width/2
        floaty.fabDelegate = self
        self.view.addSubview(floaty)
    }
    func chatlayoutFAB()
    {
        let floaty = Floaty()
        floaty.hasShadow = false
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            floaty.buttonColor = mycolor
            floaty.itemButtonColor = mycolor
        }
        floaty.addItem("Track", icon: UIImage(named: "maps-and-flags")){
            item in
            let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = stoaryboard.instantiateViewController(withIdentifier: "TrackingViewController") as! TrackingViewController
            vc.bookingDetails = self.bookingDetails
            self.present(vc, animated: true, completion: nil)
            
        }
        floaty.addItem("Chat", icon: UIImage(named: "chat (1)")){
            item in
            let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let dvc = stoaryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
            dvc.receiverId = self.bookingDetails["provider_id"]!.stringValue
            dvc.bookingId = self.bookingDetails["id"]!.stringValue
            dvc.modalTransitionStyle = .crossDissolve
            
            self.present(dvc, animated: true, completion: nil)
        }
       
//         floaty.addItem("Chat", icon: UIImage(named: "chat (1)"))
        floaty.paddingX = self.floatingView.frame.width/1.5 - floaty.frame.width/2
        floaty.fabDelegate = self
        self.view.addSubview(floaty)
    }
    func cancellayoutFAB()
    {
        let floaty = Floaty()
        floaty.hasShadow = false
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            floaty.buttonColor = mycolor
            floaty.itemButtonColor = mycolor
        }
        floaty.addItem("Chat", icon: UIImage(named: "chat (1)"))
        {
            item in
            let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let dvc = stoaryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
            dvc.receiverId = self.bookingDetails["provider_id"]!.stringValue
            dvc.bookingId = self.bookingDetails["id"]!.stringValue
            dvc.modalTransitionStyle = .crossDissolve
            
            self.present(dvc, animated: true, completion: nil)
        }
//        floaty.addItem("Bill", icon: UIImage(named: "payment"))
        floaty.paddingX = self.floatingView.frame.width/1.5 - floaty.frame.width/2
        floaty.fabDelegate = self
        self.view.addSubview(floaty)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        trackProviderBtn.isHidden = true
//        layoutFAB()
//        floaty.items.count

        workingHoursLbl.text = "Hours".localized()
        totalLbl.text = "Total".localized()
        taxLbl.text = "TAX".localized()
        bookingStatusLbl.text = "Booking Status".localized()
        cancelLbl.text = "CANCEL".localized()
        bookingNameLbl.text = "Booking Name".localized()
        bookingIdLbl.text = "Booking ID".localized()
        bookingDateLbl.text = "Date and Time".localized()
        bookingAddressLbl.text = "Address".localized()
        trackProviderBtn.setTitle("Track Provider".localized(),for: .normal)
        serviceStatusLbl.text = "Service Status".localized()
        workingHoursLbl.font = FontBook.Medium.of(size: 15)
        totalLbl.font = FontBook.Medium.of(size: 15)
        taxLbl.font = FontBook.Medium.of(size: 15)
        subCategoryName.font = FontBook.Medium.of(size: 20)
        workingHours.font = FontBook.Regular.of(size: 14)
        tax.font = FontBook.Regular.of(size: 14)
        total.font = FontBook.Regular.of(size: 14)
        bookingStatus.font = FontBook.Medium.of(size: 14)
        bookingStatusLbl.font = FontBook.Medium.of(size: 15)
        cancelLbl.font = FontBook.Regular.of(size: 13)
        bookingNameLbl.font = FontBook.Medium.of(size: 15)
        bookingName.font = FontBook.Regular.of(size: 14)
        bookingIdLbl.font = FontBook.Medium.of(size: 15)
        bookingId.font = FontBook.Regular.of(size: 14)
        bookingDateLbl.font = FontBook.Medium.of(size: 15)
        bookingDate.font = FontBook.Regular.of(size: 14)
        bookingTime.font = FontBook.Regular.of(size: 14)
        bookingAddressLbl.font = FontBook.Medium.of(size: 15)
        bookingAddress.font = FontBook.Regular.of(size: 14)
        trackProviderBtn.titleLabel!.font = FontBook.Medium.of(size: 17)
        serviceStatusLbl.font = FontBook.Medium.of(size: 15)
        print(bookingDetails)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            trackProviderBtn.backgroundColor = mycolor
            workingHours.textColor = mycolor
            bookingStatus.textColor = mycolor
            total.textColor = mycolor
            changeTintColor(imgbilling, arg: mycolor)
            changeTintColor(imgchat, arg: mycolor)
            //floatingView.backgroundColor = mycolor
            changeTintColor(marker, arg: mycolor)
        }
        
        let lat = self.bookingDetails["boooking_latitude"]!.doubleValue
        let long = self.bookingDetails["booking_longitude"]!.doubleValue
        
        let styleMapUrl: String = "https://maps.googleapis.com/maps/api/staticmap?sensor=false&size=\(2 * Int(self.mapImageView.frame.size.width))x\(2 * Int(self.mapImageView.frame.size.height))&zoom=15&center=\(lat),\(long)&style=feature:administrative%7Celement:geometry%7Ccolor:0x1d1d1d%7Cweight:1&style=feature:administrative%7Celement:labels.text.fill%7Ccolor:0x93a6b5&style=feature:landscape%7Ccolor:0xeff0f5&style=feature:landscape%7Celement:geometry%7Ccolor:0xdde3e3%7Cvisibility:simplified%7Cweight:0.5&style=feature:landscape%7Celement:labels%7Ccolor:0x1d1d1d%7Cvisibility:simplified%7Cweight:0.5&style=feature:landscape.natural.landcover%7Celement:geometry%7Ccolor:0xfceff9&style=feature:poi%7Celement:geometry%7Ccolor:0xeeeeee&style=feature:poi%7Celement:labels%7Cvisibility:off%7Cweight:0.5&style=feature:poi%7Celement:labels.text%7Ccolor:0x505050%7Cvisibility:off&style=feature:poi.attraction%7Celement:labels%7Cvisibility:off&style=feature:poi.attraction%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.business%7Celement:labels%7Cvisibility:off&style=feature:poi.business%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.government%7Celement:labels%7Cvisibility:off&style=feature:poi.government%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.medical%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.park%7Celement:geometry%7Ccolor:0xa9de82&style=feature:poi.park%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.place_of_worship%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.school%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.sports_complex%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:road%7Celement:geometry%7Ccolor:0xffffff&style=feature:road%7Celement:labels.text%7Ccolor:0xc0c0c0%7Cvisibility:simplified%7Cweight:0.5&style=feature:road%7Celement:labels.text.fill%7Ccolor:0x000000&style=feature:road.highway%7Celement:geometry%7Ccolor:0xf4f4f4%7Cvisibility:simplified&style=feature:road.highway%7Celement:labels.text%7Ccolor:0x1d1d1d%7Cvisibility:simplified&style=feature:road.highway.controlled_access%7Celement:geometry%7Ccolor:0xf4f4f4&style=feature:transit%7Celement:geometry%7Ccolor:0xc0c0c0&style=feature:water%7Celement:geometry%7Ccolor:0xa5c9e1&key=\(Constants.mapsKey)"
        
        statusArray.removeAll()
        timeStampArray.removeAll()
        
        print("booking status",bookingDetails["status"]!.stringValue)
        switch bookingDetails["status"]!.stringValue {
            
        case "Completedjob":
            bookingStatus.text = "Payment pending".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.31, blue:0.13, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//           self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Accepted)
            statusArray.append(provider_Started_to_Place)
            statusArray.append(provider_Started_Job)
            statusArray.append(provider_Completed_Job)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Accepted_time"]!.stringValue)
            timeStampArray.append(bookingDetails["StarttoCustomerPlace_time"]!.stringValue)
            timeStampArray.append(bookingDetails["startjob_timestamp"]!.stringValue)
            timeStampArray.append(bookingDetails["endjob_timestamp"]!.stringValue)
            
        case "Waitingforpaymentconfirmation":
            bookingStatus.text = "Payment pending".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//         self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Accepted)
            statusArray.append(provider_Started_to_Place)
            statusArray.append(provider_Started_Job)
            statusArray.append(provider_Completed_Job)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Accepted_time"]!.stringValue)
            timeStampArray.append(bookingDetails["StarttoCustomerPlace_time"]!.stringValue)
            timeStampArray.append(bookingDetails["startjob_timestamp"]!.stringValue)
            timeStampArray.append(bookingDetails["endjob_timestamp"]!.stringValue)
            
        case "Reviewpending":
            bookingStatus.text = "Review pending".localized()
            bookingStatus.textColor = UIColor(red:0.10, green:0.77, blue:0.49, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//             self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Accepted)
            statusArray.append(provider_Started_to_Place)
            statusArray.append(provider_Started_Job)
            statusArray.append(provider_Completed_Job)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Accepted_time"]!.stringValue)
            timeStampArray.append(bookingDetails["StarttoCustomerPlace_time"]!.stringValue)
            timeStampArray.append(bookingDetails["startjob_timestamp"]!.stringValue)
            timeStampArray.append(bookingDetails["endjob_timestamp"]!.stringValue)
            
        case "Finished":
            bookingStatus.text = "Job Completed".localized()
            bookingStatus.textColor = UIColor(red:0.10, green:0.77, blue:0.49, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//             self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Accepted)
            statusArray.append(provider_Started_to_Place)
            statusArray.append(provider_Started_Job)
            statusArray.append(provider_Completed_Job)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Accepted_time"]!.stringValue)
            timeStampArray.append(bookingDetails["StarttoCustomerPlace_time"]!.stringValue)
            timeStampArray.append(bookingDetails["startjob_timestamp"]!.stringValue)
            timeStampArray.append(bookingDetails["endjob_timestamp"]!.stringValue)
        case "StarttoCustomerPlace":
            bookingStatus.text = "On the way".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.31, blue:0.13, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//             self.view.willRemoveSubview(floaty)
           chatlayoutFAB()
            statusArray.append(service_Requested)
            statusArray.append(service_Accepted)
            statusArray.append(provider_Started_to_Place)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Accepted_time"]!.stringValue)
            timeStampArray.append(bookingDetails["StarttoCustomerPlace_time"]!.stringValue)
            
        case "Startedjob":
            bookingStatus.text = "Work in progress".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.31, blue:0.13, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            self.view.willRemoveSubview(floaty)
            cancellayoutFAB()
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Accepted)
            statusArray.append(provider_Started_to_Place)
            statusArray.append(provider_Started_Job)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Accepted_time"]!.stringValue)
            timeStampArray.append(bookingDetails["StarttoCustomerPlace_time"]!.stringValue)
            timeStampArray.append(bookingDetails["startjob_timestamp"]!.stringValue)
        case "Pending":
            bookingStatus.text = "Pending".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
//            self.view.willRemoveSubview(floaty)
            statusArray.append(service_Requested)
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            
        case "Accepted":
            bookingStatus.text = "Accepted".localized()
            bookingStatus.textColor = UIColor(red:0.10, green:0.77, blue:0.49, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//            floaty.removeItem(index: 1)
            
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
//            self.view.willRemoveSubview(floaty)
            layoutFAB()
            statusArray.append(service_Requested)
            statusArray.append(service_Accepted)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Accepted_time"]!.stringValue)
            
        case "Rejected":
            bookingStatus.text = "Rejected".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Rejected)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["Rejected_time"]!.stringValue)
            
        case "CancelledbyProvider":
            bookingStatus.text = "Cancelled by Provider".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//            self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Cancelled_by_Provider)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["CancelledbyProvider_time"]!.stringValue)
        case "CancelledbyUser":
            bookingStatus.text = "Cancelled by User".localized()
            bookingStatus.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            cancelView.isHidden = true
            vwchat.isHidden = true
//            self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
            statusArray.append(service_Requested)
            statusArray.append(service_Cancelled_by_User)
            
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
            timeStampArray.append(bookingDetails["CancelledbyUser_time"]!.stringValue)
        default:
            bookingStatus.text = "Pending".localized()
            cancelView.isHidden = true
            vwchat.isHidden = true
//           self.view.willRemoveSubview(floaty)
//            floaty.removeItem(index: 1)
//            floaty.removeItem(index: 2)
//            floaty.removeItem(index: 0)
            bookingStatus.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            statusArray.append(service_Requested)
            timeStampArray.append(bookingDetails["Pending_time"]!.stringValue)
        }
        
        print(styleMapUrl)
        if let url = URL(string: styleMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        {
            Nuke.loadImage(with: url, into: self.mapImageView)
        }
        
        serviceStatusTableView.delegate = self
        serviceStatusTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        if(bookingDetails["status"]?.stringValue == "Completedjob" || bookingDetails["status"]?.stringValue == "Waitingforpaymentconfirmation" ||
            bookingDetails["status"]?.stringValue == "Reviewpending" ||
            bookingDetails["status"]?.stringValue == "Finished")
        {
            
            self.trackProviderBtn.isHidden = true
            
            
//            vwchat.isHidden = true
            self.total.text = "₦\(bookingDetails["total_cost"]!.stringValue)"
            self.tax.text = bookingDetails["gst_cost"]!.stringValue
            self.price.text = "₦\(bookingDetails["cost"]!.stringValue)"
            self.taxLbl.text = "\(bookingDetails["tax_name"]!.stringValue) (\(bookingDetails["gst_percent"]!.stringValue)%)"
            
            
            let workhrs = minutesToHoursMinutes(minutes: bookingDetails["worked_mins"]!.intValue)
            if(workhrs.hours > 0){
                self.workingHours.text = "\(workhrs.hours) Hr & \(workhrs.leftMinutes) mins"
            }
            else{
                self.workingHours.text = "\(workhrs.leftMinutes) mins"
            }
            
            self.bookingAddress.text = bookingDetails["address_line_1"]!.stringValue
            self.bookingTime.text = bookingDetails["timing"]!.stringValue
            self.bookingDate.text = bookingDetails["booking_date"]!.stringValue
            self.bookingId.text = bookingDetails["booking_order_id"]!.stringValue
            self.bookingName.text = bookingDetails["username"]!.stringValue
            self.subCategoryName.text = bookingDetails["sub_category_name"]!.stringValue
            
        }
        else if(bookingDetails["status"]?.stringValue == "StarttoCustomerPlace")
        {
            
//            self.trackProviderBtn.isHidden = false
            priceViewHeightConstraint.constant = 0
            priceView.layoutIfNeeded()
            scrollView.layoutIfNeeded()
//            vwchat.isHidden = false
            
            self.bookingAddress.text = bookingDetails["address_line_1"]!.stringValue
            self.bookingTime.text = bookingDetails["timing"]!.stringValue
            self.bookingDate.text = bookingDetails["booking_date"]!.stringValue
            self.bookingId.text = bookingDetails["booking_order_id"]!.stringValue
            self.bookingName.text = bookingDetails["username"]!.stringValue
            self.subCategoryName.text = bookingDetails["sub_category_name"]!.stringValue
        }
        else if bookingDetails["status"]?.stringValue == "Startedjob"
        {
            
            self.trackProviderBtn.isHidden = true
            priceViewHeightConstraint.constant = 0
            priceView.layoutIfNeeded()
            scrollView.layoutIfNeeded()
//            vwchat.isHidden = false
            
            self.bookingAddress.text = bookingDetails["address_line_1"]!.stringValue
            self.bookingTime.text = bookingDetails["timing"]!.stringValue
            self.bookingDate.text = bookingDetails["booking_date"]!.stringValue
            self.bookingId.text = bookingDetails["booking_order_id"]!.stringValue
            self.bookingName.text = bookingDetails["username"]!.stringValue
            self.subCategoryName.text = bookingDetails["sub_category_name"]!.stringValue
            
        }
        else{
            self.trackProviderBtn.isHidden = true
            priceViewHeightConstraint.constant = 0
            priceView.layoutIfNeeded()
            scrollView.layoutIfNeeded()
            
//            vwchat.isHidden = true
            
            self.workingHours.text = bookingDetails["worked_mins"]!.stringValue
            self.bookingAddress.text = bookingDetails["address_line_1"]!.stringValue
            self.bookingTime.text = bookingDetails["timing"]!.stringValue
            self.bookingDate.text = bookingDetails["booking_date"]!.stringValue
            self.bookingId.text = bookingDetails["booking_order_id"]!.stringValue
            self.bookingName.text = bookingDetails["username"]!.stringValue
            self.subCategoryName.text = bookingDetails["sub_category_name"]!.stringValue
        }
        
        let serviceStatusTableViewHeight = 75 * statusArray.count
        serviceStatusTableView.rowHeight = UITableViewAutomaticDimension
        serviceStatusTableView.estimatedRowHeight = 75
        
        
        serviceStatusTableView.frame = CGRect.init(x: serviceStatusTableView.frame.origin.x, y: serviceStatusTableView.frame.origin.y, width: serviceStatusTableView.frame.size.width, height: CGFloat(serviceStatusTableViewHeight))
        serviceStatusTableConstraintConstant.constant = CGFloat(serviceStatusTableViewHeight)
        serviceStatusTableView.reloadData()
        serviceStatusTableView.layoutIfNeeded()
        
        
    }
    
    
    @IBAction func btnMessages(_ sender: Any)
    {
        let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let dvc = stoaryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
        dvc.receiverId = bookingDetails["provider_id"]!.stringValue
        dvc.bookingId = bookingDetails["id"]!.stringValue
        dvc.modalTransitionStyle = .crossDissolve

        self.present(dvc, animated: true, completion: nil)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceStatusTableViewCell", for: indexPath) as! ServiceStatusTableViewCell
        cell.statusIdentifier.text = statusArray[indexPath.row]
        cell.statusTime.text = getReadableDate(inputDate: timeStampArray[indexPath.row])
        if(indexPath.row == 0)
        {
            cell.statusIdentifier.textColor = UIColor.lightGray
            cell.centerCircle.layer.borderWidth = 1
            
            cell.topLine.isHidden = true
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                cell.centerCircle.layer.borderColor = mycolor.cgColor
                cell.centerCircle.backgroundColor = UIColor.white
              cell.bottomLine.backgroundColor = mycolor
              cell.bottomLine.isHidden = false
            }
            else
            {
                cell.centerCircle.layer.borderColor = UIColor(red:0.42, green:0.50, blue:0.99, alpha:1.0).cgColor
                cell.centerCircle.backgroundColor = UIColor.white
                cell.bottomLine.isHidden = false
            }
            
            if(indexPath.row == statusArray.count - 1)
            {
                cell.bottomLine.isHidden = true
            }
        }
        else if(indexPath.row == statusArray.count-1)
        {
            cell.statusIdentifier.textColor = UIColor(red:0.20, green:0.21, blue:0.28, alpha:1.0)
            
            cell.centerCircle.layer.borderWidth = 1
           
//            cell.topLine.isHidden = false
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                cell.topLine.isHidden = false
                cell.topLine.backgroundColor = mycolor
                cell.centerCircle.layer.borderColor = mycolor.cgColor
                cell.centerCircle.backgroundColor = mycolor
            }
            else {
                 cell.topLine.isHidden = false
                cell.centerCircle.layer.borderColor = UIColor(red:0.42, green:0.50, blue:0.99, alpha:1.0).cgColor
                cell.centerCircle.backgroundColor = UIColor(red:0.42, green:0.50, blue:0.99, alpha:1.0)
            }
            cell.bottomLine.isHidden = true
        }
        else{
            cell.statusIdentifier.textColor = UIColor.lightGray
            cell.centerCircle.layer.borderWidth = 1
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                cell.topLine.isHidden = false
                cell.bottomLine.isHidden = false
                cell.topLine.backgroundColor = mycolor
                cell.bottomLine.backgroundColor = mycolor
                cell.centerCircle.layer.borderColor = mycolor.cgColor
                cell.centerCircle.backgroundColor = UIColor.white
            }
            else
            {
                cell.centerCircle.layer.borderColor = UIColor(red:0.42, green:0.50, blue:0.99, alpha:1.0).cgColor
                cell.centerCircle.backgroundColor = UIColor.white
                cell.topLine.isHidden = false
                cell.bottomLine.isHidden = false
            }
        }
        return cell
    }
    
    func getReadableDate(inputDate : String) -> String
    {
        print(inputDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+05:30") //Current time zone
        if let date = dateFormatter.date(from: inputDate) //according to date format your date string
        {
            print(date) //Convert String to Date
        
            dateFormatter.dateFormat = "d MMM, yyyy HH:mm a" //Your New Date format as per requirement change it own
            let newDate = dateFormatter.string(from: date) //pass Date here
            
                print(newDate) //New formatted Date string
                return newDate
        }
        else{
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    

    func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int) {
        return (minutes / 60, (minutes % 60))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelBooking(_ sender: Any) {
//        let bookingId = self.bookingDetails["booking_order_id"]!.stringValue
//        let alert = UIAlertController(title: "Confirm".localized(), message: "Are you sure you want to cancel this booking?".localized(), preferredStyle: UIAlertControllerStyle.alert)
//
//        alert.addAction(UIAlertAction(title: "Yes".localized(), style: UIAlertActionStyle.default, handler: {
//            (alert: UIAlertAction!) in
//            print ("YES. CANCEL BOOKING ID :\(bookingId)")
//            let bookingId = self.bookingDetails["id"]?.stringValue
//            print(bookingId)
//            self.cancelBooking(bookingId: bookingId!)
//        }))
//
//
//        alert.addAction(UIAlertAction(title: "No".localized(), style: UIAlertActionStyle.default, handler: {
//            (alert: UIAlertAction!) in
//            print ("NO.DONT CANCEL BOOKING ID :\(bookingId)")
//        }))
//
//
//        // show the alert
//        self.present(alert, animated: true, completion: nil)
    }
    
    func cancelBooking(bookingId: String)
    {
        var headers : HTTPHeaders!
        if let accesstoken = UserDefaults.standard.string(forKey: "access_token") as String!
        {
            headers = [
                "Authorization": accesstoken,
                "Accept": "application/json"
            ]
        }
        else
        {
            headers = [
                "Authorization": "",
                "Accept": "application/json"
            ]
        }
        
        var booking = ""
        if SharedObject().hasData(value: bookingId){
            booking = bookingId
        }
        let params: Parameters = [
            "id": booking
        ]
        print("parameters",params)
        SwiftSpinner.show("Cancelling your Booking...".localized())
        
        let url = APIList().getUrlString(url: .CANCELBYUSER)

        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("CANCEL JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                        self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let vc = stoaryboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
                        self.showAlert(title: "Oops".localized(), msg: "The Booking has been canceled".localized())
//                        self.view.willRemoveSubview(self.floaty)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else{
                SwiftSpinner.hide()
                print(response.error.debugDescription)
                self.showAlert(title: "Oops".localized(), msg: response.error!.localizedDescription)
                
            }
        }
    }
    
    @IBAction func trackProvider(_ sender: Any) {
        let stoaryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = stoaryboard.instantiateViewController(withIdentifier: "TrackingViewController") as! TrackingViewController
        vc.bookingDetails = self.bookingDetails
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }*/
    @IBAction func billingDetailsAtn(_ sender: Any)
    {
//        self.transitioningDelegate = RZTransitionsManager.shared()
//        let nextViewController = UIViewController()
//        nextViewController.transitioningDelegate = RZTransitionsManager.shared()
//        self.presentViewController(nextViewController, animated:true) {}

        
        let storyboard: UIStoryboard = UIStoryboard(name: "SecondStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BilingDetailsViewController") as! BilingDetailsViewController
        
        vc.modalPresentationStyle = .overCurrentContext
        
        vc.bookingDetails = self.bookingDetails["invoicedetails"]?.arrayValue[0].dictionaryValue
        self.present(vc, animated: true, completion: nil)
        
    }
    
}

extension BookingDetailViewController : FloatyDelegate
{
    // MARK: - Floaty Delegate Methods
    func floatyWillOpen(_ floaty: Floaty) {
        print("Floaty Will Open")
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
        print("Floaty Did Open")
    }
    
    func floatyWillClose(_ floaty: Floaty)
    {
        print("Floaty Will Close")
    }
    
    func floatyDidClose(_ floaty: Floaty) {
        print("Floaty Did Close",floaty)
    }
    
}
