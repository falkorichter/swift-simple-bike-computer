//
//  AppDelegate.swift
//  Mac Simple Bike Computer
//
//  Created by Falko Richter on 16/10/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Cocoa
import CoreBluetooth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CadenceDelegate, CBPeripheralManagerDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var totalDistanceTextField: NSTextField!
    @IBOutlet weak var speedTextField: NSTextField!
    @IBOutlet weak var crankRevolutionsTextField: NSTextField!
    
    var peripheralManager:CBPeripheralManager?
    
    let hearRateChracteristic = CBMutableCharacteristic(
        type: CBUUID(string: "2A37"),
        properties: CBCharacteristicProperties.Notify,
        value: nil,
        permissions: CBAttributePermissions.Readable)
    
    override init() {
        println("init")
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    var cadenceConnector = CadenceConnector()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        cadenceConnector.delegate = self
    }
    
    func distanceDidChange(cadence: CadenceConnector!, totalDistance : Double! ){
        dispatch_async(dispatch_get_main_queue(), {
            self.totalDistanceTextField.doubleValue = totalDistance
        });
    }
    
    func speedDidChange(cadence: CadenceConnector!, speed: Double!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.speedTextField.doubleValue = speed
        });
    }
    
    func crankFrequencyDidChange(cadence: CadenceConnector!, crankRevolutionsPerMinute : Double! ){
        dispatch_async(dispatch_get_main_queue(), {
            self.crankRevolutionsTextField.doubleValue = crankRevolutionsPerMinute
        });
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(theApplication: NSApplication!) -> Bool{
        return true;
    }
    
    @IBAction func becomeHeartRateSensor(AnyObject){
        
        let heartRateService = CBMutableService(type: CBUUID(string: "180D"), primary: true)
        
        
        
        heartRateService.characteristics = [hearRateChracteristic]

        
        let infoService = CBMutableService(type: CBUUID(string: "180A"), primary: true)
        
        let infoNameCharacteristics = CBMutableCharacteristic(
            type: CBUUID(string: "2A29"),
            properties: CBCharacteristicProperties.Read,
            value: "falko".dataUsingEncoding(NSUTF8StringEncoding),
            permissions: CBAttributePermissions.Readable)
        
        infoService.characteristics = [infoNameCharacteristics]

        
        
        peripheralManager!.addService(infoService)
        peripheralManager!.addService(heartRateService)
        var advertisementData = [
            CBAdvertisementDataServiceUUIDsKey:[infoService.UUID, heartRateService.UUID],
            CBAdvertisementDataLocalNameKey : "mac of falko"
        ]
        peripheralManager!.startAdvertising(advertisementData)

        
    }
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!){
        println("state: \(peripheral.state.asString())")
        
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!){
        println("peripheralManagerDidStartAdvertising")
        
        
        var arr : [UInt32] = [1,123];
        let heartRateData = NSData(bytes: arr, length: arr.count * sizeof(UInt32))
        
        let success = peripheralManager!.updateValue(heartRateData, forCharacteristic: hearRateChracteristic, onSubscribedCentrals: nil)
        println("updated a value \(success)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!){
        println("peripheralManager:didReceiveReadRequest: \(request)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!){
        println("peripheralManager:didAddService: \(service)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!){
        println("peripheralManager:central:\(central) didSubscribeToCharacteristic:\(characteristic)")
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!){
        println("peripheralManagerIsReadyToUpdateSubscribers")
    }
    
    


}

