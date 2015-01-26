//
//  ViewController.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 08/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CadenceDelegate, HeartRateDelegate {
    
//    var cadenceConnector = CadenceConnector()
    var heartRateConnector = HeartRateConnector()
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var crankRevolutionsPerMinuteLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        cadenceConnector.delegate = self;
        heartRateConnector.delegate = self;
    }
    
    override func viewWillDisappear(animated: Bool) {
//        cadenceConnector.delegate = nil;
        heartRateConnector.delegate = self;
        super.viewWillDisappear(animated)
    }

    func distanceDidChange(cadence: CadenceConnector!, totalDistance : Double! ){
        dispatch_async(dispatch_get_main_queue(), {
            self.totalDistanceLabel.text = "\(totalDistance) m";
        });
    }
    
    func speedDidChange(cadence: CadenceConnector!, speed: Double!) {
        let speedString = NSString(format: "%.2f", speed)
        dispatch_async(dispatch_get_main_queue(), {
            self.currentSpeedLabel.text = "\(speedString) km/h";
        });
    }
    
    func crankFrequencyDidChange(cadence: CadenceConnector!, crankRevolutionsPerMinute : Double! ){
        let crankRevolutionsPerMinuteString = NSString(format: "%.2f", crankRevolutionsPerMinute)
        dispatch_async(dispatch_get_main_queue(), {
            self.crankRevolutionsPerMinuteLabel.text = "\(crankRevolutionsPerMinuteString) per minute";
        });
    }
    
    func heartRateDidChange(heartbeat: HeartRateConnector!, heartRate : UInt16! ){
        dispatch_async(dispatch_get_main_queue(), {
            self.heartRateLabel.text = "\(heartRate) beats per minute";
        });
        println("heartRateDidChange:\(heartRate)")
    }
}

