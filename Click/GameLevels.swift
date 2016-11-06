//
//  GameLevels.swift
//  Click
//
//  Created by Orkun Duman on 04/04/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import Foundation
import CoreData

class GameLevels: NSManagedObject {

    @NSManaged var level: Int16
    @NSManaged var trials: Int32
    @NSManaged var unlocked: Bool
    @NSManaged var userAcc: Float
    @NSManaged var userScore: Int32
    @NSManaged var sucClicks: Int64
    @NSManaged var totalClicks: Int64
    @NSManaged var meanReactionTime: Int32

}
