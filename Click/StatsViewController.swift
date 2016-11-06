//
//  StatsViewController.swift
//  Click
//
//  Created by Orkun Duman on 04/04/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: UIViewController, UITabBarControllerDelegate {
    
    var selectedLevel = 1

    @IBOutlet weak var table: UITableView!
    
    @IBAction func backButtonClick(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func resetGame(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Reset Game", message: "This will delete all game data. Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            self.deleteUserDefaults()
            self.deleteAllCoreData()
            self.dismiss(animated: true, completion: {})
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteUserDefaults() {
        var tempID = DeviceIDManager.getDeviceID()
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        DeviceIDManager.saveDeviceID(tempID)
    }
    
    func deleteAllCoreData() {
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "GameLevels")
        request.returnsObjectsAsFaults = false
        var results = (try! context.fetch(request)) as! [GameLevels]
        for entry: AnyObject in results {
            context.delete(entry as! NSManagedObject)
        }
        results.removeAll(keepingCapacity: false)
        do {
            try context.save()
        } catch _ {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(NUMBER_OF_ROWS) * Int(NUMBER_OF_LEVELS_ON_ROW)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "LevelCell")
        let lvl = (indexPath as NSIndexPath).row + 1
        cell.textLabel?.text = "Level \(lvl)"
        cell.contentView.backgroundColor = UIColor.black
        if isLevelUnlocked(lvl) {
            cell.textLabel?.textColor = UIColor.green
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        selectedLevel = (indexPath as NSIndexPath).row + 1
        performSegue(withIdentifier: "toLevelStats", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLevelStats" {
            if let destinationVC = segue.destination as? LevelStatsViewController{
                destinationVC.level = selectedLevel
            }
        }
    }
    
    func isLevelUnlocked(_ level : Int) -> Bool{
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "GameLevels")
        request.returnsObjectsAsFaults = false
        let results = (try! context.fetch(request)) as! [GameLevels]
        
        if results.count > 0 {
            for result in results {
                if Int(result.level) == level {
                    return result.unlocked
                }
            }
        } else {
            return false
        }
        return false
    }
}
