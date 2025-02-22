//
//  LanManager.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import Foundation
import MMLanScan
import Network

class NetworkScanner: NSObject, MMLANScannerDelegate, ObservableObject {
    @Published var alert: AlertData?
    @Published var isScanningLan: Bool = false
    var lanScanner: MMLANScanner!
    
    private var monitor: NWPathMonitor?
    private var isConnectedToNetwork: Bool = false
    
    
    @Published var devices: [DeviceInfo] = []
    
    
    override init() {
        super.init()
        lanScanner = MMLANScanner(delegate: self)
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            self.isConnectedToNetwork = path.status == .satisfied
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
    }
    
    func updateDevices() {
        self.objectWillChange.send()
    }
    
    func startScan() {
        isScanningLan = true
        lanScanner.start()
    }
    
    func stopScan() {
        DeviceDatabaseManager.shared.saveLANDevices(devices)
        isScanningLan = false
        showScanCompletionAlert()
        lanScanner.stop()
        devices.removeAll()
    }
    
    // MARK: - MMLANScannerDelegate
    
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        DispatchQueue.main.async {
            // Добавляем найденное устройство в список
            let newDevice = DeviceInfo(
                ipAddress: device.ipAddress ?? "Unknown",
                macAddress: device.macAddress ?? "Unknown",
                deviceName: device.hostname ?? "Unknown"
            )
            self.devices.append(newDevice)
        }
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        DispatchQueue.main.async {
            print("Сканирование завершено с состоянием: \(status)")
        }
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        DispatchQueue.main.async {
            let progress = (pingedHosts / Float(overallHosts)) * 100
            print("Прогресс сканирования: \(progress)%")
        }
    }
    
    func lanScanDidFailedToScan() {
        DispatchQueue.main.async {
            self.showNoNetworkAlert()
            print("Ошибка при сканировании сети")
        }
    }
    private func showScanCompletionAlert() {
        self.alert = AlertData(title: "Сканирование завершено!", message: "Найдено \(devices.count) устройств.")
    }
    
    private func showNoNetworkAlert() {
        self.alert = AlertData(title: "Нет подключения к сети", message: "Подключитесь к сети для выполнения сканирования.")
    }
}
