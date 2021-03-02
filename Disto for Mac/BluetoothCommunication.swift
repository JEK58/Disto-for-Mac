//
//  BluetoothCommunication.swift
//  XCDisplayWatch Extension
//
//  Created by Stefan on 17.10.17.
//  Copyright © 2017 Hanshans. All rights reserved.
//  Modified by JEK58

import CoreBluetooth

protocol BluetoothCommunicationDelegate: class {
    func bluetoothDidUpdateState()//Status hat sich geändert
    func bluetoothIsPoweredOn()//Bluetooth ist verfügbar
    func deviceDidConnect()//Verbunden
    func deviceDidDisconnect()//wurde getrennt
    func deviceHasNewData(_ data: Float)//Neue Daten zurückgeben
}

class BluetoothCommunication: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    //Die Objekte werden nur hier gebraucht, daher privat
    private var centralManager: CBCentralManager!
    private weak var delegate: BluetoothCommunicationDelegate?
    private var peripheral: CBPeripheral!
    private var writeCharacteristic: CBCharacteristic!
    private let distoCharateristicDistance = "3AB10101-F831-4395-B29D-570977D5BF94"
    private let distoCharateristicCommand = "3AB10109-F831-4395-B29D-570977D5BF94"
    private var dataBuffer = [Character]()

    func start(withDelegate delegate: BluetoothCommunicationDelegate) {
        if self.centralManager == nil {
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        self.delegate = delegate
    }

    func startScanning() {
        print("Start Scanning")
        if self.centralManager.state == .poweredOn {
            let string = "3ab10100-f831-4395-b29d-570977d5bf94"
            self.centralManager.scanForPeripherals(withServices: [CBUUID(string: string)],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            self.centralManager.scanForPeripherals(withServices: nil,
                                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }

      }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.bluetoothDidUpdateState()

        switch central.state {
        case .unsupported:
            break
        case .poweredOff:
            if self.peripheral != nil {
                centralManager( central, didDisconnectPeripheral: self.peripheral, error: nil)
             }
        case .unauthorized:
            break
        case .poweredOn:
            delegate?.bluetoothIsPoweredOn()
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        delegate?.deviceDidDisconnect()
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        self.peripheral.delegate = self
        central.stopScan()
        self.connect()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral.discoverServices(nil)
        delegate?.deviceDidConnect()
    }

    /*
     Original function
     func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
         for service in peripheral.services! as [CBService] {
             if error == nil {
                 switch service.uuid.uuidString {
                 case "3AB10100-F831-4395-B29D-570977D5BF94":
                     peripheral.discoverCharacteristics(nil, for: service)
                     self.writeCharacteristic = nil
                 default:
                     break
                 }
             }
         }
     }
     */

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! as [CBService] where error == nil {
                switch service.uuid.uuidString {
                case "3AB10100-F831-4395-B29D-570977D5BF94":
                    peripheral.discoverCharacteristics(nil, for: service)
                    self.writeCharacteristic = nil
                default:
                    break
                }
            }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error == nil {

            for characteristic in service.characteristics! as [CBCharacteristic] {
                switch characteristic.uuid.uuidString {
                case distoCharateristicDistance://Data Transfer
                    peripheral.setNotifyValue(true, for: characteristic)
                case distoCharateristicCommand: //Navigation Characteristic
                    self.writeCharacteristic = characteristic
                default:
                    break
                }
             }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            switch characteristic.uuid.uuidString {
            case distoCharateristicDistance:
                self.update(deviceData: characteristic.value!)

            default:
                break
            }
        }
    }

    func connect() {
        if self.peripheral != nil {
            let state = self.peripheral.state

            switch state {
            case .disconnected:
                self.centralManager.connect(self.peripheral, options: nil)
            case .connecting:
                break
            case .connected:
                break
            case .disconnecting:
                break
            @unknown default:
                fatalError()
            }
        }
    }
     // Modified
     func writeByte(data: UInt8) {
        let newData = NSMutableData(bytes: [data], length: 1)
        guard peripheral != nil else {
            print("*** Peripheral is nil ***")
            return
        }
        self.peripheral!.writeValue(newData as Data, for: self.writeCharacteristic!,
            type: CBCharacteristicWriteType.withoutResponse)
    }

    func update(deviceData: Data) {

        var fvalue: Float = 0
        (deviceData as NSData).getBytes(&fvalue, length: 4)

        delegate?.deviceHasNewData(fvalue)
    }

}
