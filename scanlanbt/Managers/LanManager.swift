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
    @Published var progress: CGFloat = 0.0
    @Published var isConnectedToNetwork: Bool = false
    @Published var devices: [DeviceInfo] = []
    
    private var monitor: NWPathMonitor?
    private var timer: Timer?
    
    var lanScanner: MMLANScanner!
    
    
    override init() {
        super.init()
        lanScanner = MMLANScanner(delegate: self)
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnectedToNetwork = path.status == .satisfied
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
    }
    
    func updateDevices() {
        self.objectWillChange.send()
    }
    
    func startScan() {
        guard isConnectedToNetwork else {
            showNoNetworkAlert()
            return
        }
        
        isScanningLan = true
        progress = 0.0
        lanScanner.start()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.progress >= 1.0 {
                self.stopScan()
            } else {
                self.progress += 0.1 / 15.0
            }
        }
    }
    
    func stopScan() {
        DeviceDatabaseManager.shared.saveLANDevices(devices)
        isScanningLan = false
        timer?.invalidate()
        progress = 0.0
        showScanCompletionAlert()
        lanScanner.stop()
        devices.removeAll()
    }
    
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        DispatchQueue.main.async {
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
            let progressValue = (pingedHosts / Float(overallHosts)) * 100
            print("Прогресс сканирования: \(progressValue)%")
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
        timer?.invalidate()
        isScanningLan = false
        self.alert = AlertData(title: "Нет подключения к сети", message: "Подключитесь к сети для выполнения сканирования.")
    }
}

