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

class CadenceConnector : GernericConnector {
    
    var CSC_SERVICE = CBUUID(string: "1816")
    var CSC_MEASUREMENT  = CBUUID(string: "2A5B")
    
    let wheel_size : Double = 2.17
    var delegate : CadenceDelegate?
    
    init(){
        super.init(services : [CSC_SERVICE])
    }

    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        if(error != nil) {
            for service in peripheral.services {
                if service.UUID == CSC_SERVICE {
                    peripheral.discoverCharacteristics([CSC_MEASUREMENT], forService: service as CBService)
                }
            }
        }
    }
    

    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if(error != nil){
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
    var lastCrankCount : UInt16 = UInt16.max
    var lastWheelCount : UInt32?
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if(error != nil && characteristic.UUID == CSC_MEASUREMENT){
            
            let measurement = characteristic.value().bikeCandenceMeasurement()
            println("cumulativeWheelRevolutions \(measurement.cumulativeWheelRevolutions) cumulativeCrankRevolutions \(measurement.cumulativeCrankRevolutions) lastCrankEventTime \(measurement.lastCrankEventTime) lastWheelEventTime \(measurement.lastWheelEventTime)")
            
            var numberOfCrankRevolutions: Int?
            
            if lastCrankCount != UInt16.max {
                numberOfCrankRevolutions = measurement.cumulativeCrankRevolutions - lastCrankCount
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
