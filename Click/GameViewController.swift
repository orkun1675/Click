//
//  GameViewController.swift
//  Click
//
//  Created by Orkun Duman on 23/03/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! LevelScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GameViewController.levelCompleteWarning(_:)),
            name: NSNotification.Name(rawValue: "LevelAlreadyCompleted"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GameViewController.finishGame(_:)),
            name: NSNotification.Name(rawValue: "FinishedGame"),
            object: nil)
        
        if let scene = LevelScene.unarchiveFromFile("LevelScene") as? LevelScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            scene.size = skView.bounds.size
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func levelCompleteWarning(_ notif: Notification) {
        let alert = UIAlertController(title: "Level Already Complete", message: "You can play this level again but it will not affect your stats as you have already completed it. Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            let userInfo:Dictionary<String,Int?> = (notif as NSNotification).userInfo as! Dictionary<String,Int?>
            let level = userInfo["level"]!
            
            let skView = self.view as! SKView
            let gs = GameScene().scene!
            gs.size = skView.bounds.size
            gs.userData = NSMutableDictionary()
            gs.userData?.setObject(level, forKey: "Level" as NSCopying)
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            skView.presentScene(gs, transition: transition)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func finishGame(_ notif: Notification) {
        performSegue(withIdentifier: "gameToEnd", sender: self)
    }

}
