
//
//  AddNewAddressViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 22/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import SwiftSpinner
import Alamofire

class AddNewAddressViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,OfflineViewControllerDelegate {
    func tryAgain() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var customLbl: UILabel!
    @IBOutlet weak var placeHolderLbl: UILabel!
    
    @IBOutlet weak var addAddressBtn: UIButton!
    

    @IBOutlet weak var txtaddadress: UITextField!
    @IBOutlet weak var titleFld: UITextField!
    @IBOutlet weak var crossHair: UIButton!
    @IBOutlet weak var addAddress: UIButton!
    @IBOutlet weak var addressCardView: CardView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var landmarkFld: UITextField!
    @IBOutlet weak var doorNoFld: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    var currentAddress : String!
    @IBOutlet weak var currentAddressLbl: UILabel!
    @IBOutlet weak var imgtxtedit: UIImageView!
    @IBOutlet weak var btnedit: UIButton!
    var locationManager : CLLocationManager!
    var currentLatitude : String!
    var currentLongitude : String!
    var selectedLatitude = ""
    var selectedLongitude = ""
    var foundCurrentLocation = false
    var isShowing = false
    var txtEditing = false
     var searchFlag = false
    @IBOutlet weak var Vwtop: UIView!
    
    @IBOutlet weak var locationIndicator: UIImageView!
    var marker:GMSMarker!
    var mycolor = UIColor()
   
    var Country : String = ""
    var existingApiCall = false;
    var centerMapCoordinate:CLLocationCoordinate2D!

    var lang : String = ""
    var validation_failed: String = ""
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ "
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        doorNoFld.delegate = self
        landmarkFld.delegate = self
        titleFld.delegate = self
        txtaddadress.delegate = self
        
        doorNoFld.keyboardType = .asciiCapable
        landmarkFld.keyboardType = .asciiCapable
        titleFld.keyboardType = .asciiCapable
        txtaddadress.keyboardType = .asciiCapable
        
        doorNoFld.autocorrectionType = .no
        landmarkFld.autocorrectionType = .no
        titleFld.autocorrectionType = .no
        txtaddadress.autocorrectionType = .no

        imgtxtedit.image = #imageLiteral(resourceName: "box1")
        
        Vwtop.layer.cornerRadius = 5.0
        Vwtop.layer.masksToBounds = true
        
        mapView.isMyLocationEnabled = true
        txtaddadress.isUserInteractionEnabled = false
        
        
        titleLbl.text = "Add new address".localized()
        customLbl.text = "Select to add Custom Address".localized()
        placeHolderLbl.text = "Select to add Custom Address".localized()
        
        
        addAddressBtn.setTitle("ADD ADDRESS".localized(),for: .normal)

        doneBtn.setTitle("CONFIRM".localized(),for: .normal)

        
        

        titleFld.placeholder = "*Title (eg. Home, Work)".localized()
        doorNoFld.placeholder = "*Door No".localized()
        landmarkFld.placeholder = "*Landmark".localized()
        
        
        titleLbl.font = FontBook.Medium.of(size: 20)
        txtaddadress.font = FontBook.Regular.of(size: 17)
        placeHolderLbl.font = FontBook.Regular.of(size: 15)
        customLbl.font = FontBook.Regular.of(size: 17)
        landmarkFld.font = FontBook.Regular.of(size: 17)
        
        
        
        titleFld.font = FontBook.Regular.of(size: 17)
        doorNoFld.font = FontBook.Regular.of(size: 17)
        
        addAddressBtn.titleLabel!.font = FontBook.Regular.of(size: 19)
        
        
       
        
        
//        lang = UserDefaults.standard.object(forKey: "Language")as! String
//        if lang == "en"{
//            validation_failed = "Validation Failed"
//        }
//        else if lang == "es"{
//            validation_failed =  "Validación fallida"
//        }
//        else if lang == "fr"{
//            validation_failed = "Validation échouée"
//        }
//        else {
//             validation_failed = "Validation Failed"
//        }
        
        do{
            let filePath: String? = Bundle.main.path(forResource: "map", ofType: "json")
            
            let url = URL.init(fileURLWithPath: filePath!)
            mapView.mapStyle = try GMSMapStyle.init(contentsOfFileURL: url)
            mapView.delegate = self
        }
        catch{
            print(error)
        }
        
//
//        self.bottomView.frame.origin.y = self.bottomView.frame.origin.y + 270
//
//        self.addAddress.frame.origin.y = self.addAddress.frame.origin.y + 270
//
        locationIndicator.layer.shadowColor = UIColor.gray.cgColor
        locationIndicator.layer.shadowOffset = CGSize(width: 0, height: 1)
        locationIndicator.layer.shadowOpacity = 1
        locationIndicator.layer.shadowRadius = 1.0
        locationIndicator.clipsToBounds = false

        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            addAddress.backgroundColor = mycolor
            doneBtn.backgroundColor = mycolor
            changeTintColor(imgtxtedit, arg: mycolor)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {

        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        self.view.bringSubview(toFront: self.bottomView)
        self.view.bringSubview(toFront: self.addressCardView)
    }
    
    @IBAction func searchLocation(_ sender: Any)
    {
        if Reachability.isConnectedToNetwork() {
        let StoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
        let dvc = StoaryBoard.instantiateViewController(withIdentifier: "SearchLocationViewController")as! SearchLocationViewController
        self.searchFlag = true
        dvc.delegate = self
        self.present(dvc, animated: true, completion: nil)
        }else {
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnEdit(_ sender: Any)
    {
        if !txtEditing {
            imgtxtedit.image = #imageLiteral(resourceName: "box2")
            mapView.delegate = nil
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                 changeTintColor(imgtxtedit, arg: mycolor)
            }
            txtaddadress.text! = ""
            txtaddadress.placeholder = "Enter the custom address"
            //            currentAddressLbl.text = ""
//            txtaddadress.placeholder = ""
            txtaddadress.isUserInteractionEnabled = true
            txtEditing = true
        }
        else {
            imgtxtedit.image = #imageLiteral(resourceName: "box1")
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                changeTintColor(imgtxtedit, arg: mycolor)
            }
            mapView.delegate = self
            txtaddadress.isUserInteractionEnabled = false
            txtEditing = false
        }
       
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if(gesture)
        {
            print("Dragging")
        }
        else{
            print("No Dragging")
        }
    }
    
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        if
//    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if(!existingApiCall)
        {
            existingApiCall = true
            getAddressFor(location: centerMapCoordinate)
        }
//        self.placeMarkerOnCenter(centerMapCoordinate:centerMapCoordinate)
    }
    
    func getAddressFor(location : CLLocationCoordinate2D){
        GMSGeocoder().reverseGeocodeCoordinate(location) { response , error in
             var placemark:CLPlacemark
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                
                self.selectedLatitude = String(location.latitude)
                self.selectedLongitude = String(location.longitude)
                
                self.currentAddress = lines.joined(separator: " ")
                if address.locality != nil
              {
                self.Country = address.locality!
                }
                else
              {
                self.Country = " "
                }
                print(self.Country)
                self.txtaddadress.text! = self.currentAddress
                print(self.currentAddress)
                self.existingApiCall = false
            }
        }
    }
    func placeMarkerOnCenter(centerMapCoordinate:CLLocationCoordinate2D) {
        if marker == nil {
            marker = GMSMarker()
        }
        marker.position = centerMapCoordinate
        marker.map = self.mapView
    }
    
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }*/
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
            case titleFld:
                doorNoFld.becomeFirstResponder()
            case doorNoFld:
                landmarkFld.becomeFirstResponder()
                break
            default:
                textField.resignFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAddress(_ sender: Any)
    {
        if (txtaddadress.text?.isEmpty)!
        {
            self.showAlert(title: "Validation Failed".localized(), msg: "Address is required".localized())
        }
       else if(titleFld.text == "")
        {
//          
            self.showAlert(title: "Validation Failed".localized(), msg: "Title is required".localized())
        }
        else if(doorNoFld.text == "")
        {
            self.showAlert(title: "Validation Failed".localized(), msg: "Door No. is required".localized())
        }
        else if(landmarkFld.text == "")
        {
            self.showAlert(title: "Validation Failed".localized(), msg: "Landmark is required".localized())
        }
        else{
            print("Confirm")
            saveAddress()
        }
    }
    
    func saveAddress(){
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
        print(UserDefaults.standard.string(forKey: "access_token") as String!)
        var lmark : String!
        
        if !isEditing {
            currentAddress = txtaddadress.text!
        }
        print(self.currentAddress)
        
        
//        let city = "Chennai"
        if let landmark = self.landmarkFld.text
        {
            lmark = landmark
        }
        else{
            lmark = ""
        }
        print(self.currentAddress)
//        print(city)
        print(self.doorNoFld.text!)
        print(lmark)
        print(self.titleFld.text!)
        print(currentLatitude)
        print(currentLongitude)
        if(selectedLatitude == "")
        {
            selectedLatitude = currentLatitude
        }
        if(selectedLongitude == "")
        {
            selectedLongitude = currentLongitude
        }
        
        var address = ""
        
        var landmark = ""
        if SharedObject().hasData(value: currentAddress){
            address = currentAddress!
        }
        if SharedObject().hasData(value: lmark){
            landmark = lmark!
        }
        
        let params: Parameters = [
            "address": address,
            "city":Country,
            "doorno": self.doorNoFld.text!,
            "landmark":landmark,
            "title":self.titleFld.text!,
            "latitude": selectedLatitude,
            "longitude": selectedLongitude
        ]
        print(params)
        SwiftSpinner.show("Saving your address...".localized())
        
        let url = APIList().getUrlString(url: .ADDADDRESS)
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("ADD ADDRESS JSON: \(json)") // serialized json response
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
    @IBAction func showHideBottomView(_ sender: Any) {
        
        if(isShowing)
        {
            isShowing = false
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations: {

                self.mapView.isUserInteractionEnabled = true
                self.resignFirstResponder()
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.crossHair.transform = CGAffineTransform(translationX: 0, y: 0)
                self.locationIndicator.transform = CGAffineTransform(translationX: 0, y: 0)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.addAddress.transform = CGAffineTransform(translationX: 0, y: 0)
            }) { (Void) in
                    
            }
        }
        else{
            isShowing = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
                self.mapView.isUserInteractionEnabled = false
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: -270)
                self.crossHair.transform = CGAffineTransform(translationX: 0, y: -270)
                self.locationIndicator.transform = CGAffineTransform(translationX: 0, y: -100)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: -100)
                self.addAddress.transform = CGAffineTransform(translationX: 0, y: -270)
                
            }) { (Void) in
                    
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        currentLatitude = String(coord.latitude)
        currentLongitude = String(coord.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: coord.latitude, longitude: coord.longitude, zoom: 15.0)
        //            print(camera)
        if(mapView != nil && !foundCurrentLocation)
        {
            foundCurrentLocation = true
            mapView.camera = camera
        }
    }
    
    @IBAction func moveCameraToCurrentLocation(_ sender: Any) {
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!, zoom: 15.0)
        //            print(camera)
        locationManager.stopUpdatingLocation()
        if(mapView != nil)
        {
            mapView.animate(to: camera)
            
            if !txtEditing
            {
                txtaddadress.text! = ""            
                getAddressFor(location: centerMapCoordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()        
        print(error)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.text = textField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == doorNoFld)
        {
            if Int(range.location) == 0 && (string == " ")
            {
                return false
            }
            else
            {
//                let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
//                let filtered = string.components(separatedBy: cs).joined(separator: "")
//                if (string == filtered)
//                {
                    let maxLength = 35
                    let currentString: NSString = textField.text! as NSString
                    let newString: NSString =
                        currentString.replacingCharacters(in: range, with: string) as NSString
                    return newString.length <= maxLength
//                }
//                else
//                {
//                    return false
//                }
            }
        }
        else if (textField == titleFld || textField == landmarkFld)
        {
            if Int(range.location) == 0 && (string == " ")
            {
                return false
            }
            else
            {
//                let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
//                let filtered = string.components(separatedBy: cs).joined(separator: "")
//                if (string == filtered)
//                {
                    let maxLength = 100
                    let currentString: NSString = textField.text! as NSString
                    let newString: NSString =
                        currentString.replacingCharacters(in: range, with: string) as NSString
                    return newString.length <= maxLength
//                }
//                else
//                {
//                    return false
//                }
            }
        }
        else {
            if Int(range.location) == 0 && (string == " ")
            {
                return false
            }
            else
            {
                let maxLength = 700
                let currentString: NSString = textField.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
            }
        }
    }
    
    func moveLocation()
    {
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!, zoom: 15.0)
        mapView.animate(to: camera)
        centerMapCoordinate = CLLocationCoordinate2D(latitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!)
        getAddressFor(location: centerMapCoordinate)
    }

}

extension AddNewAddressViewController : SearchLocationViewControllerDelegate
{
    func didSelectLocation(lat: Double, log: Double)
    {
        currentLatitude = String(format:"%f", lat)
        currentLongitude = String(format:"%f", log)
        moveLocation()
    }
}
