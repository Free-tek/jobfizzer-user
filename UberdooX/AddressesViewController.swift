//
//  AddressesViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/11/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class AddressesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,OfflineViewControllerDelegate {
    func tryAgain() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var addressesTableView: UITableView!
    var addresses : [JSON] = []
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        titleLbl.text = "Addresses".localized()
        titleLbl.font = FontBook.Medium.of(size: 20)
        
        addressesTableView.delegate = self
        addressesTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getAddress()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
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
    
    func getAddress(){
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
        
        SwiftSpinner.show("Fetching Addresses...".localized())
        let url = APIList().getUrlString(url: .LISTADDRESS)
        
        Alamofire.request(url,method: .get, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("LIST ADDRESS JSON: \(json)") // serialized json response
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
                        print(jsonResponse)
                        self.addresses = jsonResponse["list_address"].arrayValue
                        self.addressesTableView.reloadData()
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
    
    @IBAction func addNewAddress(_ sender: Any)
    {
        if Reachability.isConnectedToNetwork() {
            if Location.isLocationEnabled()
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressViewController") as! AddNewAddressViewController
                self.present(vc, animated: true, completion: nil)
            }
            else
            {
                self.showAlert(title: "Oops", msg: "Please enable your location".localized())
            }
        }else{
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell",  for: indexPath) as! AddressTableViewCell
        
        cell.titleLbl.text = self.addresses[indexPath.row]["title"].stringValue
        
        cell.addressLbl.text = self.addresses[indexPath.row]["address_line_1"].stringValue
        cell.editButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: #selector(AddressesViewController.editButtonTapped), for: .touchUpInside)
        
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(AddressesViewController.deleteButtonTapped), for: .touchUpInside)
        return cell
    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteButtonTapped(sender: UIButton!) {
        print(sender.tag)
        let alert = UIAlertController(title: "Confirm".localized(), message: "Are you sure you want to delete this address?".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            let addressId = self.addresses[sender.tag]["id"].stringValue
            self.deleteAddress(addressId: addressId)
        }))
        
        
        alert.addAction(UIAlertAction(title: "No".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            
        }))
        
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func editButtonTapped(sender: UIButton!) {
        print(sender.tag)
        if Reachability.isConnectedToNetwork() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditAddressViewController") as! EditAddressViewController
            vc.addressId = self.addresses[sender.tag]["id"].stringValue
            vc.currentLatitude = self.addresses[sender.tag]["latitude"].stringValue
            vc.currentLongitude = self.addresses[sender.tag]["longitude"].stringValue
            vc.addressLandmark = self.addresses[sender.tag]["landmark"].stringValue
            vc.doorNo = self.addresses[sender.tag]["doorno"].stringValue
            vc.addressTitle = self.addresses[sender.tag]["title"].stringValue
            vc.addressLine = self.addresses[sender.tag]["address_line_1"].stringValue
            self.present(vc, animated: true, completion: nil)
        }else{
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addresses.count
    }
    
    func deleteAddress(addressId:String!){
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
        
        var address = ""
        if SharedObject().hasData(value: addressId){
            address = addressId!
        }
        print(addressId)
        let params: Parameters = [
            "id": address
        ]
        SwiftSpinner.show("Removing service...".localized())
        let url = APIList().getUrlString(url: .DELETEADDRESS)
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("DELETE ADDRESS JSON: \(json)") // serialized json response
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
                        self.getAddress()
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
