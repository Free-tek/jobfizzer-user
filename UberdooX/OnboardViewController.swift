//
//  OnboardViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 12/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController,UIPageViewControllerDataSource {
    var pageViewController : UIPageViewController!
    var pageTitles :NSArray!
    @IBOutlet weak var skipLoginBtn: UIButton!
    var pageContents :NSArray!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    var pageImages : NSArray!
    var mycolor = UIColor()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
         skipLoginBtn.setTitle("CONTINUE WITHOUT LOGIN".localized(),for: .normal)
         signInBtn.setTitle("SIGN IN".localized(),for: .normal)
         signUpBtn.setTitle("SIGN UP".localized(),for: .normal)
        
          skipLoginBtn.titleLabel!.font = FontBook.Medium.of(size: 16)        
          signUpBtn.titleLabel!.font = FontBook.Regular.of(size: 17)
          signInBtn.titleLabel!.font = FontBook.Regular.of(size: 17)

        self.pageContents = NSArray(objects: "Jobfizzer is your one stop destination for all lifestyle services. We help you hire local professionals.".localized(),"Get the best wedding photographer near you and capture your special day to cherish later.".localized(),"Transform your house/office into your dream place with our interior design experts.".localized(),"Do you want to look great on a special occassion. Hire the best beautician in town.".localized())
        
        self.pageTitles = NSArray(objects: "Jobfizzer".localized(),"Photographer".localized(),"Interior Design".localized(),"Beautician".localized())
        
        self.pageImages = NSArray(objects:"onboard_1","onboard_2","onboard_3","onboard_4")
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        let startVC = self.viewControllerAtIndex(0) as OnBoardContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        
       self.view.bringSubview(toFront: self.skipLoginBtn)
        self.view.bringSubview(toFront: self.signInBtn)
        self.view.bringSubview(toFront: self.signUpBtn)
        self.pageViewController.didMove(toParentViewController: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    

    func viewControllerAtIndex(_ index:Int )->OnBoardContentViewController{
        if(self.pageContents.count == 0 || (index >= self.pageContents.count))
        {
            return OnBoardContentViewController()
        }
        let vc : OnBoardContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "OnBoardContentViewController") as! OnBoardContentViewController
        vc.pageIndex = index;
        vc.pageTitle = pageTitles[index] as! String
        vc.pageContent = pageContents[index] as! String
        vc.imageContent = pageImages[index] as! String
        
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! OnBoardContentViewController
        var index = vc.pageIndex as Int
        
        if(index == NSNotFound)
        {
            return nil
        }
        index += 1
        
        if(index == self.pageContents.count)
        {
            return nil
        }
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! OnBoardContentViewController
        var index = vc.pageIndex as Int
        
        if(index == 0 || index == NSNotFound)
        {
            return nil
        }
        index -= 1
        
        return self.viewControllerAtIndex(index)
        
    }
    
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
//    
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return pageContents.count
//    }
    
    @IBAction func goToSigninPage(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func goToSignUpPage(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func goToHomePage(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
    
        UserDefaults.standard.set(true, forKey: "isLoggedInSkipped")
        self.present(vc, animated: true, completion: nil)
    }
    
}
