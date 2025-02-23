//
//  ScanHistoryView.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import SwiftUI

struct ScanHistoryView: View {
    @Binding var selectedTab: Int
    @ObservedObject var viewModel = ScanHistoryViewModel()
    
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("LAN устройства")) {
                        ForEach(viewModel.lanDevices) { device in
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
                        ForEach(viewModel.bluetoothDevices) { device in
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
            }
            .navigationBarTitle("Scanned Devices", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showingAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            })
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Очистить историю?"),
                    message: Text("Вы уверены, что хотите очистить все устройства из истории?"),
                    primaryButton: .destructive(Text("Да")) {
                        viewModel.clearAllDevices()
                    },
                    secondaryButton: .cancel(Text("Нет"))
                )
            }
            .onAppear {
                viewModel.loadDevices()
            }
        }
    }
}
