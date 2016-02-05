//
//  SoundboardService.swift
//  Woef
//
//  Created by Dominggus Salampessy on 30/01/16.
//  Copyright © 2016 Dominggus Salampessy. All rights reserved.
//

import AVKit
import AVFoundation
import Foundation

class SoundService : NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = SoundService()
    
    var isLoopingEmpty = false
    let audioSession = AVAudioSession.sharedInstance()
    var player: AVAudioPlayer?
    
    lazy var emptySoundPlayer: AVAudioPlayer = {
        do {
            let soundURL = NSBundle.mainBundle().URLForResource("empty", withExtension: "mp3")
            let player = try AVAudioPlayer(contentsOfURL: soundURL!)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 0.0
            return player
        } catch {
            return AVAudioPlayer()
        }
 
    }()
    
    override init() {
        super.init()
        
        do {
            UIApplication.sharedApplication().idleTimerDisabled = true
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: .MixWithOthers)
            
            startLoopingEmpty()
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    func playSound(fileUrl:NSURL) {
        dispatch_async(dispatch_get_main_queue(), {
            do {
                
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
                self.player?.stop()
                
                self.player = try AVAudioPlayer(contentsOfURL: fileUrl)
                self.player?.delegate = self
                self.player?.play()
            
                try self.audioSession.setActive(true)
                
                
            } catch let error as NSError {
                print(error)
            }
        })
    }
    
    func killSounds() {
        self.player?.stop()
    }
    
    func startLoopingEmpty() {
        
        isLoopingEmpty = true
        emptySoundPlayer.play()
    }
    
    func stopLoopingEmpty() {
        isLoopingEmpty = false
        emptySoundPlayer.pause()
    }
    
    
    
    @objc func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        if player.isEqual(emptySoundPlayer) && isLoopingEmpty {
            emptySoundPlayer.play()
            return
        }

        self.player?.stop()
        startLoopingEmpty()
    }
}