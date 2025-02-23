//
//  ScanHistoryViewModel.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 24.02.2025.
//
import SwiftUI

class ScanHistoryViewModel: ObservableObject {
    @Published var lanDevices: [DeviceInfo] = []
    @Published var bluetoothDevices: [BluetoothDevice] = []
    
    private var deviceDatabaseManager = DeviceDatabaseManager.shared

    func loadDevices() {
        lanDevices = deviceDatabaseManager.fetchLANDevices()
        bluetoothDevices = deviceDatabaseManager.fetchBluetoothDevices()
    }
    
    func clearAllDevices() {
        deviceDatabaseManager.clearAllDevices()
        loadDevices() // Обновляем список устройств после очистки
    }
}
