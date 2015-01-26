//
//  GernericConnector.swift
//  Simple Bike Computer
//
//  Created by Falko Richter on 03/11/14.
//  Copyright (c) 2014 Falko Richter. All rights reserved.
//

import Foundation
import CoreBluetooth

class GernericConnector: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {

    var central : CBCentralManager!
    var currentPeripheral : CBPeripheral?
    var services : [CBUUID]!
    
    init(services: [CBUUID]){
        super.init()
        self.services = services
        self.central = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(central: CBCentralManager!){
        switch (central.state){
        case .PoweredOn:
            central.scanForPeripheralsWithServices(services, options: nil)
            println("starting scan for \(services)")
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
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!){
        println("didConnectPeripheral " + peripheral.name)
        peripheral.delegate = self
        peripheral.discoverServices(services)
    }


    
}