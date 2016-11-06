//
//  EndViewController.swift
//  Click
//
//  Created by Orkun Duman on 06/08/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import UIKit
import CoreData
import Darwin

class EndViewController: UIViewController {
    
    @IBOutlet weak var lblOverallScore: UILabel!
    
    @IBAction func goHome(_ sender: AnyObject) {
        AudioManager.startClickMain()
        self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let oScore = getOverallScore()
        lblOverallScore.text = "Overall Score: \(oScore)"
    }
    
    func getOverallScore() -> Int{
        var sumLevelScore = 0.0
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "GameLevels")
        request.returnsObjectsAsFaults = false
        let results = (try! context.fetch(request)) as! [GameLevels]
        if results.count > 0 {
            for result in results {
                if (result.level != 0 && Int(result.userScore) != 0) {
                    sumLevelScore += (Int(result.userScore) * Double(result.userAcc) / 100.0 / sqrt(Double(result.trials)))
                }
            }
        }
        return Int(sumLevelScore / 3.2)
    }
    
}
    

