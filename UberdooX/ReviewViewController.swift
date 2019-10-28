//
//  ReviewViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 29/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import Cosmos
import SwiftyJSON
import Alamofire
import SwiftSpinner
import SimpleImageViewer
import SDWebImage
import PDFReader


class ReviewViewController: UIViewController
{
    
    
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var helpLbl: UILabel!
    @IBOutlet weak var tellUsLbl: UILabel!
    @IBOutlet weak var receiptBtn: UIButton!
    
    
    @IBOutlet weak var thanksCardView: CardView!
    @IBOutlet weak var thanksImageView: UIImageView!
    @IBOutlet weak var thanksLbl: UILabel!
    @IBOutlet weak var thanksBtn: UIButton!
    
    
    
    @IBOutlet weak var beforeImg: UIImageView!
    @IBOutlet weak var afterImg: UIImageView!
    
    let sharedInstance = Connection()

    var receiptURL : URL!
    
    
    var flag = false
    
    @IBOutlet weak var btnconfirm: UIButton!
    var bookingDetails : [String:JSON]!
    @IBOutlet weak var reviewFld: UITextField!
//    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var ratingView: CosmosView!
//    @IBOutlet weak var topView: UIView!
    var hasAlreadyMoved = false
    var mycolor = UIColor()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        thanksCardView.isHidden = true
        ratingLbl.text = "Give us your rating".localized()
        thanksLbl.text = "Thanks for using Jobfizzer service".localized()
        helpLbl.text = "Help your provider improve their service by rating them".localized()
        tellUsLbl.text = "Tell us about our service".localized()
        reviewFld.placeholder = "Type your comments".localized()
        receiptBtn.setTitle("Get Receipt ?".localized(),for: .normal)
            btnconfirm.setTitle("CONFIRM".localized(),for: .normal)
        
        ratingLbl.font = FontBook.Medium.of(size: 20)
        helpLbl.font = FontBook.Regular.of(size: 16)
        tellUsLbl.font = FontBook.Regular.of(size: 16)
        reviewFld.font = FontBook.Regular.of(size: 16)

        receiptBtn.titleLabel!.font = FontBook.Medium.of(size: 16)
        btnconfirm.titleLabel!.font = FontBook.Medium.of(size: 16)

        print(self.bookingDetails)
        
        if SharedObject().hasData(value: self.bookingDetails)
        {
            sharedInstance.bookingID = self.bookingDetails["booking_id"]!.stringValue
        }
        else
        {
            sharedInstance.bookingID = ""
        }

        
        
/*        self.topView.frame.origin.y = self.topView.frame.origin.y + 130
        self.bottomView.frame.origin.y = self.bottomView.frame.origin.y + 270
        ratingView.didFinishTouchingCosmos = {
            rating in
            
            if(!self.hasAlreadyMoved)
            {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations: {

                self.hasAlreadyMoved = true
                self.topView.frame.origin.y = self.topView.frame.origin.y - 130
                self.bottomView.frame.origin.y = self.bottomView.frame.origin.y - 270
                    
                }) { (Void) in
                    
                }
            }
            print(rating)
        }*/
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.getImageData()
    }
    
    
    func getImageData()
    {
        
        SwiftSpinner.show("Loading...".localized())

        sharedInstance.postConnection("startjobendjobdetails", success:
        {
            (json) in
            
            SwiftSpinner.hide()
            print("Review Image Json = ",json)
            let jsonResponse = JSON(json)
            
            if(jsonResponse["error"].stringValue == "false")
            {
                self.beforeImg.sd_setImage(with: URL(string: jsonResponse["data"]["start_image"].stringValue), placeholderImage: UIImage(named: "iconforPlaceholder"))
                
                
                self.afterImg.sd_setImage(with: URL(string: jsonResponse["data"]["end_image"].stringValue), placeholderImage: UIImage(named: "iconforPlaceholder"))
                
                
                if jsonResponse["invoicelink"].arrayValue.count > 0
                {
                    self.receiptURL = jsonResponse["invoicelink"][0]["invoicelink"].url
                    
                    self.flag = true
                }
                
            }
        },
        failure:
        {
                (error) in
            
                SwiftSpinner.hide()

                print("Review Image Error = ",error)
        })
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            mycolor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
            btnconfirm.backgroundColor = mycolor
            thanksBtn.backgroundColor = mycolor
            thanksImageView.tintColor = mycolor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendReview(_ sender: Any)
    {
        if ratingView.rating == 0.0
        {
            self.showAlert(title: "Oops".localized(), msg: "Please provide a rating".localized())
        }
        else
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
            
            let bookingId = self.bookingDetails["booking_id"]!.stringValue//provider_id
            let providerId = self.bookingDetails["provider_id"]!.stringValue
            let rating = String(ratingView.rating)
            let feedback = reviewFld.text
            
            var booking = ""
            var provider = ""
            var rate = ""
            if SharedObject().hasData(value: bookingId){
                booking = bookingId
            }
            if SharedObject().hasData(value: providerId){
                provider = providerId
            }
            if SharedObject().hasData(value: rating){
                rate = rating
            }
            
            let params: Parameters = [
                "id": provider,
                "rating": rate ,
                "booking_id":booking,
                "feedback":feedback!
            ]
            
            
            SwiftSpinner.show("Thanks for your review.".localized())
            
            let url = APIList().getUrlString(url: .REVIEW)

            Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
                
                if(response.result.isSuccess)
                {
                    SwiftSpinner.hide()
                    if let json = response.result.value {
                        print("REVIEW JSON: \(json)") // serialized json response
                        let jsonResponse = JSON(json)
                        
                        
                        if(jsonResponse["error"].stringValue == "true")
                        {
                            let errorMessage = jsonResponse["error_message"].stringValue
                            self.showAlert(title: "Failed".localized(),msg: errorMessage)
                        }
                        else{
                            self.thanksCardView.isHidden = false
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
    
    /*
    func showAlert(title: String,msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func getReceiptBtn(_ sender: Any)
    {
        if flag
        {
            let document = PDFDocument(url: self.receiptURL!)!
            
            let readerController = PDFViewController.createNew(with: document, title: "", actionButtonImage: nil, actionStyle: .activitySheet)
            
            let aObjNavi = UINavigationController(rootViewController: readerController)
            
            self.present(aObjNavi, animated: true, completion: nil)
        }
        else
        {
            self.showAlert(title: "Oops".localized(), msg: "Invalid Booking".localized())
        }
    }
    @IBAction func okayBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        vc.goToBookings = true
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func beforeImgBtn(_ sender: Any)
    {
        viewImage(imgView: self.beforeImg)
    }
        
    @IBAction func afterImageBtn(_ sender: Any)
    {
        viewImage(imgView: self.afterImg)
    }
    
    func viewImage(imgView :UIImageView)
    {
        let configuration = ImageViewerConfiguration
        {
            config in
            config.imageView = imgView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
}
