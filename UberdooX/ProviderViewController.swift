//
//  ProviderViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 17/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import SwiftyJSON


private let mainColor = UIColor(red: 1.0/255.0, green: 55.0/255.0, blue: 132.0/255.0, alpha: 1.0)
class ProviderViewController: UIViewController,UIPageViewControllerDataSource {
    
    @IBOutlet weak var providerImage: UIImageView!
    @IBOutlet weak var btnbook: UIButton!
    @IBOutlet weak var providerName: UILabel!
    static var providerDetails : [String:JSON]!
    var titles: [String] = ["Profile","Reviews"]
    var viewControllers: [UIViewController] = []
    var subCategoryName : String!
    var subCategoryId : String!
    var timeSlotName : String!
    var timeSlotId : String!
    var date : String!
    var selectedAddress : [String:JSON]!
    var addressId : String!
    var pageViewController : UIPageViewController!
    var globalIndex = 0;
    var mycolor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ProviderViewController.providerDetails)
        
//        providerName.text = ProviderViewController.providerDetails["name"]?.stringValue
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProviderPageController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        let startVC = storyboard?.instantiateViewController(withIdentifier: "ProfileDetailsContentViewController") as! ProfileDetailsContentViewController
        let endVC = storyboard?.instantiateViewController(withIdentifier: "ReviewContentViewController") as! ReviewContentViewController
        
        self.viewControllers = NSArray(objects:startVC,endVC) as! [UIViewController]
        let vcs = NSArray(object: startVC) as! [UIViewController]
        
        self.pageViewController.setViewControllers(vcs, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRect(x:0, y:280, width:self.view.frame.width, height:self.view.frame.height-280)
//        self.pageViewController.view.backgroundColor = UIColor.blue
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
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
//            changeTintColor(providerImage, arg: mycolor)
        }
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

    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
    
    func viewControllerAtIndex(_ index:Int )->UIViewController{
        
        if(index > 1)
        {
            globalIndex = index - 1;
            return self.viewControllers[globalIndex];
        }
        if(index < 0)
        {
            globalIndex = index + 1;    
            return self.viewControllers[globalIndex];
        }
        globalIndex = index;
        return self.viewControllers[index];
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        print("AFTER")
        print(globalIndex)
        globalIndex += 1
        if(globalIndex == NSNotFound || globalIndex == 2)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(globalIndex)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        print("BEFORE")
        print(globalIndex)
        globalIndex -= 1
        if(globalIndex == 0 || globalIndex == NSNotFound)
        {
            return nil
        }
        
        
        return self.viewControllerAtIndex(globalIndex)
        
    }
}




