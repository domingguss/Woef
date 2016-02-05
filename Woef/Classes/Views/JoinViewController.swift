//
//  JoinViewController.swift
//  Woef
//
//  Created by Dominggus Salampessy on 31/01/16.
//  Copyright © 2016 Dominggus Salampessy. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class JoinViewController: UIViewController, PeerServiceManagerDelegate {
    
    @IBOutlet weak var label: UILabel?
    
    let soundService = SoundService()
    let peerServiceManager = JoinServiceManager()
    
    init() {
        super.init(nibName: "JoinViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        self.title = "Join"
        peerServiceManager.delegate = self
        
        super.viewDidLoad()
    }
    
    
    func connectedDevicesChanged(manager: PeerServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.label?.text = "connectedDevices:\n \(connectedDevices)"
        }
        
    }
    
    func colorChanged(manager: PeerServiceManager, colorString: String) {
        NSLog("join: found colorChanged to \(colorString)")
        switch(colorString) {
        case "yellow":
            changeColor(UIColor.yellowColor())
        break
            case "red":
            changeColor(UIColor.redColor())
            soundService.playSound()
            break
        default:
            changeColor(UIColor.whiteColor())
            break
            
        }
    }
    
    func changeColor(color: UIColor) {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            UIView.animateWithDuration(0.3) {
                self.view.backgroundColor = color
            }
        }
    }
    
    
    @IBAction func yellowButtonPressed(s: UIButton) {
        peerServiceManager.sendColor("yellow")
    }

    @IBAction func redButtonPressed(s: UIButton) {
        peerServiceManager.sendColor("red")
    }

    
    
    
}