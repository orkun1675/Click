//
//  AudioManager.swift
//  Click
//
//  Created by Orkun Duman on 09/08/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager {
    
    static let sharedInstance = AudioManager()
    
    static var filesLoaded = false
    
    static let pathToClickMain = Bundle.main.path(forResource: "ClickMain", ofType: "mp3")!
    static let pathToClickInGame = Bundle.main.path(forResource: "ClickInGame", ofType: "mp3")!
    static var playerClickMain : AVAudioPlayer {
        do {
            return try AVAudioPlayer(contentsOf: URL(fileURLWithPath: pathToClickMain))
        }
        catch {
            //print("Could not load music files!")
        }
        return AVAudioPlayer()
    }
    static var playerClickInGame : AVAudioPlayer {
        do {
            return try AVAudioPlayer(contentsOf: URL(fileURLWithPath: pathToClickInGame))
        }
        catch {
            //print("Could not load music files!")
        }
        return AVAudioPlayer()
    }
    
    static func startClickMain() {
        playerClickMain.currentTime = 0
        playerClickMain.volume = 0.7
        playerClickMain.numberOfLoops = -1
        playerClickMain.play()
    }
    
    static func stopClickMain() {
        if playerClickMain.isPlaying {
            playerClickMain.stop()
        }
    }
    
    static func startClickInGame() {
        playerClickInGame.currentTime = 0
        playerClickInGame.volume = 0.7
        playerClickInGame.numberOfLoops = -1
        playerClickInGame.play()
        
    }
    
    static func stopClickInGame() {
        if playerClickInGame.isPlaying {
            playerClickInGame.stop()
        }
    }
    
    
    
}
