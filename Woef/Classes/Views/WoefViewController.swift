//
//  File.swift
//  Woef
//
//  Created by Dominggus Salampessy on 04/02/16.
//  Copyright © 2016 Dominggus Salampessy. All rights reserved.
//

import Foundation
import UIKit


class WoefViewController: UIViewController, UITableViewDelegate, PeerServiceManagerDelegate, RecorderDelegate {
    
    var isHosting = false {
        didSet {
            if isHosting {
                peerService.serviceAdvertiser.startAdvertisingPeer()
                peerService.serviceBrowser.stopBrowsingForPeers()
                self.navigationItem.leftBarButtonItem?.title = "stop hosting"
                
                UIApplication.sharedApplication().idleTimerDisabled = true
                SoundService.sharedInstance.startLoopingEmpty()

            } else {
                peerService.serviceAdvertiser.stopAdvertisingPeer()
                peerService.serviceBrowser.startBrowsingForPeers()
                self.navigationItem.leftBarButtonItem?.title = "start hosting"
                
                UIApplication.sharedApplication().idleTimerDisabled = true
                SoundService.sharedInstance.stopLoopingEmpty()
            }
        }
    }
    private var isMuted = true {
        didSet {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: isMuted ? "sound_off" : "sound_on")
            if (isMuted) {
                SoundService.sharedInstance.player?.stop()
            }
        }
    }
    private var soundDataSource = SoundDataSource()
    var peerService = PeerServiceManager()
    private var recordIndex = 0
    
    var recordURL: NSURL?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Woef"
        
        peerService.delegate = self
        
        RecorderService.sharedInstance.delegate = self
        
        self.tableView.registerNib(UINib(nibName: "SoundCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SoundCell")
        self.tableView.dataSource = soundDataSource
        self.tableView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "sound_off"), style: .Plain, target: self, action: "soundButtonPressed:")
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(title: "reconnect", style: .Plain, target: self, action: "reconnectButtonPressed:"))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "start hosting", style: UIBarButtonItemStyle.Plain, target: self, action: "hostButtonPressed:")
        
        self.recordButton.layer.cornerRadius = self.recordButton.bounds.size.width / 2
        self.recordButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.recordButton.layer.borderWidth = 2.0
        
        self.statusLabel.text = "status: aont NIXEE"
    }
    
    func hostButtonPressed(sender: UIBarButtonItem) {
        isHosting = !isHosting
    }
    
    
    func reconnectButtonPressed(sender: UIBarButtonItem) {
        if isHosting {
            peerService.serviceAdvertiser.startAdvertisingPeer()
            peerService.serviceBrowser.stopBrowsingForPeers()
            self.navigationItem.leftBarButtonItem?.title = "stop"
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            SoundService.sharedInstance.startLoopingEmpty()
            
        } else {
            peerService.serviceAdvertiser.stopAdvertisingPeer()
            peerService.serviceBrowser.startBrowsingForPeers()
            self.navigationItem.leftBarButtonItem?.title = "start"
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            SoundService.sharedInstance.stopLoopingEmpty()
        }
    }
    
    
    func soundButtonPressed(sender: UIBarButtonItem) {
        isMuted = !isMuted
        print("soundButtonPressed --> \(isMuted)")
    }
    
    
    // tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let fileURL = soundDataSource.sounds[indexPath.row]
        
        if !isMuted {
            SoundService.sharedInstance.playSound(fileURL)
        }
        
        guard let fileName = fileURL.pathComponents?.last else {
            return
        }
        peerService.sendSound(fileName)
    }
    
    
    // peer manager service 
    
    func connectedDevicesChanged(manager: PeerServiceManager, connectedDevices: [String]) {
        dispatch_async(dispatch_get_main_queue(), {
            print("connectedDevices: \(connectedDevices)")
            if self.isHosting {
                self.statusLabel.text = "status: aont HOSTEN veur \(connectedDevices.count) aandere"
                self.view.backgroundColor = UIColor(red: 88/255, green: 148/255, blue: 206/255, alpha: 1.0)
            } else {
                
                if (connectedDevices.count == 0) {
                    
                }
            }
            
            self.navigationItem.leftBarButtonItem?.enabled = self.isHosting || (connectedDevices.count == 0)
        })
    }
    
    func receivedSoundName(manager: PeerServiceManager, soundName: String) {
        
        guard !isMuted else {
            return
        }
        
        if let fileURL = soundDataSource.fileURLforFileName(soundName) {
            SoundService.sharedInstance.playSound(fileURL)
        }
    }
    
    func receivedFile(manager: PeerServiceManager, fileURL: NSURL) {
        guard !isMuted else {
            return
        }
        
        print( "received file : \(fileURL)")
        SoundService.sharedInstance.playSound(fileURL)
    }
    
    
    
    
    
    func setIndex(manager: PeerServiceManager, index: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            if !self.isHosting {
                self.statusLabel.text = "status: gejoined, meej \(manager.session.connectedPeers.count) aandere"
                self.view.backgroundColor = UIColor(red: 37/255, green: 211/255, blue: 77/255, alpha: 1.0)
            }
        })
    }
    
    
    @IBAction func recordButtonDown(sender: UIButton) {
        
        sender.alpha = 1
        UIView.animateWithDuration(0.3, delay: 0, options: [UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: {
            sender.backgroundColor = UIColor(red: 37/255, green: 211/255, blue: 77/255, alpha: 1.0)
        }, completion: nil)
        
        let uniqueFileName = String(NSDate().timeIntervalSince1970)
        let documentDirectoryURL =  try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        self.recordURL = documentDirectoryURL.URLByAppendingPathComponent(uniqueFileName)
        
        RecorderService.sharedInstance.recordToFile(self.recordURL!)
    }

    @IBAction func recordButtonUp(sender: UIButton) {
        print("up")
        
        sender.backgroundColor = UIColor.redColor()
        
        sender.layer.removeAllAnimations()
        sender.alpha = 1
        
        RecorderService.sharedInstance.stop()
        
        print("play:")
        if let url = RecorderService.sharedInstance.url {
            peerService.sendFile(url)
            
            if !isMuted {
                SoundService.sharedInstance.playSound(url)
            }
        }
    }
    
    
}