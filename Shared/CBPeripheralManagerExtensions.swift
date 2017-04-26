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
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Unknown"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "PoweredOff"
        case .poweredOn:
            return "PoweredOn"
        }
    }
}
