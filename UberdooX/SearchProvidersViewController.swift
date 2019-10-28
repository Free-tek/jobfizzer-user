 //
//  SearchProvidersViewController.swift
//  Aclena
//
//  Created by Karthik Sakthivel on 19/02/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Nuke
import SocketIO

class SearchProvidersViewController: UIViewController,UITextFieldDelegate
{
    var rippleLayer : RippleLayer!
    var date : String!
//    var foundCurrentLocation = false
    var timeSlotId : String!
    var timeSlotName : String!
    var selectedSubCategoryName : String!
    
    @IBOutlet weak var startSerchBtn: UIButton!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var addLbl: UILabel!
    
    @IBOutlet weak var maxRadiusLbl: UILabel!
    @IBOutlet weak var milesLbl: UILabel!
    
    
    @IBOutlet weak var radiusFld: UITextField!
    @IBOutlet weak var startSearchingCardView: CardView!
    @IBOutlet weak var cancelSearchingCardView: CardView!
    
    var manager : SocketManager!
    var socket : SocketIOClient!
    
    var bookingId : String!
    var isStartSearchingCardVisible = false
    var isCancelSearchingCardVisible = false
    
    @IBOutlet weak var markerImage: UIImageView!
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var serviceDateLbl: UILabel!
    @IBOutlet weak var timeSlotLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    var addressId : String!
    var address : String!
    
    var subCategoryId : String!
    var categoryId : String!
    var subCategoryName : String!
    var selectedAddress : [String:JSON]!
    var mycolor = UIColor()
    let ACCEPTABLE_CHARACTERS1 = "0123456789"
//    var locationManager : CLLocationManager!
//    var currentLatitude : String!
//    var currentLongitude : String!
@IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var mapImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radiusFld.delegate = self
        
        titleLbl.text = "Searching Providers".localized()
        serviceLbl.text = "SERVICE".localized()
        dateLbl.text = "DATE".localized()
        timeLbl.text = "TIME".localized()
        addLbl.text = "ADDRESS".localized()
        cancelBtn.setTitle("CANCEL SEARCHING".localized(),for: .normal)
        
        maxRadiusLbl.text = "Enter the max radius to search for in miles".localized()
        radiusFld.placeholder = "eg. 5".localized()
        milesLbl.text = "miles".localized()
        startSerchBtn.setTitle("START SEARCHING".localized(),for: .normal)
        titleLbl.font = FontBook.Medium.of(size: 20)
        serviceLbl.font = FontBook.Regular.of(size: 14)
        dateLbl.font = FontBook.Regular.of(size: 14)
        timeLbl.font = FontBook.Regular.of(size: 14)
        addLbl.font = FontBook.Regular.of(size: 14)
        cancelBtn.titleLabel!.font = FontBook.Medium.of(size: 14)
        milesLbl.font = FontBook.Medium.of(size: 15)
        radiusFld.font = FontBook.Regular.of(size: 17)
        maxRadiusLbl.font = FontBook.Regular.of(size: 16)
        startSerchBtn.titleLabel!.font = FontBook.Medium.of(size: 14)
        rippleLayer = RippleLayer()
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
           
            
            mapImageView.layer.cornerRadius = mapImageView.frame.size.width/2
            mapImageView.layer.borderWidth = 5
            mapImageView.layer.borderColor = mycolor.cgColor
            mapImageView.clipsToBounds = true
//            rippleLayer.startColor = mycolor
//            rippleLayer.setupRippleEffect(colr: mycolor)
        }
        else
        {
        mapImageView.layer.cornerRadius = mapImageView.frame.size.width/2
        mapImageView.layer.borderWidth = 5
        mapImageView.layer.borderColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1).cgColor
        mapImageView.clipsToBounds = true
//        rippleLayer.startColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
//            rippleLayer.setupRippleEffect(colr: UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1))
        }
        addressId = selectedAddress["id"]?.stringValue
        serviceNameLbl.text = selectedSubCategoryName
        serviceDateLbl.text = date
        timeSlotLbl.text = timeSlotName
        addressLbl.text = "\(selectedAddress["doorno"]!.stringValue),\(selectedAddress["address_line_1"]!.stringValue)"
        self.loadImage()
        
        // Do any additional setup after loading the view.
    }

    
    func fadeInImageView(){
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.mapImageView.alpha = 1.0
            self.markerImage.alpha = 1.0
        }, completion: nil)
    }
    
    
    func loadImage(){
        let lat = self.selectedAddress["latitude"]!.stringValue
        let long = self.selectedAddress["longitude"]!.stringValue
        
        
        let styleMapUrl: String = "https://maps.googleapis.com/maps/api/staticmap?sensor=false&size=\(2 * Int(self.mapImageView.frame.size.width))x\(2 * Int(self.mapImageView.frame.size.height))&zoom=15&center=\(lat),\(long)&style=feature:administrative%7Celement:geometry%7Ccolor:0x1d1d1d%7Cweight:1&style=feature:administrative%7Celement:labels.text.fill%7Ccolor:0x93a6b5&style=feature:landscape%7Ccolor:0xeff0f5&style=feature:landscape%7Celement:geometry%7Ccolor:0xdde3e3%7Cvisibility:simplified%7Cweight:0.5&style=feature:landscape%7Celement:labels%7Ccolor:0x1d1d1d%7Cvisibility:simplified%7Cweight:0.5&style=feature:landscape.natural.landcover%7Celement:geometry%7Ccolor:0xfceff9&style=feature:poi%7Celement:geometry%7Ccolor:0xeeeeee&style=feature:poi%7Celement:labels%7Cvisibility:off%7Cweight:0.5&style=feature:poi%7Celement:labels.text%7Ccolor:0x505050%7Cvisibility:off&style=feature:poi.attraction%7Celement:labels%7Cvisibility:off&style=feature:poi.attraction%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.business%7Celement:labels%7Cvisibility:off&style=feature:poi.business%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.government%7Celement:labels%7Cvisibility:off&style=feature:poi.government%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:off&style=feature:poi.medical%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.park%7Celement:geometry%7Ccolor:0xa9de82&style=feature:poi.park%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.place_of_worship%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.school%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:poi.sports_complex%7Celement:labels.text%7Ccolor:0xa6a6a6%7Cvisibility:simplified&style=feature:road%7Celement:geometry%7Ccolor:0xffffff&style=feature:road%7Celement:labels.text%7Ccolor:0xc0c0c0%7Cvisibility:simplified%7Cweight:0.5&style=feature:road%7Celement:labels.text.fill%7Ccolor:0x000000&style=feature:road.highway%7Celement:geometry%7Ccolor:0xf4f4f4%7Cvisibility:simplified&style=feature:road.highway%7Celement:labels.text%7Ccolor:0x1d1d1d%7Cvisibility:simplified&style=feature:road.highway.controlled_access%7Celement:geometry%7Ccolor:0xf4f4f4&style=feature:transit%7Celement:geometry%7Ccolor:0xc0c0c0&style=feature:water%7Celement:geometry%7Ccolor:0xa5c9e1"
        
        
        print(styleMapUrl)
        let url = URL(string: styleMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        Nuke.loadImage(with: url!, into: self.mapImageView)
    }
    
    func showOrHideStartSearchingCard(){
        let duration = 0.5
        if(isStartSearchingCardVisible)
        {
            isStartSearchingCardVisible = false
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
//                self.startSearchingCardView.transform = CGAffineTransform(translationX: 0, y: 0)
                 self.startSearchingCardView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height - self.startSearchingCardView.frame.height)
            })
        }
        else{
            isStartSearchingCardVisible = true
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
//                self.startSearchingCardView.transform = CGAffineTransform(translationX: 0, y:  -(self.startSearchingCardView.frame.size.height))
                self.startSearchingCardView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.cancelSearchingCardView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
            })
        }

    }

    
    func showOrHideCancelSearchingCard(){
        let duration = 0.8
//        if(isCancelSearchingCardVisible)
//        {
//            isCancelSearchingCardVisible = false
//            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
////                self.cancelSearchingCardView.transform = CGAffineTransform(translationX: 0, y: 0)
//                self.cancelSearchingCardView.transform = CGAffineTransform(translationX: 0, y: 0)
//            })
//        }
//        else{
            isCancelSearchingCardVisible = true
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
//                self.cancelSearchingCardView.transform = CGAffineTransform(translationX: 0, y: -(self.cancelSearchingCardView.frame.size.height))
                self.cancelSearchingCardView.transform = CGAffineTransform(translationX: 0, y: 0)
                 self.startSearchingCardView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
            })
//        }

    }
    override func viewDidAppear(_ animated: Bool) {
//
//        let xPos = self.mapImageView.frame.origin.x + (self.mapImageView.frame.size.width/2)
//        let yPos = self.mapImageView.frame.origin.y + (self.mapImageView.frame.size.height/2)
//        rippleLayer.position = CGPoint(x: xPos, y: yPos);
        
        let xPos = (self.mapImageView.frame.size.width/2)
        let yPos = (self.mapImageView.frame.size.height/2)
        rippleLayer.position = CGPoint(x: xPos, y: yPos);
        self.rippleView.layer.addSublayer(rippleLayer)
        self.view.bringSubview(toFront: mapImageView)
        self.view.bringSubview(toFront: startSearchingCardView)
        self.view.bringSubview(toFront: cancelSearchingCardView)
        self.view.bringSubview(toFront: markerImage)
        manager = SocketManager(socketURL: URL(string: APIList().SOCKET_URL_PRO)!, config: [.log(false), .compress, .forcePolling(true)])
        socket = manager.defaultSocket
        if(socket != nil){
            socket.connect()
        }
        var userid = ""
        if let key = UserDefaults.standard.string(forKey: "userid"){
          userid = UserDefaults.standard.string(forKey: "userid")as! String
        }
        print("userid =", userid)
        let isAcceptedListenString = "random_request_accepted-\(userid)"
        
        socket.on(isAcceptedListenString) {data, ack in
            
            let alert = UIAlertController(title: "Alert".localized(), message: "Provider has accepted your request".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                vc.goToBookings = true
                self.present(vc, animated: true, completion: nil)
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let isCancelledListenString = "request_completed-\(userid)"
        socket.on(isCancelledListenString) {data, ack in
            let alert = UIAlertController(title: "Oops".localized(), message: "Our Providers are busy now. Please try again later.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                    self.dismiss(animated: true, completion: nil)
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        let isBookingPlacedListenString = "user_booking-\(userid)"
        
        
        print("bokking id ",isBookingPlacedListenString)
        
        socket.on(isBookingPlacedListenString) {data, ack in
            let jsonResponse = JSON(data)
            print(" isBookingPlacedListenString = ", jsonResponse)
            self.bookingId = jsonResponse[0]["booking_id"].stringValue
            print("booking id ", self.bookingId)
//            self.showAlert(title: "booking id", msg: self.bookingId)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.startSerchBtn.sendActions(for: .touchUpInside)
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        
//        locationManager = CLLocationManager()
//        locationManager.delegate = self;
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestLocation()
//        locationManager.startUpdatingLocation()
        self.fadeInImageView()
//        self.showOrHideStartSearchingCard()
        self.showOrHideCancelSearchingCard()
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
         startSerchBtn.backgroundColor = mycolor
            cancelBtn.backgroundColor = mycolor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
//        locationManager.stopUpdatingLocation()
        if(socket != nil){
            socket.disconnect()
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS1).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        if (string == filtered)
        {
            let maxLength = 5
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        else
        {
            return false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locationArray = locations as NSArray
//        let locationObj = locationArray.lastObject as! CLLocation
//        let coord = locationObj.coordinate
//        currentLatitude = String(coord.latitude)
//        currentLongitude = String(coord.longitude)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        locationManager.stopUpdatingLocation()
//        print(error)
//    }
    
    @IBAction func startSearching(_ sender: Any) {
    
//        if(radiusFld.text == "")
//        {
//            self.showAlert(title: "Validation Failed".localized(), msg: "Enter a valid radius to search.".localized())
//        }
//        else
//        {
            let radiu = 50000 //Int(radiusFld.text!)!
            if(radiu > 5000000)
            {
                self.showAlert(title: "Validation Failed".localized(), msg: "Enter a radius less than 50 miles.".localized())
            }
            else
            {
                
                var lat = ""
                
                if SharedObject().hasData(value: self.selectedAddress["latitude"])
                {
                    lat = self.selectedAddress["latitude"]!.stringValue
                }
                
                
                var long = ""
                
                if SharedObject().hasData(value: self.selectedAddress["longitude"])
                {
                    long = self.selectedAddress["longitude"]!.stringValue
                }
                
                var addressId = ""
                
                if SharedObject().hasData(value: self.selectedAddress["id"])
                {
                    addressId = self.selectedAddress["id"]!.stringValue
                }
                
                
                
                var userid = ""
                
                if (UserDefaults.standard.object(forKey: "userid") != nil)
                {
                    userid = UserDefaults.standard.object(forKey: "userid") as! String
                }
                
                
                var category = ""
                let radius =  String(radiu)//radiusFld.text!
                print(subCategoryId)
                print(categoryId)
                
                var subCat = ""
                
                if SharedObject().hasData(value: subCategoryId)
                {
                    subCat = subCategoryId!
                }
                
                var timeSlot = ""
                if SharedObject().hasData(value: timeSlotId)
                {
                    timeSlot = timeSlotId!
                }
                
                var dates = ""
                if SharedObject().hasData(value: date)
                {
                    dates = date!
                }
                if SharedObject().hasData(value: categoryId){
                    category = categoryId!
                }
                
                print("lat = ",lat)
                print("long = ",long)
                print("addressId = ",addressId)
                print("userid = ",userid)
                print("subCat = ",subCat)
                print("timeSlot = ",timeSlot)
                print("dates = ",dates)
                print("category_id",category)
                
                
                socket.emit("GetRandomRequest", ["latitude": lat,"longitude":long,"subcategory_id":subCat,"radius":radius,"time_slot_id":timeSlot,"date":dates,"user_id":userid,"address_id":addressId,"category_id":category])
                
                self.showOrHideStartSearchingCard()
                
                self.showOrHideCancelSearchingCard()
//                rippleLayer.startColor = mycolor
                rippleLayer.startAnimation()
            }
            
//        }
        
        
    }
    

    @IBAction func backPressed(_ sender: Any) {
        
        print("Booking Id",bookingId)
        
        
        if bookingId == nil{
            let alert = UIAlertController(title: "Confirm".localized(), message: "Are you sure you want to cancel the search?".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                            self.dismiss(animated: true, completion: nil)
                
              
            }))
            
            
            alert.addAction(UIAlertAction(title: "No".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                
            }))
            self.present(alert, animated: true, completion: nil)

            
        }
        else {
        let alert = UIAlertController(title: "Confirm".localized(), message: "Are you sure you want to cancel the search?".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
//            self.dismiss(animated: true, completion: nil)
            
            self.cancelBooking(bookingId: self.bookingId)
        }))
        
        
        alert.addAction(UIAlertAction(title: "No".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            
        }))
        
       
        // show the alert
        self.present(alert, animated: true, completion: nil)
        }
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
        
        let params: Parameters = [
            "id": bookingId
        ]
        print(params)
        
        SwiftSpinner.show("Cancelling your Request...".localized())
        let url = APIList().getUrlString(url: .CANCELREQUEST)

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
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
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

}
