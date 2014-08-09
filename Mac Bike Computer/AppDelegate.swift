//
//  AppDelegate.swift
//  Mac Bike Computer
//
//  Created by Falko Richter on 09/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!

    override init() {
        println("init")
    }
    
    var cadenceConnector : CadenceConnector?
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        cadenceConnector = CadenceConnector()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

