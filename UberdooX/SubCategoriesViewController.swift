//
//  SubCategoriesViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 15/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Nuke
import CoreData
protocol UpdateFavirate
{
    func updateFavirate()
}

class SubCategoriesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var titleLbl: UILabel!
    var subCategoryId : String!
    var subcategories : [JSON] = []
    var selectedId : String!
    var mycolor = UIColor()
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var favdelegate : UpdateFavirate!
    var isclicked = false
      var Feed :[NSManagedObject] = []
    @IBOutlet weak var subCategoryCollectionView: UICollectionView!
     var needReload = true
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Sub Categories".localized()
         Feed = coredb().fetch()
        print("Feed = \(Feed)")
        titleLbl.font = FontBook.Medium.of(size: 20)
        subCategoryCollectionView.delegate = self
        subCategoryCollectionView.dataSource = self
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
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.itemSize = CGSize(width: ((self.view.frame.width/2) - 6), height: ((self.view.frame.width / 2) - 6))
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: screenWidth / 2.2, height: screenWidth / 2)//
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        subCategoryCollectionView!.collectionViewLayout = layout
        subCategoryCollectionView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        if(needReload){
            needReload = false
            getSubCategories()
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
    
    
    func getSubCategories(){
        var headers : HTTPHeaders!
        

        
        if let accesstoken = UserDefaults.standard.string(forKey: "access_token") as String?
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
            "id": self.subCategoryId!
        ]
        
        
        
        print("accesstoken = ",UserDefaults.standard.string(forKey: "access_token") as String?);
        
        
        print("Parameters = ",params);
        
        
        SwiftSpinner.show("Fetching Services...".localized())
        
        let url = APIList().getUrlString(url: .LISTSUBCATEGORY)

        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("SUB CATEGORY JSON: \(json)") // serialized json response
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
                        self.subcategories = jsonResponse["list_subcategory"].arrayValue
                        self.subCategoryCollectionView.reloadData()
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCollectionViewCell", for: indexPath) as! SubCategoryCollectionViewCell
        cell.btnfav.addTarget(self, action: #selector(favorite(_:)), for: .touchUpInside)
        cell.btnfav.tag = indexPath.row
        let ImagId = subcategories[indexPath.row]["id"].stringValue
        cell.vwfav.roundCorners(.topRight, radius: 10)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
            cell.vwfav.backgroundColor = mycolor
        }
        if Feed.count > 0
        {
//            cell.isclicked = false
//            let dicti = Feed[indexPath.row]as! NSDictionary
            let count : Int = (Feed.count)
            
            for i in 0..<count
            {
                let dct = Feed[i]
                
                let key : String = dct.value(forKey: "subcat_id")as? String ?? ""
                if key == ""
                {
                    
                }
                else
                {
                print("Key= \(key)","ImagId=\(ImagId)")
                if key == ImagId
                {
                    cell.isclicked = false
                    
                    cell.imgfav.image = #imageLiteral(resourceName: "filled")
                }
                }
            }
//            for i in 0...Feed.count
//            {
//                
//            }
        }
        else {
            
        }
       
        cell.subCategoryName.text = self.subcategories[indexPath.row]["sub_category_name"].stringValue
        var imageURL = ""
        
        if SharedObject().hasData(value: self.subcategories[indexPath.row]["icon"])
        {
            imageURL = self.subcategories[indexPath.row]["icon"].stringValue
        }
        
        
        if imageURL == " "
        {
            
        }
        else
        {
            Nuke.loadImage(with:URL(string:imageURL)!, into: cell.subCategoryImage)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "SelectTimeAndAddressViewController") as! SelectTimeAndAddressViewController        
        vc.selectedSubCategoryId = self.subcategories[indexPath.row]["id"].stringValue
        vc.categoryId = self.subcategories[indexPath.row]["category_id"].stringValue
        vc.selectedSubCategoryName = self.subcategories[indexPath.row]["sub_category_name"].stringValue
        self.present(vc, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subcategories.count
    }
    
    @objc func favorite( _ sender : UIButton)
    {
        
        
//        let indexSection = Int(sender.accessibilityIdentifier!)
        
        //    let category = self.categoriesValues[indexSection!]
        
        
        //    print("Cat = ",category[sender.tag])
        
        let category = self.subcategories[sender.tag]
        
        
        
        /*        let indexRow = sender.tag
         let indexSection = Int(sender.accessibilityIdentifier!)
         print(self.categories[indexRow][indexSection!])
         
         
         print(self.categories[indexRow][indexSection!])
         let Cat = self.categories[indexRow][indexSection!]
         print(categories[indexRow])*/
        let imgs = category["icon"].string
        let id = category["id"].intValue
        let cat_id = category["category_id"].intValue
        let name = category["sub_category_name"].string
        let ImgId = String(describing: id)
        let catid = String(describing: cat_id)
        let cleanName = String(describing: name!)
        let cleanImg = String(describing: imgs!)
        let dict : NSDictionary = ["id" : ImgId,"name":cleanName,"icon":cleanImg,"Category": "subcategory","cat_id" : catid,"sub_Cat_id": ImgId]
        print(dict)
           Feed = coredb().fetch()
        var click = true
        if Feed.count > 0
        {
            let count : Int = (Feed.count)
            
            for i in 0..<count
            {
                let dct = Feed[i]
                print(dct)
                var key = ""
                if SharedObject().hasData(value: dct.value(forKey: "id"))
                {
                     key  = dct.value(forKey: "id")as! String
                }
//                 key  = dct.value(forKey: "cat_id")as! String
                let sub_id = dct.value(forKey: "subcat_id")as? String ?? ""
                let cate = dct.value(forKey: "category")as! String
                if cate == "subcategory" {
                print("Key= \(key)","ImagId=\(ImgId)")
//                if sub_id != "" {
                    if sub_id == ImgId
                    {
                        click = false
                        break
                    }
//                }
                }
                else {
                    
                }
            }
            if !click {
                
                print("the row will be delete or remove")
//                coredb().deleteProfile(withID: id)
                coredb().removeBannersub(Favid: id)
                isclicked = false
                
                favdelegate.updateFavirate()
            }
            else {
                isclicked = true
                coredb().insertValues(dict: dict)
//                   Feed = coredb().fetch()
                favdelegate.updateFavirate()
            }
        }
        else
        {
            isclicked = true
            coredb().insertValues(dict: dict)
//               Feed = coredb().fetch()
             favdelegate.updateFavirate()
        }
        
//        pListCreation(dict: dict, cname: name!)
//        isclicked = true
    }
    func pListCreation(dict : NSDictionary, cname : String)
    {
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let path = documentDirectory.appending("/userList.plist")
        
        if (!fileManager.fileExists(atPath: path))
        {
            
            
            let resultDict = NSMutableArray()
            
            
            let plistContent = NSDictionary(dictionary: dict)
            
            //            sam.adding(plistContent)
            
            resultDict.add(plistContent)
            
            //            print(sam)
            
            let success:Bool = resultDict.write(toFile: path, atomically: true)
            if success
            {
                print("file has been created!",path)
                
            }else{
                print("unable to create the file")
            }
            
            
//            getBannerArray()
            
        }
        else
        {
            print("file already exist",path)
            
            
            
            let sam = NSMutableArray(contentsOfFile: path)
            
            let count : Int = (sam?.count)!
            
            
            var flag = true
            
            let resultDict = NSMutableArray()
            
            for var i in 0..<count
            {
                let dct : NSDictionary = sam![i] as! NSDictionary
                
                let key : String = dct.object(forKey: "id") as! String
                
                let result : String = dict.object(forKey: "id") as! String
                
                if key == result
                {
                    flag = false
                }
                else
                {
                    
                    
                    resultDict.add(dct)
                }
            }
            
            
            
            if flag
            {
                let plistContent = NSDictionary(dictionary: dict)
                
                
                resultDict.add(plistContent)
            }
            
            
            
            
            let success:Bool = resultDict.write(toFile: path, atomically: true)
            if success {
                
                print("file has been created!",path)
            }else{
                print("unable to create the file")
            }
            
            
//            getBannerArray()
            
        }
    }
    
    func getBannerArray()
    {
        
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = documentDirectory.appending("/userList.plist")
        
        
        var sam : NSMutableArray? = nil
        
        sam  = NSMutableArray(contentsOfFile: path)
        
        //        sam = sam?.reversed() as! NSMutableArray
        
        
        
        
        if sam != nil
        {
            if ((sam?.count) == 0)
            {
//                bannerStatus = false
//                bannersView.reloadData()
            }
            else
            {
                
                sam =  NSMutableArray(array: (sam?.reverseObjectEnumerator().allObjects)!).mutableCopy() as? NSMutableArray
                
//                bannerArray = sam!
//                bannerStatus = true
//                bannersView.reloadData()
                
            }
        }
        else
        {
//            bannerStatus = false
//            bannersView.reloadData()
            
        }
        
    }
    
}
