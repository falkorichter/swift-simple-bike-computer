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
        properties: CBCharacteristicProperties.notify,
        value: nil,
        permissions: CBAttributePermissions.readable)
    
    let infoNameCharacteristics = CBMutableCharacteristic(
        type: CBUUID(string: "2A29"),
        properties: CBCharacteristicProperties.read,
        value: "falko".data(using: String.Encoding.utf8),
        permissions: CBAttributePermissions.readable)
    
    let infoService = CBMutableService(
        type: CBUUID(string: "180A"),
        primary: true)
    
    let heartRateService = CBMutableService(
        type: CBUUID(string: "180D"),
        primary: true)
    
    var peripheralManager:CBPeripheralManager!
    
    var counter:UInt8 = 1
    var prefix:UInt8 = 1
    
    var timer:Timer?

    
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
        
        peripheralManager.add(infoService)
        peripheralManager.add(heartRateService)
        let advertisementData = [
            CBAdvertisementDataServiceUUIDsKey:[infoService.uuid, heartRateService.uuid],
            CBAdvertisementDataLocalNameKey : "mac of falko"
        ] as [String : Any]
        peripheralManager.startAdvertising(advertisementData)
    }
   
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager!, error: Error!){
        print("peripheralManagerDidStartAdvertising")
    }
    
    
    func update() {
        if (counter == 250){
            counter = 1
        } else {
            counter += 1
        }
        
        var arr : [UInt8] = [prefix, counter];
        let heartRateData = Data(bytes: UnsafePointer<UInt8>(arr), count: arr.count * MemoryLayout<UInt32>.size)
        
        let success = peripheralManager!.updateValue(heartRateData, for: hearRateChracteristic, onSubscribedCentrals: nil)
        print("updated a value \(success) with value \(arr[1])")
    }
    
    //just for logging
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager!){
        print("peripheralManagerDidUpdateState: \(peripheral.state.asString())")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager!, didReceiveRead request: CBATTRequest!){
        print("peripheralManager:\(peripheral) didReceiveReadRequest: \(request)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager!, didAdd service: CBService!, error: Error!){
        print("peripheralManager:\(peripheral) didAddService: \(service)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeTo characteristic: CBCharacteristic!){
        print("peripheralManager:central:\(central) didSubscribeToCharacteristic:\(characteristic)")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HeartRatePeripheral.update), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager!){
        print("peripheralManagerIsReadyToUpdateSubscribers:\(peripheral)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFrom characteristic: CBCharacteristic!){
        print("peripheralManager:\(peripheral) central:\(central) didUnsubscribeFromCharacteristic:\(characteristic)")
        timer!.invalidate()
    }
    
}
