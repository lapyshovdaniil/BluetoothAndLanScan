//
//  Untitled.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import SwiftUI

struct LANScanView: View {
    @Binding var selectedTab: Int
    @StateObject private var networkScanner = NetworkScanner()
    
    var body: some View {
        NavigationView {
            VStack {
                List(networkScanner.devices) { device in
                    HStack {
                        Text(device.ipAddress)
                        Spacer()
                        Text(device.deviceName ?? "Неизвестное устройство")
                        Spacer()
                        if let macAddress = device.macAddress {
                            Text("MAC: \(macAddress)")
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        if networkScanner.isScanningLan {
                            networkScanner.stopScan()
                        } else {
                            networkScanner.startScan()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green)
                            
                            if networkScanner.isConnectedToNetwork {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red)
                                    .frame(width: nil, height: nil)
                                    .scaleEffect(x: networkScanner.progress, y: 1, anchor: .leading)
                                    .animation(.linear(duration: 0.1), value: networkScanner.progress)
                            }
                            Text(networkScanner.isScanningLan ? "Остановить сканирование" : "Начать сканирование")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(height: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Network Devices", displayMode: .inline)
        }
        .onAppear {
            networkScanner.updateDevices()
        }
        .alert(item: $networkScanner.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
    }
}


