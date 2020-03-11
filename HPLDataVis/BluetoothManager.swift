//
//  Bluetooth.swift
//  HPLDataVis
//
//  Created by Eric Zeiberg on 2/23/20.
//  Copyright © 2020 University of Connecticut. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {

    var dataPacket: Array<[Int]>?
    private let notificationCenter: NotificationCenter
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
         print("Central state update")
       if central.state != .poweredOn {
           print("Central is not powered on") // EAA8FEE7-EF57-C8F5-6CE2-67FEE0647A22
       } else {
           print("Central scanning for", "");
           centralManager.scanForPeripherals(withServices: [CBUUID.init(string: "FFE0")],
                                             options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
       }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // We've found it so stop scan
        self.centralManager.stopScan()

        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self

        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
              if peripheral == self.peripheral {
                  print("Connected")
                 
                  peripheral.discoverServices([CBUUID.init(string: "FFE0")])
                
              }
          }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID.init(string: "FFE0") {
                    peripheral.discoverCharacteristics([CBUUID.init(string: "FFE1")], for: service)
                }
            }
            }
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID.init(string: "FFE1") {
                    print(characteristic)
                    peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
//        let data = Data(bytes: byteArray)
//        let value = UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
//        print(data)
        if let string = String(bytes: byteArray, encoding: .utf8) {
            print(string)
            notificationCenter.post(name: Notification.Name("DataReceived"), object: nil, userInfo: ["value": string])
        } else {
            print("not a valid UTF-8 sequence")
        }
        

        
    }
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        dataPacket = [[Int]]()
    }
    

    
    public func startBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
}
