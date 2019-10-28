//
//  MyAPIClient.swift
//  SwyftX
//
//  Created by Karthik Sakthivel on 02/03/18.
//  Copyright © 2018 Swyft. All rights reserved.
//

import Foundation
import Stripe
import SwiftyJSON
import Alamofire

class MyAPIClient: NSObject, STPEphemeralKeyProvider {
    
    static let sharedClient = MyAPIClient()
    func completeCharge(_ result: STPPaymentResult,
                        amount: String,
                        bookingId : String,
                        completion: @escaping STPErrorBlock) {
        
        let accesstoken = UserDefaults.standard.string(forKey: "access_token") as String!
        print(accesstoken!)
        let headers: HTTPHeaders = [
            "Authorization": accesstoken!,
            "Accept": "application/json"
        ]
        let base = URL.init(string: APIList().BASE_URL)!
        let url = base.appendingPathComponent("stripe")
        print(url)
        let params: [String: Any] = [
            "token": result.source.stripeID,
            "id": bookingId,
            "amount": amount
        ]
        print(params)
        Alamofire.request(url, method: .post, parameters: params, headers:headers).responseJSON { response in
                
                let jsonResponse = JSON(response)
                print(jsonResponse)
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
//    func createCharge()
    
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let base = URL.init(string: APIList().BASE_URL)!
        let url = base.appendingPathComponent("ephemeral_keys")
        print(url)
        print(apiVersion)
        let accesstoken = UserDefaults.standard.string(forKey: "access_token") as String!
        
//        print(accesstoken!)
        let headers: HTTPHeaders = [
            "Authorization": accesstoken!,
            "Accept": "application/json"
        ]
        let parameters : Parameters = [
            "api_version": apiVersion
        ]
        print(parameters)
        print(headers)
        Alamofire.request(url, method: .post, parameters: parameters, headers:headers)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                print(responseJSON)
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
}

