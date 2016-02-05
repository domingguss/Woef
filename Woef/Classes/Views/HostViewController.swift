//
//  HostViewController.swift
//  Woef
//
//  Created by Dominggus Salampessy on 01/02/16.
//  Copyright © 2016 Dominggus Salampessy. All rights reserved.
//

import Foundation
import UIKit

class HostViewController: UIViewController, PeerServiceManagerDelegate {
    
    @IBOutlet weak var label: UILabel?
    
    let soundService = SoundService()
    let peerServiceManager = HostServiceManager()
    
    init() {
        super.init(nibName: "HostViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        self.title = "Host"
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
}