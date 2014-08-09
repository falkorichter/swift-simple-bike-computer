//
//  CadenceConnector.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 08/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Foundation
import CoreBluetooth

class CadenceConnector : NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    let CSC_SERVICE = CBUUID.UUIDWithString("1816")
    let CSC_MEASUREMENT  = CBUUID.UUIDWithString("2A5B")
    
    var wheel_size_ : Double
    
    var central : CBCentralManager?
    var currentPeripheral : CBPeripheral?
    
    override init(){
        wheel_size_ = 2000; // default 2000 mm wheel size
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!){
        switch (central.state){
        case .PoweredOn:
                central.scanForPeripheralsWithServices(nil, options: nil)
        default:
            println("not powered on")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        println("didDiscoverPeripheral \(peripheral)")
        if let current = currentPeripheral  {           //can we do this prettier?
            println("we´re allready connected to \(current)")
        }
        else{
            currentPeripheral = peripheral;
            central.connectPeripheral(peripheral, options: nil);
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!){
        println("didConnectPeripheral " + peripheral.name)
        
        peripheral.delegate = self
        // NOTE you might only discover/Users/falkorichter/Documents/workspaces/sensorberg/_wwdc/Simple Bike Computer/Simple Bike Computer.xcodeproj RSC service, but on this example we discover all services
        
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        if(!error) {
            for service in peripheral.services {
                if service.UUID == CSC_SERVICE {
                    peripheral.discoverCharacteristics(nil, forService: service as CBService)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if(!error){
            if service.UUID == CSC_SERVICE {
                for characteristic in service.characteristics{
                    if (characteristic as CBCharacteristic).UUID == CSC_MEASUREMENT {
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic);
                    }
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("did update value" + characteristic.value().hexPresentation())
        
        if(!error && characteristic.UUID == CSC_MEASUREMENT){
            let bytes = characteristic.value
            let measurement = characteristic.value().bikeCandenceMeasurement()
            println("cumulativeWheelRevolutions \(measurement.cumulativeWheelRevolutions) cumulativeCrankRevolutions \(measurement.cumulativeCrankRevolutions) lastCrankEventTime \(measurement.lastCrankEventTime) lastWheelEventTime \(measurement.lastWheelEventTime)")
        }
    }
}
