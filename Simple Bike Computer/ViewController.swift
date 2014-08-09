//
//  ViewController.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 08/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    var cadenceConnector : CadenceConnector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cadenceConnector = CadenceConnector()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

