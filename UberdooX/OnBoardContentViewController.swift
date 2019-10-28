//
//  OnBoardContentViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 12/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit

class OnBoardContentViewController: UIViewController
{

    @IBOutlet weak var firstPageLogo: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var firstPageContent: UILabel!
    @IBOutlet weak var firstPageTitle: UILabel!
    @IBOutlet weak var otherPageTitle: UILabel!
    @IBOutlet weak var otherPageContent: UILabel!
    
    var pageIndex :Int!
    var pageTitle :String!
    var pageContent :String!
    var imageContent : String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        otherPageTitle.font = FontBook.Medium.of(size: 20)
        firstPageContent.font = FontBook.Medium.of(size: 25)
        firstPageContent.font = FontBook.Regular.of(size: 17)
        otherPageContent.font = FontBook.Regular.of(size: 17)
        

        if(pageIndex == 0)
        {
            firstPageLogo.isHidden = false
            firstPageTitle.isHidden = false
            firstPageContent.isHidden = false
            otherPageTitle.isHidden = true
            otherPageContent.isHidden = true
        }
        else{
            firstPageLogo.isHidden = true
            firstPageTitle.isHidden = true
            firstPageContent.isHidden = true
            otherPageTitle.isHidden = false
            otherPageContent.isHidden = false
        }
        self.backgroundImage.image = UIImage(named: self.imageContent)
        self.firstPageTitle.text = self.pageTitle
        self.otherPageTitle.text = self.pageTitle
        self.firstPageContent.text = self.pageContent
        self.otherPageContent.text = self.pageContent

//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationDuration(10.0)
//        UIView.setAnimationDelegate(self)
//        
//        self.backgroundImage.frame.origin.x = self.backgroundImage.frame.origin.x - 100;
//        self.backgroundImage.frame.origin.x = self.backgroundImage.frame.origin.x + 250;
  
//        [UIView animateWithDuration:0.3f
//            delay:0.0f
//            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
//            animations:^{
//            [testView setFrame:CGRectMake(0.0f, 100.0f, 300.0f, 200.0f)];
//            }
//            completion:nil];
//        let rect = CGRect(x: self.backgroundImage.frame.minX-100, y: self.backgroundImage.frame.minY, width: self.backgroundImage.frame.width, height: self.backgroundImage.frame.height)
//
//        UIView.animate(withDuration: 10.0, delay: 0.0, options: [.repeat,.autoreverse], animations:{ self.backgroundImage.frame = rect}, completion: nil)
//        UIView.commitAnimations()
//
//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationDuration(10.0)
//        self.backgroundImage.frame.origin.x = self.backgroundImage.frame.origin.x + 350;
//        UIView.commitAnimations()
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
