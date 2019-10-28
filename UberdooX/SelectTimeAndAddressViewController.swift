//
//  SelectTimeAndAddressViewController.swift
//  Aclena
//
//  Created by Karthik Sakthivel on 17/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class SelectTimeAndAddressViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
  
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var orLbl: UILabel!
    @IBOutlet weak var withOutLoginView: UIView!
    
    @IBOutlet weak var chooseProviderBtn: UIButton!
    @IBOutlet weak var localProviderBtn: UIButton!
    
    
    @IBOutlet weak var addressCollectionView: UICollectionView!
    
    @IBOutlet weak var noAvailableSlots: UILabel!
    @IBOutlet weak var timeSlotsCollectionView: UICollectionView!
    @IBOutlet weak var datesCollectionView: UICollectionView!
    var dates = [Int]()
    var days = [String]()
    var formattedDates = [String]()
    var selectedDates = [Bool]()
    var selectedAddresses = [Bool]()
    var addresses : [JSON] = []
    var selectedTimeSlots = [Bool]()
    var selectedSubCategoryId : String!
    var selectedSubCategoryName : String!
    var selectedAddressId : String!
    var selectedAddress : [String:JSON]!
    var categoryId : String!
    var selectedTimeSlotId : String!
    var selectedTimeSlotName : String!
    var selectedDate : String!
    var needReload = true
    var validTimeSlots : [JSON] = []
    var mycolor = UIColor()
    var isLoginSkipped:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserDefaults.standard.bool(forKey: "isLoggedInSkipped") != nil){
            isLoginSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
        }
         withOutLoginView.isHidden = true
        datesCollectionView.delegate = self
        datesCollectionView.dataSource = self
        
        
        titleLbl.text = "Select Time & Place".localized()
        
        subTitleLbl.text = "DAY & TIME".localized()
        
        noAvailableSlots.text = "NO TIME SLOTS AVAILABLE. TRY ANOTHER DATE.".localized()
        
        addressLbl.text = "ADDRESS".localized()
        orLbl.text = "(OR)".localized()
        
        
        chooseProviderBtn.setTitle("CHOOSE PROVIDER".localized(),for: .normal)
        
        localProviderBtn.setTitle("OFFER JOB OUT TO LOCAL PROVIDERS".localized(),for: .normal)
        
        
        titleLbl.font = FontBook.Medium.of(size: 20)
        subTitleLbl.font = FontBook.Medium.of(size: 16)
        noAvailableSlots.font = FontBook.Medium.of(size: 16)
        addressLbl.font = FontBook.Medium.of(size: 16)
        orLbl.font = FontBook.Regular.of(size: 15)
        chooseProviderBtn.titleLabel!.font = FontBook.Medium.of(size: 14)
        localProviderBtn.titleLabel!.font = FontBook.Medium.of(size: 14)
        
        
        print(selectedSubCategoryId)
        
        selectedDate = ""
        selectedTimeSlotId = ""
        selectedAddressId = ""
        
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        
        for i in 1 ... 7 {
            let datee = cal.component(.day, from: date)
            dates.append(datee)
            if(i == 1){
                selectedDates.append(true)
            }
            else{
                selectedDates.append(false)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let dayOfWeekString = dateFormatter.string(from: date)
            days.append(dayOfWeekString)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let formattedDate = dateFormatter.string(from: date)
            formattedDates.append(formattedDate)
            if(i == 1)
            {
                selectedDate = formattedDate
            }
            date = cal.date(byAdding: .day, value: +1, to: date)!
        }
        print(formattedDates)

        timeSlotsCollectionView.delegate = self
        timeSlotsCollectionView.dataSource = self
        if(isLoginSkipped == true){
            withOutLoginView.isHidden = false
        }else{
             withOutLoginView.isHidden = true
            reloadTimeSlots()
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func signInBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(vc, animated: true, completion: nil)
    }
    func reloadTimeSlots(){
        let currentdate = NSDate()
        let calender = NSCalendar.current
        let components = calender.dateComponents([.hour, .minute], from: currentdate as Date)
        let currenthour = components.hour!
        
        selectedTimeSlots.removeAll()
        validTimeSlots.removeAll()
        for i in 0 ... Constants.timeSlots.count-1
        {
            
            let fromString = Constants.timeSlots[i]["fromTime"].stringValue
            let toString = Constants.timeSlots[i]["toTime"].stringValue
            
            let fromComponents = fromString.components(separatedBy: ":")
            let toComponents = toString.components(separatedBy: ":")
            
            let fromHour = Int(fromComponents[0])!
            let toHour = Int(toComponents[0])!
            
            print(fromHour)
            print(currenthour)
            print(toHour)
            
            if(selectedDates[0])
            {
                if((fromHour > currenthour || toHour > currenthour))
                {
                    validTimeSlots.append(Constants.timeSlots[i])
                    if(i == 0)
                    {
                        selectedTimeSlots.append(true)
                        selectedTimeSlotId = Constants.timeSlots[i]["id"].stringValue
                        print("selectedTimeSlotId =",selectedTimeSlotId)
                        selectedTimeSlotName = Constants.timeSlots[i]["timing"].stringValue
                    }
                    else{
//                        selectedTimeSlotId = ""
                        selectedTimeSlots.append(false)
                    }
                }
            }
            else{
                validTimeSlots.append(Constants.timeSlots[i])
                if(i == 0)
                {
                    selectedTimeSlots.append(true)
                    selectedTimeSlotId = Constants.timeSlots[i]["id"].stringValue
                    print("selectedTimeSlotId =",selectedTimeSlotId)
                    selectedTimeSlotName = Constants.timeSlots[i]["timing"].stringValue
                }
                else{
                    selectedTimeSlots.append(false)
                }
            }
            
        }
        if(validTimeSlots.count > 0)
        {
            noAvailableSlots.isHidden = true
        }
        else{
            noAvailableSlots.isHidden = false
        }
        print(validTimeSlots)
        timeSlotsCollectionView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        if(needReload){
            needReload = false
            getAddresses()
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
            chooseProviderBtn.backgroundColor = mycolor
            localProviderBtn.backgroundColor = mycolor
        }
        if(UserDefaults.standard.bool(forKey: "isLoggedInSkipped") != nil){
            isLoginSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAddresses(){
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
        SwiftSpinner.show("Fetching Addresses...".localized())
        
        let url = APIList().getUrlString(url: .LISTADDRESS)

        Alamofire.request(url,method: .get,  headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("Addresses JSON: \(json)") // serialized json response
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
                        self.selectedAddresses.removeAll()
                        self.addresses = jsonResponse["list_address"].arrayValue
                        if(self.addresses.count > 0)
                        {
                            for i in 0 ...  self.addresses.count{
                                if(i == 0)
                                {
                                    self.selectedAddresses.append(true)
                                    self.selectedAddressId = self.addresses[i]["id"].stringValue
                                    self.selectedAddress = self.addresses[i].dictionary
                                }
                                else{
                                    self.selectedAddresses.append(false)
                                }
                            }
                        }
                        self.selectedAddresses.append(false)
                        self.addressCollectionView.delegate = self
                        self.addressCollectionView.dataSource = self
                        self.addressCollectionView.reloadData()
                    }
                }
            }
            else{
                SwiftSpinner.hide()
                print(response.error!.localizedDescription)
                self.showAlert(title: "Oops".localized(), msg: response.error!.localizedDescription)
                
            }
        }
    }

    
    @IBAction func selectRandomProviders(_ sender: Any) {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if(isLoggedIn)
        {
            print("selectedTimeSlotId =",selectedTimeSlotId)
            if(selectedAddressId == "")
            {
                showAlert(title: "Address Required".localized(), msg: "Your address is required to proceed further".localized())
            }
            else if(selectedTimeSlotId == "")
            {
                showAlert(title: "Time Slot Required".localized(), msg: "Select a time slot to proceed further".localized())
            }
            else if(selectedDate == "")
            {
                showAlert(title: "Date Required".localized(), msg: "Select a date to proceed further".localized())
            }
            else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchProvidersViewController") as! SearchProvidersViewController
                print(selectedSubCategoryName)
                print(selectedDate)
                print(selectedTimeSlotName)
                print("categoryId", categoryId)
                print(selectedTimeSlotId)
                print(selectedSubCategoryId)
                print(selectedAddress)
                
                vc.categoryId = categoryId
                vc.timeSlotId = selectedTimeSlotId
                vc.timeSlotName = selectedTimeSlotName
                vc.date = selectedDate
                vc.subCategoryId = selectedSubCategoryId
                vc.selectedSubCategoryName = selectedSubCategoryName
                vc.selectedAddress = selectedAddress
                self.present(vc, animated: true, completion: nil)
            }
        }
        else{
            let alert = UIAlertController(title: "Wait!".localized(), message: "Please login to continue.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.present(vc, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
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
    
    
    @IBAction func nextPage(_ sender: Any) {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if(isLoggedIn)
        {
           print("selectedTimeSlotId =",selectedTimeSlotId)
            if(selectedAddressId == "")
            {
                showAlert(title: "Address Required".localized(), msg: "Your address is required to proceed further".localized())
            }
            else if(selectedTimeSlotId == "")
            {
                showAlert(title: "Time Slot Required".localized(), msg: "Select a time slot to proceed further".localized())
            }
            else if(selectedDate == "")
            {
                showAlert(title: "Date Required".localized(), msg: "Select a date to proceed further".localized())
            }
            else{
                
                
                print("selectedAddress = ",selectedAddress)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectProvidersViewController") as! SelectProvidersViewController
                
                //            vc.addressId = selectedAddressId
                vc.timeSlotId = selectedTimeSlotId
                vc.timeSlotName = selectedTimeSlotName
                vc.date = selectedDate
                vc.subCategoryId = selectedSubCategoryId
                vc.selectedSubCategoryName = selectedSubCategoryName
                vc.selectedAddress = selectedAddress
                
                self.present(vc,animated:true,completion:nil)
            }
        }
        else{
            let alert = UIAlertController(title: "Wait!".localized(), message: "Please login to continue.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.present(vc, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DatesCollectionViewCell", for: indexPath) as! DatesCollectionViewCell
            var currentday = days[indexPath.row];
            currentday = String(currentday[..<currentday.index(currentday.startIndex, offsetBy: 3)])
            cell.dayLbl.text = currentday;
            cell.dateLbl.text = String(dates[indexPath.row])
            if(selectedDates[indexPath.row])
            {
                if UserDefaults.standard.object(forKey: "myColor") != nil
                {
                    //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                    let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                    //            var color: UIColor? = nil
                    mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                    cell.dateBg.backgroundColor = mycolor
                    cell.dateLbl.textColor = UIColor.white
                }
                else
                {
                    cell.dateBg.backgroundColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
                    cell.dateLbl.textColor = UIColor.white
                }
//                cell.dateBg.backgroundColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
//                cell.dateLbl.textColor = UIColor.white
            }
            else{
                cell.dateBg.backgroundColor = UIColor.white
                cell.dateLbl.textColor = UIColor.lightGray //init(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotsCollectionViewCell", for: indexPath) as! TimeSlotsCollectionViewCell
            let title = validTimeSlots[indexPath.row]["timing"].stringValue
            cell.timeSlotBtn.setTitle(title, for: UIControlState.normal)
            print(indexPath.row)
            cell.timeSlotBtn.isUserInteractionEnabled = false
            if(selectedTimeSlots[indexPath.row])
            {
                cell.timeSlotBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
                if UserDefaults.standard.object(forKey: "myColor") != nil
                {
                    //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                    let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                    //            var color: UIColor? = nil
                    mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                    cell.timeSlotBtn.backgroundColor = mycolor
                }
                else
                {
                    cell.timeSlotBtn.backgroundColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
                }
//                cell.timeSlotBtn.backgroundColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
            }
            else{
                cell.timeSlotBtn.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
                cell.timeSlotBtn.setTitleColor(UIColor.init(red: 52/255, green: 53/255, blue: 72/255, alpha: 1), for: UIControlState.normal)
            }

            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddressCollectionViewCell", for: indexPath) as! AddressCollectionViewCell
                if(indexPath.row == self.addresses.count)
                {
                    cell.addressbl.isHidden = true
                    cell.addressTitleLbl.isHidden = true
                    cell.plusImgView.isHidden = false
                    cell.addNewAddressLbl.isHidden = false
                    cell.cardSelectedImgView.isHidden = true
                    if UserDefaults.standard.object(forKey: "myColor") != nil
                    {
                        //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                        let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                        //            var color: UIColor? = nil
                        mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
//                        cell.viewBackground.layer.borderColor = mycolor.cgColor
                        cell.addNewAddressLbl.textColor = mycolor
                        changeTintColor(cell.plusImgView, arg: mycolor)
                    }
                    else
                    {
                        cell.addNewAddressLbl.textColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
                        changeTintColor(cell.plusImgView, arg: UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1))
                    
                    }
                    cell.viewBackground.layer.borderColor = UIColor.init(red: 239/255, green: 239/255, blue: 239/255, alpha: 1).cgColor
                }
                else{
                    cell.addressbl.text = self.addresses[indexPath.row]["address_line_1"].stringValue
                    cell.addressTitleLbl.text = self.addresses[indexPath.row]["title"].stringValue
                    cell.addressbl.isHidden = false
                    cell.addressTitleLbl.isHidden = false
                    cell.plusImgView.isHidden = true
                    cell.addNewAddressLbl.isHidden = true
                    cell.cardSelectedImgView.isHidden = false
                    if(self.selectedAddresses[indexPath.row])
                    {
                        cell.cardSelectedImgView.isHidden = false
                        if UserDefaults.standard.object(forKey: "myColor") != nil
                        {
                            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                            //            var color: UIColor? = nil
                            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                            cell.viewBackground.layer.borderColor = mycolor.cgColor
                            cell.addNewAddressLbl.textColor = mycolor
                            changeTintColor(cell.cardSelectedImgView, arg: mycolor)
                        }
                        else
                        {
                            cell.viewBackground.layer.borderColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1).cgColor
                            cell.addNewAddressLbl.textColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
                        }
//                        cell.viewBackground.layer.borderColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1).cgColor
                    }
                    else{
                        cell.cardSelectedImgView.isHidden = true
                        cell.viewBackground.layer.borderColor = UIColor.init(red: 239/255, green: 239/255, blue: 239/255, alpha: 1).cgColor
                    }
                }
            
            
                cell.viewBackground.layer.borderWidth = 1;
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DatesCollectionViewCell", for: indexPath) as! DatesCollectionViewCell
            var currentday = days[indexPath.row];
            currentday = String(currentday[..<currentday.index(currentday.startIndex, offsetBy: 3)])
            cell.dayLbl.text = currentday;
            cell.dateLbl.text = String(dates[0])
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return 7
        case 1:
            return validTimeSlots.count
        case 2:
            return self.addresses.count + 1
        default:            
            return 7
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag
        {
        case 0:
            
            selectedDates.removeAll()
            for i in 0 ... 6 {
                if(i == indexPath.row)
                {
                    selectedDate = formattedDates[indexPath.row]
                    selectedDates.append(true)
                }
                else{
                    selectedDates.append(false)
                }
            }
            reloadTimeSlots()
            collectionView.reloadData()
            break;
        case 1:
            self.selectedTimeSlots.removeAll()
            for i in 0 ... validTimeSlots.count-1 {
                if(i == indexPath.row)
                {
                    selectedTimeSlotId = validTimeSlots[indexPath.row]["id"].stringValue
                    print("selectedTimeSlotId =",selectedTimeSlotId)
                    selectedTimeSlotName = validTimeSlots[i]["timing"].stringValue
                    self.selectedTimeSlots.append(true)
                }
                else{
                    self.selectedTimeSlots.append(false)
                }
            }
            print(self.selectedTimeSlots)
            self.timeSlotsCollectionView.reloadData()
            break;
        case 2:
            if(indexPath.row == self.addresses.count)
            {
                

                
                let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                if(isLoggedIn)
                {
                    needReload = true
                    
                    if Location.isLocationEnabled()
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressViewController") as! AddNewAddressViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        self.showAlert(title: "Oops", msg: "Please enable your location".localized())
                    }
                }
                else{
                    let alert = UIAlertController(title: "Wait!".localized(), message: "Please login to continue.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: {
                        (alert: UIAlertAction!) in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else{
                

                
                self.selectedAddresses.removeAll()
                for i in 0 ... addresses.count {
                    if(i == indexPath.row)
                    {
                        selectedAddressId = addresses[indexPath.row]["id"].stringValue
                        selectedAddress = addresses[indexPath.row].dictionary
                        selectedAddresses.append(true)
                    }
                    else{
                        selectedAddresses.append(false)
                    }
                }
                self.addressCollectionView.reloadData()
            }
            break;
        default:
            selectedDates.removeAll()
            for i in 0 ... 6 {
                if(i == indexPath.row)
                {
                    selectedDate = formattedDates[indexPath.row]
                    selectedDates.append(true)
                }
                else{
                    selectedDates.append(false)
                }
            }
            collectionView.reloadData()
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
