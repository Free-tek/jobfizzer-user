//
//  ChatViewController.swift
//  Tindo
//
//  Created by Karthik Sakthivel on 05/12/17.
//  Copyright © 2017 Pyramidions. All rights reserved.
//

import UIKit
import Nuke
import Alamofire
import SwiftyJSON
import SDWebImage
import IQKeyboardManagerSwift
import NextGrowingTextView
import IQKeyboardManagerSwift
import SwiftSpinner
import SimpleImageViewer
import PDFReader
import QuickLook
import AWSCore
import AWSS3
import Photos
//import KRProgressHUD
import MobileCoreServices


class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIDocumentPickerDelegate
{
    
    var documentController : UIDocumentInteractionController!
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    
    @IBOutlet weak var sendProImage: UIImageView!
    lazy var previewItem = NSURL()
    
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var progressBlock: AWSS3TransferUtilityProgressBlock?
    
    let transferUtility = AWSS3TransferUtility.default()
    
    var fileLink = ""
    var isBack = false
    
    @IBOutlet weak var toHideButton: UIButton!
    @IBOutlet weak var toScaleView: UIView!
    @IBOutlet weak var chatBarView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var chatBarFld: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var userDetails : [JSON] = []
    var toScaleViewYpos: CGFloat!
    var keyboardHeight : CGFloat!
    @IBOutlet weak var animatedEmojiCollectionView: UICollectionView!
    
    var isLoadingList : Bool = false
    var isGoingUp : Bool = false
    
    //    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    var isFromMatch : Bool!
    var receiverId : String!
    var messages : [JSON] = []
    
    var imageName : String!
    var name : String!
    
    var rainView : UIView!
    
    var startTimer: Timer!
    var endTimer: Timer!
    var clearTimer: Timer!
    var moveLayer: CALayer!
    
    var isKeyboardShowing = false
    
    let RainImageViewRadius = 0.0
    let RainTimeInterval = 0.3
    let RainEndTime = 5.0
    let RainAnimationTime = 2.0
    var RainClearTime = 0.0
    
    var heartImage = "heart"
    var laughImage = "laughing"
    var wowImage = "surprised"
    var angryImage = "angry"
    var currentImage = "heart"
    
    var isAnimationAlreadyInProgress = false
    var isBottomViewShowing = false
    
    var emojis = [String]()
    var emojiBgs = [String]()
    var bookingId :String = ""
    var booking : String = ""
    var profileImg : String = ""
    
    var senderProImage = ""
    var receiverProImage = ""
    var message: [String] = []
    
    
    var Total_Page_Count : Int = 0
    var Current_page : Int = 1
    
    
    lazy var refreshControl: UIRefreshControl =
        {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(ChatViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
            refreshControl.tintColor = UIColor.black
            refreshControl.attributedTitle = NSAttributedString(string: "Fetching...")
            
            return refreshControl
    }()
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    //    var indicator : NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        appDelegate.chatReceiveID = receiverId
        
        
        growingTextView.textView.keyboardType = UIKeyboardType.asciiCapable;
        
        
        tableView.estimatedRowHeight = 77
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        self.tableView.addSubview(self.refreshControl)
        
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().enable = false
        
        
        
        
        // Do any additional setup after loading the sview.
        
        //        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        //        self.toScaleViewYpos = self.toScaleView.frame.origin.y
        //        IQKeyboardManager.sharedManager().enable = false
        //        chatBarFld.autocorrectionType = UITextAutocorrectionType.no
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        self.growingTextView.maxNumberOfLines = 5
        
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Type your message",
                                                                            attributes: [NSAttributedStringKey.font: self.growingTextView.textView.font!,
                                                                                         NSAttributedStringKey.foregroundColor: UIColor.gray
            ]
        )
        
        
        
        
        tableView.keyboardDismissMode = .onDrag
        
        emojis.append("heart_emoji_trans")
        emojis.append("wow_emoji")
        emojis.append("emoji_laugh")
        emojis.append("angry_emoji")
        
        emojiBgs.append("hearts_bg.png")
        emojiBgs.append("wow_bg.png")
        emojiBgs.append("laugh_bg.png")
        emojiBgs.append("angry_bg.png")
        
        //        animatedEmojiCollectionView.delegate = self
        //        animatedEmojiCollectionView.dataSource = self
        //        animatedEmojiCollectionView.showsHorizontalScrollIndicator = false
        
        RainClearTime = RainEndTime + RainAnimationTime
        
        self.userPicture.layer.cornerRadius = self.userPicture.frame.size.height/2
        self.userPicture.clipsToBounds = true
        
        
        self.sendProImage.layer.cornerRadius = self.userPicture.frame.size.height/2
        self.sendProImage.clipsToBounds = true
        
        
        
        
        
        /*
         let orangeColor = UIColor(red: 253.0 / 255.0, green: 131.0 / 255.0, blue: 67.0 / 255.0, alpha: 1.0)
         let redColor = UIColor(red: 236.0 / 255.0, green: 76.0 / 255.0, blue: 118.0 / 255.0, alpha: 1.0)
         setGradientBackground(button: sendBtn, startColor: redColor, endColor: orangeColor)*/
        
        userName.text = name
        /*        if let imgUrl = URL.init(string: imageName){
         //            Nuke.loadImage(with: imgUrl, into: self.userPicture)
         }*/
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "TextTableViewCell")
        self.tableView.register(UINib(nibName: "ReceiverTextTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverTextTableViewCell")
        
        self.tableView.register(UINib(nibName: "SenderImageTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderImageTableViewCell")
        
        self.tableView.register(UINib(nibName: "ReceiverImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageTableViewCell")
        
        self.tableView.register(UINib(nibName: "SenderPDFTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderPDFTableViewCell")
        
        self.tableView.register(UINib(nibName: "ReceiverPDFTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverPDFTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageReceived(_:)), name: NSNotification.Name(rawValue: "MessageReceived"), object: nil)
        
        
        
        /*        let frame = CGRect.init(x: (self.view.frame.size.width/2)-25, y: (self.view.frame.size.height/2)-25, width: 50, height: 50)
         indicator = NVActivityIndicatorView(frame: frame, type: .ballSpinFadeLoader, color: redColor, padding: 0)
         self.view.addSubview(indicator)
         self.view.bringSubview(toFront: indicator)*/
        
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl)
    {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:
            {
                //                self.pullToloadFeeds()
                
                if self.Total_Page_Count > 1
                {
                    if !self.isLoadingList
                    {
                        if self.Total_Page_Count >= self.Current_page
                        {
                            self.refreshControl.isUserInteractionEnabled = true
                            
                            self.updateChatList()
                        }
                        else
                        {
                            self.refreshControl.endRefreshing()
                            self.refreshControl.removeFromSuperview()
                            
                        }
                    }
                    else
                    {
                        self.refreshControl.endRefreshing()
                        self.refreshControl.removeFromSuperview()
                        
                    }
                }
                else
                {
                    self.refreshControl.removeFromSuperview()
                    
                    self.refreshControl.endRefreshing()
                }
        })
        
    }
    
    
    
    func scrollToBottom() {
        if self.messages.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(item:messages.count-1, section: 0), at: .bottom, animated: false)
        }
        
    }
    
    
    //
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        view.endEditing(true)
    //    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        print("isBack = ",isBack)
        
        if !isBack
        {
            self.getChatsList()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        IQKeyboardManager.sharedManager().enable = true
        
        appDelegate.chatReceiveID = ""
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        appDelegate.chatReceiveID = receiverId
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.post(name: Notification.Name("disableSwipeGesture"), object: nil)
        
        
    }
    
    
    
    
//    func showAlert(title: String,msg : String)
//    {
//        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
//
//        // add an action (button)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//
//        // show the alert
//        self.present(alert, animated: true, completion: nil)
//    }
    
    
    
    func getChatsList()
    {
        
        if let accesstoken = UserDefaults.standard.string(forKey: "userid")
        {
            //            indicator.startAnimating()
            
            SwiftSpinner.show( "Loading...")
            
            var senderId = ""
            
            if (UserDefaults.standard.object(forKey: "userid") != nil)
            {
                senderId = UserDefaults.standard.object(forKey: "userid") as! String
            }
            
            
            let params: Parameters = [
                "senderID": senderId,
                "receiverID": self.receiverId!,
                "page":Current_page,
                "senderType":"user"
            ]
            
            print("Params = ",params)
            //            let url = "\(Constants.baseURL)chatlist"
            
            let url = ("\(APIList().SOCKET_MESSAGE)userchatlist")
            
            print("Url= \(url)")
            let Headers: HTTPHeaders = [
                "Content-Type":"application/x-www-form-urlencoded"
            ]
            
            
            Alamofire.request(url, method: .post, parameters: params, headers: Headers)
                .responseJSON
                { response in
                    
                    //                    self.indicator.stopAnimating()
                    
                    SwiftSpinner.hide()
                    
                    
                    if(response.result.isSuccess)
                    {
                        if let json = response.result.value {
                            print("CHAT SCREEN JSON: \(json)") // serialized json response
                            let jsonResponse = JSON(json)
                            if(jsonResponse["error"].stringValue == "false" )
                            {
                                self.messages = jsonResponse["results"].arrayValue
                                self.userDetails = jsonResponse["userdetails"].arrayValue
                                
                                
                                self.Current_page = jsonResponse["currentpage"].intValue
                                self.Total_Page_Count = jsonResponse["pageCount"].intValue
//                                self.bookingId = jsonResponse["booking_id"].stringValue
                                
                                /*                                let tempMessage : [JSON] = jsonResponse["results"].arrayValue
                                 
                                 for temp in tempMessage.reversed()
                                 {
                                 self.messages.append(temp)
                                 }
                                 */
                                
                                
                                self.userName.text = jsonResponse["receiver_name"].stringValue
                                
                                self.senderProImage = jsonResponse["sender_profilePic"].stringValue
                                self.receiverProImage = jsonResponse["receiver_profilePic"].stringValue
                                
                                
                                
                                self.userPicture.sd_setImage(with: URL(string: self.receiverProImage), placeholderImage: UIImage(named: "profile"))
                                self.sendProImage.sd_setImage(with: URL(string: self.senderProImage), placeholderImage: UIImage(named: "profile"))
                                
                                
                                
                                
                                if(self.messages.count>0)
                                {
                                    for i in 0 ... self.messages.count-1{
                                        //                                        let size = self.sizeOfString(string: self.messages[i]["content"].stringValue, constrainedToWidth: 200)
                                        self.messages[i]["row_height"].floatValue = 0.0
                                    }
                                }else{
                                    
                                }
                                print("AAA",self.messages)
                                self.tableView.reloadData()
                                self.scrollToBottom()
                            }
                            else{
                                //                                self.showAlert(title: "Oops", msg: jsonResponse["message"].stringValue)
                            }
                        }
                    }
                    else{
                        print("Error1",response.error.debugDescription)
                        self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
                        
                    }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
    }
    
    var lastContentOffset: CGFloat = 0
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    
    
    /*
     func scrollViewDidScroll(scrollView: UIScrollView) {
     if (self.lastContentOffset < scrollView.contentOffset.y) {
     // moved to top
     
     isGoingUp = true
     
     print("isGoingUp")
     
     } else if (self.lastContentOffset > scrollView.contentOffset.y) {
     // moved to bottom
     
     isGoingUp = false
     
     print("isGoingDown")
     
     } else {
     // didn't move
     }
     }
     */
    /*
     func scrollViewDidScrollToTop(_ scrollView: UIScrollView)
     {
     if (self.lastContentOffset < scrollView.contentOffset.y)
     {
     isGoingUp = true
     
     print("isGoingUp")
     }
     else if (self.lastContentOffset > scrollView.contentOffset.y)
     {
     isGoingUp = false
     
     print("isGoingDown")
     }
     else
     {
     // didn't move
     }
     }
     */
    /*
     
     func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
     {
     if targetContentOffset.pointee.y < scrollView.contentOffset.y
     {
     isGoingUp = true
     
     print("isGoingUp")
     }
     else
     {
     isGoingUp = false
     
     print("isGoingDown")
     
     }
     
     }
     */
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        print("First Cell")
        
        
        
        if isGoingUp
        {
            if Total_Page_Count > 1
            {
                if !isLoadingList
                {
                    if Total_Page_Count >= Current_page
                    {
                        
                        self.refreshControl.isUserInteractionEnabled = true
                        
                        Current_page = Current_page + 1
                        
                        print("Current_page = ",Current_page)
                        print("Total_Page_Count = ",Total_Page_Count)
                        
                        self.refreshControl.beginRefreshing()
                        
                        
                        self.handleRefresh(self.refreshControl)
                        
                        //                        updateChatList()
                    }
                    else
                    {
                        self.refreshControl.removeFromSuperview()
                    }
                }
            }
            else
            {
                self.refreshControl.removeFromSuperview()
            }
        }
        
    }
    
    
    func updateChatList()
    {
        
        if let accesstoken = UserDefaults.standard.string(forKey: "userid")
        {
            //            indicator.startAnimating()
            
            //            KRProgressHUD.show(withMessage: "Loading...")
            
            
            var senderId = ""
            
            if (UserDefaults.standard.object(forKey: "userid") != nil)
            {
                senderId = UserDefaults.standard.object(forKey: "userid") as! String
            }
            
            
            let params: Parameters = [
                "senderID": senderId,
                "receiverID": self.receiverId!,
                "page":Current_page,
                "senderType":"user"
            ]
            
            print("Params = ",params)
            //            let url = "\(Constants.baseURL)chatlist"
            
            let url = ("\(APIList().SOCKET_MESSAGE)userchatlist")
            
            
            
            let Headers: HTTPHeaders = [
                "Content-Type":"application/x-www-form-urlencoded"
            ]
            
            
            Alamofire.request(url, method: .post, parameters: params, headers: Headers)
                .responseJSON
                { response in
                    
                    //                    self.indicator.stopAnimating()
                    
                    //                    KRProgressHUD.dismiss()
                    
                    
                    self.refreshControl.endRefreshing()
                    
                    
                    self.isLoadingList = false
                    
                    if(response.result.isSuccess)
                    {
                        if let json = response.result.value {
                            print("CHAT SCREEN JSON: \(json)") // serialized json response
                            let jsonResponse = JSON(json)
                            if(jsonResponse["error"].stringValue == "false" )
                            {
                                var tempArray : [JSON] = jsonResponse["results"].arrayValue
                                if(self.messages.count > 0){
                                    for i in 0 ... self.messages.count-1
                                    {
                                        tempArray.append(self.messages[i])
                                    }
                                }
                                self.messages = tempArray
                                self.userDetails = jsonResponse["userdetails"].arrayValue
                                
                                
                                self.Current_page = jsonResponse["currentpage"].intValue
                                self.Total_Page_Count = jsonResponse["pageCount"].intValue
                                
                                
                                
                                self.userName.text = jsonResponse["receiver_name"].stringValue
                                
                                
                                
                                self.senderProImage = jsonResponse["sender_profilePic"].stringValue
                                self.receiverProImage = jsonResponse["receiver_profilePic"].stringValue
                                
                                
                                self.userPicture.sd_setImage(with: URL(string: self.receiverProImage), placeholderImage: UIImage(named: "default-user-image"))
                                self.sendProImage.sd_setImage(with: URL(string: self.senderProImage), placeholderImage: UIImage(named: "default-user-image"))
                                
                                
                                if(self.messages.count>0)
                                {
                                    for i in 0 ... self.messages.count-1{
                                        //                                        let size = self.sizeOfString(string: self.messages[i]["content"].stringValue, constrainedToWidth: 200)
                                        self.messages[i]["row_height"].floatValue = 0.0
                                    }
                                }
                                
                                
                                
                                print("BBB",self.messages)
                                self.tableView.reloadData()
                                //                                self.scrollToBottom()
                            }
                            else
                            {
                                
                                self.Current_page = self.Current_page - 1
                                
                                //                                self.showAlert(title: "Oops", msg: jsonResponse["message"].stringValue)
                            }
                        }
                    }
                    else
                    {
                        
                        self.Current_page = self.Current_page - 1
                        
                        print("Error2",response.error.debugDescription)
                        self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
                        
                    }
            }
        }
    }
    
    
    
    
    /*
     
     func report(reason : String!)
     {
     self.indicator.startAnimating()
     if let senderId = UserDefaults.standard.string(forKey: "userId"){
     let params: Parameters = [
     "senderID": senderId,
     "receiverID ": self.receiverId!,
     "reason":reason
     ]
     print(params)
     let url = "\(Constants.baseURL)report"
     Alamofire.request(url,method: .post, parameters:params).spin().responseJSON { response in
     self.indicator.stopAnimating()
     if(response.result.isSuccess)
     {
     if let json = response.result.value {
     print("REPORT JSON: \(json)") // serialized json response
     let jsonResponse = JSON(json)
     if(jsonResponse["error"].stringValue == "false" )
     {
     self.dismiss(animated: true, completion: nil)
     
     }
     else{
     self.showAlert(title: "Oops", msg: jsonResponse["message"].stringValue)
     }
     }
     }
     else{
     print(response.error.debugDescription)
     self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
     
     }
     }
     }
     }
     
     func unMatch(){
     self.indicator.startAnimating()
     if let accesstoken = UserDefaults.standard.string(forKey: "accessToken"){
     let params: Parameters = [
     "accessToken": accesstoken,
     "unmatchID": self.receiverId
     ]
     let url = "\(Constants.baseURL)Unmatch"
     Alamofire.request(url,method: .post, parameters:params).spin().responseJSON { response in
     
     self.indicator.stopAnimating()
     if(response.result.isSuccess)
     {
     if let json = response.result.value {
     print("UNMATCH JSON: \(json)") // serialized json response
     let jsonResponse = JSON(json)
     if(jsonResponse["error"].stringValue == "false" )
     {
     self.dismiss(animated: true, completion: nil)
     }
     else{
     self.showAlert(title: "Oops", msg: jsonResponse["message"].stringValue)
     
     }
     }
     }
     else{
     print(response.error.debugDescription)
     self.showAlert(title: "Oops", msg: response.error!.localizedDescription)
     
     }
     }
     }
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: Any)
    {
        
        
        self.dismiss(animated: true, completion: nil)
        
        
        //        self.navigationController?.popViewController(animated: true)
        
        /*        if(isFromMatch)
         {
         let vc = self.storyboard?.instantiateViewController(withIdentifier:"MainViewController") as! MainViewController
         self.present(vc, animated: true, completion: nil)
         }
         else{
         self.dismiss(animated: true, completion: nil)
         }*/
        
    }
    
    
    
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize
    {
        let font = UIFont(name: "Poppins-Medium", size: 15)!
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSAttributedStringKey.font: font],
                                                     context: nil).size
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //        if self.messages[indexPath.row]["content_type"].stringValue == "text"
        //        {
        return UITableViewAutomaticDimension
        //        }
        //        else
        //        {
        //            return 200
        //        }
        
        /*
         
         if(self.messages[indexPath.row]["content_type"].stringValue == "text")
         {
         let height = self.messages[indexPath.row]["row_height"].floatValue
         //            print("HEIGHT STARTS")
         //                print(height)
         //            print("HEIGHT ENDS")
         return CGFloat.init(height+70)//sizeOfString(string: content, constrainedToWidth: 200.0).height
         }
         else
         {
         return 90
         }*/
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            // moved to top
            
            isGoingUp = false
            
            print("isGoingUp")
            
        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
            // moved to bottom
            
            isGoingUp = true
            
            print("isGoingDown")
            
        }
        else
        {
            // didn't move
        }
        
        /*
         if (Int(scrollView.contentOffset.y + scrollView.frame.size.height) == Int(scrollView.contentSize.height + scrollView.contentInset.bottom))
         {
         //            self.ShowBottomView((Any).self)
         }*/
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if messages.count != 0
        {
            if bookingId == ""
            {
                bookingId = messages[0]["booking_id"].stringValue
            }
        }
        
        let myCell = UITableViewCell()
        
        if(self.messages[indexPath.row]["senderID"].stringValue == self.receiverId!)
        {
            
            if self.messages[indexPath.row]["content_type"].stringValue == "text"
            {
                let myCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTextTableViewCell", for: indexPath) as! ReceiverTextTableViewCell
                
                
                myCell.userImage.layer.cornerRadius = myCell.userImage.frame.size.width/2
                myCell.userImage.clipsToBounds = true
                
                myCell.userImage.sd_setImage(with: URL(string: self.receiverProImage), placeholderImage: UIImage(named: "profile"))
                
                myCell.userImage.isHidden = false
                myCell.messageContent.isHidden = false
                
                if(self.messages[indexPath.row]["content_type"].stringValue == "text")
                {
                    myCell.messageContent.text = self.messages[indexPath.row]["content"].stringValue
                    myCell.myViewBg.backgroundColor = UIColor.groupTableViewBackground
                    myCell.timeLbl.isHidden = false
                    
                }
                myCell.selectionStyle = UITableViewCellSelectionStyle.none
                myCell.timeLbl.text = getFormattedTime(mills: self.messages[indexPath.row]["Time"].stringValue)
                
                return myCell
            }
            else if self.messages[indexPath.row]["content_type"].stringValue == "image"
            {
                let myCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageTableViewCell", for: indexPath) as! ReceiverImageTableViewCell
                
                
                myCell.proImage.layer.cornerRadius = myCell.proImage.frame.size.width/2
                myCell.proImage.clipsToBounds = true
                
                myCell.proImage.sd_setImage(with: URL(string: self.receiverProImage), placeholderImage: UIImage(named: "profile"))
                
                myCell.imgView.sd_setImage(with: URL(string: self.messages[indexPath.row]["content"].stringValue), placeholderImage: UIImage(named: "profile"))
                
                myCell.delegate = self
                myCell.indexPath = indexPath
                
                
                myCell.proImage.isHidden = false
                //                myCell.messageContent.isHidden = false
                
                //                if(self.messages[indexPath.row]["content_type"].stringValue == "text")
                //                {
                //                    myCell.messageContent.text = self.messages[indexPath.row]["content"].stringValue
                //                    myCell.myViewBg.backgroundColor = UIColor.groupTableViewBackground
                //                    myCell.timeLbl.isHidden = false
                //
                //                }
                myCell.selectionStyle = UITableViewCellSelectionStyle.none
                myCell.timeLbl.text = getFormattedTime(mills: self.messages[indexPath.row]["Time"].stringValue)
                
                return myCell
            }
            else if self.messages[indexPath.row]["content_type"].stringValue == "pdf" || self.messages[indexPath.row]["content_type"].stringValue == "doc" || self.messages[indexPath.row]["content_type"].stringValue == "docx"
            {
                let myCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverPDFTableViewCell", for: indexPath) as! ReceiverPDFTableViewCell
                
                
                myCell.proImage.layer.cornerRadius = myCell.proImage.frame.size.width/2
                myCell.proImage.clipsToBounds = true
                
                myCell.proImage.sd_setImage(with: URL(string: self.receiverProImage), placeholderImage: UIImage(named: "profile"))
                
                let theFileName = (self.messages[indexPath.row]["content"].stringValue as NSString).lastPathComponent
                
                
                myCell.delegate = self
                myCell.indexPath = indexPath
                
                myCell.fileNameLbl.text =  theFileName
                
                myCell.proImage.isHidden = false
                myCell.selectionStyle = UITableViewCellSelectionStyle.none
                myCell.timeLbl.text = getFormattedTime(mills: self.messages[indexPath.row]["Time"].stringValue)
                
                return myCell
            }
            else
            {
                return myCell
            }
            
        }
        else
        {
            if(self.messages[indexPath.row]["content_type"].stringValue == "text")
            {
                
                let myCell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell
                
                myCell.userImage.layer.cornerRadius = myCell.userImage.frame.size.width/2
                myCell.userImage.clipsToBounds = true
                
                myCell.userImage.sd_setImage(with: URL(string: self.senderProImage), placeholderImage: UIImage(named: "profile"))
                
                myCell.userImage.isHidden = false
                myCell.messageContent.isHidden = false
                
                if(self.messages[indexPath.row]["content_type"].stringValue == "text")
                {
                    myCell.messageContent.text = self.messages[indexPath.row]["content"].stringValue
                    myCell.myViewBg.backgroundColor = UIColor.groupTableViewBackground
                    myCell.timeLbl.isHidden = false
                    
                }
                
                
                myCell.selectionStyle = UITableViewCellSelectionStyle.none
                myCell.timeLbl.text = getFormattedTime(mills: self.messages[indexPath.row]["Time"].stringValue)
                return myCell
            }
            else if(self.messages[indexPath.row]["content_type"].stringValue == "image")
            {
                
                let myCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageTableViewCell", for: indexPath) as! SenderImageTableViewCell
                
                myCell.proImage.layer.cornerRadius = myCell.proImage.frame.size.width/2
                myCell.proImage.clipsToBounds = true
                
                myCell.proImage.sd_setImage(with: URL(string: self.senderProImage), placeholderImage: UIImage(named: "profile"))
                
                myCell.imgView.sd_setImage(with: URL(string: self.messages[indexPath.row]["content"].stringValue), placeholderImage: UIImage(named: "profile"))
                
                myCell.delegate = self
                myCell.indexPath = indexPath
                
                
                myCell.proImage.isHidden = false
                
                myCell.selectionStyle = UITableViewCellSelectionStyle.none
                myCell.timeLbl.text = getFormattedTime(mills: self.messages[indexPath.row]["Time"].stringValue)
                return myCell
            }
            else if self.messages[indexPath.row]["content_type"].stringValue == "pdf" || self.messages[indexPath.row]["content_type"].stringValue == "doc" || self.messages[indexPath.row]["content_type"].stringValue == "docx"
            {
                let myCell = tableView.dequeueReusableCell(withIdentifier: "SenderPDFTableViewCell", for: indexPath) as! SenderPDFTableViewCell
                
                
                myCell.proImage.layer.cornerRadius = myCell.proImage.frame.size.width/2
                myCell.proImage.clipsToBounds = true
                
                myCell.proImage.sd_setImage(with: URL(string: self.receiverProImage), placeholderImage: UIImage(named: "profile"))
                
                let theFileName = (self.messages[indexPath.row]["content"].stringValue as NSString).lastPathComponent
                
                myCell.fileNameLbl.text =  theFileName
                
                myCell.delegate = self
                myCell.indexPath = indexPath
                
                
                myCell.proImage.isHidden = false
                myCell.selectionStyle = UITableViewCellSelectionStyle.none
                myCell.timeLbl.text = getFormattedTime(mills: self.messages[indexPath.row]["Time"].stringValue)
                
                return myCell
            }
            else
            {
                return myCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //        if self.messages[indexPath.row]["content_type"].stringValue == "image"
        //        {
        //            let image = UIImageView()
        //            image.sd_setImage(with: URL(string: self.messages[indexPath.row]["content"].stringValue), placeholderImage: UIImage(named: "profile"))
        //            self.viewImage(imgView: image)
        //
        //        }
        //        else if self.messages[indexPath.row]["content_type"].stringValue == "pdf"
        //        {
        //
        //        }
        
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
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    /*
     func reportReasons(){
     let actionSheet = UIAlertController(title: "Report User", message: "Is this person bothering you? Tell us what they did. ", preferredStyle: .actionSheet)
     
     actionSheet.addAction(UIAlertAction(title: "Inappropriate Messages", style: .default, handler: {(_ action: UIAlertAction) -> Void in
     
     self.report(reason: "Inappropriate Messages")
     }))
     actionSheet.addAction(UIAlertAction(title: "Inappropriate Photos", style: .default, handler: {(_ action: UIAlertAction) -> Void in
     
     self.report(reason: "Inappropriate Photos")
     }))
     actionSheet.addAction(UIAlertAction(title: "Bad Offline Behavior", style: .default, handler: {(_ action: UIAlertAction) -> Void in
     
     self.report(reason: "Bad Offline Behavior")
     }))
     actionSheet.addAction(UIAlertAction(title: "Feels Like Spam", style: .default, handler: {(_ action: UIAlertAction) -> Void in
     
     self.report(reason: "Feels Like Spam")
     }))
     actionSheet.addAction(UIAlertAction(title: "Other", style: .default, handler: {(_ action: UIAlertAction) -> Void in
     self.report(reason: "Other")
     }))
     actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
     // OK button tapped.
     
     self.dismiss(animated: true, completion: {() -> Void in
     })
     }))
     
     // Present action sheet.
     present(actionSheet, animated: true)
     }*/
    
    @IBAction func HideBottomView(_ sender: Any) {
        self.toHideButton.isUserInteractionEnabled = false
        self.isBottomViewShowing = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
            var transform = CATransform3DIdentity
            transform.m34 = 1.0 / 200 //your own perspective value here
            transform = CATransform3DScale(transform, 1.0, 1.0, 1.0)
            transform = CATransform3DTranslate(transform, 0, 0, 0)
            self.toScaleView.layer.transform = transform
            self.toHideButton.transform = CGAffineTransform.init(translationX: 0, y: 0)
            
        }) { (Void) in
            
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations:
            {
                var transform = CATransform3DIdentity
                transform.m34 = 1.0 / 200 //your own perspective value here
                transform = CATransform3DTranslate(transform, 0, 0, 0)
                self.chatBarView.layer.transform = transform
                
        })
        {   (Void) in
            self.setNeedsStatusBarAppearanceUpdate()
            
        }
    }
    
    @IBAction func ShowBottomView(_ sender: Any) {
        
        
        
        self.growingTextView.textView.resignFirstResponder()
        
        if (isKeyboardShowing)
        {
            self.toScaleView.frame.origin.y += keyboardHeight
            self.chatBarView.frame.origin.y += keyboardHeight
            self.isKeyboardShowing = false
            
            self.growingTextView.textView.resignFirstResponder()
            
            //            chatBarFld.resignFirstResponder()
            //                self.toScaleViewYpos = self.toScaleView.frame.origin.y
        }
        
        self.toHideButton.isUserInteractionEnabled = true
        self.isBottomViewShowing = true
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
            var transform = CATransform3DIdentity
            transform.m34 = 1.0 / 200 //your own perspective value here
            transform = CATransform3DScale(transform, 0.9, 1.0, 1.0)
            transform = CATransform3DTranslate(transform, 0, -350, 0)
            self.toScaleView.layer.transform = transform
            self.toHideButton.transform = CGAffineTransform.init(translationX: 0, y: -330)
        }) { (Void) in
            
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
            var transform = CATransform3DIdentity
            transform.m34 = 1.0 / 200 //your own perspective value here
            transform = CATransform3DTranslate(transform, 0, 90, 0)
            self.chatBarView.layer.transform = transform
            
        }) { (Void) in
            //            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return false //self.isBottomViewShowing
    }
    /*
     @IBAction func overflowAction(_ sender: Any)
     {
     let actionSheet = UIAlertController(title: "Select an option", message: "", preferredStyle: .actionSheet)
     
     actionSheet.addAction(UIAlertAction(title: "Report", style: .default, handler: {(_ action: UIAlertAction) -> Void in
     // Distructive button tapped.
     self.reportReasons()
     
     }))
     actionSheet.addAction(UIAlertAction(title: "Unmatch", style: .default, handler: {(_ action: UIAlertAction) -> Void in
     // OK button tapped.
     let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to unmatch this person?", preferredStyle: UIAlertControllerStyle.alert)
     
     alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
     (alert: UIAlertAction!) in
     self.unMatch()
     }))
     
     
     alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {
     (alert: UIAlertAction!) in
     
     }))
     
     
     // show the alert
     self.present(alert, animated: true, completion: nil)
     
     //            self.dismiss(animated: true, completion: {() -> Void in
     //
     //            })
     }))
     actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
     // Cancel button tappped.
     }))
     
     // Present action sheet.
     present(actionSheet, animated: true)
     }*/
    
    func stopAllRainFunc()
    {
        endRainFunc()
        clearRainFunc()
    }
    
    @objc  func endRainFunc()
    {
        startTimer.invalidate()
        endTimer.invalidate()
        startTimer = nil
        endTimer = nil
    }
    
    func getFormattedTime(mills:String) -> String
    {
        let date = Date(timeIntervalSince1970: Double(mills)! / 1000)
        let formatter = DateFormatter()
        let timeZone = TimeZone.current
        formatter.timeZone = timeZone
        formatter.dateFormat = "hh:mm a"
        
        
        //        print(formatter.string(from:date))
        return formatter.string(from: date)
    }
    
    @objc func activateEmoji(_ button : UIButton)
    {
        print("DDD",button.tag)
        
        if(self.messages[button.tag]["content_type"] == "text")
        {
            
        }
        else{
            if(self.messages[button.tag]["content_type"] == "heart")
            {
                currentImage = heartImage
            }
            else if(self.messages[button.tag]["content_type"] == "wow")
            {
                currentImage = wowImage
            }
            else if(self.messages[button.tag]["content_type"] == "laugh")
            {
                currentImage = laughImage
            }
            else if(self.messages[button.tag]["content_type"] == "angry")
            {
                currentImage = angryImage
            }
            
            if(!isAnimationAlreadyInProgress)
            {
                isAnimationAlreadyInProgress = true
                rainView = UIView(frame: self.view.frame)
                rainView.backgroundColor = UIColor.clear
                rainView.isUserInteractionEnabled = false
                view.addSubview(rainView)
                view.bringSubview(toFront: rainView)
                startTimer = Timer.scheduledTimer(timeInterval: RainTimeInterval, target: self, selector: #selector(self.showRain), userInfo: "", repeats: true)
                endTimer = Timer.scheduledTimer(timeInterval: RainEndTime, target: self, selector: #selector(self.endRainFunc), userInfo: "", repeats: false)
                clearTimer = Timer.scheduledTimer(timeInterval: RainClearTime, target: self, selector: #selector(self.clearRainFunc), userInfo: "", repeats: false)
                RunLoop.current.add(startTimer, forMode: .commonModes)
                RunLoop.current.add(endTimer, forMode: .commonModes)
                RunLoop.current.add(clearTimer, forMode: .commonModes)
            }
        }
    }
    
    @objc func messageReceived(_ notification: NSNotification)
    {
        if let data = notification.userInfo?["data"] as? [Any]
        {
            // do something with your image
            let response = JSON(data)
            print("CCC",response)
            var message : JSON!  = JSON.init()
            message["Time"].stringValue = response[0]["Time"].stringValue
            message["senderID"].stringValue = response[0]["sender_id"].stringValue
            message["receiverID"].stringValue = response[0]["reciever_id"].stringValue
            message["message_id"].stringValue = response[0]["message_id"].stringValue
            message["content_type"].stringValue = response[0]["content_type"].stringValue
            message["content"].stringValue = response[0]["content"].stringValue
            //            message[""].stringValue = response[]
            //            let size = self.sizeOfString(string:response[0]["content"].stringValue, constrainedToWidth: 200)
            message["row_height"].floatValue = 0.0
            
            if(message["senderID"].stringValue == self.receiverId!)
            {
                self.messages.append(message)
                
                //                print(self.messages)
                self.tableView.reloadData()
                self.scrollToBottom()
                
                if(message["content_type"] == "heart")
                {
                    self.currentImage = self.heartImage
                }
                else if(message["content_type"] == "wow")
                {
                    self.currentImage = self.wowImage
                }
                else if(message["content_type"] == "laugh")
                {
                    self.currentImage = self.laughImage
                }
                else if(message["content_type"] == "angry")
                {
                    self.currentImage = self.angryImage
                }
                
                if(message["content_type"] != "text")
                {
                    if(!self.isAnimationAlreadyInProgress)
                    {
                        self.isAnimationAlreadyInProgress = true
                        self.rainView = UIView(frame: self.view.frame)
                        self.rainView.backgroundColor = UIColor.clear
                        self.rainView.isUserInteractionEnabled = false
                        self.view.addSubview(self.rainView)
                        self.view.bringSubview(toFront: self.rainView)
                        self.startTimer = Timer.scheduledTimer(timeInterval: self.RainTimeInterval, target: self, selector: #selector(self.showRain), userInfo: "", repeats: true)
                        self.endTimer = Timer.scheduledTimer(timeInterval: self.RainEndTime, target: self, selector: #selector(self.endRainFunc), userInfo: "", repeats: false)
                        self.clearTimer = Timer.scheduledTimer(timeInterval: self.RainClearTime, target: self, selector: #selector(self.clearRainFunc), userInfo: "", repeats: false)
                        RunLoop.current.add(self.startTimer, forMode: .commonModes)
                        RunLoop.current.add(self.endTimer, forMode: .commonModes)
                        RunLoop.current.add(self.clearTimer, forMode: .commonModes)
                    }
                }
            }
            
        }
    }
    
    @objc func clearRainFunc()
    {
        clearTimer.invalidate()
        clearTimer = nil
        
        moveLayer.removeFromSuperlayer()
        moveLayer = nil
        rainView.removeFromSuperview()
        rainView = nil
        isAnimationAlreadyInProgress = false
    }
    
    @objc  func showRain()
    {
        let imageView = UIImageView(image: UIImage(named: currentImage))
        let randomRadius = arc4random_uniform(61) + 40;
        imageView.bounds = CGRect(x: 0, y: 0, width: CGFloat(randomRadius), height: CGFloat(randomRadius))
        moveLayer = CALayer()
        moveLayer.bounds = imageView.bounds
        moveLayer.anchorPoint = CGPoint(x: 0, y: 0)
        moveLayer.position = CGPoint(x: CGFloat(-Double(randomRadius)), y: CGFloat(-Double(randomRadius)))
        moveLayer.contents = imageView.image?.cgImage
        rainView.layer.addSublayer(moveLayer)
        addAnimation()
    }
    
    
    /*
     
     @objc func keyboardWillShow(_ sender: NSNotification)
     {
     print("KEYBOARD SHOW")
     
     
     if let userInfo = (sender as NSNotification).userInfo {
     if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
     self.inputContainerViewBottom.constant = keyboardHeight
     
     
     
     tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
     
     
     tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
     //                tableView.scrollToRow(at: editingIndexPath, at: .top, animated: true)
     
     
     
     
     var aRect: CGRect = self.view.frame
     aRect.size.height -= keyboardHeight
     let activeTextFieldRect: CGRect?
     let activeTextFieldOrigin: CGPoint?
     
     activeTextFieldRect = self.growingTextView?.superview?.superview?.frame
     activeTextFieldOrigin = activeTextFieldRect?.origin
     
     self.tableView.scrollRectToVisible(activeTextFieldRect!, animated:true)
     
     
     self.scrollToBottom()
     
     
     //                let indexPath = IndexPath(item: 0, section: 0)
     //
     //
     //
     //                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
     
     
     
     UIView.animate(withDuration: 0.25, animations: { () -> Void in
     self.view.layoutIfNeeded()
     })
     }
     }
     
     /*
     if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
     print(keyboardSize.height)
     keyboardHeight = keyboardSize.height
     if (!isKeyboardShowing)
     {
     self.toScaleView.frame.origin.y -= keyboardHeight
     self.chatBarView.frame.origin.y -= keyboardHeight
     self.isKeyboardShowing = true
     //                self.toScaleViewYpos = self.toScaleView.frame.origin.y
     }
     }*/
     }
     
     
     @objc func keyboardWillHide(_ sender: NSNotification)
     {
     print("KEYBOARD HIDE")
     
     
     if let userInfo = (sender as NSNotification).userInfo {
     if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
     //key point 0,
     self.inputContainerViewBottom.constant =  0
     
     
     
     
     tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
     
     
     
     //textViewBottomConstraint.constant = keyboardHeight
     UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
     }
     }
     
     /*
     
     if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
     {
     print(keyboardSize.height)
     
     if (isKeyboardShowing)
     {
     self.toScaleView.frame.origin.y += keyboardHeight
     self.chatBarView.frame.origin.y += keyboardHeight
     self.isKeyboardShowing = false
     //                self.toScaleViewYpos = self.toScaleView.frame.origin.y
     }
     }*/
     }*/
    
    
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print("FFF",notification)
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.inputContainerViewBottom.constant = keyboardFrame!.height
            
            self.view.layoutIfNeeded()
            
            
            let flag = self.tableView.isCellVisible(section: 0, row: self.messages.count - 1)
            
            if flag
            {
                self.scrollToBottom()
            }
            else
            {
                
            }
            
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.inputContainerViewBottom.constant = 0
            
            
            self.view.layoutIfNeeded()
            
            
        }
    }
    
    
    @objc func addAnimation() {
        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
        moveAnimation.values = [NSValue(cgPoint: CGPoint(x: Int(arc4random_uniform(320)), y: 10)), NSValue(cgPoint: CGPoint(x: Int(arc4random_uniform(320)), y: 500))]
        moveAnimation.duration = RainAnimationTime
        moveAnimation.repeatCount = 1
        moveAnimation.isRemovedOnCompletion = true
        moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        moveLayer.add(moveAnimation, forKey: "move")
    }
    
    @IBAction func showProfileDetails(_ sender: Any)
    {
        
        if (self.userDetails.count == 0)
        {
            
        }
        else
        {
            
            /*
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
             vc.isFromChatPage = true
             vc.name = "\(self.userDetails[0]["userName"].stringValue), \(self.userDetails[0]["age"].stringValue)"
             vc.InstaStatus = self.userDetails[0]["InstaStatus"].stringValue
             vc.InstaToken = self.userDetails[0]["InstaToken"].stringValue
             vc.InstaSenderID = self.userDetails[0]["InstaSenderID"].stringValue
             vc.detailImages = self.userDetails[0]["profile_images"].arrayValue
             if(self.userDetails[0]["company"].stringValue != " ")
             {
             
             if(self.userDetails[0]["jobTitle"].stringValue != " ")
             {
             vc.work = "\(self.userDetails[0]["jobTitle"].stringValue) at \(self.userDetails[0]["company"].stringValue)"
             }
             else{
             vc.work = "Working at \(self.userDetails[0]["company"].stringValue)"
             }
             }
             else{
             if(self.userDetails[0].stringValue != " ")
             {
             vc.work = "\(self.userDetails[0].stringValue)"
             }
             else{
             vc.work = "NA"
             }
             }
             
             
             vc.distance =  String(format: "%.2f", self.userDetails[0]["company"].doubleValue)
             vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
             self.present(vc, animated: false, completion: nil)*/
        }
    }
    
    @IBAction func sendMessage(_ sender: Any)
    {
        self.growingTextView.textView.text = self.growingTextView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var content = ""
        content = self.growingTextView.textView.text!
        
        
        if(content.count > 0)
        {
            self.sendMessage(content: content, contentType: "text",fileName: "")
            self.growingTextView.textView.text! = ""
        }
    }
    
    func sendMessage(content :String,contentType :String,fileName :String = "")
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var booking_Id = ""
        if SharedObject().hasData(value: bookingId)
        {
            booking_Id = bookingId
        }
        
        if(appDelegate.socket != nil)
        {
            if(content.count > 0)
            {
                var senderId = ""
                
                if (UserDefaults.standard.object(forKey: "userid") != nil)
                {
                    senderId = UserDefaults.standard.object(forKey: "userid") as! String
                }
                
                let messageId = UUID().uuidString
                
                let currentTime = getCurrentMillis()
                
                appDelegate.socket.emit("sendmessagefromuser", ["sender_id":senderId,"reciever_id":self.receiverId!,"message_id":messageId,"content_type":contentType,"content":content,"Time":currentTime,"booking_id":booking_Id,"fileName":fileName])
                
                var message : JSON!  = JSON.init()
                message["Time"].stringValue = String(currentTime)
                message["senderID"].stringValue = senderId
                message["receiverID"].stringValue = self.receiverId!
                message["message_id"].stringValue = messageId
                message["content_type"].stringValue = contentType
                message["content"].stringValue = content
                message["booking_id"].stringValue = booking_Id
                message["fileName"].stringValue = fileName
                message["row_height"].floatValue = 0.0
                
                self.messages.append(message)
                print("HHH",self.messages)
                self.tableView.reloadData()
                self.scrollToBottom()
            }
            else
            {
                print("Content is Empty")
            }
        }
        else
        {
            
            print("Socket is not connected")
            
            self.growingTextView.textView.resignFirstResponder()
            //            self.view.makeToast("Socket is not connected")
            appDelegate.applicationDidBecomeActive(UIApplication.shared)
        }
    }
    
    func setGradientBackground(button:UIButton, startColor:UIColor, endColor: UIColor){
        let size = CGSize(width: button.frame.width, height: button.frame.height)
        let layer = CAGradientLayer()
        
        
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        layer.colors = [startColor.cgColor,endColor.cgColor]
        // end color
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        UIGraphicsBeginImageContext(size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        button.setBackgroundImage(image, for: .normal)
    }
    
    @IBAction func attachAtn(_ sender: Any)
    {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            
            picker.sourceType = .camera
            picker.allowsEditing = true
            self.isBack = true
            self.present(picker, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default , handler:{ (UIAlertAction)in
            //            self.sendMessage(content: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBAVIkJ8HXyPX0FK5cQGTS3X4YxpDs6YeyvXngnQlUYHdM6nq6", contentType: "image",fileName: "")
            
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.isBack = true
            self.present(picker, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "iCloud Drive", style: .default , handler:
            {
                (UIAlertAction)in
                
                //            self.sendMessage(content: "https://www.antennahouse.com/XSLsample/pdf/sample-link_1.pdf", contentType: "pdf",fileName: "")
                
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc","org.openxmlformats.wordprocessingml.document",kUTTypePDF as String], in: UIDocumentPickerMode.import)
                
                
                //            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "public.data"], in: .import)
                documentPicker.delegate = self
                documentPicker.modalPresentationStyle = .formSheet
                self.present(documentPicker, animated: true)
                
                
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL)
    {
        
        self.isBack = true
        
        let cico = url as URL
        print("GGG",cico)
        print("UURL",url)
        print("UURL!",url.lastPathComponent)
        
        var docData = Data()
        do
        {
            docData = try Data(contentsOf: cico as URL)
        }
        catch
        {
            print("Unable to load data: \(error)")
        }
        
        let filename = "\(url.lastPathComponent)"
        let extention = "\(url.pathExtension)"
        
        let setName = "FILE_" + getFileName() + "_." + String(describing: extention)
        
        
        self.uploadDocument(with: docData, strFileName: setName, type: extention)
        
        print("UURRL",url.pathExtension)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated: true)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data:Data = UIImagePNGRepresentation(image)!
        
        let filename = "IMG_" + getFileName() + ".jpg"
        self.uploadImage(with: data, strFileName: filename)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func openPDF(receiptURL: URL)
    {
        
        SwiftSpinner.show("Loading...")
        
        self.downloadfile(itemUrl: receiptURL, completion:
            {
                (success, fileLocationURL) in
                if success
                {
                    SwiftSpinner.hide()
                    self.previewItem = fileLocationURL! as NSURL
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    self.present(previewController, animated: true, completion: nil)
                }
                else
                {
                    SwiftSpinner.hide()
                    self.showAlert(title: "Oops", msg: "File can't be viewed")
                }
        })
    }
    
    func downloadfile(itemUrl: URL, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void)
    {
        clearAllFilesFromTempDirectory()
        
        let fileManager = FileManager.default
        
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let paths = documentDirectory.appending("/Chat")
        
        
        print("Paths = ",paths)
        
        
        let filename = (itemUrl.absoluteString as NSString).lastPathComponent
        
        if !fileManager.fileExists(atPath: paths)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        let destinationUrl = paths.appending("/"+filename)
        
        //        let desUrl = URL(string: destinationUrl)
        
        let desUrl:URL = URL.init(fileURLWithPath: destinationUrl)
        
        print("destinationUrl = ",desUrl)
        
        // to check if it exists before downloading it
        /*        if FileManager.default.fileExists(atPath: desUrl.path) {
         debugPrint("The file already exists at path")
         completion(true, desUrl)
         
         } else {*/
        
        // you can use NSURLSession.sharedSession to download the data asynchronously
        URLSession.shared.downloadTask(with: itemUrl, completionHandler:
            {
                (location, response, error) -> Void in
                
                print("Response = ",response)
                
                guard let tempLocation = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: tempLocation, to: desUrl)
                    print("File moved to documents folder")
                    completion(true, desUrl)
                } catch let error as NSError {
                    print("Error = ",error.localizedDescription)
                    completion(false, nil)
                }
        }).resume()
        //        }
    }
    
    func clearAllFilesFromTempDirectory()
    {
        
        let fileManager = FileManager.default
        
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let paths = documentDirectory.appending("/Chat/")
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: paths)
            
            
            for filePath in filePaths {
                
                print("filePaths = ",paths + filePath)
                
                try fileManager.removeItem(atPath: paths + filePath)
            }
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }
    
    func uploadImage(with data: Data,strFileName :String)
    {
        SwiftSpinner.show("Uploading...")
        
        let expression = AWSS3TransferUtilityUploadExpression()
        
        expression.progressBlock =
            {
                (task, progress) in DispatchQueue.main.async(execute:
                    {
                        print("Upload Progress = ",progress)
                })
        }
        
        completionHandler =
            {
                (task, error) -> Void in
                DispatchQueue.main.async(execute:
                    {
                        self.fileLink = Constants.IMAGES_BUCKET + strFileName
                        print("self.fileLink = ",self.fileLink)
                        SwiftSpinner.hide()
                        self.sendMessage(content: self.fileLink, contentType: "image")
                        
                })
        }
        
        transferUtility.uploadData(data, bucket: Constants.BUCKET_NAME, key: strFileName, contentType: "image/png", expression: expression, completionHandler: completionHandler).continueWith
            {
                (task) -> AnyObject? in
                if let error = task.error
                {
                    SwiftSpinner.hide()
                    print("Error: \(error.localizedDescription)")
                }
                
                if let _ = task.result
                {
                    
                }
                return nil;
        }
    }
    
    func uploadDocument(with data: Data,strFileName :String,type :String)
    {
        SwiftSpinner.show("Uploading...")
        
        let expression = AWSS3TransferUtilityUploadExpression()
        
        expression.progressBlock =
            {
                (task, progress) in DispatchQueue.main.async(execute:
                    {
                        print("Upload Progress = ",progress)
                })
        }
        
        completionHandler =
            {
                (task, error) -> Void in
                DispatchQueue.main.async(execute:
                    {
                        self.fileLink = Constants.IMAGES_BUCKET + strFileName
                        print("self.fileLink = ",self.fileLink)
                        SwiftSpinner.hide()
                        self.sendMessage(content: self.fileLink, contentType: type)
                        
                })
        }
        
        transferUtility.uploadData(data, bucket: Constants.BUCKET_NAME, key: strFileName, contentType: "file", expression: expression, completionHandler: completionHandler).continueWith
            {
                (task) -> AnyObject? in
                if let error = task.error
                {
                    SwiftSpinner.hide()
                    print("Error: \(error.localizedDescription)")
                }
                
                if let _ = task.result
                {
                    
                }
                return nil;
        }
    }
    
    func getFileName() ->String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        return formatter.string(from: Date())
    }
}

extension UITableView
{
    func isCellVisible(section:Int, row: Int) -> Bool
    {
        guard let indexes = self.indexPathsForVisibleRows else
        {
            return false
        }
        return indexes.contains {$0.section == section && $0.row == row }
    }
}

extension ChatViewController : SenderImageTableViewCellDelegate
{
    func senderImageDidTap(_ sender: SenderImageTableViewCell, index: IndexPath)
    {
        let cell = tableView.cellForRow(at: index) as! SenderImageTableViewCell
        self.viewImage(imgView: cell.imgView)
    }
}

extension ChatViewController : ReceiverImageTableViewCellDelegate
{
    func receiverImageDidTap(_ sender: ReceiverImageTableViewCell, index: IndexPath)
    {
        let cell = tableView.cellForRow(at: index) as! ReceiverImageTableViewCell
        self.viewImage(imgView: cell.imgView)
    }
}


extension ChatViewController : SenderPDFTableViewCellDelegate
{
    func senderPDFDidTap(_ sender: SenderPDFTableViewCell, index: IndexPath)
    {
        print("URL = ",self.messages[index.row]["content"].stringValue)
        
        if URL(string: self.messages[index.row]["content"].stringValue) != nil
        {
            let url = URL(string: self.messages[index.row]["content"].stringValue)
            self.openPDF(receiptURL: url!)
        }
        else
        {
            self.showAlert(title: "Oops", msg: "File can't be viewed")
        }
    }
}

extension ChatViewController : ReceiverPDFTableViewCellDelegate
{
    func receiverPDFDidTap(_ sender: ReceiverPDFTableViewCell, index: IndexPath)
    {
        
        print("URL = ",self.messages[index.row]["content"].stringValue)
        
        if URL(string: self.messages[index.row]["content"].stringValue) != nil
        {
            let url = URL(string: self.messages[index.row]["content"].stringValue)
            self.openPDF(receiptURL: url!)
        }
        else
        {
            self.showAlert(title: "Oops", msg: "File can't be viewed")
        }
    }
}

extension ChatViewController: QLPreviewControllerDataSource
{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int
    {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem
    {
        return self.previewItem as QLPreviewItem
    }
}
