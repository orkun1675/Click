//
//  GameScene.swift
//  Click
//
//  Created by Orkun Duman on 23/03/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import SpriteKit
import CoreData
import UIKit
import Parse

class GameScene: SKScene {
    
    //DESIGN VARIABLES
    let dotScreenHeightPercantage = 28.0
    let explosionScreenHeightPercantage = 28.0
    let frameMarginSize = 30.0
    let extraSpaceOnTop = 15.0
    let distanceBetweenButtons = 20.0
    
    //GAME VARIABLES
    let game_Time_Default = 30
    let minScoreToRunAI = 400
    let numberOfPointsToBeGenerated = 100
    let last_level = 12
    
    var maxX = 1
    var minX = 0
    var maxY = 1
    var minY = 0
    
    var dot = SKSpriteNode()
    var explosion = SKSpriteNode()
    var bgImage = SKSpriteNode()
    var lbl_score = SKLabelNode()
    var lbl_remaningTime = SKLabelNode()
    var lbl_countDown = SKLabelNode()
    var btn_start = SKLabelNode()
    var btn_resume = SKLabelNode()
    var lbl_level = SKLabelNode()
    var lbl_goal = SKLabelNode()
    var btn_playAgain = SKLabelNode()
    var btn_back = SKLabelNode()
    var countDown_Timer = Timer()
    var data = CoordinateRecorder(name: "")
    var grayOut = SKSpriteNode()
    var lbl_flashTimer = SKLabelNode()
    var lbl_finalScore = SKLabelNode()
    var lbl_finalAccuracy = SKLabelNode()
    var lbl_result = SKLabelNode()
    var btn_playAgain_opt = SKLabelNode()
    var spinner = SKSpriteNode()
    
    var lbl_exp_main1 = SKLabelNode()
    var lbl_exp_main2 = SKLabelNode()
    var lbl_exp_main3 = SKLabelNode()
    var lbl_exp_close = SKLabelNode()
    var lbl_exp_time = SKLabelNode()
    var lbl_exp_score = SKLabelNode()
    
    var explanationModeOpen = false
    var gameRunning = false
    var gamePaused = false
    var pauseCount = 0
    var totalClicks : Float = 0
    var succesfullClicks : Float = 0
    var accuracy : Float = 0.0
    var game_Time = 30
    var game_Score = 0
    var level = 0
    var goal = 0
    var dotData : Array<Array<Double>> = [[]]
    var dotCounter = 0
    var gameStartTime : Int64 = 0
    var gameEndTime : Int64 = 0
    
    var explosionAnimation = SKAction()
    var tempRec = SKShapeNode()
    var viewController: GameViewController!
    
    override func didMove(to view: SKView) {        
        game_Time = game_Time_Default
        level = self.userData?.value(forKey: "Level") as! Int
        goal = getGoalForLevel(level)
        data = CoordinateRecorder(name: "\(level)")
        
        //LISTENER
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GameScene.goingToBackground(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        
        //CREATE BACKGROUND
        let bgTexture = SKTexture(imageNamed: "img/Background.png")
        for i:CGFloat in 0 ..< 3 {
            bgImage = SKSpriteNode(texture: bgTexture)
            let oldWidth = bgImage.size.width
            bgImage.size.width = self.frame.width
            bgImage.size.height = bgImage.size.height * (bgImage.size.width / oldWidth)
            bgImage.yScale = 1.0
            bgImage.position = CGPoint(x: self.frame.midX, y: bgImage.size.height / 2 + bgImage.size.height * i)
            let movebg = SKAction.move(by: CGVector(dx: 0, dy: -bgImage.size.height), duration: 18)
            let replacebg = SKAction.move(by: CGVector(dx: 0, dy: bgImage.size.height), duration: 0)
            let movebgForever = SKAction.repeatForever(SKAction.sequence([movebg, replacebg]))
            bgImage.run(movebgForever)
            self.addChild(bgImage)
        }
        
        //CREATE DOT
        let dotTexture = SKTexture(imageNamed: "img/BlueDot.png")
        dot = SKSpriteNode(texture: dotTexture)
        dot.size.height = CGFloat(Double(self.frame.height) * dotScreenHeightPercantage / 100.0)
        dot.size.width = dot.size.height
        dot.zPosition = 1
        
        //SET SCREEN SIZE
        let dotRadius = Double(dot.size.height / 2 * 166 / 400)
        minX = Int(frameMarginSize + dotRadius)
        maxX = Int(Double(self.frame.width) - frameMarginSize - dotRadius)
        minY = Int(frameMarginSize + dotRadius)
        maxY = Int(Double(self.frame.height) - frameMarginSize - dotRadius - extraSpaceOnTop)
        
        //CREATE EXPLOSION
        let explosionTexture = SKTexture(imageNamed: "img/Explosion1.png")
        explosion = SKSpriteNode(texture: explosionTexture)
        explosion.size.height = CGFloat(Double(self.frame.height) * explosionScreenHeightPercantage / 100)
        explosion.size.width = explosion.size.height
        explosion.zPosition = 2
        var explosionTextures : Array<SKTexture> = []
        for var i = 1; i <= 5; i += 1 {
            explosionTextures.append(SKTexture(imageNamed: "img/Explosion\(i).png"))
        }
        explosionAnimation = SKAction.animate(with: explosionTextures, timePerFrame: 0.03)
        
        //CREATE SCORE LABEL
        lbl_score = SKLabelNode()
        lbl_score.text = "\(game_Score)p"
        lbl_score.fontSize = 26
        lbl_score.fontName = "AmericanTypewriter-Bold"
        lbl_score.fontColor = UIColor.black
        lbl_score.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        lbl_score.position = CGPoint(x: self.frame.width - 15, y: self.frame.height - 30)
        self.addChild(lbl_score)
        
        //CREATE TIME LABEL
        lbl_remaningTime = SKLabelNode()
        lbl_remaningTime.text = "\(game_Time)s"
        lbl_remaningTime.fontSize = 26
        lbl_remaningTime.fontName = "AmericanTypewriter-Bold"
        lbl_remaningTime.fontColor = UIColor.black
        lbl_remaningTime.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        lbl_remaningTime.position = CGPoint(x: 10.0, y: self.frame.height - 30)
        self.addChild(lbl_remaningTime)
        
        if level == 0 {
            reCreateDotAtPoint(Int(self.frame.midX), y: maxY - 2 * Int(distanceBetweenButtons), effect: false)
        } else {
            reCreateDotAtRandomPoint(false)
        }
        
        //GRAY OUT FIELD
        grayOutField(true)
        
        //CREATE LEVEL LABEL
        lbl_level = SKLabelNode()
        lbl_level.text = "Level \(level)"
        if level == 0 {
            lbl_level.text = "Tutorial"
        }
        lbl_level.fontColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
        lbl_level.fontName = "AmericanTypewriter-Bold"
        lbl_level.fontSize = 32
        lbl_level.zPosition = 301
        
        //CREATE GOAL LABEL
        lbl_goal = SKLabelNode()
        lbl_goal.text = "Goal: \(goal)"
        lbl_goal.fontColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
        lbl_goal.fontName = "AmericanTypewriter-Bold"
        lbl_goal.fontSize = 32
        lbl_goal.zPosition = 301
        
        //CREATE START BUTTON
        btn_start = SKLabelNode()
        btn_start.text = "Start Game"
        if level != 0 {
            btn_start.text = "Getting Smarter"
        }
        btn_start.fontColor = UIColor(red: 184, green: 0, blue: 0, alpha: 1)
        btn_start.fontName = "AmericanTypewriter-Bold"
        btn_start.fontSize = 38
        btn_start.zPosition = 301
        
        //CREATE RESUME BUTTON
        btn_resume = SKLabelNode()
        btn_resume.text = "Resume"
        btn_resume.fontColor = UIColor(red: 184, green: 0, blue: 0, alpha: 1)
        btn_resume.fontName = "AmericanTypewriter-Bold"
        btn_resume.fontSize = 38
        btn_resume.zPosition = 301
        btn_resume.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        //ADD BUTTON-LEVEL TO SCREEN
        var height = lbl_level.frame.height / 2 + lbl_goal.frame.height + btn_start.frame.height / 2 + CGFloat(distanceBetweenButtons) * 2
        lbl_level.position = CGPoint(x: self.frame.midX, y: self.frame.midY + lbl_goal.frame.height / 2 + CGFloat(distanceBetweenButtons) + lbl_level.frame.height / 2)
        self.addChild(lbl_level)
        lbl_goal.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(lbl_goal)
        btn_start.position = CGPoint(x: self.frame.midX, y: self.frame.midY - lbl_goal.frame.height / 2 - CGFloat(distanceBetweenButtons) - btn_start.frame.height / 2)
        self.addChild(btn_start)
        
        //CREATE BACK BUTTON
        btn_back = SKLabelNode()
        btn_back.text = "< Back"
        btn_back.fontSize = 26
        btn_back.horizontalAlignmentMode = .left
        btn_back.fontColor = SKColor.orange
        btn_back.fontName = "MarkerFelt-Wide"
        btn_back.zPosition = 304
        btn_back.position = CGPoint(x: 10, y: 10)
        self.addChild(btn_back)
        
        //DEFINE SPINNER
        var textures : Array<SKTexture> = []
        for i in 1 ..< 25 {
            textures.append(SKTexture(imageNamed: "img/spinner/spinner_\(i).png"))
        }
        let animation = SKAction.animate(with: textures, timePerFrame: 0.05)
        let spinSpinner = SKAction.repeatForever(animation)
        spinner = SKSpriteNode(texture: SKTexture(imageNamed: "img/spinner/spinner_1.png"))
        spinner.size = CGSize(width: 50, height: 50)
        spinner.position = CGPoint(x: self.frame.midX, y: btn_start.position.y - btn_start.frame.height / 2 - spinner.frame.height / 2)
        spinner.run(spinSpinner)
        spinner.zPosition = 401
        
        //TUTORIAL SPECIALS
        if level != 0 {
            self.addChild(spinner)
            loadPointsFromAIManager()
        } else {
            //RE-GRAY FIELD IF TUTORIAL & ADD EXPLANATIONS
            grayOutField(false)
            grayOutAllField(true)
            let line1 = "Click on the escaping Balloon"
            let line2 = "as fast as you can, to reach"
            let line3 = "the target points."
            lbl_exp_main1 = SKLabelNode()
            lbl_exp_main1.text = line1
            lbl_exp_main1.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
            lbl_exp_main1.fontName = "Noteworthy-Bold"
            lbl_exp_main1.fontSize = 28
            lbl_exp_main1.zPosition = 401
            lbl_exp_main1.position = CGPoint(x: self.frame.midX, y: self.frame.midY - lbl_exp_main1.frame.height / 2)
            lbl_exp_main2 = SKLabelNode()
            lbl_exp_main2.text = line2
            lbl_exp_main2.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
            lbl_exp_main2.fontName = "Noteworthy-Bold"
            lbl_exp_main2.fontSize = 28
            lbl_exp_main2.zPosition = 401
            lbl_exp_main2.position = CGPoint(x: lbl_exp_main1.position.x, y: lbl_exp_main1.position.y - lbl_exp_main1.frame.height / 2 - lbl_exp_main2.frame.height / 2)
            lbl_exp_main3 = SKLabelNode()
            lbl_exp_main3.text = line3
            lbl_exp_main3.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
            lbl_exp_main3.fontName = "Noteworthy-Bold"
            lbl_exp_main3.fontSize = 28
            lbl_exp_main3.zPosition = 401
            lbl_exp_main3.position = CGPoint(x: lbl_exp_main1.position.x, y: lbl_exp_main2.position.y - lbl_exp_main2.frame.height / 2 - lbl_exp_main3.frame.height / 2)
            
            lbl_exp_close = SKLabelNode()
            lbl_exp_close.text = "(touch the screen to proceed)"
            lbl_exp_close.fontColor = UIColor(red: 0.8, green: 0, blue: 0.05, alpha: 1)
            lbl_exp_close.fontName = "Noteworthy-Bold"
            lbl_exp_close.fontSize = 14
            lbl_exp_close.zPosition = 401
            lbl_exp_close.position = CGPoint(x: lbl_exp_main1.position.x, y: lbl_exp_close.frame.height)
            
            lbl_exp_time = SKLabelNode()
            lbl_exp_time.text = "Remaining Time"
            lbl_exp_time.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
            lbl_exp_time.fontName = "Noteworthy-Bold"
            lbl_exp_time.fontSize = 20
            lbl_exp_time.zPosition = 401
            lbl_exp_time.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            lbl_exp_time.position = CGPoint(x: lbl_remaningTime.position.x, y: lbl_remaningTime.position.y - CGFloat(distanceBetweenButtons) - lbl_exp_time.frame.height / 2)
            
            lbl_exp_score = SKLabelNode()
            lbl_exp_score.text = "Current Score"
            lbl_exp_score.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
            lbl_exp_score.fontName = "Noteworthy-Bold"
            lbl_exp_score.fontSize = 20
            lbl_exp_score.zPosition = 401
            lbl_exp_score.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            lbl_exp_score.position = CGPoint(x: lbl_score.position.x, y: lbl_score.position.y - CGFloat(distanceBetweenButtons) - lbl_exp_score.frame.height / 2)
            
            lbl_level.removeFromParent()
            lbl_goal.removeFromParent()
            btn_start.removeFromParent()
            btn_back.removeFromParent()
            self.addChild(lbl_exp_main1)
            self.addChild(lbl_exp_main2)
            self.addChild(lbl_exp_main3)
            self.addChild(lbl_exp_close)
            self.addChild(lbl_exp_time)
            self.addChild(lbl_exp_score)
            explanationModeOpen = true
        }
    }
    
    func loadPointsFromAIManager() {
        let aiManager = AIManager(loadFromMemory: true)
        aiManager.getPoints(self, numOfPoints: numberOfPointsToBeGenerated)
    }
    
    func upadateDotData(_ data : Array<Array<Double>>) {
        dotData = data
        btn_start.text = "Start Game"
        spinner.removeFromParent()
    }
    
    func startFlashTimer(_ startTimerFrom : Int) {
        lbl_flashTimer = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        lbl_flashTimer.fontSize = 42
        lbl_flashTimer.fontColor = SKColor.blue
        lbl_flashTimer.text = "\(startTimerFrom)"
        lbl_flashTimer.alpha = 0
        lbl_flashTimer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        lbl_flashTimer.zPosition = 302
        self.addChild(lbl_flashTimer)
        flashLabel(lbl_flashTimer, forSeconds: startTimerFrom)
    }
    
    func flashLabel(_ label : SKLabelNode, forSeconds : Int) {
        if (forSeconds == 0) {
            label.removeFromParent()
            grayOutField(false)
            startGame()
            return
        }
        let flashAction = SKAction.sequence([SKAction.fadeIn(withDuration: 0.1), SKAction.wait(forDuration: 0.8), SKAction.fadeOut(withDuration: 0.1)])
        lbl_flashTimer.run(flashAction, completion: {label.text = "\(forSeconds - 1)"; self.flashLabel(label, forSeconds: forSeconds - 1);})
    }
    
    func grayOutField(_ positive : Bool) {
        if positive {
            grayOut = SKSpriteNode(color: UIColor(red: 80, green: 80, blue: 80, alpha: 1), size: CGSize(width: self.frame.width, height: self.frame.height))
            grayOut.alpha = 0.9
            grayOut.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            grayOut.zPosition = 300
            self.addChild(grayOut)
        } else {
            grayOut.removeFromParent()
        }
    }
    
    func grayOutAllField(_ positive : Bool) {
        if positive {
            grayOut = SKSpriteNode(color: UIColor(red: 80, green: 80, blue: 80, alpha: 1), size: CGSize(width: self.frame.width, height: self.frame.height))
            grayOut.alpha = 0.7
            grayOut.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            grayOut.zPosition = 400
            self.addChild(grayOut)
        } else {
            grayOut.removeFromParent()
        }
    }
    
    func startGame() {
        totalClicks = 0
        succesfullClicks = 0
        game_Time = game_Time_Default - 14
        game_Score = 310
        lbl_remaningTime.text = "\(game_Time)s"
        lbl_score.text = "\(game_Score)"
        dotCounter = 0
        
        if level == 0 {
            reCreateDotAtRandomPoint(false)
        } else {
            reCreateDotAtNextPoint(false)
        }
        
        gameRunning = true
        countDown_Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.decreaseSeconds), userInfo: nil, repeats: true)
        AudioManager.startClickInGame()
    }
    
    func endGame() {
        gameRunning = false
        AudioManager.stopClickInGame()
        grayOutField(true)
        spinner.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(spinner)
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            self.endGameSaveJobs()
            DispatchQueue.main.async(execute: { () -> Void in
                self.endGameSaveComplete()
            })
        })
    }
    
    func endGameSaveJobs() {
        let levelAlreadyComplete = isLevelAlreadyCompleted(level)
        
        if totalClicks < 1 {
            accuracy = 0.0
        } else {
            accuracy = succesfullClicks / totalClicks * 100
        }
        if level != 0 && !levelAlreadyComplete {
            saveLevelData(level, scr: game_Score, g: goal, acc: accuracy, successClicks: Int(succesfullClicks), totClicks: Int(totalClicks), totReactionTime: Int(gameEndTime - gameStartTime))
        }
        
        //CREATE RESULT LABEL
        lbl_result = SKLabelNode()
        if game_Score >= goal {
            lbl_result.text = "PASS"
        } else {
            if level == 0 {
                lbl_result.text = "FAILED TUTORIAL"
            } else {
                lbl_result.text = "FAILED"
            }
        }
        lbl_result.fontSize = 42
        lbl_result.fontColor = SKColor.blue
        lbl_result.fontName = "AmericanTypewriter-Bold"
        lbl_result.zPosition = 301
        
        //CREATE ACCURACY LABEL
        lbl_finalAccuracy = SKLabelNode()
        lbl_finalAccuracy.text = "Accuracy: " + String(format: "%.2f", accuracy) + "%"
        lbl_finalAccuracy.fontSize = 28
        lbl_finalAccuracy.fontColor = SKColor.black
        lbl_finalAccuracy.fontName = "AmericanTypewriter-Bold"
        lbl_finalAccuracy.zPosition = 301
        
        //CREATE SCORE LABEL
        lbl_finalScore = SKLabelNode()
        lbl_finalScore.text = "Score: \(game_Score)/\(goal)"
        lbl_finalScore.fontSize = 28
        lbl_finalScore.fontColor = SKColor.black
        lbl_finalScore.fontName = "AmericanTypewriter-Bold"
        lbl_finalScore.zPosition = 301
        
        //SAVE DATA
        if (!levelAlreadyComplete) {
            var dataResult = data.getArrayWithoutDotCoordinates()
            let dataRaw = data.getRawDotCoordinates()
            let deviceID = DeviceIDManager.getDeviceID()
            if let dotData = UserDefaults.standard.object(forKey: "GameData") as? Array<Array<Double>> {
                dataResult = dotData + dataResult
            }
            dataResult = trimArray(dataResult)
            if game_Score >= goal {
                UserDefaults.standard.set(dataResult, forKey: "GameData")
                UserDefaults.standard.synchronize()
                var aiManager = AIManager(loadFromMemory: false)
                if level == 0{
                    UserDefaults.standard.set(true, forKey: "TutorialPlayed")
                    UserDefaults.standard.synchronize()
                    saveGameDataToCloud(deviceID, levelToBeSaved: level, scoreToBeSaved: game_Score, aiRunning: false, dataToBeSaved: dataRaw)
                } else {
                    saveGameDataToCloud(deviceID, levelToBeSaved: level, scoreToBeSaved: game_Score, aiRunning: true, dataToBeSaved: dataRaw)
                }
            } else {
                if level != 0 &&  game_Score >= minScoreToRunAI {
                    saveGameDataToCloud(deviceID, levelToBeSaved: level, scoreToBeSaved: game_Score, aiRunning: true, dataToBeSaved: dataRaw)
                }
            }
        }
        
        //SET LABELS
        if game_Score >= goal {
            if level == 0{
                unlockLevel(1)
                btn_playAgain = SKLabelNode()
                btn_playAgain.text = "Finish Tutorial"
            } else if level == last_level {
                btn_playAgain = SKLabelNode()
                btn_playAgain.text = "Finish Game"
            } else {
                btn_playAgain = SKLabelNode()
                btn_playAgain.text = "Next Level"
            }
        } else {
            if level == 0 {
                btn_playAgain = SKLabelNode()
                btn_playAgain.text = "Try Again"
            } else {
                btn_playAgain = SKLabelNode()
                btn_playAgain.text = "Play Again"
            }
        }
        
        
        btn_playAgain.fontColor = UIColor(red: 184, green: 0, blue: 0, alpha: 1)
        btn_playAgain.fontName = "AmericanTypewriter-Bold"
        btn_playAgain.fontSize = 32
        btn_playAgain.zPosition = 301
        
        //ADD TO PAGE
        lbl_result.position = CGPoint(x: self.frame.midX, y: self.frame.midY + CGFloat(distanceBetweenButtons) / 2 + lbl_finalAccuracy.frame.height + CGFloat(distanceBetweenButtons) + lbl_result.frame.height / 2)
        lbl_finalAccuracy.position = CGPoint(x: self.frame.midX, y: self.frame.midY + CGFloat(distanceBetweenButtons) / 2 + lbl_finalAccuracy.frame.height / 2)
        lbl_finalScore.position = CGPoint(x: self.frame.midX, y: self.frame.midY - CGFloat(distanceBetweenButtons) / 2 - lbl_finalScore.frame.height / 2)
        btn_playAgain.position = CGPoint(x: self.frame.midX, y: self.frame.midY - CGFloat(distanceBetweenButtons) / 2 - lbl_finalScore.frame.height - CGFloat(distanceBetweenButtons) - btn_playAgain.frame.height / 2)
        
        //CREATE BACK BUTTON
        btn_back = SKLabelNode()
        btn_back.text = "< Back"
        btn_back.fontSize = 26
        btn_back.horizontalAlignmentMode = .left
        btn_back.fontColor = SKColor.orange
        btn_back.fontName = "MarkerFelt-Wide"
        btn_back.zPosition = 304
        btn_back.position = CGPoint(x: 10, y: 10)
        
        //CREATE PLAY AGAIN OPTION
        if game_Score >= goal && level != 0{
            btn_playAgain_opt = SKLabelNode()
            btn_playAgain_opt.text = "Play Again"
            btn_playAgain_opt.fontSize = 26
            btn_playAgain_opt.horizontalAlignmentMode = .right
            btn_playAgain_opt.fontColor = SKColor.orange
            btn_playAgain_opt.fontName = "MarkerFelt-Wide"
            btn_playAgain_opt.zPosition = 304
            btn_playAgain_opt.position = CGPoint(x: self.frame.maxX - 10, y: 10)
        }
    }
    
    func endGameSaveComplete() {
        spinner.removeFromParent()
        self.addChild(lbl_result)
        self.addChild(lbl_finalAccuracy)
        self.addChild(lbl_finalScore)
        self.addChild(btn_playAgain)
        self.addChild(btn_back)
        if game_Score >= goal && level != 0{
            self.addChild(btn_playAgain_opt)
        }
    }
    
    func saveGameDataToCloud(_ deviceID : Int, levelToBeSaved : Int, scoreToBeSaved : Int, aiRunning : Bool, dataToBeSaved : Array<Array<Double>>) {
        var appVersion = "0.0"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        let parseGameDataSaver = PFObject(className: "GameData")
        parseGameDataSaver["AppVersion"] = appVersion
        parseGameDataSaver["DeviceID"] = deviceID
        parseGameDataSaver["DeviceType"] = UIDevice.current.modelName
        parseGameDataSaver["Level"] = levelToBeSaved
        parseGameDataSaver["Score"] = scoreToBeSaved
        parseGameDataSaver["AIRunning"] = aiRunning
        parseGameDataSaver["Clicks"] = dataToBeSaved
        parseGameDataSaver.saveEventually()
    }
    
    func reCreateDotAtRandomPoint(_ effect : Bool) {
        let corX = randomInt(minX, max: maxX)
        let corY = randomInt(minY, max: maxY)
        reCreateDotAtPoint(corX, y: corY, effect: effect)
    }
    
    func reCreateDotAtPoint(_ x : Int, y : Int, effect : Bool) {
        if effect {explosion.position = dot.position}
        dot.removeFromParent()
        if effect {
            self.addChild(explosion)
            explosion.run(SKAction.sequence([explosionAnimation, SKAction.removeFromParent()]))
        }
        dot.position = CGPoint(x: x, y: y)
        self.addChild(dot)
    }
    
    func reCreateDotAtNextPoint(_ effect : Bool) {
        let corX = Int(Double(maxX - minX) * dotData[dotCounter][0]) + minX
        let corY = Int(Double(maxY - minY) * dotData[dotCounter][1]) + minY
        reCreateDotAtPoint(corX, y: corY, effect: effect)
        dotCounter += 1
    }
    
    func randomInt(_ min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            if explanationModeOpen {
                lbl_exp_main1.removeFromParent()
                lbl_exp_main2.removeFromParent()
                lbl_exp_main3.removeFromParent()
                lbl_exp_close.removeFromParent()
                lbl_exp_score.removeFromParent()
                lbl_exp_time.removeFromParent()
                grayOutAllField(false)
                grayOutField(true)
                self.addChild(lbl_level)
                self.addChild(lbl_goal)
                self.addChild(btn_start)
                self.addChild(btn_back)
                explanationModeOpen = false
                break
            }
            
            let location = touch.location(in: self)
            let node = atPoint(location)
            if gameRunning {
                totalClicks += 1
                if node == dot && checkIfInsideCircle(dot, x: location.x, y: location.y){
                    succesfullClicks += 1
                    recordClick(location, clickedNode: node)
                    incrementScore()
                    if level == 0{
                        reCreateDotAtRandomPoint(true)
                    } else {
                        reCreateDotAtNextPoint(true)
                    }
                }
            }
            if node == btn_start && btn_start.text == "Start Game"{
                btn_back.removeFromParent()
                btn_start.removeFromParent()
                lbl_level.removeFromParent()
                lbl_goal.removeFromParent()
                startFlashTimer(3)
            }
            if node == btn_playAgain {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
                if btn_playAgain.text == "Finish Game" {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishedGame"), object: self)
                } else if game_Score >= goal {
                    if level == 0 {
                        let ls = LevelScene().scene!
                        ls.size = self.view!.scene!.size
                        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                        self.view?.presentScene(ls, transition: transition)
                    } else {
                        let gs = GameScene().scene!
                        gs.size = self.view!.scene!.size
                        gs.userData = NSMutableDictionary()
                        gs.userData?.setObject(level + 1, forKey: "Level" as NSCopying)
                        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                        self.view?.presentScene(gs, transition: transition)
                    }
                } else {
                    if level == 0 {
                        let ls = LevelScene().scene!
                        ls.size = self.view!.scene!.size
                        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                        self.view?.presentScene(ls, transition: transition)
                    } else {
                        let gs = GameScene().scene!
                        gs.size = self.view!.scene!.size
                        gs.userData = NSMutableDictionary()
                        gs.userData?.setObject(level, forKey: "Level" as NSCopying)
                        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                        self.view?.presentScene(gs, transition: transition)
                    }
                }
            }
            if node == btn_resume {
                if gamePaused {
                    btn_resume.removeFromParent()
                    grayOutField(false)
                    countDown_Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.decreaseSeconds), userInfo: nil, repeats: true)
                    gamePaused = false
                }
            }
            if node == btn_back {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
                if level == 0 {
                    let vc = self.view!.window!.rootViewController!
                    AudioManager.startClickMain()
                    vc.dismiss(animated: true, completion: {})
                } else {
                    let ls = LevelScene().scene!
                    ls.size = self.view!.scene!.size
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    self.view?.presentScene(ls, transition: transition)
                }
            }
            if node == btn_playAgain_opt {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "LevelAlreadyCompleted"), object: self, userInfo:["level": level])
            }
        }
    }
    
    func recordClick(_ clickLocation : CGPoint, clickedNode : SKNode) {
        let date = Date()
        let now = Int64(floor(date.timeIntervalSince1970 * 1000))
        if gameStartTime == 0 {
            gameStartTime = now
        }
        gameEndTime = now
        let clickX : Double = (Double(clickLocation.x) - Double(minX)) / Double(maxX - minX)
        let clickY : Double = (Double(clickLocation.y) - Double(minY)) / Double(maxY - minY)
        let dotX : Double = (Double(clickedNode.position.x) - Double(minX)) / Double(maxX - minX)
        let dotY : Double = (Double(clickedNode.position.y) - Double(minY)) / Double(maxY - minY)
        let event =  ClickEvent(clickX: clickX, clickY: clickY, dotX: dotX, dotY: dotY, epochTime: now)
        data.addPoint(event)
    }
    
    func incrementScore() {
        game_Score += 10
        lbl_score.text = "\(game_Score)p"
    }
    
    func decreaseSeconds() {
        game_Time = game_Time - 1
        if game_Time < 1 {
            lbl_remaningTime.text = "Time Up!"
            countDown_Timer.invalidate()
            endGame()
        } else if game_Time == 1{
            lbl_remaningTime.text = "\(game_Time)s"
        } else {
            lbl_remaningTime.text = "\(game_Time)s"
        }
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
    
    func saveLevelData(_ lvl : Int, scr : Int, g : Int, acc : Float, successClicks : Int, totClicks : Int, totReactionTime : Int) {
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "GameLevels")
        request.returnsObjectsAsFaults = false
        let results = (try! context.fetch(request)) as! [GameLevels]
        if results.count > 0 {
            for result in results {
                if Int(result.level) == lvl {
                    result.setValue(Int(result.trials) + 1, forKey: "trials")
                    if scr > Int(result.userScore) {
                        result.setValue(scr, forKey: "userScore")
                        result.setValue(acc, forKey: "userAcc")
                    } else if scr == Int(result.userScore) && acc > result.userAcc {
                        result.setValue(acc, forKey: "userAcc")
                    }
                    result.setValue(Int(result.sucClicks) + successClicks, forKey: "sucClicks")
                    result.setValue(Int(result.totalClicks) + totClicks, forKey: "totalClicks")
                    let prevClicks = (Int(result.sucClicks) - result.trials)
                    let newMeanReac = (Int(result.meanReactionTime) * prevClicks + totReactionTime) / Double(prevClicks + successClicks - 1)
                    result.setValue(Int(newMeanReac), forKey: "meanReactionTime")
                    do {
                        try context.save()
                    } catch _ {
                    }
                }
            }
        }
        if scr >= g {
            unlockLevel(lvl + 1)
        }
    }
    
    func unlockLevel(_ lvl : Int) {
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "GameLevels")
        request.returnsObjectsAsFaults = false
        let results = (try! context.fetch(request)) as! [GameLevels]
        var done = false
        if results.count > 0 {
            for result in results {
                if Int(result.level) == lvl {
                    result.setValue(true, forKey: "unlocked")
                    do {
                        try context.save()
                    } catch _ {
                    }
                    done = true
                }
            }
        }
        if !done {
            let levelData = NSEntityDescription.insertNewObject(forEntityName: "GameLevels", into: context) 
            levelData.setValue(lvl, forKey: "level")
            levelData.setValue(0, forKey: "userScore")
            levelData.setValue(0.0, forKey: "userAcc")
            levelData.setValue(0, forKey: "trials")
            levelData.setValue(true, forKey: "unlocked")
            levelData.setValue(0, forKey: "sucClicks")
            levelData.setValue(0, forKey: "totalClicks")
            levelData.setValue(0, forKey: "meanReactionTime")
            do {
                try context.save()
            } catch _ {
            }
        }
    }
    
    func checkIfInsideCircle(_ node: SKSpriteNode, x: CGFloat, y: CGFloat) -> Bool {
        if (pow(x - node.position.x, 2) + pow(y - node.position.y, 2)) <= pow(node.size.width / 2 * 200 / 400, 2) {
            return true
        } else {
            return false
        }
    }
    
    @objc func goingToBackground(_ notification: Notification) {
        if !gamePaused && gameRunning {
            countDown_Timer.invalidate()
            pauseCount += 1
            if pauseCount >= 4 {
                decreaseSeconds()
            }
            grayOutField(true)
            self.addChild(btn_resume)
            gamePaused = true
        }
    }
    
    func trimArray(_ longArray: Array<Array<Double>>) -> Array<Array<Double>> {
        let maxArrayLength = 150
        if (longArray.count <= maxArrayLength) {
            return longArray
        }
        var shortArray = Array(repeating: Array(repeating: 0.0, count: longArray[0].count), count: maxArrayLength)
        let lastIndex = longArray.count - 1
        let firstIndex = longArray.count - maxArrayLength
        var counter = maxArrayLength - 1
        for (var i = lastIndex; i >= firstIndex; i -= 1) {
            shortArray[counter] = longArray[i]
            counter -= 1
        }
        return shortArray
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
                    return Int(result.userScore) >= goal
                }
            }
        }
        return false
    }
    
}
