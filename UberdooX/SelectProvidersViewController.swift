//
//  SelectProvidersViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 15/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Nuke
import SDWebImage

class SelectProvidersViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,UITableViewDelegate,UITableViewDataSource
{
    
    
    @IBOutlet weak var titleLbl: UILabel!
    
    
    let fullView: CGFloat = 50
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 60
    }

    @IBOutlet weak var providerBtn: UIButton!
    @IBOutlet weak var greenArrow: UIImageView!
    var bluredView : UIVisualEffectView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var providersView: UICollectionView!
    // @IBOutlet weak var providersView: ScalingCarouselView!
    @IBOutlet weak var mapView: GMSMapView!
    var addressId : String!
    var address : String!
    
    var date : String!
    var foundCurrentLocation = false
    var timeSlotId : String!
    var timeSlotName : String!
    var selectedSubCategoryName : String!
    
    var subCategoryId : String!
    var subCategoryName : String!
    
    var locationManager : CLLocationManager!
    var currentLatitude : String!
    var currentLongitude : String!
    var providers : [JSON] = []
    var providersLoaded  = false
    
    var isBottomSheetVisible = false
    var markers : [GMSMarker] = []
    var selectedAddress : [String:JSON]!
    var centerIndex = 0
    var mycolor = UIColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        titleLbl.text = "Select a Provider".localized()
        providerBtn.setTitle("All Providers".localized(),for: .normal)
        
        
        titleLbl.font = FontBook.Medium.of(size: 20)
       providerBtn.titleLabel!.font = FontBook.Medium.of(size: 22)
        
        print(selectedAddress)
        addressId = selectedAddress["id"]?.stringValue
        print(date)
        print(timeSlotId)
        print(subCategoryId)
        
        tableView.delegate = self
        tableView.dataSource = self
        do{
            let filePath: String? = Bundle.main.path(forResource: "map", ofType: "json")
            
            let url = URL.init(fileURLWithPath: filePath!)
            mapView.mapStyle = try GMSMapStyle.init(contentsOfFileURL: url)
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
        }
        catch{
            print(error)
        }
        self.prepareBackgroundView()
        self.bluredView.isHidden = true
        self.isBottomSheetVisible = false

//        self.providersView.frame.origin.y = self.providersView.frame.origin.y + 270
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(SelectProvidersViewController.panGesture))
        gesture.delegate = self as? UIGestureRecognizerDelegate
    self.bottomSheetView.addGestureRecognizer(gesture)
        
        
        
        getProviders(city: selectedAddress["city"]?.stringValue ?? "", latitude: selectedAddress["latitude"]?.stringValue ?? "", longitude: selectedAddress["longitude"]?.stringValue ?? "")

        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.providers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProvidersTableViewCell", for: indexPath) as! ProvidersTableViewCell
        cell.providerName.text = self.providers[indexPath.row]["name"].stringValue
        
        if let imageString = self.providers[indexPath.row]["image"].string{
            if let imageURL = URL.init(string: imageString){
                Nuke.loadImage(with: imageURL, into: cell.providerImage)
            }
            else{
                if UserDefaults.standard.object(forKey: "myColor") != nil
                {

                    let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                    //            var color: UIColor? = nil
                    mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                    
                    //                cell.providerImage.textColor = mycolor
                    changeTintColor(cell.providerImage, arg: mycolor)
                    //                    cell.providerImage.image = UIImage(named: "dp")
                    print("mycolor****",mycolor)
                }
                else{
                cell.providerImage.image = UIImage(named: "dp")
                    
                }
            }
        }
        else{
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
       
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                
                //                cell.providerImage.textColor = mycolor
                changeTintColor(cell.providerImage, arg: mycolor)
                //                    cell.providerImage.image = UIImage(named: "dp")
                print("mycolor****",mycolor)
            }
            else{
                cell.providerImage.image = UIImage(named: "dp")

            }
           
        }
        cell.selectionStyle = .none
        
        var distance = self.providers[indexPath.row]["distance"].stringValue
        if(distance != "0"){
            if(distance.count >= 5)
            {
                distance = String(distance[..<distance.index(distance.startIndex, offsetBy: 5)])
            }
        }
        else{
            distance = "0"
        }
        cell.distancelabel.text = distance.appending(" KM")
        cell.ratingView.rating = self.providers[indexPath.row]["avg_rating"].doubleValue
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        /*
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()*/
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
        }
    }
    

    func getProviders(city:String,latitude:String,longitude:String)
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
        
        
        print("accesstoken = ",UserDefaults.standard.string(forKey: "access_token") as String?)
        
        
        var subcatgory = ""
        var tieslot = ""
        var datet = ""
        if SharedObject().hasData(value: subCategoryId)
        {
            subcatgory = subCategoryId!
            
        }
        if SharedObject().hasData(value: timeSlotId)
        {
            tieslot = timeSlotId!
        }
        
        if SharedObject().hasData(value: date){
            datet = date!
        }
        let params: Parameters = [
            "service_sub_category_id": subcatgory,
            "time_slot_id": tieslot,
            "date":datet,
            "city": city,
            "lat": latitude,
            "lon": longitude
        ]
        SwiftSpinner.show("Fetching Providers...")
        let url = APIList().getUrlString(url: .LISTPROVIDER)

        print("Params = ",params)
        
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("PROVIDERS JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                        self.showAlert(title: "Oops", msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
                        self.providers = jsonResponse["all_providers"].arrayValue
                        
                        for i in 0 ... self.providers.count-1
                        {
                            let coords = CLLocationCoordinate2D.init(latitude: self.providers[i]["latitude"].doubleValue, longitude: self.providers[i]["longitude"].doubleValue)
                            let marker = GMSMarker.init(position: coords)
                            marker.icon = UIImage(named:"blue_marker")
                            marker.appearAnimation = GMSMarkerAnimation.pop
                            marker.map = self.mapView
                            self.markers.append(marker)
                        }
                        self.providersView.dataSource = self
                        self.providersView.delegate = self
                        self.providersView.reloadData()
                        self.tableView.reloadData()
                        UIView.animate(withDuration: 0.9, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
//                            self.providersView.frame.origin.y = self.providersView.frame.origin.y - 270
                        }) {(void) in
                            
                        }
                    }
                }
            }
            else{
                SwiftSpinner.hide()
                print(response.error.debugDescription)
                self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
                
            }
        }
        
    }
    
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
            let coord = locationObj.coordinate
            currentLatitude = String(coord.latitude)
            currentLongitude = String(coord.longitude)
            let camera = GMSCameraPosition.camera(withLatitude: coord.latitude, longitude: coord.longitude, zoom: 11.0)

        if(mapView != nil && !foundCurrentLocation)
        {
            foundCurrentLocation = true
            mapView.camera = camera
        }
            if(!providersLoaded)
            {
                providersLoaded = true
                getProviders(city: "Chennai", latitude: String(coord.latitude), longitude: String(coord.longitude))
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        if locationManager != nil
        {
            locationManager.stopUpdatingLocation()
            print(error)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
//        let camera = GMSCameraPosition.camera(withLatitude: 13.86, longitude: 80.20, zoom: 21.0)
//        let location = CLLocation.

        self.view.bringSubview(toFront: self.providersView)
        self.view.bringSubview(toFront: self.bottomSheetView)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.providers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "providerCell", for: indexPath) as! SelectProvidersCollectionCell
        cell.providerName.text = self.providers[indexPath.row]["name"].stringValue
        
        if let imageString = self.providers[indexPath.row]["image"].string
        {
            if let imageURL = URL.init(string: imageString){
                Nuke.loadImage(with: imageURL, into: cell.providerImage)
            }
            else {
                if UserDefaults.standard.object(forKey: "myColor") != nil
                    {
                
                     let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                                    //            var color: UIColor? = nil
                        mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                
                                    //                cell.providerImage.textColor = mycolor
//                        cell.providerImage.image = UIImage(named: "dp")
                        changeTintColor(cell.providerImage, arg: mycolor)
                
                                    print("mycolor****",mycolor)
                                }
                                else{
                                    cell.providerImage.image = UIImage(named: "dp")
                                }
  
            }
            
        }
        else
        {
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                
                //                cell.providerImage.textColor = mycolor
                //                        cell.providerImage.image = UIImage(named: "dp")
                changeTintColor(cell.providerImage, arg: mycolor)
                
                print("mycolor****",mycolor)
            
                cell.providerImage.image = UIImage(named: "dp")
                changeTintColor(cell.providerImage, arg: mycolor)
            }

        }
        cell.VWTOP.roundCorners([.topLeft, .topRight], radius: 10)
        cell.vwbottom.roundCorners([.bottomLeft, .bottomRight], radius: 10)
//      if let imageString = self.providers[indexPath.row]["image"].string
//        {
//            if let imageURL = URL.init(string: imageString){
//                    Nuke.loadImage(with: imageURL, into: cell.providerImage)
//            }
//            else
//            {
//                if UserDefaults.standard.object(forKey: "myColor") != nil
//                {
//
//                    let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
//                    //            var color: UIColor? = nil
//                    mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
//
//                    //                cell.providerImage.textColor = mycolor
//                    cell.providerImage.image = UIImage(named: "dp")
//                    changeTintColor(cell.providerImage, arg: mycolor)
//
//                    print("mycolor****",mycolor)
//                }
//                else{
////                    cell.providerImage.image = UIImage(named: "dp")
//                }
//
//            }
//        }
//        else{
//            if UserDefaults.standard.object(forKey: "myColor") != nil
//            {
//
//                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
//                //            var color: UIColor? = nil
//                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
//
//                //                cell.providerImage.textColor = mycolor
//                 cell.providerImage.image = UIImage(named: "dp")
//                changeTintColor(cell.providerImage, arg: mycolor)
//                print("mycolor****",mycolor)
//
//            }
//            else
//            {
////            cell.providerImage.image = UIImage(named: "dp")
//            }
//        }
        
        var distance = self.providers[indexPath.row]["distance"].stringValue
        if(distance != "0")
        {
            if(distance.count >= 5)
            {
                distance = String(distance[..<distance.index(distance.startIndex, offsetBy: 5)])
            }
        }
        else{
            distance = "0"
        }
        cell.distancelabel.text = distance.appending(" KM")
        cell.ratingView.rating = self.providers[indexPath.row]["avg_rating"].doubleValue

        return cell
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        providersView.didScroll()
       // guard let currentCenterIndex = providersView.currentCenterCellIndex?.row else { return }
        var visibleRect = CGRect()
        
        visibleRect.origin = providersView.contentOffset
        visibleRect.size = providersView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = providersView.indexPathForItem(at: visiblePoint) else { return }
        
        let currentCenterIndex = indexPath.row
        if(currentCenterIndex != self.centerIndex)
        {
            print(currentCenterIndex)
            centerIndex = currentCenterIndex
            let lat = self.providers[currentCenterIndex]["latitude"].doubleValue
            let lon = self.providers[currentCenterIndex]["longitude"].doubleValue
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15.0)
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            // your camera code goes here, example:
            mapView.animate(to: camera)
            CATransaction.commit()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProviderProfileViewController") as! ProviderProfileViewController
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProviderProfileViewController") as! ProviderProfileViewController
        ProviderProfileViewController.providerDetails = self.providers[indexPath.row].dictionaryValue
        
        vc.subCategoryName = self.selectedSubCategoryName
        vc.subCategoryId = self.subCategoryId
        vc.timeSlotName = self.timeSlotName
        vc.timeSlotId = self.timeSlotId
        vc.date = self.date
        vc.selectedAddress = self.selectedAddress
        vc.addressId = self.addressId
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProviderProfileViewController") as! ProviderProfileViewController
        ProviderProfileViewController.providerDetails = self.providers[indexPath.row].dictionaryValue
        
        vc.subCategoryName = self.selectedSubCategoryName
        vc.subCategoryId = self.subCategoryId
        vc.timeSlotName = self.timeSlotName
        vc.timeSlotId = self.timeSlotId
        vc.date = self.date
        vc.selectedAddress = self.selectedAddress
        vc.addressId = self.addressId
        
        self.present(vc, animated: true, completion: nil)
    }
    func carousel(_ collectionView: UICollectionView!, didSelectElementAt selectedIndex: UInt) {
        
    }

    @IBAction func showOrHideAllProviders(_ sender: Any) {
        let duration = 0.5
        if(isBottomSheetVisible)
        {
            isBottomSheetVisible = false
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                self.greenArrow.transform = CGAffineTransform.init(rotationAngle:  0)
                self.bluredView.isHidden = true
                self.bottomSheetView.frame = CGRect(x: 0, y: self.partialView, width: self.bottomSheetView.frame.width, height: self.bottomSheetView.frame.height)
                
            })
        }
        else{
            isBottomSheetVisible = true
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                self.greenArrow.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
                self.bluredView.isHidden = false
                self.bottomSheetView.frame = CGRect(x: 0, y: self.fullView, width: self.bottomSheetView.frame.width, height: self.bottomSheetView.frame.height)
                
            })
        }
    }
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.bottomSheetView)
        let velocity = recognizer.velocity(in: self.bottomSheetView)
        
        print(translation)
        print(velocity)
        let y = self.bottomSheetView.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.bottomSheetView.frame = CGRect(x: 0, y: y + translation.y, width: bottomSheetView.frame.width, height: bottomSheetView.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.bottomSheetView)
        }

        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )

            duration = duration > 1.3 ? 1 : duration

            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.greenArrow.transform = CGAffineTransform.init(rotationAngle:  0)
                    self.bluredView.isHidden = true
                    self.bottomSheetView.frame = CGRect(x: 0, y: self.partialView, width: self.bottomSheetView.frame.width, height: self.bottomSheetView.frame.height)
                } else {
                    self.greenArrow.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
                    self.bluredView.isHidden = false
                    self.bottomSheetView.frame = CGRect(x: 0, y: self.fullView, width: self.bottomSheetView.frame.width, height: self.bottomSheetView.frame.height)
                }

            }, completion: { [weak self] _ in
                if ( velocity.y < 0 ) {
                    self?.tableView.isScrollEnabled = true
                }
            })
        }
    }
    
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        self.view.addSubview(bluredView)
    }
    

    
    @IBAction func moveCameraToCurrentLocation(_ sender: Any) {
        let camera = GMSCameraPosition.camera(withLatitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!, zoom: 15.0)
        //            print(camera)
        if(mapView != nil)
        {
            mapView.animate(to: camera)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        if locationManager != nil
        {
            locationManager.stopUpdatingLocation()
        }
    }
}
extension SelectProvidersViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
       return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
       
            return CGSize(width: collectionView.frame.size.width / 2.6 , height: collectionView.frame.size.height )
       
//            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
      
    }
}
