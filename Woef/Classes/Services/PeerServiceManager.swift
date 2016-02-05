//
//  ColorServiceManager.swift
//  ConnectedColors
//
//  Created by Ralf Ebert on 28/04/15.
//  Copyright (c) 2015 Ralf Ebert. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol PeerServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : PeerServiceManager, connectedDevices: [String])
    func receivedSoundName(manager : PeerServiceManager, soundName: String)
    func receivedFile(manager : PeerServiceManager, fileURL: NSURL)
    func setIndex(manager : PeerServiceManager, index: Int)
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

internal class PeerServiceManager : NSObject {
    
    let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    var hostPeerId: MCPeerID?
    
    let myServiceType = "PeerServiceWoef"
    
    lazy var serviceAdvertiser : MCNearbyServiceAdvertiser = {
        let advertiser = MCNearbyServiceAdvertiser(peer: self.myPeerId, discoveryInfo: nil, serviceType: self.myServiceType)
        advertiser.delegate = self
        return advertiser
    }()
    
    lazy var serviceBrowser : MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: self.myServiceType)
        browser.delegate = self
        return browser
    }()
    
    lazy var session: MCSession = {
        let s = MCSession(peer: self.myPeerId)
        s.delegate = self
        return s
    }()

    var delegate : PeerServiceManagerDelegate?

    override init() {
        super.init()
        
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    
    func sendSound(soundName: String) {
        NSLog("%@", "sendSoundName: \(soundName)")
        
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                let data = "sound:" + soundName
                try self.session.sendData(data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                NSLog("%@", "\(error)")
            }
        }
    }
    
    func sendFile(fileURL: NSURL) {
        NSLog("%@", "sendFile: \(fileURL)")
        if session.connectedPeers.count > 0 {
            if let host = hostPeerId {
                self.session.sendResourceAtURL(fileURL, withName: "record", toPeer: host, withCompletionHandler: { (error) -> Void in
                    if let e = error {
                        print(e)
                    }
                })
            }
        }
    }
    
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
}




extension PeerServiceManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("'\(peerID.displayName)' didChangeState: \(state.stringValue())")
        
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
        
        // send index
        if (state == .Connected) {
            var error : NSError?
            do {
                let index = session.connectedPeers.indexOf(peerID)! + 1,
                    data = "index:" + String(index)
                try self.session.sendData(data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                NSLog("%@", "\(error)")
            }
            
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("didReceiveData: \(data.length) bytes")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
        let comps = str.characters.split{$0 == ":"}.map{String($0)}
        guard comps.count == 2 else {
            return
        }
        
        
        switch(comps[0]) {
        case "sound":
            self.delegate?.receivedSoundName(self, soundName: comps[1])
            
        case "index":
            hostPeerId = peerID
            self.delegate?.setIndex(self, index: Int(comps[1])!)
            
        default:
            break   
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
        
        self.delegate?.receivedFile(self, fileURL: localURL)
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        NSLog("didReceiveCertificate")
        certificateHandler(true)
    }
    
}


extension PeerServiceManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension PeerServiceManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        invitationHandler(true, self.session)
    }
}



