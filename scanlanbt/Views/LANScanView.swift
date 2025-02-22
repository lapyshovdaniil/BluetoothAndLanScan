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
    @State private var progress: CGFloat = 0.0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
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
                            stopScanning()
                        } else {
                            startScanning()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red)
                                .frame(width: nil, height: nil)
                                .scaleEffect(x: progress, y: 1, anchor: .leading)
                                .animation(.linear(duration: 0.1), value: progress)
                            
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
    func startScanning() {
        networkScanner.startScan()
        networkScanner.updateDevices()
        isTimerRunning = true
        progress = 0.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.progress >= 1.0 {
                self.stopScanning()
            } else {
                self.progress += 0.1 / 15.0
            }
        }
    }
    
    func stopScanning() {
        networkScanner.stopScan()
        timer?.invalidate()
        isTimerRunning = false
        progress = 0.0
    }
}



