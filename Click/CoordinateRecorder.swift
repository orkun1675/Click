//
//  CoordinateRecorder.swift
//  Click
//
//  Created by Orkun Duman on 24/03/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import Foundation

class CoordinateRecorder {
    
    var points: [ClickEvent]
    var gameName : String
    
    init(name : String) {
        points = [ClickEvent]()
        gameName = name
    }
    
    func addPoint(_ click : ClickEvent) {
        points.append(click)
    }
    
    func getPoint(_ index: Int) -> ClickEvent {
        return points[index]
    }
    
    func getGameName() -> String {
        return gameName
    }
    
    //DotX, DotY, DeltaTime
    func getRawDotCoordinates() -> Array<Array<Double>>{
        if points.count < 1 {
            return Array<Array<Double>>()
        }
        var array = Array(repeating: Array(repeating: 0.0, count: 3), count: points.count)
        for i in 0 ..< array.count {
            let event = points[i]
            array[i][0] = event.dotX
            array[i][1] = event.dotY
            array[i][2] = Double(event.epochTime)
        }
        return array
    }
        
    //DotX, DotY, Prev 3 Dots, DeltaTime
    func getArrayWithoutDotCoordinates() -> Array<Array<Double>>{
        if points.count < 4 {
            return Array<Array<Double>>()
        }
        var array = Array(repeating: Array(repeating: 0.0, count: 2*4+1), count: points.count - 3)
        var prev1 = points[0]
        var prev2 = points[1]
        var prev3 = points[2]
        for i in 0 ..< array.count {
            let event = points[i + 3]
            array[i][0] = event.dotX
            array[i][1] = event.dotY
            array[i][2] = prev3.dotX
            array[i][3] = prev3.dotY
            array[i][4] = prev2.dotX
            array[i][5] = prev2.dotY
            array[i][6] = prev1.dotX
            array[i][7] = prev1.dotY
            array[i][8] = Double(event.epochTime) - Double(prev3.epochTime)
            prev1 = prev2
            prev2 = prev3
            prev3 = event
        }
        return array
    }
    
    //DotX, DotY, ClickX, ClickY, DeltaTime, PrevDotX, PrevDotY, PrevClickX, PrevClickY, PrevDeltaTime
    func getArrayWithDotCoordinates() -> Array<Array<Double>>{
        var array = Array<Array<Double>>()
        var prevX = -1.0
        var prevY = -1.0
        var prevCX = -1.0
        var prevCY = -1.0
        var prevT : Int64 = -1
        var prevDT : Int64 = -1
        for i in 0 ..< points.count {
            let event = points[i]
            array[i][0] = event.dotX
            array[i][1] = event.dotY
            array[i][2] = event.clickX
            array[i][3] = event.clickY
            if prevT < 0 {
                array[i][4] = Double(prevT)
            } else {
                array[i][4] = Double(event.epochTime) - Double(prevT)
            }
            array[i][5] = prevX
            array[i][6] = prevY
            array[i][7] = prevCX
            array[i][8] = prevCY
            array[i][9] = Double(prevDT)
            
            prevX = event.dotX
            prevY = event.dotY
            prevCX = event.clickX
            prevCY = event.clickY
            prevT = event.epochTime
            prevDT = Int64(array[i][4])
        }
        return array
    }
    
    func printAll() {
        for (i in 0 ..< points.count) {
            let str = points[i].toString()
            Swift.print(str)
        }
    }
    
}
