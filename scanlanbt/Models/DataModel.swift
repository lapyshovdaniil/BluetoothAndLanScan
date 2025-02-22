//
//  DataModel.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import Foundation

struct ScannedDevice: Identifiable {
    var id: UUID
    var name: String
    var uuid: String?
    var ipAddress: String?
    var macAddress: String?
    var rssi: Int?
}
