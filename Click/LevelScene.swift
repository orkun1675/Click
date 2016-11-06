//
//  LevelScene.swift
//  Click
//
//  Created by Orkun Duman on 29/03/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import SpriteKit
import CoreData

let NUMBER_OF_LEVELS_ON_ROW = 4.0
let NUMBER_OF_ROWS = 3.0

class LevelScene : SKScene {
    
    let frameMarginSize = 30.0
    let minSpacingBetweenButtons = 15.0
    
    var btn_background = SKSpriteNode()
    var btn_text = SKLabelNode()
    var btn_locked = SKSpriteNode()
    var btn_back = SKLabelNode()
    var bg = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        //CHECK IF TUTORIAL FINISHED
        var playTutorial = true
        if let tutorialPlayed = UserDefaults.standard.object(forKey: "TutorialPlayed") as? Bool {
            if tutorialPlayed == true {
                playTutorial = false
            }
        }
        
        if playTutorial {
            let gs = GameScene().scene!
            gs.size = self.view!.scene!.size
            gs.userData = NSMutableDictionary()
            gs.userData?.setObject(0, forKey: "Level" as NSCopying)
            self.view?.presentScene(gs)
        } else {
            //SET BACKGROUND
            let backgroundTexture = SKTexture(imageNamed: "img/LevelSelectBackground.png")
            bg = SKSpriteNode(texture: backgroundTexture)
            bg.size = CGSize(width: self.frame.width, height: self.frame.height)
            bg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            self.addChild(bg)
            
            //CREATE BACK BUTTON
            btn_back = SKLabelNode(text: "< Back")
            btn_back.fontSize = 26
            btn_back.horizontalAlignmentMode = .left
            btn_back.fontColor = SKColor.blue
            btn_back.fontName = "MarkerFelt-Wide"
            btn_back.zPosition = 304
            btn_back.position = CGPoint(x: 10, y: 10)
            self.addChild(btn_back)
            
            //CREATE LEVEL BUTTONS
            let minY = Double(btn_back.position.y + btn_back.frame.height / 2) + frameMarginSize
            let height = Double(self.frame.height) - frameMarginSize - minY
            let width = Double(self.frame.width) - frameMarginSize * 2
            createLevelButtons(CGRect(x: frameMarginSize, y: minY, width: width, height: height))
        }
    }
    
    func createLevelButtons(_ boundry: CGRect) {
        var rowHeight = (Double(boundry.height) - (NUMBER_OF_ROWS - 1) * minSpacingBetweenButtons) / NUMBER_OF_ROWS
        var columnWidth = (Double(boundry.width) - (NUMBER_OF_LEVELS_ON_ROW - 1) * minSpacingBetweenButtons) / NUMBER_OF_LEVELS_ON_ROW
        if rowHeight > columnWidth {
            rowHeight = columnWidth
        } else if columnWidth > rowHeight{
            columnWidth = rowHeight
        }
        let actualHorSpacingBetweenButtons = (Double(boundry.width) - columnWidth * NUMBER_OF_LEVELS_ON_ROW) / (NUMBER_OF_LEVELS_ON_ROW + 1)
        let actualVerSpacingBetweenButtons = (Double(boundry.height) - rowHeight * NUMBER_OF_ROWS) / (NUMBER_OF_ROWS - 1)
        let xStart = columnWidth / 2 + Double(boundry.minX)
        let yStart = rowHeight / 2 + Double(boundry.minY)
        let backgroundTexture = SKTexture(imageNamed: "img/BtnLevelBackground.png")
        let lockedLevelTexture = SKTexture(imageNamed: "img/LockedLevelForground.png")
        for row in 0.0 ..< NUMBER_OF_ROWS {
            for col in 0.0 ..< NUMBER_OF_LEVELS_ON_ROW {
                let btnNum = Int(row * NUMBER_OF_LEVELS_ON_ROW + col + 1)
                
                btn_background = SKSpriteNode(texture: backgroundTexture)
                btn_background.size = CGSize(width: columnWidth, height: rowHeight)
                let posX = xStart + col * columnWidth + (col + 1) * actualHorSpacingBetweenButtons
                let posY = yStart + (NUMBER_OF_ROWS - row - 1) * (rowHeight + actualVerSpacingBetweenButtons)
                btn_background.position = CGPoint(x: posX, y: posY)
                btn_text = SKLabelNode()
                btn_text.text = "\(btnNum)"
                btn_text.fontName = "AmericanTypewriter-Bold"
                btn_text.position = CGPoint(x: btn_background.position.x, y: btn_background.position.y - btn_text.frame.height / 2)
                
                if isLevelUnlocked(btnNum) {
                    btn_background.name = "Btn\(btnNum)"
                    btn_text.name = "Btn\(btnNum)"
                    self.addChild(btn_background)
                    btn_text.zPosition = 10
                    self.addChild(btn_text)
                } else {
                    btn_locked = SKSpriteNode(texture: lockedLevelTexture)
                    btn_locked.size = CGSize(width: columnWidth, height: rowHeight)
                    btn_locked.setScale(0.8)
                    btn_locked.position = CGPoint(x: btn_background.position.x, y: btn_background.position.y)
                    self.addChild(btn_background)
                    self.addChild(btn_locked)
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if node == btn_back {
                //BACK TO MENU
                let vc = self.view!.window!.rootViewController!
                AudioManager.startClickMain()
                vc.dismiss(animated: true, completion: {})
            }
            if node.name != nil && node.name?.range(of: "Btn") != nil {
                let level = Int(node.name!.replacingOccurrences(of: "Btn", with: ""))!
                if isLevelAlreadyCompleted(level) {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "LevelAlreadyCompleted"), object: self, userInfo:["level": level])
                } else {
                    self.startLevel(level)
                }
            }
        }
    }
    
    func startLevel(_ level: Int) {
        let gs = GameScene().scene!
        gs.size = self.view!.scene!.size
        gs.userData = NSMutableDictionary()
        gs.userData?.setObject(level, forKey: "Level" as NSCopying)
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(gs, transition: transition)
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
    
    func isLevelAlreadyCompleted(_ checkLevel: Int) -> Bool{
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "GameLevels")
        request.returnsObjectsAsFaults = false
        let results = (try! context.fetch(request)) as! [GameLevels]
        if results.count > 0 {
            for result in results {
                if Int(result.level) == checkLevel {
                    return Int(result.userScore) >= getGoalForLevel(checkLevel)
                }
            }
        }
        return false
    }
    
    func getGoalForLevel(_ reqLevel : Int) -> Int {
        if let path = Bundle.main.path(forResource: "GameLevelStatics", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, Int> {
                if let g = dict["\(reqLevel)"] {
                    return g
                }
            }
        }
        return 0
    }
    
}
