//
//  LanModel.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import Foundation

struct DeviceInfo: Identifiable, Hashable{
    let id = UUID()
    let ipAddress: String
    let macAddress: String?
    let deviceName: String?
}
