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
    
    func heartRateDidChange(_ heartbeat: HeartRateConnector!, heartRate : UInt8! )
}

class HeartRateConnector : GernericConnector {
    
    var HEARTBEAT_SERVICE = CBUUID(string: "180D")
    var HEARTBEAT_MEASUREMENT = CBUUID(string: "2A37")
    
    var delegate : HeartRateDelegate?
    
    init(){
        super.init(services : [HEARTBEAT_SERVICE])
    }
    
    func peripheral(_ peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        print("didDiscoverServices:error:\(error)")
        if(error != nil) {
            for service in peripheral.services! {
                if service.uuid == HEARTBEAT_SERVICE {
                    peripheral.discoverCharacteristics([HEARTBEAT_SERVICE], for: service as CBService)
                    print("discoverCharacteristics")
                }
            }
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        print("didDiscoverCharacteristicsForService:\(service) error:\(error)")
        if(error != nil){
            if service.uuid == HEARTBEAT_SERVICE {
                for characteristic in service.characteristics!{
                    if (characteristic as CBCharacteristic).uuid == HEARTBEAT_MEASUREMENT {
                        peripheral.setNotifyValue(true, for: characteristic as CBCharacteristic);
                    }
                }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        print("didUpdateValueForCharacteristic:\(characteristic) error:\(error)")
        if(error != nil && characteristic.uuid == HEARTBEAT_MEASUREMENT){
            
            var heartRate : UInt8 = 0
            (characteristic.value() as NSData).getBytes(&heartRate, range: NSMakeRange(1, 1))
            
            
            delegate?.heartRateDidChange(self, heartRate:heartRate)
        }
    }
}
