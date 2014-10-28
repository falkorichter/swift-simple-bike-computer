//
//  CBPeripheralManagerExtensions.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 27/10/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheralManagerState{
    func asString() -> String {
        switch self{
        case Unknown:
            return "Unknown"
        case Resetting:
            return "Unknown"
        case Unsupported:
            return "Unsupported"
        case Unauthorized:
            return "Unauthorized"
        case PoweredOff:
            return "PoweredOff"
        case PoweredOn:
            return "PoweredOn"
        }
    }
}