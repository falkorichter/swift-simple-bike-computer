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
    
    func heartRateDidChange(heartbeat: HeartRateConnector!, heartRate : UInt16! )
}

class HeartRateConnector : GernericConnector {
    
    var HEARTBEAT_SERVICE = CBUUID(string: "2A37")
    
    var delegate : HeartRateDelegate?
    
    init(){
        super.init(services : [HEARTBEAT_SERVICE])
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        if(error != nil) {
            for service in peripheral.services {
                if service.UUID == HEARTBEAT_SERVICE {
                    peripheral.discoverCharacteristics([HEARTBEAT_SERVICE], forService: service as CBService)
                }
            }
        }
    }
    
    
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if(error != nil){
            if service.UUID == HEARTBEAT_SERVICE {
                for characteristic in service.characteristics{
                    if (characteristic as CBCharacteristic).UUID == HEARTBEAT_SERVICE {
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic);
                    }
                }
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if(error != nil && characteristic.UUID == HEARTBEAT_SERVICE){
            
            var heartRate : UInt16 = 0
            characteristic.value().getBytes(&heartRate, range: NSMakeRange(0, 2))
            
            
            delegate?.heartRateDidChange(self, heartRate:heartRate)
        }
    }
}