//
//  BookingsViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 13/10/17.
//  Copyright © 2017 Uberdoo. All r ights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Nuke
import UserNotifications

class BookingsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UNUserNotificationCenterDelegate {
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var vwtop: UIView!
    
    @IBOutlet weak var noBookingsLbl: UILabel!
    @IBOutlet weak var noBookingsImage: UIImageView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var tableView: UITableView!

    var bookings : [JSON] = []
    var mycolor = UIColor()
    var isLoginSkipped:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } 
        // Do any additional setup after loading the view.
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localized())
        refreshControl.addTarget(self, action:  #selector(BookingsViewController.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(BookingsViewController.refresh(sender:)), name: NSNotification.Name(rawValue: "Refresh"), object: nil)


        getMyBookings()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if(UserDefaults.standard.bool(forKey: "isLoggedInSkipped") != nil){
            isLoginSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
        }
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            tabBarController?.tabBar.tintColor = mycolor
            
        }
        if(MainViewController.reloadPage)
        {
            getMyBookings()
        }
        
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        getMyBookings()
    }
    @objc func trackPressed(sender:UIButton!) {
        print("Track Clicked \(sender.tag)")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrackingViewController") as! TrackingViewController
        vc.bookingDetails = self.bookings[sender.tag].dictionary
        MainViewController.changePage = false
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func cancelPressed(sender:UIButton!) {
        print("Cancel Clicked \(sender.tag)")
        
        let alert = UIAlertController(title: "Confirm".localized(), message: "Are you sure you want to cancel this booking?".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            print ("YES. CANCEL BOOKING ID :\(self.bookings[sender.tag]["booking_order_id"].stringValue)")
            let bookingId = self.bookings[sender.tag]["id"].stringValue
            self.cancelBooking(bookingId: bookingId)
        }))
        
        
        alert.addAction(UIAlertAction(title: "No".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            print ("NO.DONT CANCEL BOOKING ID :\(self.bookings[sender.tag]["booking_order_id"].stringValue)")
        }))
        
       
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    func getMyBookings(){
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
        print("header = \(headers!)")
        SwiftSpinner.show("Fetching your Bookings...".localized())
        let url = APIList().getUrlString(url: .VIEWBOOKINGS)
        Alamofire.request(url,method: .get, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                self.refreshControl.endRefreshing()
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("BOOKINGS JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                        self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
                        self.bookings = jsonResponse["all_bookings"].arrayValue
                        if self.bookings.count == 0 {
                            self.vwtop.isHidden = false
                            if(self.isLoginSkipped == false){
                                self.noBookingsLbl.text = "You have no bookings available".localized()
                                self.noBookingsImage.image = UIImage(named: "empty")
                            }else{
                                self.noBookingsLbl.text = "Please Sign-in to access this feature".localized()
                                self.noBookingsImage.image = UIImage(named: "block1")
                            }
                        }
                        else {
                            self.vwtop.isHidden = true
                        }
                        self.tableView.dataSource = self
                        self.tableView.delegate = self
                        self.tableView.reloadData()
                        self.getAppSettings()
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
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }*/
   
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
        
        let params: Parameters = [
            "id": bookingId
        ]
        SwiftSpinner.show("Cancelling your Booking...".localized())
        let url = APIList().getUrlString(url: .CANCELBYUSER)

        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                self.refreshControl.endRefreshing()
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
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
                        self.getMyBookings()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingTableCell", for: indexPath) as! BookingTableCell
        cell.subCategoryName.text = self.bookings[indexPath.row]["sub_category_name"].stringValue
        cell.serviceDate.text = self.bookings[indexPath.row]["booking_date"].stringValue
        cell.serviceTime.text = self.bookings[indexPath.row]["timing"].stringValue
//        if let imageURL = URL.init(string:self.bookings[indexPath.row]["image"].stringValue)
//        {
//            Nuke.loadImage(with: imageURL, into: cell.subCategoryImage)
//        }
        
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
            //            cell.groupTitle.textColor = mycolor
            changeTintColor(cell.subCategoryImage, arg: mycolor)
            print("mycolor****",mycolor)
        }
        else
        {
            if let imageURL = URL.init(string:self.bookings[indexPath.row]["image"].stringValue)
            {
                Nuke.loadImage(with: imageURL, into: cell.subCategoryImage)
            }
        }
        
        let status = self.bookings[indexPath.row]["status"].stringValue
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.providerName.text = self.bookings[indexPath.row]["providername"].stringValue
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
            //            cell.groupTitle.textColor = mycolor
          
            if let imageURL = URL.init(string:self.bookings[indexPath.row]["image"].stringValue)
            {
                Nuke.loadImage(with: imageURL, into: cell.subCategoryImage)
            }
            else {
                  changeTintColor(cell.subCategoryImage, arg: mycolor)
                
    
                
            }
            print("mycolor****",mycolor)
        }
        else {
            if let imageURL = URL.init(string:self.bookings[indexPath.row]["image"].stringValue)
            {
                Nuke.loadImage(with: imageURL, into: cell.subCategoryImage)
            }
        }
        
                if #available(iOS 11.0, *) {
                    cell.cornerView.clipsToBounds = true
                    cell.cornerView.layer.cornerRadius = 10
        
                    cell.cornerView.layer.maskedCorners = [.layerMaxXMaxYCorner]
                } else {
                    // Fallback on earlier versions
                    cell.cornerView.clipsToBounds = true
                    let maskPath = UIBezierPath(roundedRect: cell.cornerView.bounds,
                                                byRoundingCorners: [.bottomRight],
                                                cornerRadii: CGSize(width: 10.0, height: 10.0))
                    let shape = CAShapeLayer()
                    shape.path = maskPath.cgPath
                    cell.cornerView.layer.mask = shape
        
                }

        if(status == "Pending")
        {
            
            cell.bookingStatusImageView.image = UIImage(named: "pending_red")
            cell.bookingStatusLbl.text = "Pending".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            
            cell.cornerView.isHidden = false
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = true
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 1), for: UIControlState.normal)
            
        }
        else if(status == "Rejected")
        {
            cell.bookingStatusImageView.image = UIImage(named: "new_cancelled")
            cell.bookingStatusLbl.text = "Rejected".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            
            
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = false
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
        }
        else if(status == "Accepted")
        {
            cell.bookingStatusImageView.image = UIImage(named: "finished_green")
            cell.bookingStatusLbl.text = "Accepted".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.10, green:0.77, blue:0.49, alpha:1.0)
            
            cell.cornerView.isHidden = false
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = true
           
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 1), for: UIControlState.normal)
        }
        else if(status == "CancelledbyUser")
        {
            cell.bookingStatusImageView.image = UIImage(named: "new_cancelled")
            cell.bookingStatusLbl.text = "Cancelled by User".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = false
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            
        }
        else if(status == "CancelledbyProvider")
        {
            cell.bookingStatusImageView.image = UIImage(named: "new_cancelled")
            cell.bookingStatusLbl.text = "Cancelled by Provider".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.13, blue:0.19, alpha:1.0)
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = false
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
        }
        else if(status == "StarttoCustomerPlace")
        {
            cell.bookingStatusImageView.image = UIImage(named: "start_to_place")
            cell.bookingStatusLbl.text = "On the way".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.31, blue:0.13, alpha:1.0)
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = true
            cell.cancel.isUserInteractionEnabled = false
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 1), for: UIControlState.normal)
        }
        else if(status == "Startedjob")
        {
            cell.bookingStatusImageView.image = UIImage(named: "start_job")
            cell.bookingStatusLbl.text = "Work in progress".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.31, blue:0.13, alpha:1.0)
            
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = true
            cell.cancel.isUserInteractionEnabled = false
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 1), for: UIControlState.normal)
            
            
        }
        else if(status == "Completedjob")
        {
            cell.bookingStatusImageView.image = UIImage(named: "pay")
            cell.bookingStatusLbl.text = "Payment pending".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.31, blue:0.13, alpha:1.0)
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = false
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            
        }
        else if(status == "Waitingforpaymentconfirmation")
        {
            cell.bookingStatusImageView.image = UIImage(named: "pay")
            cell.bookingStatusLbl.text = "Payment pending".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.89, green:0.31, blue:0.13, alpha:1.0)
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = false
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
        }
        else if(status == "Reviewpending")
        {
            cell.bookingStatusImageView.image = UIImage(named: "new_finished")
            cell.bookingStatusLbl.text = "Review pending".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.10, green:0.77, blue:0.49, alpha:1.0)
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = false
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
        }
        else if(status == "Finished")
        {
            cell.bookingStatusImageView.image = UIImage(named: "new_finished")
            cell.bookingStatusLbl.text = "Job Completed".localized()
            cell.bookingStatusLbl.textColor = UIColor(red:0.10, green:0.77, blue:0.49, alpha:1.0)
            
            cell.cornerView.isHidden = true
            cell.track.isUserInteractionEnabled = false
            cell.cancel.isUserInteractionEnabled = false
            cell.track.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
            cell.cancel.setTitleColor(UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.25), for: UIControlState.normal)
        }
        cell.track.tag = indexPath.row
        cell.cancel.tag = indexPath.row
        cell.cancel.addTarget(self, action: #selector(self.cancelPressed(sender:)), for: .touchUpInside)
        cell.track.addTarget(self, action: #selector(self.trackPressed(sender:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let stoaryboard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
        let vc = stoaryboard.instantiateViewController(withIdentifier: "BookingDetailViewController")as! BookingDetailViewController
        MainViewController.changePage = false
        vc.bookingDetails = self.bookings[indexPath.row].dictionary
        self.present(vc, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookings.count
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        let dct : NSDictionary = userInfo as NSDictionary
        
        print("dct = ",dct)
        
        if (dct.object(forKey: "notification_type") != nil)
        {
            let type = dct.object(forKey: "notification_type") as! String
            
            if type == "chat"
            {
                
                let receiver_id = dct.object(forKey: "sender_id") as! String
                
                if appDelegate.chatReceiveID == ""
                {
                    completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
                }
                else
                {
                    
                    
                }
                
            }
            else
            {
                getAppSettings()
                getMyBookings()
                completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
                
            }
        }
        else
        {
            getAppSettings()
            getMyBookings()
            
            completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
            
            
            
        }
        
    }
    
    
    func getAppSettings(){
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
        let url = APIList().getUrlString(url: .APPSETTINGS)

        Alamofire.request(url,method: .get, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                if let json = response.result.value {
                    print("APP SETTINGS JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                        self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else if(jsonResponse["delete_status"].stringValue == "active")
                    {
                        print(jsonResponse["delete_status"].stringValue)
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        let alert = UIAlertController(title: "Attenction!".localized(), message: "HI! Your Account Has Been Suspended By Admin. For Further Information Please Contact admin@uberdoo.com".localized(), preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                            self.present(vc, animated: true, completion: nil)
                        }))
                        // alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else{
                        Constants.locations = jsonResponse["location"].arrayValue
                        Constants.timeSlots = jsonResponse["timeslots"].arrayValue
                        
                        let statusArray = jsonResponse["status"].arrayValue;
                        if(statusArray.count > 0){
                            let statusDict = statusArray[0].dictionary
                            let currentStatus = statusDict!["status"]?.stringValue
                            if(currentStatus == "Completedjob")
                            {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
                                vc.bookingDetails = statusDict
                                vc.modalPresentationStyle = .overCurrentContext
                                self.present(vc, animated: true, completion: nil)
                            }
                            else if(currentStatus == "Waitingforpaymentconfirmation"){
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WaitingForPaymentConfirmationViewController") as! WaitingForPaymentConfirmationViewController
                                vc.bookingDetails = statusDict
                                self.present(vc, animated: true, completion: nil)
                            }
                            else if(currentStatus == "Reviewpending"){
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as!     ReviewViewController
                                vc.bookingDetails = statusDict
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            else{
                print(response.error!.localizedDescription)
                //                self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
}
