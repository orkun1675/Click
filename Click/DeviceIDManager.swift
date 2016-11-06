//
//  DeviceIDManager.swift
//  Click
//
//  Created by Orkun Duman on 11/05/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import UIKit
import Parse

open  class DeviceIDManager {
    
    static var deviceID : Int = 0
    
    static func fetchDeviceID() {
        if let deviceIDFromNS = UserDefaults.standard.object(forKey: "DeviceID") as? Int {
            deviceID =  deviceIDFromNS
        }
        
        if deviceID == 0 {
            let parseDeviceIDFetcher = PFQuery(className: "UserIDCounter")
            parseDeviceIDFetcher.getObjectInBackground(withId: "DqLUCnc3Jf") {
                (deviceIDFromParse: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    Swift.print(error)
                } else if let deviceIDFromParse = deviceIDFromParse {
                    let id = deviceIDFromParse.object(forKey: "deviceID") as! Int
                    self.deviceID = id
                    deviceIDFromParse["deviceID"] = id + 1
                    deviceIDFromParse.saveInBackground()
                    self.saveDeviceID(id)
                }
            }
        }
    }
    
    static func getDeviceID() -> Int {
        return deviceID
    }
    
    static func saveDeviceID(_ newID: Int) {
        UserDefaults.standard.set(newID, forKey: "DeviceID")
        UserDefaults.standard.synchronize()
    }
    
}
