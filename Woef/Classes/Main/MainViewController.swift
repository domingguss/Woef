//
//  ViewController.swift
//  Woef
//
//  Created by Dominggus Salampessy on 23/01/16.
//  Copyright © 2016 Dominggus Salampessy. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MainViewController: UIViewController {
    
    let soundService = SoundService()
    var timer: NSTimer?
    
    let peerServiceManager = PeerServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "timerTick", userInfo: nil, repeats: true)
    }
    
    
    @IBAction func buttonPressed(sender: UIButton?) {
        timerTick()
    }
    
    func timerTick() {
        NSLog("timerTick")
//        soundService.playSound()
    }
    
    
    
    
}

