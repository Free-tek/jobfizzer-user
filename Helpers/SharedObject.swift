//
//  SharedObject.swift
//  UberdooX
//
//  Created by Pyramidions on 05/08/18.
//  Copyright © 2018 Uberdoo. All rights reserved.
//

import UIKit

class SharedObject: NSObject {

    static let sharedInstance = SharedObject()
    
    func hasData<T>(value : T?) -> Bool
    {
        if value == nil
        {
            return false
        }
        else
        {
            return true

        }
    }

}
