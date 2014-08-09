//
//  ViewController.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 08/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CadenceDelegate {
    
    var cadenceConnector = CadenceConnector()
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cadenceConnector.delegate = self;
    }
    
    override func viewWillDisappear(animated: Bool) {
        cadenceConnector.delegate = nil;
        super.viewWillDisappear(animated)
    }

    func distanceDidChange(cadence: CadenceConnector!, totalDistance : Double! ){
        totalDistanceLabel.text = "\(totalDistance)"
    }
}

