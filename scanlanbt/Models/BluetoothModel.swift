//
//  BluetoothModel.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import Foundation
 
struct BluetoothDevice: Identifiable {
    var id = UUID()
    var name: String
    var uuid: String
    var rssi: Int
}

