//
//  CBCharacteristic+value.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 16/10/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import CoreBluetooth

extension CBCharacteristic {
    func value() -> NSData {
        return value
    }
}