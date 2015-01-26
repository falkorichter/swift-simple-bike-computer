//
//  HeartBeatPreipheral.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 28/10/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Foundation
import CoreBluetooth

class HeartRatePeripheral: NSObject, CBPeripheralManagerDelegate {
    
    let hearRateChracteristic = CBMutableCharacteristic(
        type: CBUUID(string: "2A37"),
        properties: CBCharacteristicProperties.Notify,
        value: nil,
        permissions: CBAttributePermissions.Readable)
    
    let infoNameCharacteristics = CBMutableCharacteristic(
        type: CBUUID(string: "2A29"),
        properties: CBCharacteristicProperties.Read,
        value: "falko".dataUsingEncoding(NSUTF8StringEncoding),
        permissions: CBAttributePermissions.Readable)
    
    let infoService = CBMutableService(
        type: CBUUID(string: "180A"),
        primary: true)
    
    let heartRateService = CBMutableService(
        type: CBUUID(string: "180D"),
        primary: true)
    
    var peripheralManager:CBPeripheralManager!
    
    var counter:UInt8 = 1
    var prefix:UInt8 = 1
    
    var timer:NSTimer?

    
    override init(){
        super.init()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func stopBroadcasting(){
        if (peripheralManager.isAdvertising){
            peripheralManager.stopAdvertising()
        }
        peripheralManager.removeAllServices()
    }
    
    func startBroadcasting(){
        heartRateService.characteristics = [hearRateChracteristic]
        infoService.characteristics = [infoNameCharacteristics]
        
        peripheralManager.addService(infoService)
        peripheralManager.addService(heartRateService)
        var advertisementData = [
            CBAdvertisementDataServiceUUIDsKey:[infoService.UUID, heartRateService.UUID],
            CBAdvertisementDataLocalNameKey : "mac of falko"
        ]
        peripheralManager.startAdvertising(advertisementData)
    }
   
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!){
        println("peripheralManagerDidStartAdvertising")
    }
    
    
    func update() {
        if (counter == 250){
            counter = 1
        }
        
        var arr : [UInt8] = [prefix, counter++];
        let heartRateData = NSData(bytes: arr, length: arr.count * sizeof(UInt32))
        
        let success = peripheralManager!.updateValue(heartRateData, forCharacteristic: hearRateChracteristic, onSubscribedCentrals: nil)
        println("updated a value \(success) with value \(arr[1])")
    }
    
    //just for logging
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!){
        println("peripheralManagerDidUpdateState: \(peripheral.state.asString())")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!){
        println("peripheralManager:\(peripheral) didReceiveReadRequest: \(request)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!){
        println("peripheralManager:\(peripheral) didAddService: \(service)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!){
        println("peripheralManager:central:\(central) didSubscribeToCharacteristic:\(characteristic)")
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!){
        println("peripheralManagerIsReadyToUpdateSubscribers:\(peripheral)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!){
        println("peripheralManager:\(peripheral) central:\(central) didUnsubscribeFromCharacteristic:\(characteristic)")
        timer!.invalidate()
    }
    
}
