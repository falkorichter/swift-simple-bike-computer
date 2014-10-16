//
//  AppDelegate.swift
//  Mac Simple Bike Computer
//
//  Created by Falko Richter on 16/10/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CadenceDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var totalDistanceTextField: NSTextField!
    @IBOutlet weak var speedTextField: NSTextField!
    @IBOutlet weak var crankRevolutionsTextField: NSTextField!
    
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
    
    func speedDidChange(cadence: CadenceConnector!, speed: Double!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.speedTextField.doubleValue = speed
        });
    }
    
    func crankFrequencyDidChange(cadence: CadenceConnector!, crankRevolutionsPerMinute : Double! ){
        dispatch_async(dispatch_get_main_queue(), {
            self.crankRevolutionsTextField.doubleValue = crankRevolutionsPerMinute
        });
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
        
    }
    


}

