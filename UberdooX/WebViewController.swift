//
//  WebViewController.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 08/11/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//


import UIKit
import WebKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

protocol PaymentStatusDelegate: class
{
    func returnStatus()
}

class WebViewController: UIViewController,WKNavigationDelegate
{
    
    weak var payStatusDelegate: PaymentStatusDelegate?
    @IBOutlet weak var otherTitleLbl: UILabel!
    @IBOutlet weak var paymentTitleLbl: UILabel!
    var isPayment = false
    var paymentURL = ""
    var bookingID = ""
    var paymentStatus : [String:JSON]!
    var status : Bool = false
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var webKitView: WKWebView!
    @IBOutlet weak var otherWebView: UIView!
    @IBOutlet weak var paymentWebView: UIView!
    var titleString: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webKitView.navigationDelegate = self
        
        if(titleString == "About Us")
        {
            otherTitleLbl.text = titleString
            paymentWebView.isHidden = true
            //            getWebContent(key: "aboutus")
        }
        else if(titleString == "Help and FAQ")
        {
            otherTitleLbl.text = titleString
            paymentWebView.isHidden = true
            //            getWebContent(key: "faq")
        }
        else if(titleString == "Terms & Conditions")
        {
            otherTitleLbl.text = titleString
            paymentWebView.isHidden = true
            //            getWebContent(key: "terms")
        }
        else if(titleString == "Paystack Payment")
        {
            paymentTitleLbl.text = titleString
            paymentWebView.isHidden = false
        }
               
        if isPayment == true
        {
            let myUrl = URL(string: paymentURL)
            print("URL:",myUrl!)
            let request = URLRequest(url: myUrl!)
            webKitView.load(request)
        }
        else
        {
            getWebContent()
        }
        // Do any additional setup after loading the view.
    }
    
    func getWebContent(){
        
        SwiftSpinner.show("Loading...".localized())
//        let url = "\(Constants.adminBaseURL)/showPag"
        
        let url = APIList().getAdminUrlString(url: .SHOWPAG)

        
        Alamofire.request(url,method: .post).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value {
                    print("WEB JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    print(jsonResponse)
                    if(jsonResponse["error"].stringValue == "Unauthenticated" || jsonResponse["error"].stringValue == "true")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else{
                        
                        if self.titleString == "About Us"
                        {
                            let image = jsonResponse["page"][0]["privacyPolicy"].stringValue
                            self.lblPrivacy.text! = image
                        }
                        else
                        {
                            let image = jsonResponse["page"][0]["termsAndCondition"].stringValue
                            self.lblPrivacy.text! = image
                        }
                        //                        let pageUrlString = jsonResponse["static_pages"][0]["page_url"].stringValue
                        //                        let pageUrl = URL.init(string: pageUrlString)
                        //                        let urlRequest = URLRequest.init(url: pageUrl!)
                        //                        self.webView.loadRequest(urlRequest)
                    }
                }
            }
            else{
                SwiftSpinner.hide()
                print(response.error.debugDescription)
            }
        }
    }
    
    func paystackStatus()
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
        let bookingId = self.bookingID
        print("Booking",bookingId)
        let params: Parameters = [
            "booking_id": bookingId
        ]
        print(params)
        
        SwiftSpinner.show("Please wait...".localized())
        let url = APIList().getUrlString(url: .PAYSTACKPAYMENTSTATUS)
        print(url)
        
        Alamofire.request(url,method: .post, parameters:params, headers:headers).responseJSON { response in
            
            if(response.result.isSuccess)
            {
                SwiftSpinner.hide()
                if let json = response.result.value
                {
                    print("PAYMENT STATUS JSON: \(json)") // serialized json response
                    let jsonResponse = JSON(json)
                    print("PaymentJSON",jsonResponse)
                    if(jsonResponse["error"].stringValue == "true" )
                    {
                        self.showAlert(title: "Oops".localized(), msg: jsonResponse["error_message"].stringValue)
                    }
                    else if(jsonResponse["error"].stringValue == "Unauthenticated")
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        self.paymentStatus = jsonResponse["order_details"].dictionaryValue
                        print("PAY STATUS JSON",self.paymentStatus)
                        self.status = self.paymentStatus["status"]?.boolValue ?? false
                        print("Status:",self.status)
                        self.goBack()
                    }
                }
            }
            else
            {
                SwiftSpinner.hide()
                print(response.error.debugDescription)
                self.showAlert(title: "Oops".localized(), msg: response.error!.localizedDescription)
                
            }
        }
    }
 
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backFromPayment(_ sender: UIButton)
    {
        if sender.tag == 1
        {
            checkPaymentStatus()
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func checkPaymentStatus()
    {
        paystackStatus()
    }
    
    func goBack()
    {
        if self.status
        {
            payStatusDelegate?.returnStatus()
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //    func webViewDidStartLoad(_ webView: UIWebView) {
    //        SwiftSpinner.show("Loading")
    //    }
    //
    //    func webViewDidFinishLoad(_ webView: UIWebView) {
    //        SwiftSpinner.hide()
    //    }
    //
    //    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    //        SwiftSpinner.hide()
    //        self.showAlert(title: "Oops", msg: error.localizedDescription)
    //    }
    
    /*
     public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void)
     {
     print("NavURL",navigationAction.request.url!)
     if(navigationAction.navigationType == .other)
     {
     if navigationAction.request.url != nil
     {
     //do what you need with url
     //self.delegate?.openURL(url: navigationAction.request.url!)
     }
     decisionHandler(.cancel)
     return
     }
     decisionHandler(.allow)
     }*/
    
    /*   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
     {
     
     }
     */
}

