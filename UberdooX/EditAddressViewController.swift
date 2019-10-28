//
//  EditAddressViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/11/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import SwiftSpinner
import Alamofire

class EditAddressViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate,GMSMapViewDelegate {

    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var customAddressLbl: UILabel!
    
    var addressTitle : String!
    var doorNo : String!
    var addressLandmark : String!
    var addressLine : String!
    var searchFlag = false
    
    @IBOutlet weak var titleFld: UITextField!
    @IBOutlet weak var crossHair: UIButton!
    @IBOutlet weak var changeAddress: UIButton!
    @IBOutlet weak var addressCardView: CardView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var landmarkFld: UITextField!
    @IBOutlet weak var doorNoFld: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    var currentAddress : String!
    @IBOutlet weak var currentAddressLbl: UILabel!
    
    @IBOutlet weak var Vwtop: UIView!
    
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var imgtxtedit: UIImageView!
    @IBOutlet weak var btnedit: UIButton!
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ "
    var txtEditing = true
    var locationManager : CLLocationManager!
    var currentLatitude : String!
    var currentLongitude : String!
    var selectedLatitude = ""
    var selectedLongitude = ""
    var foundCurrentLocation = false
    var isShowing = false
    var mycolor = UIColor()
    @IBOutlet weak var locationIndicator: UIImageView!
    var marker:GMSMarker!
    
    var addressId : String!
    
    var existingApiCall = false;
    var centerMapCoordinate:CLLocationCoordinate2D!

    var lang : String = ""
    var validation_failed: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        titleLbl.text = "Edit Address".localized()
        customAddressLbl.text = "Select to add Custom Address".localized()
        changeAddress.setTitle("CHANGE ADDRESS".localized(),for: .normal)
        titleFld.placeholder = "*Title (eg. Home, Work)".localized()
        doorNoFld.placeholder = "*Door No".localized()
        landmarkFld.placeholder = "*Landmark".localized()
        txtAddress.placeholder = "Enter the custom address".localized()
        
        titleLbl.font = FontBook.Medium.of(size: 20)
        customAddressLbl.font = FontBook.Medium.of(size: 17)
        txtAddress.font = FontBook.Medium.of(size: 17)
        titleFld.font = FontBook.Regular.of(size: 17)
        doorNoFld.font = FontBook.Regular.of(size: 17)
        landmarkFld.font = FontBook.Regular.of(size: 17)
        changeAddress.titleLabel!.font = FontBook.Regular.of(size: 19)

        
        
        print(addressId)
        doorNoFld.delegate = self
        landmarkFld.delegate = self
        titleFld.delegate = self
        txtAddress.delegate = self
        txtAddress.isUserInteractionEnabled = false
        imgtxtedit.image = #imageLiteral(resourceName: "box1")
        mapView.isMyLocationEnabled = true
        
        doorNoFld.text = doorNo
        titleFld.text = addressTitle
        landmarkFld.text = addressLandmark
        txtAddress.text = addressLine
        Vwtop.layer.cornerRadius = 5.0
        Vwtop.layer.masksToBounds = true
        
        
        landmarkFld.keyboardType = .asciiCapable
        txtAddress.keyboardType = .asciiCapable
        titleFld.keyboardType = .asciiCapable

        
        
        do{
            let filePath: String? = Bundle.main.path(forResource: "map", ofType: "json")
            
            let url = URL.init(fileURLWithPath: filePath!)
            mapView.mapStyle = try GMSMapStyle.init(contentsOfFileURL: url)
            mapView.delegate = nil
            
        }
        catch{
            print(error)
        }
        

        let lat = Double(currentLatitude)
        let lng = Double(currentLongitude)
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: lng!, zoom: 15.0)
        //            print(camera)
        if(mapView != nil && !foundCurrentLocation)
        {
            foundCurrentLocation = true
            mapView.camera = camera
        }
        
        locationIndicator.layer.shadowColor = UIColor.gray.cgColor
        locationIndicator.layer.shadowOffset = CGSize(width: 0, height: 1)
        locationIndicator.layer.shadowOpacity = 1
        locationIndicator.layer.shadowRadius = 1.0
        locationIndicator.clipsToBounds = false
        
        
        
        
        imgtxtedit.image = #imageLiteral(resourceName: "box2")
        mapView.delegate = self
        txtAddress.isUserInteractionEnabled = true
        txtEditing = false
        
        
        
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
            validation_failed = "Validation Failed".localized()
//        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        if(locationManager != nil){
//            locationManager.stopUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            changeAddress.backgroundColor = mycolor
            btnConfirm.backgroundColor = mycolor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnEdit(_ sender: Any)
    {
        if !txtEditing {
            //            imgtxtedit.image = #imageLiteral(resourceName: "box1")
            //            mapView.delegate = nil
            //            txtAddress.text! = ""
            //            txtAddress.isUserInteractionEnabled = true
            imgtxtedit.image = #imageLiteral(resourceName: "box1")
            mapView.delegate = self
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                changeTintColor(imgtxtedit, arg: mycolor)
            }
            txtAddress.isUserInteractionEnabled = false
            txtEditing = true
        }
        else {
            imgtxtedit.image = #imageLiteral(resourceName: "box2")
            //            mapView.delegate = self
            //            txtAddress.isUserInteractionEnabled = false
            ////            txtAddress.text! = ""
            //            imgtxtedit.image = #imageLiteral(resourceName: "box1")
            mapView.delegate = nil
            txtAddress.text! = ""
            
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                changeTintColor(imgtxtedit, arg: mycolor)
            }
            txtAddress.isUserInteractionEnabled = true
            txtEditing = false
        }
    }
    
    

    @IBAction func searchMapAtn(_ sender: Any)
    {
        let StoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
        let dvc = StoaryBoard.instantiateViewController(withIdentifier: "SearchLocationViewController")as! SearchLocationViewController
        self.searchFlag = true
        dvc.delegate = self
        self.present(dvc, animated: true, completion: nil)
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if(!existingApiCall)
        {
            
            if txtEditing {
                
                existingApiCall = true

                getAddressFor(location: centerMapCoordinate)
            }

//            getAddressFor(location: centerMapCoordinate)
        }
        //        self.placeMarkerOnCenter(centerMapCoordinate:centerMapCoordinate)
    }
    
    func getAddressFor(location : CLLocationCoordinate2D)
    {
        GMSGeocoder().reverseGeocodeCoordinate(location)
        {
            response , error in
            if let address = response?.firstResult()
            {
                let lines = address.lines! as [String]
                
                self.selectedLatitude = String(location.latitude)
                self.selectedLongitude = String(location.longitude)
                
                self.currentAddress = lines.joined(separator: " ")
                
                self.txtAddress.text = self.currentAddress
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
        case doorNoFld:
            landmarkFld.becomeFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
  
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAddress(_ sender: Any) {
        if (txtAddress.text?.isEmpty)! {
            self.showAlert(title: validation_failed, msg: "Address is required".localized())
        }
       else if(titleFld.text == "")
        {
            
//            if lang == "en"{
                self.showAlert(title: validation_failed, msg: "Title is required".localized())
//            }
//            else if lang == "es"{
//                self.showAlert(title: validation_failed, msg: "Título es requerido")
//            }
//            else if lang == "fr"{
//                self.showAlert(title: validation_failed, msg: "Titre requis")
//            }
//            else {
//                self.showAlert(title: validation_failed, msg: "Title is required")
//            }
        }
        else if(doorNoFld.text == "")
        {
//            if lang == "en"{
                self.showAlert(title: validation_failed, msg: "Door No. is required".localized())
//            }
//            else if lang == "es"{
//                self.showAlert(title: validation_failed, msg: "No se requiere puerta")
//            }
//            else if lang == "fr"{
//                self.showAlert(title: validation_failed, msg: "Le numéro de porte est requis")
//            }
//            else {
//            self.showAlert(title: validation_failed, msg: "Door No. is required")
//            }
        }else if(landmarkFld.text == "")
        {
            //            if lang == "en"{
            self.showAlert(title: validation_failed, msg: "Landmark is required".localized())
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
        let city = "Chennai"
        
        if !txtEditing{
            currentAddress = txtAddress.text!
        }
        
        if let landmark = self.landmarkFld.text
        {
            lmark = landmark
        }
        else{
            lmark = ""
        }
        print(self.currentAddress)
        print(city)
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
        var addr = ""
        var landmark = ""
        if SharedObject().hasData(value: currentAddress){
            address = currentAddress!
        }
        if SharedObject().hasData(value: lmark){
            landmark = lmark!
        }
        if SharedObject().hasData(value: addressId){
            addr = addressId!
        }
        if address == ""
        {
            address = txtAddress.text!
        }
        
        let params: Parameters = [
            "address": address,
            "id":addr,
            "doorno": self.doorNoFld.text!,
            "landmark":landmark,
            "title":self.titleFld.text!,
            "latitude": selectedLatitude,
            "longitude": selectedLongitude
        ]
        print(params)
        
            SwiftSpinner.show("Saving your address...".localized())
        
        let url = APIList().getUrlString(url: .UPDATEADDRESS)
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("UPDATE ADDRESS JSON: \(json)") // serialized json response
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
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.crossHair.transform = CGAffineTransform(translationX: 0, y: 0)
                self.locationIndicator.transform = CGAffineTransform(translationX: 0, y: 0)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.changeAddress.transform = CGAffineTransform(translationX: 0, y: 0)
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
                self.changeAddress.transform = CGAffineTransform(translationX: 0, y: -270)
                
            }) { (Void) in
                
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locationArray = locations as NSArray
//        let locationObj = locationArray.lastObject as! CLLocation
//        let coord = locationObj.coordinate
//        currentLatitude = String(coord.latitude)
//        currentLongitude = String(coord.longitude)
//        let camera = GMSCameraPosition.camera(withLatitude: coord.latitude, longitude: coord.longitude, zoom: 15.0)
//        //            print(camera)
//        if(mapView != nil && !foundCurrentLocation)
//        {
//            foundCurrentLocation = true
//            mapView.camera = camera
//        }
    }
    
    @IBAction func moveCameraToCurrentLocation(_ sender: Any) {
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!, zoom: 15.0)
        //            print(camera)
        if(mapView != nil)
        {
            mapView.animate(to: camera)
            
             if txtEditing {
                getAddressFor(location: centerMapCoordinate)
            }
        }
    }
    @IBAction func searchLocation(_ sender: Any) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error)
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
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if (string == filtered)
            {
                let maxLength = 35
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
        }
        else if (textField == titleFld || textField == landmarkFld)
        {
            if Int(range.location) == 0 && (string == " ")
            {
                return false
            }
            else
            {
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if (string == filtered)
            {
                let maxLength = 100
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
           
//                let maxLength = 700
//                let currentString: NSString = textField.text! as NSString
//                let newString: NSString =
//                    currentString.replacingCharacters(in: range, with: string) as NSString
//                return newString.length <= maxLength
           
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.text = textField.text!.trimmingCharacters(in: .whitespaces)
    }
    func moveLocation()
    {
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!, zoom: 15.0)
        mapView.animate(to: camera)
        centerMapCoordinate = CLLocationCoordinate2D(latitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!)
        getAddressFor(location: centerMapCoordinate)
    }
}

extension EditAddressViewController : SearchLocationViewControllerDelegate
{
    func didSelectLocation(lat: Double, log: Double)
    {
        currentLatitude = String(format:"%f", lat)
        currentLongitude = String(format:"%f", log)
        moveLocation()
    }
}
