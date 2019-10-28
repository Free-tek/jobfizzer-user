//
//  AppDelegate.swift
//  UberdooX
//
//  Created by Karthik Sakthivel on 04/10/17.
//  Copyright © 2017 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import FBSDKCoreKit
import Stripe
import GoogleSignIn
import SocketIO
import SwiftyJSON
import CoreData
import AWSS3
import AWSCore
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate, GIDSignInDelegate{
    
    
    var manager : SocketManager!
    var socket : SocketIOClient!
    
    var window: UIWindow?
    var Userinfo = NSDictionary()
    let gcmMessageIDKey = "gcm.message_id"
    var IsAppActive:String = ""
    
    var chatData = NSDictionary()
    var chatReceiveID = ""

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        STPPaymentConfiguration.shared().publishableKey = "pk_test_kDAKKfqc7yUrjxvl9hS7Ycwn"// "pk_live_O3NJof6bYkQ9EfRdBBWXYLiG"

        Fabric.with([STPAPIClient.self, Crashlytics.self])

        GMSServices.provideAPIKey(Constants.mapsKey)
        GMSPlacesClient.provideAPIKey(Constants.placesKey)
        IQKeyboardManager.sharedManager().enable = true

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
 
        
        Messaging.messaging().delegate = self
        
        FirebaseApp.configure()
        Messaging.messaging().shouldEstablishDirectChannel = true

        GIDSignIn.sharedInstance().clientID = "191606272140-gflcli9r3e0t76c9g4u87ct4tu8i22ni.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().delegate = self as! GIDSignInDelegate
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APSouth1,
                                                                identityPoolId:Constants.AWS_S3_POOL_ID)
        
        let configuration = AWSServiceConfiguration(region:.APSouth1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    
        // Override point for customization after application launch.
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        return handled || GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
//         (.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as? String,
//                                                            annotation: options[.annotation])
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        // Add any custom logic here.
        return handled || GIDSignIn.sharedInstance().handle(url,
                                                            sourceApplication: options[.sourceApplication] as? String,
                                                            annotation: options[.annotation])
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        let dct : NSDictionary = userInfo as NSDictionary
        
        
        
        if (dct.object(forKey: "notification_type") != nil)
        {
            let type = dct.object(forKey: "notification_type") as! String
            
            if type == "chat"
            {
                
                let sender_id = dct.object(forKey: "reciever_id") as! String
                let receiver_id = dct.object(forKey: "sender_id") as! String
                
                let msgData:NSDictionary = ["sender_id": sender_id,"reciever_id":receiver_id]
                
                print("Chat Data = ",msgData)
                
                
                chatData = msgData
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChatData"), object: self)//, userInfo: msgData)
                
                
                
            }
            else
            {
                
            }
        }
        else
        {
            
        }
        
        
        
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        let dct : NSDictionary = userInfo as NSDictionary
        
        
        
        if (dct.object(forKey: "notification_type") != nil)
        {
            let type = dct.object(forKey: "notification_type") as! String
            
            if type == "chat"
            {
                
                let sender_id = dct.object(forKey: "reciever_id") as! String
                let receiver_id = dct.object(forKey: "sender_id") as! String
                
                //                let msgData:[String: String] = ["sender_id": sender_id,"reciever_id":receiver_id]
                
                
                let msgData:NSDictionary = ["sender_id": sender_id,"reciever_id":receiver_id]
                
                
                chatData = msgData
                
                print("Chat Data = ",msgData)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChatData"), object: self)//, userInfo: msgData)
                
                
                //                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: imageDataDict)
                
            }
            else
            {
            }
        }
        else
        {
        }
        
        print("Notification Dictionary = ",dct)
        
        
        // Print full message.
        //        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveReview"), object: self)
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
          let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        manager = SocketManager(socketURL: URL(string: APIList().SOCKET_URL)!, config: [.log(true), .compress, .forcePolling(true)])
        print("socket url",APIList().SOCKET_URL)
        socket = manager.defaultSocket
        if(socket != nil)
        {
            
            var uid = ""
            
            if (UserDefaults.standard.object(forKey: "userid") != nil)
            {
                uid = UserDefaults.standard.object(forKey: "userid") as! String
            }
            
            socket.on(clientEvent: .connect) {data, ack in
                print("socket connected")
//                let senderId = UserDefaults.standard.string(forKey: "userId")!
                self.socket.emit("get_user_online", ["userid":uid])
                self.socket.emit("userisOnline", ["userid":uid])
                
            }
            socket.on("recievemessage") {data, ack in
                let response = JSON(data)
                print("Recieve Message = ",response)
                let dataDict:[String: Any] = ["data": data]
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MessageReceived"), object: self, userInfo: dataDict)
            }
        }
            socket.connect()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

        
        if(isLoggedIn)
        {
            
            var uid : String = ""
            
            
            if (UserDefaults.standard.object(forKey: "userid") != nil)
            {
                uid = UserDefaults.standard.object(forKey: "userid") as! String
                
                socket.emit("userisOffline", ["userid":uid])
            }
            
            self.saveContext()
            
            //            let uid = UserDefaults.standard.string(forKey: "userId")
            //            socket.emit("isOffline", ["userid":uid])
        }
        
    }
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    
    // Coredata
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
       
        let container = NSPersistentContainer(name: "UberdooX")
         print(NSPersistentContainer.defaultDirectoryURL())
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        
        
        
        let userInfo = notification.request.content.userInfo
        
        
        let dct : NSDictionary = userInfo as NSDictionary
        
        
        
        if (dct.object(forKey: "notification_type") != nil)
        {
            let type = dct.object(forKey: "notification_type") as! String
            
            if type == "chat"
            {
                
                let receiver_id = dct.object(forKey: "sender_id") as! String
                
                if chatReceiveID == ""
                {
                    completionHandler([])
                }
                else
                {
                    
                }
                
            }
            else
            {
                let userInfo = notification.request.content.userInfo
                
                // With swizzling disabled you must let Messaging know about the message, for Analytics
                Messaging.messaging().appDidReceiveMessage(userInfo)
                
                // Print message ID.
                if let messageID = userInfo[gcmMessageIDKey] {
                    print("Message ID: \(messageID)")
                }
                
                // Print full message.
                print(userInfo)
                
                // Change this to your preferred presentation option
                completionHandler([])
            }
        }
        else
        {
            let userInfo = notification.request.content.userInfo
            
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            // Print full message.
            print(userInfo)
            
            // Change this to your preferred presentation option
            completionHandler([])
        }

        
    }
    /*{
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }*/
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        
        
        let userInfo = response.notification.request.content.userInfo
        
        
        let dct : NSDictionary = userInfo as NSDictionary
        
        
        
        if (dct.object(forKey: "notification_type") != nil)
        {
            let type = dct.object(forKey: "notification_type") as! String
            
            if type == "chat"
            {
                
                let sender_id = dct.object(forKey: "reciever_id") as! String
                let receiver_id = dct.object(forKey: "sender_id") as! String
                
                let msgData:NSDictionary = ["sender_id": sender_id,"reciever_id":receiver_id]
                
                print("Chat Data = ",msgData)
                
                
                chatData = msgData
                
                
                MainViewController.startChat = true
                
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChatData"), object: self)//, userInfo: msgData)
                
                
                //                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: imageDataDict)
                
            }
            else
            {
                let userInfo = response.notification.request.content.userInfo
                // Print message ID.
                if let messageID = userInfo[gcmMessageIDKey] {
                    print("Message ID: \(messageID)")
                }
                MainViewController.reloadPage = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Refresh"), object: self)
                // Print full message.
                print(userInfo)
                
                completionHandler()
            }
        }
        else
        {
            let userInfo = response.notification.request.content.userInfo
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            MainViewController.reloadPage = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Refresh"), object: self)
            // Print full message.
            print(userInfo)
            
            completionHandler()
        }
        
        
    }
/*    {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        MainViewController.reloadPage = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Refresh"), object: self)
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }*/
    
}

