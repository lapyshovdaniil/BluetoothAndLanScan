//
//  ScanHistoryView.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import SwiftUI

struct ScanHistoryView: View {
    @Binding var selectedTab: Int
    let lanDevices: [DeviceInfo] = DeviceDatabaseManager.shared.fetchLANDevices()  // Выгрузка LAN устройств
    let bluetoothDevices: [BluetoothDevice] = DeviceDatabaseManager.shared.fetchBluetoothDevices()  // Выгрузка Bluetooth устройств
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("LAN устройства")) {
                    ForEach(lanDevices) { device in
                        VStack(alignment: .leading) {
                            Text(device.deviceName ?? "Неизвестное устройство")
                                .font(.headline)
                            Text("IP: \(device.ipAddress)")
                            if let macAddress = device.macAddress {
                                Text("MAC: \(macAddress)")
                            } else {
                                Text("MAC-адрес не указан")
                            }
                        }
                        .padding()
                    }
                }
                
                Section(header: Text("Bluetooth устройства")) {
                    ForEach(bluetoothDevices) { device in
                        VStack(alignment: .leading) {
                            Text(device.name)
                                .font(.headline)
                            Text("UUID: \(device.uuid)")
                            Text("RSSI: \(device.rssi)")
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Сканирование устройств")
        }
    }
}
