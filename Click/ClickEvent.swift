//
//  ClickEvent.swift
//  Click
//
//  Created by Orkun Duman on 25/03/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import Foundation

class ClickEvent {
    
    var clickX : Double = 0
    var clickY : Double = 0
    var dotX : Double = 0
    var dotY : Double = 0
    var epochTime : Int64 = 0
    
    init(clickX : Double, clickY : Double, dotX : Double, dotY : Double, epochTime : Int64) {
        self.clickX = clickX
        self.clickY = clickY
        self.dotX = dotX
        self.dotY = dotY
        self.epochTime = epochTime
    }
    
    func toString() -> String {
        return "ClickEvent Data: clicked (\(clickX), \(clickY)), dot (\(dotX), \(dotY)), time (\(epochTime))"
    }
    
}
