//
//  CommonClass.swift
//  UberdooX
//
//  Created by Pyramidions on 15/09/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftSpinner
import UIKit
import CoreLocation

class Connection
{    
    var bookingID: String = ""

    func postConnection(_ strURL: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void)
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
        
        let url = "\(APIList().BASE_URL)" + strURL

        
        print("URL = ",url)
        
        
//        let url = "\(Constants.baseURL)/api/" + strURL
        
        let params: Parameters = [
            "booking_id": bookingID
        ]
        
        
        print("Params = ",params)
        
        Alamofire.request(url,method: .post,parameters:params).responseJSON
            {
                response in
                
                if(response.result.isSuccess)
                {
                    let resJson = JSON(response.result.value!)
                    success(resJson)
                }
                else
                {
                    let error : Error = response.result.error!
                    failure(error)
                }
                
        }
    }

}

class Location
{
    class func isLocationEnabled() ->Bool
    {
        if CLLocationManager.locationServicesEnabled()
        {
            switch CLLocationManager.authorizationStatus()
            {
            case .notDetermined, .restricted, .denied:
                print("No access")
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                return true
            }
        }
        else
        {
            print("Location services are not enabled")
            return false
        }
    }
}

