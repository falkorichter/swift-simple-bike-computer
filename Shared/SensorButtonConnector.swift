//
//  SensorButtonConnector.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 03/11/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Foundation
import CoreBluetooth

class SensorButtonConnector: GernericConnector {
    
    let buttonServiceUUID = CBUUID(string: "FFED")
    let buttonCharacteristicUUID = CBUUID(string: "FFE1")
    
}