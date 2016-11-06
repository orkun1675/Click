//
//  LevelStatsViewController.swift
//  Click
//
//  Created by Orkun Duman on 04/04/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import UIKit
import CoreData

class LevelStatsViewController: UIViewController {
    
    var level : Int = 1

    @IBOutlet weak var lbl_title: UINavigationItem!
    @IBOutlet weak var lbl_maxScore: UILabel!
    @IBOutlet weak var lbl_accuracy: UILabel!
    @IBOutlet weak var lbl_trials: UILabel!
    @IBOutlet weak var lbl_succClicks: UILabel!
    @IBOutlet weak var lbl_totalClicks: UILabel!
    @IBOutlet weak var lbl_avgReactionTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    func updateLabels() {
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "GameLevels")
        request.returnsObjectsAsFaults = false
        let results = (try! context.fetch(request)) as! [GameLevels]
        var found = false
        if results.count > 0 {
            for result in results {
                if Int(result.level) == level {
                    lbl_title.title = "Level \(level) Statistics"
                    lbl_maxScore.text = "\(Int(result.userScore))"
                    lbl_accuracy.text = String(format: "%.2f", result.userAcc) + "%"
                    lbl_trials.text = "\(Int(result.trials))"
                    lbl_succClicks.text = "\(Int(result.sucClicks))"
                    lbl_totalClicks.text = "\(Int(result.totalClicks))"
                    lbl_avgReactionTime.text = "\(Int(result.meanReactionTime))ms"
                    found = true
                }
            }
        }
        if !found {
            lbl_title.title = "Level \(level) Statistics"
            lbl_maxScore.text = "Level Locked"
            lbl_accuracy.text = "Level Locked"
            lbl_trials.text = "Level Locked"
            lbl_succClicks.text = "Level Locked"
            lbl_totalClicks.text = "Level Locked"
            lbl_avgReactionTime.text = "Level Locked"
        }
    }

    @IBAction func closePage(_ sender: AnyObject) {
        dismiss(animated: true, completion: {})
    }
    
}
