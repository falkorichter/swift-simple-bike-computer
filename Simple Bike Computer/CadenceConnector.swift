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
            let services = [CSC_SERVICE]
                central.scanForPeripheralsWithServices(services, options: nil)
        default:
            println("not powered on")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        println("didDiscoverPeripheral \(peripheral) advertisementData: \(advertisementData)")
        
        let advertisementData = advertisementData["kCBAdvDataManufacturerData"]
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
        
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        if(!error) {
            var found = false
            for service in peripheral.services {
                if service.UUID == CSC_SERVICE {
                    found = true
                    peripheral.discoverCharacteristics(nil, forService: service as CBService)
                }
            }
            if !found {
                central?.cancelPeripheralConnection(peripheral)
            }
        }
    }
    
    func centralManager(central: CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!){
       println("didRetrieveConnectedPeripherals peripherals:\(peripherals)")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!){
        println("didFailToConnectPeripheral \(peripheral) error:\(error)")
        self.currentPeripheral = nil
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!){
        println("didDisconnectPeripheral \(peripheral) error:\(error)")
        self.currentPeripheral = nil
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
    
    var lastCrankTime : Double?
    var lastWheelTime : Double?
    var lastCrankCount : UInt16?
    
    let startTime = NSDate()
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if(!error && characteristic.UUID == CSC_MEASUREMENT){
            
            let measurement = characteristic.value().bikeCandenceMeasurement()
            println("cumulativeWheelRevolutions \(measurement.cumulativeWheelRevolutions) cumulativeCrankRevolutions \(measurement.cumulativeCrankRevolutions) lastCrankEventTime \(measurement.lastCrankEventTime) lastWheelEventTime \(measurement.lastWheelEventTime)")
            
            var numberOfCrankRevolutions: Int?
            
            if let crankCount = lastCrankCount {
                numberOfCrankRevolutions = measurement.cumulativeCrankRevolutions - crankCount
                println("numberOfCrankRevolutions: \(numberOfCrankRevolutions)")
            }

            let timeSinceStart = NSDate().timeIntervalSinceDate(startTime)
            print("time since start: \(timeSinceStart)")

            
            if lastCrankTime != measurement.lastCrankEventTime {
                
                let timeDiffToCrankTime = measurement.lastCrankEventTime
                print(" crank diff to start: \(timeDiffToCrankTime)")

                
                if let last = lastCrankTime{
                    var timeDiff = measurement.lastCrankEventTime - last
                    if numberOfCrankRevolutions > 0 {
                        timeDiff = timeDiff / Double(numberOfCrankRevolutions!)
                    }
                    
                    print(" timediff crank :\(timeDiff)")
                }
                lastCrankTime = measurement.lastCrankEventTime
            }
            print("\n")
            
            if lastWheelTime != measurement.lastWheelEventTime {
                if let lastWheel = lastWheelTime{
                    let timeDiff = measurement.lastWheelEventTime - lastWheel
                    println("timediff wheel :\(timeDiff)")
                }
                lastWheelTime = measurement.lastWheelEventTime
            }
            
            lastCrankCount = measurement.cumulativeCrankRevolutions
            
        }
    }
}
