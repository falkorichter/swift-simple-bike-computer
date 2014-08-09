//
//  NSDataExtensions.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 09/08/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Foundation


extension NSData {
    
    func bikeCandenceMeasurement() ->
        (cumulativeWheelRevolutions:UInt32,
        lastWheelEventTime:Double,
        cumulativeCrankRevolutions:UInt16,
        lastCrankEventTime:Double){
            var currentpos = 1;
            var cumulativeWheelRevolutions : UInt32 = 0
            getBytes(&cumulativeWheelRevolutions, range: NSMakeRange(currentpos, 4))
            currentpos += 4
            
            var lastWheelEventReadValue : UInt16 = 0
            getBytes(&lastWheelEventReadValue, range: NSMakeRange(currentpos, 2))
            currentpos += 2
            
            var cumulativeCrankRevolutions : UInt16 = 0
            getBytes(&cumulativeCrankRevolutions, range: NSMakeRange(currentpos, 2))
            currentpos += 2
            
            var lastCrankEventReadValue : UInt16 = 0
            getBytes(&lastCrankEventReadValue, range: NSMakeRange(currentpos, 2))
            
            let lastCrankEventTime = Double(lastCrankEventReadValue) / 1024
            let lastWheelEventTime = Double(lastWheelEventReadValue) / 1024
            
            return (cumulativeWheelRevolutions, lastWheelEventTime , cumulativeCrankRevolutions, lastCrankEventTime )
    }
    
    func hexPresentation() -> String {
        var byteArray = [UInt8](count: self.length, repeatedValue: 0x0)
        
        getBytes(&byteArray, length:self.length)
        
        var hexBits = "" as String
        for value in byteArray {
            hexBits += NSString(format:"%2X", value) as String
        }
        
        return hexBits
    }
}
