//
//  HeartBeatConnector.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 26/01/15.
//  Copyright (c) 2015 Falko Richter. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol HeartRateDelegate{
    
    func heartRateDidChange(heartbeat: HeartRateConnector!, heartRate : UInt8! )
}

class HeartRateConnector : GernericConnector {
    
    var HEARTBEAT_SERVICE = CBUUID(string: "180D")
    var HEARTBEAT_MEASUREMENT = CBUUID(string: "2A37")
    
    var delegate : HeartRateDelegate?
    
    init(){
        super.init(services : [HEARTBEAT_SERVICE])
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        println("didDiscoverServices:error:\(error)")
        if(error != nil) {
            for service in peripheral.services {
                if service.UUID == HEARTBEAT_SERVICE {
                    peripheral.discoverCharacteristics([HEARTBEAT_SERVICE], forService: service as CBService)
                    println("discoverCharacteristics")
                }
            }
        }
    }
    
    
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        println("didDiscoverCharacteristicsForService:\(service) error:\(error)")
        if(error != nil){
            if service.UUID == HEARTBEAT_SERVICE {
                for characteristic in service.characteristics{
                    if (characteristic as CBCharacteristic).UUID == HEARTBEAT_MEASUREMENT {
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic);
                    }
                }
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("didUpdateValueForCharacteristic:\(characteristic) error:\(error)")
        if(error != nil && characteristic.UUID == HEARTBEAT_MEASUREMENT){
            
            var heartRate : UInt8 = 0
            characteristic.value().getBytes(&heartRate, range: NSMakeRange(1, 1))
            
            
            delegate?.heartRateDidChange(self, heartRate:heartRate)
        }
    }
}