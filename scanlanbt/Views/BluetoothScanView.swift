//
//  ContentView.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import SwiftUI

struct BluetoothScan: View {
    @Binding var selectedTab: Int
    @ObservedObject var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            VStack {
                List(bluetoothManager.discoveredDevices) { device in
                    HStack {
                        Text(device.name)
                        Spacer()
                        Text(device.uuid)
                        Spacer()
                        Text("RSSI: \(device.rssi)")
                            .foregroundColor(device.rssi < -70 ? .red : .green)
                    }
                }
                HStack {
                    Button(action: {
                        if bluetoothManager.isScanningBt {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red)
                                .frame(width: nil, height: nil)
                                .scaleEffect(x: bluetoothManager.progress, y: 1, anchor: .leading)
                                .animation(.linear(duration: 0.1), value: bluetoothManager.progress)
                            
                            Text(bluetoothManager.isScanningBt ? "Остановить сканирование" : "Начать сканирование")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(height: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Bluetooth Devices", displayMode: .inline)
        }
        .alert(item: $bluetoothManager.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
    }
}




