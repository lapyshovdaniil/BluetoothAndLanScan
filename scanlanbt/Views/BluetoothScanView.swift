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
    @State private var progress: CGFloat = 0.0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
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
        .onAppear {
        }
        .alert(item: $bluetoothManager.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
    }
    
    func startScanning() {
        bluetoothManager.startScanning()
        //        bluetoothManager.updateDevices()
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
        bluetoothManager.stopScanning()
        timer?.invalidate()
        isTimerRunning = false
        progress = 0.0
    }
}




