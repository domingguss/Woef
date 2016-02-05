//
//  SoundDataSource.swift
//  Woef
//
//  Created by Dominggus Salampessy on 04/02/16.
//  Copyright © 2016 Dominggus Salampessy. All rights reserved.
//

import Foundation
import UIKit

class SoundDataSource: NSObject, UITableViewDataSource {
    
    var sounds: [NSURL]
    var names: [String]
    
    override init() {
        self.sounds = NSBundle.mainBundle().URLsForResourcesWithExtension("mp3", subdirectory: "MP3")!
        self.names = self.sounds.map({ ($0.pathComponents?.last)! })
        super.init()
    }

    
    func fileURLforFileName(name: String) -> NSURL? {
        
        if let index = names.indexOf(name) {
            return sounds[index]
        }
        return nil
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SoundCell") else {
            NSLog("cell not found with identifier")
            return UITableViewCell()
        }
        
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        
        cell.textLabel!.text = names[indexPath.row]
        cell.detailTextLabel!.text = nil
        return cell
    }
    
}

