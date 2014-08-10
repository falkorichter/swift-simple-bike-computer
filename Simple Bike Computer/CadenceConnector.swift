//
//  CadenceConnector.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 08/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol CadenceDelegate{
    
    func distanceDidChange(cadence: CadenceConnector!, totalDistance : Double! )
    
    func speedDidChange(cadence: CadenceConnector!, speed : Double! )
    
    func crankFrequencyDidChange(cadence: CadenceConnector!, crankRevolutionsPerMinute : Double! )
}

class CadenceConnector : NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    let CSC_SERVICE = CBUUID.UUIDWithString("1816")
    let CSC_MEASUREMENT  = CBUUID.UUIDWithString("2A5B")
    
    var wheel_size : Double
    
    var central : CBCentralManager?
    var currentPeripheral : CBPeripheral?
    
    var delegate : CadenceDelegate?
    
    override init(){
        wheel_size = 2.17;
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
    var lastWheelCount : UInt32?
    
    
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if(!error && characteristic.UUID == CSC_MEASUREMENT){
            
            let measurement = characteristic.value.bikeCandenceMeasurement()
            println("cumulativeWheelRevolutions \(measurement.cumulativeWheelRevolutions) cumulativeCrankRevolutions \(measurement.cumulativeCrankRevolutions) lastCrankEventTime \(measurement.lastCrankEventTime) lastWheelEventTime \(measurement.lastWheelEventTime)")
            
            var numberOfCrankRevolutions: Int?
            
            if let crankCount = lastCrankCount {
                numberOfCrankRevolutions = measurement.cumulativeCrankRevolutions - crankCount
                println("numberOfCrankRevolutions: \(numberOfCrankRevolutions)")
            }
            
            var numberOfWheelRevolutions: Int?
            
            if let wheelRevolutions = lastWheelCount {
                numberOfWheelRevolutions = measurement.cumulativeWheelRevolutions - wheelRevolutions
            }

            
            delegate?.distanceDidChange(self, totalDistance: wheel_size * Double(measurement.cumulativeWheelRevolutions))
            
            if lastCrankTime != measurement.lastCrankEventTime {
                
                if let last = lastCrankTime{
                    var timeDiff = measurement.lastCrankEventTime - last
                    if numberOfCrankRevolutions > 0 {
                        timeDiff = timeDiff / Double(numberOfCrankRevolutions!)
                    }
                    
                    let crankRevPerSecond = 1 / timeDiff
                    let crankRevPerMinute = 60 * crankRevPerSecond
                    
                    self.delegate?.crankFrequencyDidChange(self, crankRevolutionsPerMinute: crankRevPerMinute)
                    
                    print(" timediff crank :\(timeDiff)")
                }
                lastCrankTime = measurement.lastCrankEventTime
            }
            print("\n")
            
            if lastWheelTime != measurement.lastWheelEventTime {
                if let lastWheel = lastWheelTime{
                    var timeDiff = measurement.lastWheelEventTime - lastWheel
                    
                    if(numberOfWheelRevolutions > 0){
                        timeDiff = timeDiff / Double(numberOfWheelRevolutions!)
                    }
                    
                    println("timediff wheel :\(timeDiff)")
                    
                    let speedInMetersPerSecond = wheel_size / timeDiff
                    let speedInKilometersPerHour = speedInMetersPerSecond * 3.6
                    
                    delegate?.speedDidChange(self, speed: speedInKilometersPerHour)
                }
                lastWheelTime = measurement.lastWheelEventTime
            }
            
            lastCrankCount = measurement.cumulativeCrankRevolutions
            lastWheelCount = measurement.cumulativeWheelRevolutions
            
        }
    }
}
