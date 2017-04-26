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

    func centralManagerDidUpdateState(_ central: CBCentralManager!){
        switch (central.state){
        case .poweredOn:
            central.scanForPeripherals(withServices: services, options: nil)
            print("starting scan for \(services)")
        default:
            print("not powered on")
        }
    }
    
    func centralManager(_ central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [AnyHashable: Any]!, RSSI: NSNumber!) {
        
        print("didDiscoverPeripheral \(peripheral) advertisementData: \(advertisementData)")
        
        if let current = currentPeripheral  {           //can we do this prettier?
            print("we´re allready connected to \(current)")
        }
        else{
            currentPeripheral = peripheral;
            central.connect(peripheral, options: nil);
        }
    }
    
    func centralManager(_ central: CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!){
        print("didRetrieveConnectedPeripherals peripherals:\(peripherals)")
    }
    
    func centralManager(_ central: CBCentralManager!, didFailToConnect peripheral: CBPeripheral!, error: Error!){
        print("didFailToConnectPeripheral \(peripheral) error:\(error)")
        self.currentPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: Error!){
        print("didDisconnectPeripheral \(peripheral) error:\(error)")
        self.currentPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager!, didConnect peripheral: CBPeripheral!){
        print("didConnectPeripheral " + peripheral.name!)
        peripheral.delegate = self
        peripheral.discoverServices(services)
    }


    
}
