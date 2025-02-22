//
//  AlertData.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import Foundation

struct AlertData: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
