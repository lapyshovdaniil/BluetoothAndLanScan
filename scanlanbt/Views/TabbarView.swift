//
//  TabbarView.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import SwiftUI

struct TabbarView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BluetoothScan(selectedTab: $selectedTab)
                .tabItem {
                    Label("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(0)
            
            LANScanView(selectedTab: $selectedTab)
                .tabItem {
                    Label("LAN", systemImage: "network")
                }
                .tag(1)
            
            ScanHistoryView(selectedTab: $selectedTab)
                .tabItem {
                    Label("История", systemImage: "clock")
                }
                .tag(2)
        }
    }
}
struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(width: 150)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

#Preview {
    TabbarView()
}
