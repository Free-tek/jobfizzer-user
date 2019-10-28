	//
//  ProviderProfileViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Nuke


private let mainColor = UIColor(red: 1.0/255.0, green: 55.0/255.0, blue: 132.0/255.0, alpha: 1.0)
class ProviderProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {

  
    @IBOutlet weak var addLbl: UILabel!
    @IBOutlet weak var sumLbl: UILabel!
    @IBOutlet weak var otherSerLbl: UILabel!
    
    
    @IBOutlet weak var btnbooknow: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var reviewTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var otherServicesTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var otherServicesTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var summaryLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var imgCal: UIImageView!
    
    @IBOutlet weak var imgMsg: UIImageView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var contactNumberLbl: UILabel!
    @IBOutlet weak var providerImage: UIImageView!
    @IBOutlet weak var providerName: UILabel!
    static var providerDetails : [String:JSON]!
    var titles: [String] = ["Profile","Reviews"]
    var subCategoryName : String!
    var subCategoryId : String!
    var timeSlotName : String!
    var timeSlotId : String!
    var date : String!
    var selectedAddress : [String:JSON]!
    var addressId : String!
    var pageViewController : UIPageViewController!
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        addLbl.text = "Address".localized()
        sumLbl.text = "Summary".localized()
        otherSerLbl.text = "Other Services".localized()
        reviewLabel.text = "Reviews".localized()
        btnbooknow.setTitle("BOOK NOW".localized(),for: .normal)
        

        
        
        
        providerName.font = FontBook.Medium.of(size: 18)
        contactNumberLbl.font = FontBook.Medium.of(size: 14)
        distanceLbl.font = FontBook.Regular.of(size: 14)
        ratingLbl.font = FontBook.Regular.of(size: 14)
        priceLbl.font = FontBook.Regular.of(size: 14)
        addLbl.font = FontBook.Medium.of(size: 18)
        sumLbl.font = FontBook.Medium.of(size: 18)
        otherSerLbl.font = FontBook.Medium.of(size: 18)
        reviewLabel.font = FontBook.Medium.of(size: 18)
        btnbooknow.titleLabel!.font = FontBook.Medium.of(size: 17)
        
        addressLbl.font = FontBook.Regular.of(size: 14)
        summaryLbl.font = FontBook.Regular.of(size: 14)
        
        
        
        
        
        print(ProviderProfileViewController.providerDetails)

//        titleLbl.text = ProviderProfileViewController.providerDetails["name"]?.stringValue
        providerName.text = ProviderProfileViewController.providerDetails["name"]?.stringValue
        ratingLbl.text =  String(format: "%.2f", ProviderProfileViewController.providerDetails["avg_rating"]!.floatValue)
        priceLbl.text = "$\(String(describing: ProviderProfileViewController.providerDetails["priceperhour"]!.stringValue)) per hour"
        
        scrollView.delegate = self
        
        self.titleLbl.isHidden = false
//        self.titleLbl.transform = CGAffineTransform(translationX: 0, y: 50)
        
        if let imageName = ProviderProfileViewController.providerDetails["image"]?.string
        {
            if let imageURL = URL.init(string: imageName){
                Nuke.loadImage(with: imageURL, into: providerImage)
            }
        }
        
        var distance = ProviderProfileViewController.providerDetails["distance"]!.stringValue
        if(distance != "0"){
            if(distance.count >= 5)
            {
                distance = String(distance[..<distance.index(distance.startIndex, offsetBy: 5)])
            }
        }
        else{
            distance = "0"
        }
        let address1 = ProviderProfileViewController.providerDetails["addressline1"]?.stringValue
        let address2 = ProviderProfileViewController.providerDetails["addressline2"]?.stringValue
        let zipcode = ProviderProfileViewController.providerDetails["zipcode"]?.stringValue
        let city = ProviderProfileViewController.providerDetails["city"]?.stringValue
        let state = ProviderProfileViewController.providerDetails["state"]?.stringValue
        let address = address1! + " " + address2!
        let add1 =  state! + " " + city!
        let add2 = " - " + zipcode!
        let main_add = address + add1 + add2
        print(main_add)
        addressLbl.text = main_add
        
        distanceLbl.text = distance.appending(" KM")
//        distanceLbl.text = "\(String(describing: ProviderProfileViewController.providerDetails["distance"]!.stringValue)) KM"
        contactNumberLbl.text = ProviderProfileViewController.providerDetails["mobile"]?.stringValue
        summaryLbl.text = ProviderProfileViewController.providerDetails["about"]?.stringValue
        
        let tableHeight = CGFloat.init(ProviderProfileViewController.providerDetails["provider_services"]!.arrayValue.count * 22)
        
        otherServicesTableView.frame = CGRect.init(x: otherServicesTableView.frame.origin.x
            , y: otherServicesTableView.frame.origin.y
            , width: otherServicesTableView.frame.size.width, height: tableHeight)
        otherServicesTableView.rowHeight = UITableViewAutomaticDimension
        otherServicesTableView.estimatedRowHeight = 22
        
        var reviewTableHeight = 0
        reviewTableView.rowHeight = UITableViewAutomaticDimension
        reviewTableView.estimatedRowHeight = 67
        
        if(ProviderProfileViewController.providerDetails["reviews"]!.arrayValue.count == 0)
        {
            reviewLabel.isHidden = true
            
        }
        else if(ProviderProfileViewController.providerDetails["reviews"]!.arrayValue.count > 2)
        {
            reviewTableHeight = 134
            reviewTableView.frame = CGRect.init(x: reviewTableView.frame.origin.x, y: reviewTableView.frame.origin.y, width: reviewTableView.frame.size.width, height: CGFloat(reviewTableHeight))
        }
        else{
            reviewTableHeight = 67
            reviewTableView.frame = CGRect.init(x: reviewTableView.frame.origin.x, y: reviewTableView.frame.origin.y, width: reviewTableView.frame.size.width, height: CGFloat(reviewTableHeight))
        }
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
//        reviewTableHeightConstraint.constant = reviewTableView.frame.size.height
//        reviewTableView.layoutIfNeeded()
        
        
//        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        otherServicesTableView.delegate = self
        otherServicesTableView.dataSource = self
        otherServicesTableHeightConstraint.constant = otherServicesTableView.frame.size.height
        otherServicesTableView.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            btnbooknow.backgroundColor = mycolor
            if let imageName = ProviderProfileViewController.providerDetails["image"]?.string
            {
                if let imageURL = URL.init(string: imageName){
                    Nuke.loadImage(with: imageURL, into: providerImage)
                }
            }
            else {
                changeTintColor(providerImage, arg: mycolor)
            }
            changeTintColor(imgCal, arg:mycolor)
            changeTintColor(imgMsg, arg: mycolor)
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    @IBOutlet weak var btnMessage: UIButton!
    
    @IBAction func BtnMessage(_ sender: Any)
    {
       
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
    
    @IBAction func callProvider(_ sender: Any) {
    
    print(ProviderProfileViewController.providerDetails["mobile"]!.stringValue)
       
    guard let number = URL(string: "tel://" + ProviderProfileViewController.providerDetails["mobile"]!.stringValue) else { return }
            UIApplication.shared.openURL(number)        

        }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let hideAnimations: (() -> Void) = {
//            self.titleLbl.transform = CGAffineTransform(translationX: 0, y: 50)
        }
        
        let showAnimations: (() -> Void) = {
//            self.titleLbl.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        if(scrollView.contentOffset.y > 22)
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: showAnimations, completion: nil)
           
//            titleLbl.isHidden = false
        }
        else{
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: hideAnimations, completion: nil)
//            titleLbl.isHidden = true
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bookNow(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmBookingViewController") as! ConfirmBookingViewController
        
        vc.timeSlot = self.timeSlotName
        vc.timeSlotId = self.timeSlotId
        vc.subCategoryId = self.subCategoryId
        vc.subCategoryName = self.subCategoryName
        vc.address = self.selectedAddress
        vc.addressId = self.addressId
        vc.date = self.date
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 0)
        {
        return ProviderProfileViewController.providerDetails["provider_services"]!.arrayValue.count
        }
        else{
//            if(ProviderProfileViewController.providerDetails["reviews"]!.arrayValue.count > 2)
//            {
//                return 2
//            }
//            else{
                return ProviderProfileViewController.providerDetails["reviews"]!.arrayValue.count
//            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0)
        {
            return 24
        }
        else{
            return 67
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView.tag == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherServicesTableViewCell", for: indexPath) as! OtherServicesTableViewCell
            cell.serviceName.text = ProviderProfileViewController.providerDetails["provider_services"]![indexPath.row]["sub_category_name"].stringValue
            cell.servicePrice.text = "$\(ProviderProfileViewController.providerDetails["provider_services"]![indexPath.row]["priceperhour"].stringValue)/HR"
            if UserDefaults.standard.object(forKey: "myColor") != nil
            {
                //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
                let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
                //            var color: UIColor? = nil
                mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
                cell.vwdot.backgroundColor = mycolor
            }
      
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
            if let reviews = ProviderProfileViewController.providerDetails["reviews"]?.array
            {
            cell.userName.text = reviews[indexPath.row]["username"].stringValue
            cell.ratingView.rating = reviews[indexPath.row]["rating"].doubleValue
            cell.review.text = reviews[indexPath.row]["feedback"].stringValue
            cell.review.numberOfLines = 0
            cell.review.sizeToFit()
            }
            return cell
        }
    }
    
    
}

extension ProviderProfileViewController: BmoViewPagerDataSource {
    // Optional
    func bmoViewPagerDataSourceNaviagtionBarItemNormalAttributed(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> [NSAttributedStringKey : Any]? {
        return [
            NSAttributedStringKey.font : UIFont (name: "Ubuntu-Regular", size: 17)!,
            NSAttributedStringKey.foregroundColor : UIColor.lightGray
        ]
    }
    func bmoViewPagerDataSourceNaviagtionBarItemHighlightedAttributed(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> [NSAttributedStringKey : Any]? {
        return [
            NSAttributedStringKey.font : UIFont (name: "Ubuntu-Regular", size: 17)!,
            NSAttributedStringKey.foregroundColor : UIColor.black
        ]
    }
    func bmoViewPagerDataSourceNaviagtionBarItemHighlightedBackgroundView(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> UIView? {
        let view = UnderlineView()
        view.marginX = 100.0
        view.lineWidth = 5.0
        view.strokeColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
        return view
    }
    func bmoViewPagerDataSourceNaviagtionBarItemTitle(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> String? {
        return self.titles[page]
    }
    
    // Required
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        return self.titles.count
    }
    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        switch page {
        case 0:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileDetailsContentViewController") as? ProfileDetailsContentViewController {
                return vc
            }
        case 1:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewContentViewController") as? ReviewContentViewController
            {
                return vc
            }
        default:
            break
        }
        return UIViewController()
    }
    
    

   
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
}



