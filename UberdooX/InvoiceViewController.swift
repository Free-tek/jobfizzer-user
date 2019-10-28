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
import Stripe

class InvoiceViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UNUserNotificationCenterDelegate/*,STPPaymentContextDelegate*/
{
    @IBOutlet weak var paymenTitleLbl: UILabel!
    @IBOutlet weak var invoiceLbl: UILabel!
    @IBOutlet weak var cnameLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var pnameLbl: UILabel!
    @IBOutlet weak var billNameLbl: UILabel!
    @IBOutlet weak var bidLbl: UILabel!
    @IBOutlet weak var datLbl: UILabel!
    @IBOutlet weak var timLbl: UILabel!
    @IBOutlet weak var whoursLbl: UILabel!
    @IBOutlet weak var prLbl: UILabel!
    @IBOutlet weak var totLbl: UILabel!
    @IBOutlet weak var discountHeight: NSLayoutConstraint!
    
    @IBOutlet weak var miscellaneousDetailLbl: UILabel!
    @IBOutlet weak var invoiceMiscellaneousTableView: UITableView!
    @IBOutlet weak var invoiceMiscellaneousTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var taxDetailLbl: UILabel!
    @IBOutlet weak var taxTableView: UITableView!
    @IBOutlet weak var taxTableHeight: NSLayoutConstraint!

    @IBOutlet weak var addCouponBackgroundView: UIView!
    @IBOutlet weak var addCouponView: CardView!
    @IBOutlet weak var addCouponViewY: NSLayoutConstraint!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var couponCodeText: UITextField!
    @IBOutlet weak var okCouponBtn: UIButton!
    @IBOutlet weak var cancelCouponBtn: UIButton!
    @IBOutlet weak var couponApplyImgView: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
    var isCoupon_Applied = ""
    var iscouponApplied : Bool = false
    var viewHeight : CGFloat = 0.0

    @IBOutlet weak var offerLbl: UILabel!
    
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var selectedCardDetailsLbl: UILabel!
    @IBOutlet weak var selectedCardLbl: UILabel!
/*    private let customerContext: STPCustomerContext
    private let paymentContext: STPPaymentContext   */
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
    @IBOutlet weak var paymentTypes: UICollectionView!
    var bookingDetails : [String:JSON]!
    var paymentTypeNames: [String] = ["Cash","Card"]
    var paymentTypeImageSelected: [String] = ["icon","credit-card"]
    var paymentTypeImageUnSelected: [String] = ["icon","credit-card"]
    var selectedPaymentTypes: [Bool] = [true,false]
    private var price = "0"
    
    var payment : [String:JSON]!
    var authorizeURL = ""
    //{        didSet {
    //            // Forward value to payment context
    //            paymentContext.pa = Int(price)
    //        }
    //    }
    
    @IBOutlet weak var confirmButton: UIButton!
    var mycolor = UIColor()
  
 /*   required init?(coder aDecoder: NSCoder) {
        let config = STPPaymentConfiguration.shared()
        config.publishableKey = "pk_test_kDAKKfqc7yUrjxvl9hS7Ycwn"
        config.companyName = "self.companyName"
        config.requiredBillingAddressFields = STPBillingAddressFields.none
        config.requiredShippingAddressFields = .none
        config.shippingType = STPShippingType.delivery
        
        //
        //        let theme = STPTheme()
        //        theme.primaryBackgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
        //        theme.secondaryBackgroundColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.00)
        //        theme.primaryForegroundColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.00)
        //        theme.secondaryForegroundColor = UIColor(red:0.66, green:0.66, blue:0.66, alpha:1.00)
        ////        theme.accentColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.00)// UIColor(red:107/255, green:127/255, blue:252/255, alpha:1.00)
        //        theme.errorColor = UIColor(red:0.87, green:0.18, blue:0.20, alpha:1.00)
        //        theme.font = UIFont(name: "Ubuntu-Regular", size: 17)
        //        theme.emphasisFont = UIFont(name: "Ubuntu-Bold", size: 17)
        //
        customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        paymentContext = STPPaymentContext(customerContext: customerContext,configuration:config,theme:STPTheme.default())
        
        super.init(coder: aDecoder)
        
        // Create card sources instead of card tokens
        
    }   */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paymentTypes.delegate = self
        self.paymentTypes.dataSource = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        paymenTitleLbl.text = "PAYMENT METHOD".localized()
        invoiceLbl.text = "INVOICE".localized()
        cnameLbl.text = "Apply Coupon".localized()
//        discountLbl.text = "Discount \(couponCodeText.text!)".localized()
        pnameLbl.text = "Provider Name".localized()
        billNameLbl.text = "Billing Name".localized()
        bidLbl.text = "Booking ID".localized()
        datLbl.text = "Date".localized()
        timLbl.text = "Time".localized()
        whoursLbl.text = "Working Hours".localized()
        prLbl.text = "Price".localized()
        taxNameLbl.text = "Tax".localized()
        totLbl.text = "TOTAL".localized()
        selectedCardLbl.text = "Selected Card :".localized()
        addCardButton.setTitle("ADD CARD".localized(),for: .normal)
        changeButton.setTitle("Change".localized(),for: .normal)
        
        paymenTitleLbl.font = FontBook.Medium.of(size: 20)
        invoiceLbl.font = FontBook.Medium.of(size: 20)
        cnameLbl.font = FontBook.Regular.of(size: 16)
        discountLbl.font = FontBook.Regular.of(size: 16)
        pnameLbl.font = FontBook.Regular.of(size: 16)
        billNameLbl.font = FontBook.Regular.of(size: 16)
        bidLbl.font = FontBook.Regular.of(size: 16)
        datLbl.font = FontBook.Regular.of(size: 16)
        timLbl.font = FontBook.Regular.of(size: 16)
        whoursLbl.font = FontBook.Regular.of(size: 16)
        prLbl.font = FontBook.Regular.of(size: 16)
        taxNameLbl.font = FontBook.Regular.of(size: 16)
        totLbl.font = FontBook.Regular.of(size: 16)
        selectedCardLbl.font = FontBook.Regular.of(size: 17)
        addCardButton.titleLabel!.font = FontBook.Medium.of(size: 17)
        changeButton.titleLabel!.font = FontBook.Medium.of(size: 16)
        
        
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
        selectedCardDetailsLbl.font = FontBook.Regular.of(size: 16)
      
        addCouponBackgroundView.isHidden = true
        addCouponView.isHidden = true
        
        discountHeight.constant = 0
        
        taxTableView.delegate = self
        taxTableView.dataSource = self
        
        taxTableHeight.constant = 0
        
        invoiceMiscellaneousTableView.delegate = self
        invoiceMiscellaneousTableView.dataSource = self
        invoiceMiscellaneousTableView.separatorStyle = .none
        
        invoiceMiscellaneousTableHeight.constant = 0
        
        miscellaneousDetailLbl.text = "Miscellaneous Details".localized()
        taxDetailLbl.text = "Tax Details".localized()
        
        taxTableView.separatorStyle = .none
        selectedCardLbl.isHidden = true
        selectedCardDetailsLbl.isHidden = true
        changeButton.isHidden = true
        isCoupon_Applied = self.bookingDetails["coupon_applied"]!.stringValue
        print("isCoupon_Applied = ",isCoupon_Applied)
        offerLbl.textColor = UIColor.red
        if isCoupon_Applied == ""
        {
            iscouponApplied = false
            offerLbl.text = "-0"
            self.discountLbl.text = "No discount applied".localized()
            discountHeight.constant = 0
        }
        else
        {
            iscouponApplied = true
            offerLbl.text = "-" + self.bookingDetails["off"]!.stringValue
            cnameLbl.text = isCoupon_Applied.uppercased()
            discountHeight.constant = 18
            let str1 = "Discount".localized()
            var str2 = isCoupon_Applied.uppercased()
            print("STring 2:",str2)
            self.discountLbl.text = "\(str1) (\(str2))".localized()
        }
        
        if iscouponApplied == true
        {
            couponApplyImgView.image = UIImage(named: "new_cancelled")
        }
        else
        {
            couponApplyImgView.image = UIImage(named: "new_arrow_right")
        }
        
        self.totalLbl.text = "$ \(String(describing: self.bookingDetails["total_cost"]!.stringValue))"
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
            if(arr.count == 0){
                taxTableHeight.constant = 0
            }else{
                taxTableHeight.constant = CGFloat(arr.count * 33)+33
            }
            
            let miscArr = self.bookingDetails["material_details"]!.arrayValue
            if(miscArr.count == 0){
                invoiceMiscellaneousTableHeight.constant = 0
            }else{
                invoiceMiscellaneousTableHeight.constant = CGFloat(miscArr.count * 33)+33
            }
        }
        else
        {
            let mins = "mins".localized()
            self.workingHoursLbl.text = "\(workhrs.leftMinutes) \(mins)"
            if workhrs.leftMinutes <= 1
            {
                //taxTableView.isHidden = true
//                 taxTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
                let arr = self.bookingDetails["alltax"]!.arrayValue
                if(arr.count == 0){
                    taxTableHeight.constant = 0
                }else{
                    taxTableHeight.constant = CGFloat(arr.count * 33)+33
                }
                
                let miscArr = self.bookingDetails["material_details"]!.arrayValue
                if(miscArr.count == 0){
                    invoiceMiscellaneousTableHeight.constant = 0
                }else{
                    invoiceMiscellaneousTableHeight.constant = CGFloat(miscArr.count * 33)+33
                }
            }
            else {
                let arr = self.bookingDetails["alltax"]!.arrayValue
                if(arr.count == 0){
                    taxTableHeight.constant = 0
                }else{
                    taxTableHeight.constant = CGFloat(arr.count * 33)+33
                }
                
                let miscArr = self.bookingDetails["material_details"]!.arrayValue
                if(miscArr.count == 0){
                    invoiceMiscellaneousTableHeight.constant = 0
                }else{
                    invoiceMiscellaneousTableHeight.constant = CGFloat(miscArr.count * 33)+33
                }
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
        
    /*    paymentContext.delegate = self
        paymentContext.hostViewController = self    */

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addCouponView.isHidden = true;
        addCouponBackgroundView.isHidden = true;
        
        viewHeight = self.view.bounds.size.height;
        
        self.addCouponViewY.constant = viewHeight;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addCouponView.isHidden = true
        addCouponBackgroundView.isHidden = true
        
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            confirmButton.backgroundColor = mycolor
            addCardButton.titleLabel?.textColor = mycolor
            changeButton.titleLabel?.textColor = mycolor
//            couponBtn.titleLabel?.textColor = mycolor
        }
        
//        self.view.bringSubview(toFront: addCouponView)
//        self.view.bringSubview(toFront: addCouponBackgroundView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        taxTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
//        self.taxTableHeight.constant = self.taxTableView.contentSize.height
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if let obj = object as? UITableView
        {
            taxTableHeight.constant = taxTableView.contentSize.height
            invoiceMiscellaneousTableHeight.constant = invoiceMiscellaneousTableView.contentSize.height
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }*/
    
    func payByCash(){
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
        let bookingId = self.bookingDetails["booking_id"]!.stringValue
        let params: Parameters = [
            "id": bookingId,
            "method": "cash"
        ]
        print(params)
        SwiftSpinner.show("Making your payment...".localized())
        let url = APIList().getUrlString(url: .PAY)
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("CHANGE PASSWORD JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "true")
                    {
                        let errorMessage = jsonResponse["error_message"].stringValue
                        self.showAlert(title: "Failed".localized(),msg: errorMessage)
                    }
                    else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WaitingForPaymentConfirmationViewController") as! WaitingForPaymentConfirmationViewController
                        vc.bookingDetails = self.bookingDetails
                        self.present(vc, animated: true, completion: nil)
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
    
    @IBAction func addANewCard(_ sender: Any) {
        addCouponView.isHidden = true
        addCouponBackgroundView.isHidden = true
  /*      self.paymentContext.presentPaymentMethodsViewController()     */
    }
    
 /*   func payByCard()
    {
        self.paymentContext.requestPayment()
    }   */
    
    
    
    @IBAction func initiatePayment(_ sender: Any)
    {
        addCouponView.isHidden = true
        addCouponBackgroundView.isHidden = true
        if(selectedPaymentTypes[0])
        {
            payByCash()
        }
        else
        {
            getAppSettings()
//            payStackAccess()
        /*    payByCard()   */
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //paymentTypeCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentTypeCell", for: indexPath) as! PaymentTypeCollectionViewCell
        
        cell.typeName.text = self.paymentTypeNames[indexPath.row]
        if(selectedPaymentTypes[indexPath.row])
        {
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
//                cell.layer.borderColor = mycolor.cgColor
//                cell.layer.borderWidth = 1
                cell.typeImage.image = UIImage.init(named: self.paymentTypeImageSelected[indexPath.row])
                changeTintColor(cell.typeImage, arg: mycolor)
                 cell.typeName.textColor = mycolor
            }
            else
            {
                changeTintColor(cell.typeImage, arg: UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1))
//                cell.layer.borderColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1).cgColor
//                cell.layer.borderWidth = 1
                cell.typeImage.image = UIImage.init(named: self.paymentTypeImageSelected[indexPath.row])
                cell.typeName.textColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
            }
        }
        else
        {
//            cell.layer.borderColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1).cgColor
//            cell.layer.borderWidth = 1
            cell.typeImage.image = UIImage.init(named: self.paymentTypeImageUnSelected[indexPath.row])
            cell.typeName.textColor = UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        }
        return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPaymentTypes.removeAll()
        for i in 0 ... self.paymentTypeNames.count {
            if(i == indexPath.row)
            {
                selectedPaymentTypes.append(true)
            }
            else{
                selectedPaymentTypes.append(false)
            }
        }
        if(selectedPaymentTypes[0])
        {
            selectedCardLbl.isHidden = true
            selectedCardDetailsLbl.isHidden = true
            changeButton.isHidden = true
            addCardButton.isHidden = true
            confirmButton.setTitle("PAY BY CASH".localized(), for: .normal)
        }
        else{
            selectedCardLbl.isHidden = true
            selectedCardDetailsLbl.isHidden = true
            changeButton.isHidden = true
            addCardButton.isHidden = true
            confirmButton.setTitle("PAY BY CARD".localized(), for: .normal)
            
     /*       if let methods = paymentContext.paymentMethods
            {
                if(methods.count > 0)
                {
                    self.selectedCardDetailsLbl.isHidden = false
                    self.changeButton.isHidden = false
                    self.addCardButton.isHidden = true
                }
                else
                {
                    self.selectedCardDetailsLbl.isHidden = true
                    self.changeButton.isHidden = true
                    self.addCardButton.isHidden = false
                }
            }   */
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paymentTypeNames.count
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
                
                completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
                
            }
        }
        else
        {
            getAppSettings()
            
            completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.alert.rawValue) | UInt8(UNNotificationPresentationOptions.sound.rawValue))))
            
            
            
        }
        
    }
    
    func getAppSettings()
    {
        
        var flag = true
        
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
                    print("APP",jsonResponse)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
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
                    else
                    {
                        Constants.locations = jsonResponse["location"].arrayValue
                        Constants.timeSlots = jsonResponse["timeslots"].arrayValue
                        
                        let statusArray = jsonResponse["status"].arrayValue;
                        if(statusArray.count > 0)
                        {
                            let statusDict = statusArray[0].dictionary
                            let currentStatus = statusDict!["status"]?.stringValue
                            let authorizeURL = statusArray[0]["paystack_transaction_url"].stringValue
                            if authorizeURL == "0"
                            {
                                flag = false
                                self.payStackAccess()
                            }
                            else
                            {
                                flag = false
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                                vc.paymentTitleLbl.text = "Paystack Payment".localized()
                                vc.isPayment = true
                                vc.paymentURL = authorizeURL
                                print("URL:",authorizeURL)
                                vc.bookingID = statusArray[0]["booking_id"].stringValue
                                print("BookingID",statusArray[0]["booking_id"].stringValue)
                                vc.payStatusDelegate = self
                                vc.otherWebView.isHidden = true
                                vc.paymentWebView.isHidden = false
                                self.present(vc, animated: true, completion: nil)
                            }
                            
                            if(currentStatus == "Completedjob")
                            {
                                if flag
                                {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
                                    vc.bookingDetails = statusDict
                                    vc.modalPresentationStyle = .overCurrentContext
                                    self.present(vc, animated: false, completion: nil)
                                }
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
    
    func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int) {
        return (minutes / 60, (minutes % 60))
    }
    
    func reloadSettings()
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
        let url = APIList().getUrlString(url: .APPSETTINGS)
        
        Alamofire.request(url,method: .get, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                if let json = response.result.value {
                    print("APP SETTINGS JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    print("APP",jsonResponse)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
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
                    else
                    {
                        Constants.locations = jsonResponse["location"].arrayValue
                        Constants.timeSlots = jsonResponse["timeslots"].arrayValue
                        
                        let statusArray = jsonResponse["status"].arrayValue;
                        if(statusArray.count > 0)
                        {
                            let statusDict = statusArray[0].dictionary
                            let currentStatus = statusDict!["status"]?.stringValue
                           
                            if(currentStatus == "Completedjob")
                            {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
                                    vc.bookingDetails = statusDict
                                    vc.modalPresentationStyle = .overCurrentContext
                                    self.present(vc, animated: false, completion: nil)
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
    
    
/*    func paymentContext(_ paymentContext: STPPaymentContext,
                        didCreatePaymentResult paymentResult: STPPaymentResult,
                        completion: @escaping STPErrorBlock) {
        print(paymentResult)
        //
        var myAPIClient = MyAPIClient.init()
        let bookingId = self.bookingDetails["booking_id"]!.stringValue
        myAPIClient.completeCharge(paymentResult, amount: price, bookingId: bookingId, completion: { (error: Error?) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
//                self.taxTableView.removeObserver(self, forKeyPath: "contentSize")
            }
        })
    }   */
    
    @IBAction func changePaymentMethod(_ sender: Any) {
        addCouponView.isHidden = true
        addCouponBackgroundView.isHidden = true
 /*       self.paymentContext.presentPaymentMethodsViewController()     */
    }
    
 /*   func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
        if let stpPM = paymentContext.selectedPaymentMethod
        {
            print("stppm =",stpPM)
            let stpCard = stpPM as? STPCard
            var cardBrand = "Card"
            if (stpCard?.brand == STPCardBrand.visa)
            {
                cardBrand = "VISA"
            }
            else if (stpCard?.brand == STPCardBrand.amex)
            {
                cardBrand = "AMEX"
            }
            else if (stpCard?.brand == STPCardBrand.masterCard)
            {
                cardBrand = "MASTERCARD"
            }
            else if (stpCard?.brand == STPCardBrand.discover)
            {
                cardBrand = "DISCOVER"
            }
            else if (stpCard?.brand == STPCardBrand.JCB)
            {
                cardBrand = "JCB"
            }
            else if (stpCard?.brand == STPCardBrand.dinersClub)
            {
                cardBrand = "DINERS CLUB"
            }
            let card = "Card Ending in nil"
            print(stpCard?.last4)
            if stpCard?.last4 == nil
            {
//                self.selectedCardDetailsLbl.text = ""
//                self.changeButton.isHidden = true
//                addCardButton.isHidden = false
            }
                
            else
            {
                print("cardBrand = ",cardBrand)
                print("stpCard!.last4 = ",stpCard!.last4)

                self.selectedCardDetailsLbl.text = "\(cardBrand) Ending in \(stpCard!.last4)"
            }
        }
        
        if(selectedPaymentTypes[1])
        {
            if let methods = paymentContext.paymentMethods
            {
                if(methods.count > 0)
                {
                    self.selectedCardDetailsLbl.isHidden = false
                    self.changeButton.isHidden = false
                    self.addCardButton.isHidden = true
                }
                else
                {
                    self.selectedCardDetailsLbl.isHidden = true
                    self.changeButton.isHidden = true
                    self.addCardButton.isHidden = false
                }
            }
        }
        
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFinishWith    status: STPPaymentStatus,
                        error: Error?) {
        
        switch status {
        case .error:
            //            self.showError(error)
            print(error)
        case .success:
            print("Success")
            self.getAppSettings()
        case .userCancellation:
            return // Do nothing
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFailToLoadWithError error: Error) {
        self.navigationController?.popViewController(animated: true)
        // Show the error to your user, etc.
    }   */
    
    @IBAction func addCouponAtn(_ sender: Any)
    {
        if isCoupon_Applied == ""
        {
            addCouponView.isHidden = false
            addCouponBackgroundView.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options:.curveEaseOut, animations:
                {
                    self.addCouponViewY.constant = 0;
                    self.view.layoutIfNeeded()
            },
                           completion:
                {
                    (finished: Bool) in
                    
            })
            
//            let alertController = UIAlertController(title: "Coupon".localized(), message: "Enter your Coupon".localized(), preferredStyle: .alert)
//
//
//            let saveAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:
//            { alert -> Void in
//                let firstTextField = alertController.textFields![0] as UITextField
//
//                if firstTextField.text! != ""
//                {
//                    self.couponVerify(coupon: firstTextField.text!)
//                }
//            })
//
//            saveAction.isEnabled = false
//
//
//            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler:
//            {
//                (action : UIAlertAction!) -> Void in
//            })
//
//            alertController.addAction(saveAction)
//            alertController.addAction(cancelAction)
//
//
//            alertController.addTextField { (textField : UITextField!) -> Void in
//                textField.placeholder = "Enter Your Coupon".localized()
//
//
//                NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using:
//                    {_ in
//
//                        let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count ?? 0
//                        let textIsNotEmpty = textCount > 0
//
//                        saveAction.isEnabled = textIsNotEmpty
//
//                })
//
//
//            }
//
//            self.present(alertController, animated: true, completion: nil)
        }
            
        else
        {
            removeVerify()
        }
    }
    
    @IBAction func couponOKBtnPressed(_ sender: Any)
    {
        if couponCodeText.text! != ""
        {
            self.addCouponView.isHidden = true
            self.addCouponBackgroundView.isHidden = true
            self.couponVerify(coupon: couponCodeText.text!)
        }
        else
        {
            let alert = UIAlertController(title: "Coupon", message: "Enter a Valid coupon".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func couponCancelButtonPressed(_ sender: Any)
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, options:.curveEaseOut, animations:
            {
                self.addCouponViewY.constant = self.viewHeight;
                self.view.layoutIfNeeded()
        },
                       completion:
            {
                (finished: Bool) in
                self.addCouponView.isHidden = true
                self.addCouponBackgroundView.isHidden = true
        })
    }
    
    
    func couponVerify(coupon :String)
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
        
        
        
        
        let bookingId = self.bookingDetails["booking_order_id"]!.stringValue
        let params: Parameters = [
            "couponname": coupon,
            "booking_order_id": bookingId
        ]
        
        print("Verify Coupon Params = ",params)
        
        SwiftSpinner.show("Verify Coupon...".localized())
        let url = APIList().getUrlString(url: .COUPONVERIFY)
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON
        {
            response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value
                {
                    print("Coupon Verify: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    
                    
                    if(jsonResponse["error"].stringValue == "true")
                    {
                        let errorMessage = jsonResponse["error_message"].stringValue
                        
                        let alertController = UIAlertController(title: "Coupon".localized(), message: errorMessage, preferredStyle: .alert)
                        
                        let action1 = UIAlertAction(title: "Ok".localized(), style: .default) { (action:UIAlertAction) in
                            
                        }
                        
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else
                    {
                        let errorMessage = jsonResponse["error_message"].stringValue
                        
                        let alertController = UIAlertController(title: "Coupon".localized(), message: errorMessage, preferredStyle: .alert)
                        
                        let action1 = UIAlertAction(title: "Ok".localized(), style: .default)
                        {
                            (action:UIAlertAction) in
                            self.getAppSettings()
                        }
                        
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
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
    
    func removeVerify()
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
        
        let bookingId = self.bookingDetails["booking_order_id"]!.stringValue
        let params: Parameters = [
            "couponname": isCoupon_Applied,
            "booking_order_id": bookingId
        ]
        print(params)
        
        SwiftSpinner.show("Remove Coupon...".localized())
        let url = APIList().getUrlString(url: .COUPONREMOVE)

        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value
                {
                    print("remove Verify: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    
                    
                    
                     if(jsonResponse["error"].stringValue == "true")
                     {
                        let errorMessage = jsonResponse["error_message"].stringValue
                        
                        let alertController = UIAlertController(title: "Coupon".localized(), message: errorMessage, preferredStyle: .alert)
                        
                        let action1 = UIAlertAction(title: "Ok".localized(), style: .default) { (action:UIAlertAction) in

                        }
                        
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
                     }
                     else
                     {
                        let errorMessage = jsonResponse["error_message"].stringValue
                        
                        let alertController = UIAlertController(title: "Coupon".localized(), message: errorMessage, preferredStyle: .alert)
                        
                        let action1 = UIAlertAction(title: "Ok".localized(), style: .default)
                        {
                            (action:UIAlertAction) in
                            
                            self.getAppSettings()
                        }
                        
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
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
    
    func payStackAccess()
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
        let bookingId = self.bookingDetails["booking_id"]!.stringValue
        let params: Parameters = [
            "booking_id": bookingId,
            "amount" : self.price
        ]
        print(params)
        
        SwiftSpinner.show("Redirecting to Payment...".localized())
        let url = APIList().getUrlString(url: .PAYSTACKACCESS)
        print(url)
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value
                {
                    print("PayStack Access JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    print("PaymentJSON",jsonResponse)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                        self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        self.payment = jsonResponse["data"].dictionaryValue
                        self.authorizeURL = self.payment["authorization_url"]?.stringValue ?? ""
                        print("Authorize_URL:",self.authorizeURL)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                        vc.titleString = "Paystack Payment".localized()
                        vc.isPayment = true
                        vc.paymentURL = self.authorizeURL
                        vc.bookingID = bookingId
                        vc.payStatusDelegate = self
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
            else
            {
                SwiftSpinner.hide()
                print(response.error.debugDescription)
                self.showAlert(title: "Oops".localized(), msg: response.error!.localizedDescription)
                
            }
        }
    }
    
}

extension InvoiceViewController: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
                print("Count = ",self.bookingDetails["alltax"]!.arrayValue)
        
        if(tableView == taxTableView){
            return self.bookingDetails["alltax"]!.arrayValue.count
        }else{
            return self.bookingDetails["material_details"]!.arrayValue.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if(tableView == taxTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaxTableViewCell", for: indexPath) as! TaxTableViewCell
            
            cell.taxNameLbl.text = "\(self.bookingDetails["alltax"]!.arrayValue[indexPath.row]["taxname"].stringValue) \(self.bookingDetails["alltax"]!.arrayValue[indexPath.row]["tax_amount"].stringValue)% "
            
            cell.taxValueLbl.text = "$ \(self.bookingDetails["alltax"]!.arrayValue[indexPath.row]["tax_totalamount"].stringValue)";
            
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MiscellaneousTableViewCell", for: indexPath) as! MiscellaneousTableViewCell
            
            cell.miscellaneousNameLbl.text = "\(self.bookingDetails["material_details"]!.arrayValue[indexPath.row]["material_name"].stringValue)"
            
            cell.miscellaneousValueLbl.text = " $ \(self.bookingDetails["material_details"]!.arrayValue[indexPath.row]["material_cost"].stringValue)"
            
            cell.selectionStyle = .none
            return cell
        }
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

extension InvoiceViewController : PaymentStatusDelegate
{
    func returnStatus()
    {
        reloadSettings()
    }
    
}

