//
//  BluetoothManager.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    
    @Published var alert: AlertData?
    @Published var discoveredDevices: [BluetoothDevice] = []
    @Published var isScanningBt: Bool = false
    private var scanCompleted = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        if centralManager.state == .poweredOn {
            isScanningBt = true
            scanCompleted = false
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            showBluetoothOffAlert()
        }
    }
    
    
    func stopScanning() {
        DeviceDatabaseManager.shared.saveBluetoothDevices(discoveredDevices)
        isScanningBt = false
        centralManager.stopScan()
        
        if !scanCompleted {
            showScanCompletionAlert()
            discoveredDevices.removeAll()
        }
    }
    
    // Обновляем список каждые 3 секунды
    func updateDevices() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.objectWillChange.send() 
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Ошибка при обнаружении сервисов: \(error.localizedDescription)")
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Ошибка при обнаружении характеристик: \(error.localizedDescription)")
            return
        }
        for characteristic in service.characteristics ?? [] {
            peripheral.readValue(for: characteristic)
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // Сканирование запускается только после нажатия на кнопку
            break
        case .poweredOff:
            print("Bluetooth выключен")
        default:
            break
        }
    }
    
    // Сканирование
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        let device = BluetoothDevice(name: peripheral.name ?? "Unknown device", uuid: peripheral.identifier.uuidString, rssi: rssi.intValue)
        // Проверка, есть ли уже устройство в списке
        if !discoveredDevices.contains(where: { $0.uuid == device.uuid }) {
            discoveredDevices.append(device)
        }
        centralManager.connect(peripheral, options: nil)
    }
    // Успешное подключение
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    // Метод для показа алерта по завершении сканирования
    private func showScanCompletionAlert() {
        let deviceCount = discoveredDevices.count
        scanCompleted = true // Устанавливаем флаг завершения сканирования
        self.alert = AlertData(
            title: "Сканирование завершено!",
            message: "Найдено \(deviceCount) Bluetooth устройств."
        )
    }
    // Метод для показа алерта, если Bluetooth выключен
    private func showBluetoothOffAlert() {
        self.alert = AlertData(
            title: "Bluetooth выключен",
            message: "Включите Bluetooth для выполнения сканирования."
        )
    }
}

