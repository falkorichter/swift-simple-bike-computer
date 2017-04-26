//
//  AppDelegate.swift
//  Mac Simple Bike Computer
//
//  Created by Falko Richter on 16/10/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Cocoa
import CoreBluetooth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var heartBeatPeripheral: HeartRatePeripheral?
    
    var peripheralManager:CBPeripheralManager!
    
    
    override init() {
        print("init")
        super.init()
    }
    
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        heartBeatPeripheral!.stopBroadcasting()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(theApplication: NSApplication!) -> Bool{
        return true;
    }
    
    
    
    @IBAction func becomeHeartRateSensor(_: AnyObject){
        heartBeatPeripheral = HeartRatePeripheral()        
        heartBeatPeripheral!.startBroadcasting();
        
    }
}

