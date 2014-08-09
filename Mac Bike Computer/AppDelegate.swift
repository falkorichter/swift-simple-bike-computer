//
//  AppDelegate.swift
//  Mac Bike Computer
//
//  Created by Falko Richter on 09/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, CadenceDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var totalDistanceTextField: NSTextField!

    override init() {
        println("init")
    }
    
    var cadenceConnector = CadenceConnector()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        cadenceConnector.delegate = self
    }
    
    func distanceDidChange(cadence: CadenceConnector!, totalDistance : Double! ){
        dispatch_async(dispatch_get_main_queue(), {
            self.totalDistanceTextField.doubleValue = totalDistance
        });
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application

    }


}

