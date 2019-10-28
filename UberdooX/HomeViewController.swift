//
//  HomeViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 13/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON
import Nuke
import UserNotifications
import CoreData
import CenteredCollectionView

//protocol updateBannerdelegate
//{
//    func Imagebannner(index : Int)
//    func BannerImages(img : NSArray)
//}

/*

class SavedTracks: NSObject,NSCoding {
    var Id: Int
    var Image: String
    
    required init(id:Int=0, imag:String="") {
        self.Id = id
        self.Image = imag
    }
    
    required init(coder decoder: NSCoder) {
        self.Id = decoder.decodeObject(forKey: "Id") as? Int ?? 0
        self.Image = decoder.decodeObject(forKey: "Image") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(Id, forKey:"Id")
        coder.encode(Image, forKey:"Image")
    }
}

class DataModel: NSObject {
    
    var saveTrack = [SavedTracks]()
    
    override init(){
        super.init()
        print("document file path：\(documentsDirectory())")
//        print("Data file path：\(dataFilePath())")
    }
    
    //save data
    func saveData() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(saveTrack, forKey: "userList")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    //read data
    func loadData() {
        let path = self.dataFilePath()
        let defaultManager = FileManager()
        if defaultManager.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            let data = try! Data(contentsOf: url)
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            saveTrack = unarchiver.decodeObject(forKey: "userList") as! Array
            unarchiver.finishDecoding()
        }
    }
    
    func documentsDirectory()->String {
       
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentsDirectory = paths.first!
        
        
        
        let file = documentsDirectory.appendingFormat("/userList.plist")
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if FileManager.default.fileExists(atPath: String(describing: file)) {
           
            
           print("File Exists",file)
        }
        else {
            do {
                try FileManager.default.createDirectory(atPath: file, withIntermediateDirectories: true, attributes: nil)
                
                print("fileurl ****",file)
                
               
            } catch {
                NSLog("Couldn't create document directory")
            }
        }

        
        
        
        
        
        
        
        return documentsDirectory
    }
    
    func dataFilePath ()->String{
        return self.documentsDirectory().appendingFormat("/userList.plist")
    }
}
*/
class HomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UNUserNotificationCenterDelegate,UIScrollViewDelegate,UpdateFavirate
{
   
    
    
   
//    var dataModel = DataModel()
    
//    var itemInfo = IndicatorInfo(title: "View")
    
    @IBOutlet weak var collectView: UICollectionView!
    @IBOutlet weak var collectViewHeight: NSLayoutConstraint!
    
    let cellPercentWidth: CGFloat = 0.85
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!

    @IBOutlet weak var titleLbl: UILabel!
    

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var bannersView: ScalingCarouselView!
    
    @IBOutlet weak var bannersView: UICollectionView!
    
    
    @IBOutlet weak var tableView: UITableView!
    var categories : [JSON] = []
    var banners : [JSON] = []
    var locations : [JSON] = []
    var categoryGroups : [String] = []
    var images : [String] = []
    var isclicked: Bool!
    var Imagesdat = Array<Any>()
    var mycolor = UIColor()
    
    var favoritimgs:[JSON] = []
    var favoriteName : [JSON] = []
    var Feed :[NSManagedObject] = []
    var categoriesValues : [JSON] = []
    var bannerArray = NSMutableArray()
    var bannerStatus = false
    var isLoginSkipped:Bool = false
    
    //    var upadateDelegate : updateBannerdelegate
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
        if(UserDefaults.standard.bool(forKey: "isLoggedInSkipped") != nil){
            isLoginSkipped = UserDefaults.standard.bool(forKey: "isLoggedInSkipped")
        }
        isclicked = false
        titleLbl.text = "Jobfizzer".localized()
        titleLbl.font = FontBook.Medium.of(size: 24)
        self.collectView.delegate = self
        self.collectView.dataSource = self
        
        
        bannersView.delegate = self
        bannersView.dataSource = self

        centeredCollectionViewFlowLayout = (bannersView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
        
        bannersView.decelerationRate = UIScrollViewDecelerationRateFast
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        
        
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * cellPercentWidth,
            height: 210
        )

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate  = self
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.ChatData(_:)), name: NSNotification.Name(rawValue: "ChatData"), object: nil)
        Feed = coredb().fetch()
        if(MainViewController.status.count > 0)
        {
            let statusDict = MainViewController.status[0].dictionary

        /*
            let currentStatus = statusDict!["status"]?.stringValue
            if(currentStatus == "Completedjob")
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
                vc.bookingDetails = statusDict
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
            }
            else if(currentStatus == "Waitingforpaymentconfirmation"){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WaitingForPaymentConfirmationViewController") as! WaitingForPaymentConfirmationViewController
                vc.bookingDetails = statusDict
                self.present(vc, animated: true, completion: nil)
            }
            else if(currentStatus == "Reviewpending"){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
                vc.bookingDetails = statusDict
                self.present(vc, animated: true, completion: nil)
            }
            else{*/
                getHomeDetails()
//            }
        }
        else{
            getHomeDetails()
        }
      
    }
    
    func updateFavirate()
    {
        Feed = coredb().fetch()
        bannersView.reloadData()
    }
    
//    override func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {
//
//    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if let obj = object as? UICollectionView
        {
            //            .constant = addressTableView.contentSize.height
            collectViewHeight.constant = collectView.contentSize.height
        }
    }
    
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
//        collectViewHeight.constant = CGFloat(categoriesValues.count * 145)//collectView.contentSize.height
        
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
                bannerStatus = false
                bannersView.reloadData()
            }
            else
            {
                
                sam =  NSMutableArray(array: (sam?.reverseObjectEnumerator().allObjects)!).mutableCopy() as? NSMutableArray

                bannerArray = sam!
                bannerStatus = true
                bannersView.reloadData()

            }
        }
        else
        {
            bannerStatus = false
            bannersView.reloadData()

        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(isLoginSkipped == false){
            getAppSettings()
        }else{
            
        }
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
//            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
//            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            tabBarController?.tabBar.tintColor = mycolor
            titleLbl.textColor = mycolor
            
//            changeTintColor(, arg: mycolor)
        }
//        collectView.reloadData()
        
        if (MainViewController.startChat)
        {
            
            MainViewController.startChat = false
            
            if let reciever_id = appDelegate.chatData["reciever_id"] as? String
            {
                
                let StoaryBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = StoaryBoard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
                vc.receiverId = reciever_id
                vc.name = ""
                
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                
                //            vc.modalTransitionStyle = .crossDissolve
                //
                self.present(vc, animated: true, completion: nil)
                //
                //            self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
//         collectView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        print("mycolor****",mycolor)
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("Disappered")
    }
    
    @objc func ChatData(_ notification: NSNotification)
    {
        
        if let reciever_id = appDelegate.chatData["reciever_id"] as? String
        {
            
            let StoaryBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = StoaryBoard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
            vc.receiverId = reciever_id
            vc.name = ""
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            //            vc.modalTransitionStyle = .crossDissolve
            //
            self.present(vc, animated: true, completion: nil)
            //
            //            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }*/
    
    
    override func viewDidAppear(_ animated: Bool) {
       Feed = coredb().fetch()
    }
    
    override var preferredContentSize: CGSize{
        get {
            self.tableView.layoutIfNeeded()
            return self.tableView.contentSize
        }
        set {}
    }
    
    func getHomeDetails(){
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

        print(headers)
        SwiftSpinner.show("Fetching Services...".localized())
        let url = APIList().getUrlString(url: .HOMEDASHBOARDNEW)

        Alamofire.request(url,method: .get,headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("HOME JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    
                    print(jsonResponse)
                    self.locations = jsonResponse["location"].arrayValue
                    let catarray = jsonResponse["list_category"].arrayValue
                    self.banners = jsonResponse["banner_images"].arrayValue
                    self.bannersView.reloadData()
                    let image = jsonResponse["image"].string
                    //UserDefaults.standard.set(image, forKey: "image")
                    
                    
                    
                    
                    
                    self.categoriesValues = catarray
                    print("Category responce =\(self.categoriesValues)")
                    
                    /*
                    
                    let roundedValue1 : Double = Double(self.categoriesValues.count / 3).rounded(.up)
                    
                    
                    let tableHeight = Int(roundedValue1)  * 170;
                    self.collectView.contentSize = CGSize.init(width: 320, height: tableHeight)
                    self.collectView.frame = CGRect.init(x: self.collectView.frame.origin.x, y: self.collectView.frame.origin.y, width: self.collectView.frame.size.width, height: CGFloat(tableHeight))
                    self.collectView.layoutIfNeeded()
                    let scrollViewHeight = Float(self.bannersView.frame.size.height) + Float(tableHeight) + 50.0
                    self.scrollView.contentSize = CGSize.init(width: 320, height: Int(scrollViewHeight))
                    */
                    
                    
                    
                    
                    
                    /*
                    
                    
                    let rootdict = catarray[0].dictionary as NSDictionary!
                    
                    self.categoryGroups = rootdict!.allKeys as! [String]
                    
                    let tableHeight = self.categoryGroups.count * 170;
                    self.tableView.contentSize = CGSize.init(width: 320, height: tableHeight)
                    self.tableView.frame = CGRect.init(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: CGFloat(tableHeight))
                    self.tableView.layoutIfNeeded()
                    let scrollViewHeight = Float(self.bannersView.frame.size.height) + Float(tableHeight) + 50.0
                    self.scrollView.contentSize = CGSize.init(width: 320, height: Int(scrollViewHeight))
                    for cat in self.categoryGroups
                    {
                        let group = rootdict![cat]
                        
                        self.categories.append(group! as! JSON)
                    }
                    */
                    
//                    self.categoriesValues = catarray
                    
                    
                    print("categoryGroups = ",self.categoryGroups)
                    print("categories = ",self.categories)
                     let ct = CGFloat(self.categoriesValues.count * 145 )
                    
                    let cnt = CGFloat( ct / 2.7)
                    
                    
                    let value = String(format: "%.2f", cnt)
                    
                    print(value)
                    
                    
                    print("Cnt = ",cnt)
                    
                    
                    //                        let count = cnt.rounded(.up)
                    
                    let count = cnt.rounded(.toNearestOrAwayFromZero)
                    
                    print("count = ",count)
                    
                    self.collectViewHeight.constant = count
                    
                    self.getBannerArray()

                    
                    self.collectView.reloadData()                    
                }
            }
            else{
                SwiftSpinner.hide()
                print(response.error.debugDescription)
                self.showAlert(title: "Oops".localized(), msg: response.error!.localizedDescription)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryGroups.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let categoryCell = cell as? HomeTableViewCell else { return }
            categoryCell.setCollectionView(dataSourceDelegate: self, forRow: indexPath.row)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            
            cell.groupTitle.textColor = mycolor

        }
        cell.groupTitle.text = self.categoryGroups[indexPath.row]
        cell.categoryCollectionView.tag = indexPath.row
        
        cell.categoryCollectionView.allowsMultipleSelection = true
        return cell
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        bannersView.didScroll()
//        guard let currentCenterIndex = bannersView.currentCenterCellIndex?.row else { return }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        collectView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    
    
    
    /*
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth: Float = 210
        
        let currentOffset = Float(scrollView.contentOffset.x)
        let targetOffset = targetContentOffset.pointee.x
        var newTargetOffset: Float = 0
        
        
        
        if Float(targetOffset) > currentOffset {
            newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
        } else {
            newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
        }
        
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if CGFloat(newTargetOffset) > scrollView.contentSize.width {
            newTargetOffset = Float(scrollView.contentSize.width)
        }
        
        targetContentOffset.pointee.x = CGFloat(currentOffset)
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: 0), animated: true)
    }*/

    
    

}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let index = collectionView.tag
        
        if(index == -1)
        {
            
            if Feed.count == 0
            {
                return banners.count
            }
            else
            {
                return self.Feed.count
            }
        }
        else if collectionView == self.collectView
        {
            
            print("self.categoriesValues = ",self.categoriesValues.count)
            
            return self.categoriesValues.count
        }
        else
        {
            return self.categories[index].count
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
            let index = collectionView.tag
            if(index == -1)
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
                if Feed.count == 0
                {
                    cell.bannerName.text = self.banners[indexPath.row]["banner_name"].stringValue
                    if let imageName = self.banners[indexPath.row]["banner_logo"].string
                    {
                        if let imageUrl = URL.init(string: imageName)
                        {
                            Nuke.loadImage(with: imageUrl, into: cell.bannerImage)
                        }
                    }
                    
//                    }
                }
                else
                {
                    let dict = Feed[indexPath.row]
                    cell.bannerName.text = dict.value(forKey: "name") as? String ?? ""
                    
                    //                    let feedPosts = self.bannerArray[indexPath.row]as! NSDictionary
                    //                    let name = feedPosts["name"]as? String ?? ""
                    let icon = dict.value(forKey: "icon")as? String ?? ""
                    //                    cell.bannerName.text = name
                    //                    if let imageName = feedPosts["icon"]as? String ?? ""
                    //                    {
                    if let imageUrl = URL.init(string: icon)
                    {
                        Nuke.loadImage(with: imageUrl, into: cell.bannerImage)
                    }
                }
                return cell
            }
            else if collectionView == self.collectView
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
                let category = self.categoriesValues[indexPath.row]
                print("Categories = ",category)
                if UserDefaults.standard.object(forKey: "myColor") != nil
                {
                    //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                    let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                    //            var color: UIColor? = nil
                    mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                     cell.vwtheme.backgroundColor = mycolor
                    //            changeTintColor(, arg: mycolor)
                }
                cell.vwtheme.roundCorners(.topRight, radius: 10)
                cell.categoryName.text = category["category_name"].stringValue
                cell.btnFavorate.addTarget(self, action: #selector(favorite(_:)), for: .touchUpInside)
                cell.btnFavorate.tag = indexPath.row
                cell.btnFavorate.accessibilityIdentifier = "\(collectionView.tag)"
                print("Image String = ",category["icon"].stringValue)
                if let imageString = category["icon"].string
                {
                    if imageString == "" || imageString == " "
                    {
                        if let imageURL = URL(string:"https://www.joomlapartner.nl/components/com_easyblog/themes/wireframe/images/placeholder-image.png")
                        {
                            Nuke.loadImage(with: imageURL, into: cell.categoryImage)
                        }
                    }
                    else
                    {
                        if let imageURL = URL(string:imageString)
                        {
                            Nuke.loadImage(with: imageURL, into: cell.categoryImage)
                        }
                        else
                        {
                            if let imageURL = URL(string:"https://www.joomlapartner.nl/components/com_easyblog/themes/wireframe/images/placeholder-image.png")
                            {
                                Nuke.loadImage(with: imageURL, into: cell.categoryImage)
                            }
                        }
                    }
                }
                else
                {
                    if let imageURL = URL(string:"https://www.joomlapartner.nl/components/com_easyblog/themes/wireframe/images/placeholder-image.png")
                    {
                        Nuke.loadImage(with: imageURL, into: cell.categoryImage)
                    }
                }
                
                let id = category["id"].intValue
                
                
                print("Image ID = ",id)
                
                let ImgId = String(describing: id)
                
                
                
//                let fileManager = FileManager.default
//                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//                let path = documentDirectory.appending("/userList.plist")
                
                
                
//                var sam = Feed[indexPath.row]
                
//                sam  = NSMutableArray(contentsOfFile: path)
                
                
//                if sam == nil
//                {
//
//                }
//                else
//                {
                    let count : Int = (Feed.count)
                    
                    for i in 0..<count
                    {
                        let dct = Feed[i]
                        
                        let key : String = dct.value(forKey: "id") as! String
                        
                        if key == ImgId
                        {
                            cell.isclicked = false
                            
                            cell.imgFaviorate.image = #imageLiteral(resourceName: "filled")
                        }
                    }
//                }
                
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
                
                let category = self.categories[index]
                
                
                print("Categories = ",category)
                
                
                
                
                
                cell.categoryName.text = category[indexPath.row]["category_name"].stringValue
                
                
                
                cell.btnFavorate.addTarget(self, action: #selector(favorite(_:)), for: .touchUpInside)
                cell.btnFavorate.tag = indexPath.row
                
                
                
                cell.btnFavorate.accessibilityIdentifier = "\(collectionView.tag)"
                
                if let imageString = category[indexPath.row]["icon"].string
                {
                    if let imageURL = URL(string:imageString)
                    {
                        Nuke.loadImage(with: imageURL, into: cell.categoryImage)
                    }
                }
                
                
                let id = category[indexPath.row]["id"].int
                
                let ImgId = String(describing: id!)

                
                
                let fileManager = FileManager.default
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let path = documentDirectory.appending("/userList.plist")
                
                
                
                var sam : NSMutableArray? = nil
                
                sam  = NSMutableArray(contentsOfFile: path)
                
                
                if sam == nil
                {
                    
                }
                else
                {
                    let count : Int = (sam!.count)
                    
                    for i in 0..<count
                    {
                        let dct : NSDictionary = sam![i] as! NSDictionary
                        
                        let key : String = dct.object(forKey: "id") as! String
                        
                        if key == ImgId
                        {
                            cell.isclicked = false
                            
                            cell.imgFaviorate.image = #imageLiteral(resourceName: "filled")
                        }
                    }
                }
                
                return cell
            }
    }
    
   @objc func favorite( _ sender : UIButton)
   {
    
    
    let indexSection = Int(sender.accessibilityIdentifier!)

//    let category = self.categoriesValues[indexSection!]
//    print("Cat = ",category[sender.tag])
    let category = self.categoriesValues[sender.tag]
/*        let indexRow = sender.tag
        let indexSection = Int(sender.accessibilityIdentifier!)
        print(self.categories[indexRow][indexSection!])
    

        print(self.categories[indexRow][indexSection!])
        let Cat = self.categories[indexRow][indexSection!]
        print(categories[indexRow])*/
    print("Category =",category)
        let imgs = category["icon"].string
        let id = category["id"].intValue
        let name = category["category_name"].string
        let ImgId = String(describing: id)
        let cleanName = String(describing: name!)
        let cleanImg = String(describing: imgs!)
//        let dict : NSDictionary = ["id" : ImgId,"name":cleanName,"icon":cleanImg]
    let dict : NSDictionary = ["id" : ImgId,"name":cleanName,"icon":cleanImg, "Category": "category","cat_id" : ImgId,"sub_Cat_id": ""]
    print("Dictionary",dict)
      Feed = coredb().fetch()
    let count = Feed.count
    var click = true
    if count != 0
    {
        let count : Int = (Feed.count)
        
        for i in 0..<count
        {
            let dct = Feed[i]
            
            let key : String = dct.value(forKey: "cat_id")as! String
            let cat_name = dct.value(forKey: "category")as? String ?? ""
//            if cat_name == "category"
//            {
            print("Dictionary =", dct)
            print("Key= \(key)","ImagId=\(ImgId)")
                if key == ImgId
                {
                    click = false
                   break
                }
            
            
            }
        
        if !click
        {
            coredb().removeBanner(Favid: id)
            print("the row will be delete or remove")
            Feed = coredb().fetch()
            bannersView.reloadData()
        }
        else {
            isclicked = true
            coredb().insertValues(dict: dict)
            Feed = coredb().fetch()
            bannersView.reloadData()
        }
        
           
//    }
    }
    else
    {
//         isclicked = true
       coredb().insertValues(dict: dict)
        Feed = coredb().fetch()
        bannersView.reloadData()
    }
//    bannersView.reloadData()
//    isclicked = true
//    Feed = coredb().fetch()
//    bannersView.reloadData()
//        pListCreation(dict: dict, cname: name!)
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = collectionView.tag
        
        if collectionView == self.collectView
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoriesViewController") as! SubCategoriesViewController
            
            let category = self.categoriesValues[indexPath.row]
            
            vc.subCategoryId = category["id"].stringValue
//            vc.favdelegate = self
            vc.favdelegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
        
/*        if(index != -1)
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoriesViewController") as! SubCategoriesViewController
            
            let category = self.categories[index]
            vc.subCategoryId = category[indexPath.row]["id"].stringValue
            self.present(vc, animated: true, completion: nil)
        }*/
        else
        {
            if(index == -1)
            {
                
                if Feed.count != 0
                {
                    let dict = Feed[indexPath.row]
                    let categoryname = dict.value(forKey: "category")as! String
                    print("category =",categoryname)
                    if categoryname == "category"
                    {
                        let feedPosts = self.Feed[indexPath.row]
                        
                        let id = feedPosts.value(forKey: "cat_id")as! String//["id"]as? String ?? ""
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoriesViewController") as! SubCategoriesViewController
                        vc.favdelegate = self
                        vc.subCategoryId = id
                        self.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        let feed = Feed[indexPath.row]
                        let id = feed.value(forKey: "subcat_id")as! String
                        let catid = feed.value(forKey: "cat_id")as! String
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectTimeAndAddressViewController")as! SelectTimeAndAddressViewController
                        vc.selectedSubCategoryId = id
                        vc.categoryId = catid
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    
                }
                else
                {

                }
            }
    
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        if collectionView == self.collectView
        {
            return 5
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        if collectionView == self.collectView
        {
            return 5
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == self.collectView
        {
            return CGSize(width: collectionView.frame.size.width / 3 - 5, height: 145)
        }
        else
        {
            return CGSize(width: view.bounds.width * cellPercentWidth, height: bannersView.frame.size.height)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
//    {
//        if collectionView == self.collectView
//        {
//            return UIEdgeInsetsMake(0, 0, 0, 0)
//        }
//        else
//        {
//            return UIEdgeInsetsMake(0, 0, 0, 0)
//        }
//    }
    
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
            
            
            getBannerArray()
            
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
            
            
            getBannerArray()

        }
    }
    
    
    func readdata(){
        if let path = Bundle.main.path(forResource: "userList", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                // use swift dictionary as normal
//                dict[""]
                print(dict)
            }
        }
    }
    
    func getAppSettings(){
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
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                        self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else if(jsonResponse["message"].stringValue == "Unauthenticated.")
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
                    else{
                        Constants.locations = jsonResponse["location"].arrayValue
                        Constants.timeSlots = jsonResponse["timeslots"].arrayValue
                        
                        let statusArray = jsonResponse["status"].arrayValue;
                        if(statusArray.count > 0){
                            let statusDict = statusArray[0].dictionary
                            let currentStatus = statusDict!["status"]?.stringValue
                            if(currentStatus == "Completedjob")
                            {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
                                vc.bookingDetails = statusDict
                                vc.modalPresentationStyle = .overCurrentContext
                                self.present(vc, animated: true, completion: nil)
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
    
}

