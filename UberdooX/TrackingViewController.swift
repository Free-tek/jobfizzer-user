//
//  TrackingViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import SocketIO

class TrackingViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {

    
    @IBOutlet weak var titleLbl: UILabel!
    
    
    var bookingDetails : [String:JSON]!
    
    @IBOutlet weak var disLbl: UILabel!
    @IBOutlet weak var timLbl: UILabel!
    
    
    
    @IBOutlet weak var vwcall: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var manager : SocketManager!
    var socket : SocketIOClient!
    
    var jobLocation : CLLocationCoordinate2D!
    var providerLocation : CLLocationCoordinate2D!
    
    var jobMarker : GMSMarker!
    var providerMarker : GMSMarker!
    
    var bounds:GMSCoordinateBounds!
    var currentLatitude : String!
    var currentLongitude : String!
    var foundCurrentLocation = false
    var phoneNumber = ""
    var mycolor = UIColor()
//    var timer : Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vwcall.layer.cornerRadius = vwcall.frame.size.width / 2
        vwcall.layer.masksToBounds = true
        
        titleLbl.text = "Tracking".localized()
        disLbl.text = "Distance".localized()
        timLbl.text = "Time".localized()
        
        
        titleLbl.font = FontBook.Medium.of(size: 20)
        disLbl.font = FontBook.Regular.of(size: 17)
        timLbl.font = FontBook.Regular.of(size: 17)

        distanceLbl.font = FontBook.Regular.of(size: 16)
        timeLbl.font = FontBook.Regular.of(size: 16)


        

//        providerName.text = self.bookingDetails["providername"]?.stringValue
//        self.providerId = self.bookingDetails["providername"]?.stringValue
//        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(TrackingViewController.updateLocation), userInfo: nil, repeats: true)
          print("booking details =",self.bookingDetails)
        let desLat = self.bookingDetails["boooking_latitude"]!.doubleValue
        let desLon = self.bookingDetails["booking_longitude"]!.doubleValue
        
        jobLocation = CLLocationCoordinate2D.init(latitude: desLat, longitude: desLon)
        jobMarker = GMSMarker.init(position: jobLocation)
        jobMarker.icon = UIImage.init(named: "track_location")
        jobMarker.map = self.mapView
        
        let providerLat = self.bookingDetails["provider_latitude"]!.doubleValue
        let providerLon = self.bookingDetails["provider_longitude"]!.doubleValue
        phoneNumber = self.bookingDetails["provider_mobile"]?.stringValue ?? ""
        providerLocation = CLLocationCoordinate2D.init(latitude: providerLat, longitude: providerLon)
        providerMarker = GMSMarker.init(position: providerLocation)
        providerMarker.icon = UIImage.init(named:"track_location_2")
        providerMarker.map = self.mapView
        

        self.bounds = GMSCoordinateBounds.init(coordinate: providerLocation, coordinate: jobLocation)
        
        let cameraUpdate : GMSCameraUpdate = GMSCameraUpdate.fit(self.bounds)
        
        getPolylineRoute(from: providerLocation,to: jobLocation)
        self.mapView.animate(with: cameraUpdate)
        do{
            let filePath: String? = Bundle.main.path(forResource: "map", ofType: "json")
            
            let url = URL.init(fileURLWithPath: filePath!)
            mapView.mapStyle = try GMSMapStyle.init(contentsOfFileURL: url)
            mapView.delegate = self
            
            
        }
        catch{
            print(error)
        }
        updateLocation()

        // Do any additional setup after loading the view.
    }
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor =  UIColor.init(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        polyline.map = mapView // Your map view
    }
    
    

    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
//        let config = URLSessionConfiguration.default
////        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(Constants.directionsKey)")!
        
        print(url)
        
        Alamofire.request(url,method: .get).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                if let json = response.result.value {
                    let jsonResponse = JSON(json)
                    print(jsonResponse)
                    if let routes = jsonResponse["routes"].array{
                        if(routes.count>0)
                        {
                            if let overview_polyline = routes[0]["overview_polyline"].dictionary
                            {
                                let points = overview_polyline["points"]?.stringValue
                                self.showPath(polyStr: points!)
                            }
                            
                            if let legs = routes[0]["legs"].array{
                                if(legs.count > 0)
                                {
                                    if let distance = legs[0]["distance"].dictionary
                                    {
                                        let away = "away from you".localized()
                                        
                                        self.distanceLbl.text = "\(distance["text"]!.stringValue) \(away)"
                                    }
                                    if let duration = legs[0]["duration"].dictionary{
                                        
                                        let reach = "to reach you".localized()

                                        self.timeLbl.text = "\(duration["text"]!.stringValue) \(reach)"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        manager = SocketManager(socketURL: URL(string: APIList().SOCKET_URL)!, config: [.log(true), .compress, .forcePolling(true)])
        socket = manager.defaultSocket
        if(socket != nil){
            socket.connect()
        }
        let providerId = self.bookingDetails["provider_id"]!.stringValue
        let listenString = "GetLocation-\(providerId)"
        print(listenString)
        socket.on(listenString) {data, ack in
            print(data)
            
            let jsonResponse = JSON(data)
            
            let latitude = jsonResponse[0]["latitude"].doubleValue
            let longitude = jsonResponse[0]["longitude"].doubleValue
            
            print(latitude)
            print(longitude)
            
            self.providerLocation.latitude = latitude
            self.providerLocation.longitude = longitude
            
            
            let desLat = self.bookingDetails["boooking_latitude"]!.doubleValue
            let desLon = self.bookingDetails["booking_longitude"]!.doubleValue
            
            self.jobLocation = CLLocationCoordinate2D.init(latitude: desLat, longitude: desLon)
            self.jobMarker = GMSMarker.init(position: self.jobLocation)
            self.jobMarker.icon = UIImage.init(named: "track_location")
            self.jobMarker.map = self.mapView
            
            let providerLat = self.bookingDetails["provider_latitude"]!.doubleValue
            let providerLon = self.bookingDetails["provider_longitude"]!.doubleValue
            
            self.providerLocation = CLLocationCoordinate2D.init(latitude: providerLat, longitude: providerLon)
            self.providerMarker = GMSMarker.init(position: self.providerLocation)
            self.providerMarker.icon = UIImage.init(named:"track_location_2")
            self.providerMarker.map = self.mapView
            
            
            self.getPolylineRoute(from: self.providerLocation,to: self.jobLocation)
            
            self.bounds = GMSCoordinateBounds.init(coordinate: self.providerLocation, coordinate: self.jobLocation)
            
            let cameraUpdate : GMSCameraUpdate = GMSCameraUpdate.fit(self.bounds)
            self.mapView.animate(with: cameraUpdate)
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        timer.invalidate()
        if(socket != nil){
            socket.disconnect()
        }
    }
    @objc func updateLocation()
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
        
        let providerId = self.bookingDetails["provider_id"]?.stringValue
        let params: Parameters = [
            "provider_id":providerId!
        ]
//        SwiftSpinner.show("Fetching Location...")
        
        let url = APIList().getUrlString(url: .GETPROVIDERLOCATION)
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
//                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("PROVIDER LOCATION JSON: \(json)") // serialized json response
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
                        let latitude = jsonResponse["latitude"].doubleValue
                        let longitude = jsonResponse["longitude"].doubleValue

                            
                        self.providerLocation.latitude = latitude
                        self.providerLocation.longitude = longitude
                        
                        
                        self.getPolylineRoute(from: self.providerLocation,to: self.jobLocation)
                        
                        self.bounds = GMSCoordinateBounds.init(coordinate: self.providerLocation, coordinate: self.jobLocation)
                        
                        let cameraUpdate : GMSCameraUpdate = GMSCameraUpdate.fit(self.bounds)
                        self.mapView.animate(with: cameraUpdate)
                        
                        
                    }
                }
            }
            else{
                print(response.error.debugDescription)
                self.showAlert(title: "Oops".localized(), msg: response.error!.localizedDescription)
                
            }
        }

    }
    override func viewWillAppear(_ animated: Bool)
    {
       super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
       {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            vwcall.backgroundColor = mycolor
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }*/
    
    
    @IBAction func updateCamera(_ sender: Any) {
        let cameraUpdate : GMSCameraUpdate = GMSCameraUpdate.fit(self.bounds)
        
        getPolylineRoute(from: providerLocation,to: jobLocation)
        self.mapView.animate(with: cameraUpdate)
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
        
        //        if(!providersLoaded)
        //        {
        //            providersLoaded = true
        //            getProviders(city: "Chennai", latitude: String(coord.latitude), longitude: String(coord.longitude))
        //        }
        //
        
        
        
    }
    
    @available(iOS 10.0, *)
    @IBAction func callProvider(_ sender: Any) {
        print("Call Provider")
        print(self.bookingDetails)
        
//         phoneNumber = "+919500834273"
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }

        
    }
    @IBAction func moveCameraToCurrentLocation(_ sender: Any) {
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(currentLatitude)!, longitude: Double(currentLongitude)!, zoom: 15.0)
        //            print(camera)
        if(mapView != nil)
        {
            mapView.animate(to: camera)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error != nil)
        {
            print(error)
        }
    }

}
