//
//  ConfirmBookingViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Nuke

class ConfirmBookingViewController: UIViewController {
    
    
    
    @IBOutlet weak var addLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    @IBOutlet weak var lblprice: UILabel!
    
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var bookingSlot: UILabel!
    @IBOutlet weak var bookingDate: UILabel!
    @IBOutlet weak var providerImage: UIImageView!
    @IBOutlet weak var pricing: UILabel!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var addressTitleLbl: UILabel!
    var subCategoryName : String!
    var subCategoryId : String!
    var date : String!
    var timeSlot : String!
    var timeSlotId : String!
    var pricePerHour : String!
    var address : [String:JSON]!
    var addressId : String!
    var providerId : String!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        titleLbl.text = "Order Confirmation".localized()
        lblprice.text = "PRICE/HR".localized()
        dateLbl.text = "DATE".localized()
        timeLbl.text = "TIME".localized()
        addLbl.text = "ADDRESS".localized()
        btnConfirm.setTitle("CONFIRM BOOKING".localized(),for: .normal)
        
        titleLbl.font = FontBook.Medium.of(size: 20)
        providerName.font = FontBook.Medium.of(size: 19)
        serviceName.font = FontBook.Medium.of(size: 15)
        dateLbl.font = FontBook.Medium.of(size: 16)
        timeLbl.font = FontBook.Medium.of(size: 16)
        bookingDate.font = FontBook.Medium.of(size: 15)
        bookingSlot.font = FontBook.Medium.of(size: 15)
        addressTitleLbl.font = FontBook.Medium.of(size: 13)
        addressLbl.font = FontBook.Medium.of(size: 13)
        btnConfirm.titleLabel!.font = FontBook.Medium.of(size: 13)
        
        
        
        
        
        
        print(subCategoryId)
        print(timeSlotId)
        print(subCategoryId)
        print(date)
        
        providerId = ProviderProfileViewController.providerDetails["id"]?.stringValue
        print(providerId!)
        print(addressId)
        
        providerName.text = ProviderProfileViewController.providerDetails["name"]?.stringValue
        serviceName.text = self.subCategoryName
        bookingDate.text = self.date
        bookingSlot.text = self.timeSlot
        addressLbl.text = self.address["address_line_1"]?.stringValue
        addressTitleLbl.text = "(\(self.address["title"]!.stringValue))"
        pricing.text = "₦\(ProviderProfileViewController.providerDetails["priceperhour"]?.stringValue ?? "0")"
        // Do any additional setup after loading the view.
        
        if let imageName = ProviderProfileViewController.providerDetails["image"]?.string
        {
            if let imageURL = URL.init(string: imageName)
            {
                Nuke.loadImage(with: imageURL, into: providerImage)
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let lat = self.address["latitude"]!.stringValue
        let long = self.address["longitude"]!.stringValue
        
        
        let styleMapUrl: String = "https://maps.googleapis.com/maps/api/staticmap?sensor=false&size=\(2 * Int(self.addressImageView.frame.size.width))x\(2 * Int(self.addressImageView.frame.size.height))&zoom=15&center=\(lat),\(long)&style=feature:administrative%7Celement:geometry%7Ccolor:0x1d1d1d%7Cweight:1&style=feature:administrative%7Celement:labels.text.fill%7Ccolor:0x93a6b5&style=feature:landscape%7Ccolor:0xeff0f5&style=feature:landscape%7Celement:geometry%7Ccolor:0xdde3e3%7Cvisibility:simplified%7Cweight:0.5&style=feature:landscape%7Celement:labels%7Ccolor:0x1d1d1d%7Cvisibility:simplified%7Cweight:0.5&style=feature:landscape.natural.landcover%7Celement:geometry%7Ccolor:0xfceff9&style=feature:poi%7Celement:geometry%7Ccolor:0xeeeeee&style=feature:poi%7Celement:labels%7Cvisibility:off%7Cweight:0.5&style=feature:poi%7Celement:labels.text%7Ccolor:0x505050%7Cvisibility:off&style=feature:poi.attraction%7Celement:labels%7Cvisibility:off&style=feature:poi.attraction%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.business%7Celement:labels%7Cvisibility:off&style=feature:poi.business%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.government%7Celement:labels%7Cvisibility:off&style=feature:poi.government%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.medical%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.park%7Celement:geometry%7Ccolor:0xa9de82&style=feature:poi.park%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.place_of_worship%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.school%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.sports_complex%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:road%7Celement:geometry%7Ccolor:0xffffff&style=feature:road%7Celement:labels.text%7Ccolor:0xc0c0c0%7Cvisibility:simplified%7Cweight:0.5&style=feature:road%7Celement:labels.text.fill%7Ccolor:0x000000&style=feature:road.highway%7Celement:geometry%7Ccolor:0xf4f4f4%7Cvisibility:simplified&style=feature:road.highway%7Celement:labels.text%7Ccolor:0x1d1d1d%7Cvisibility:simplified&style=feature:road.highway.controlled_access%7Celement:geometry%7Ccolor:0xf4f4f4&style=feature:transit%7Celement:geometry%7Ccolor:0xc0c0c0&style=feature:water%7Celement:geometry%7Ccolor:0xa5c9e1&key=\(Constants.mapsKey)"
        
        
//        print("styleMapUrl = ",styleMapUrl)
        let url = URL(string: styleMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        
        
       
        
        let staticMap: String = "http://maps.google.com/maps/api/staticmap?markers=\(lat),\(long)&\("zoom=15&size=\(2 * Int(addressImageView.frame.size.width))x\(2 * Int(addressImageView.frame.size.height))")&sensor=true&key=\(Constants.mapsKey)"
        
        
        let mapUrl = URL(string: staticMap.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

        
//        let mapUrl: NSURL = NSURL(string: staticMap)!
//        self.imgViewMap.sd_setImage(with: mapUrl as URL, placeholderImage: UIImage(named: "palceholder"))

        
        print("URL = ",mapUrl)

        
        
        Nuke.loadImage(with: url!, into: self.addressImageView)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            btnConfirm.backgroundColor = mycolor
            lblprice.textColor = mycolor
            pricing.textColor = mycolor
           
            if let imageName = ProviderProfileViewController.providerDetails["image"]?.string
            {
                if let imageURL = URL.init(string: imageName)
                {
                    Nuke.loadImage(with: imageURL, into: providerImage)
                }
            }
            else
            {
                 changeTintColor(providerImage, arg: mycolor)
            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmBooking(_ sender: Any) {
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
        
        var subcategory = ""
        var time = ""
        var datet = ""
        var provider = ""
        var addressid = ""
        
        if SharedObject().hasData(value: subCategoryId){
            subcategory = subCategoryId!
        }
        if SharedObject().hasData(value: timeSlotId){
            time = timeSlotId!
        }
        if SharedObject().hasData(value: datet){
            datet = date!
        }
        if SharedObject().hasData(value: providerId){
            provider = providerId!
        }
        if SharedObject().hasData(value: addressId){
            addressid = addressId!
        }
        
        let params: Parameters = [
            "service_sub_category_id": subcategory,
            "time_slot_id": time,
            "date":datet,
            "provider_id": provider,
            "address_id": addressid,
            ]
        
        SwiftSpinner.show("Sending your request...".localized())
        let url = APIList().getUrlString(url: .NEWBOOKING)
        print("params =",params)
        
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("CONFIRM BOOKING JSON: \(json)") // serialized json response
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
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookingRequestViewController") as! BookingRequestViewController
                        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
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
    
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }*/
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
