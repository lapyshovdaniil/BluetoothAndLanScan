//
//  DataManager.swift
//  scanlanbt
//
//  Created by Даниил Лапышов on 22.02.2025.
//
import Foundation
import SQLite

class DeviceDatabaseManager {
    static let shared = DeviceDatabaseManager()
    private var db: Connection?

    // Таблицы
    private let bluetoothTable = Table("bluetooth_devices")
    private let lanTable = Table("lan_devices")

    // Поля для Bluetooth
    private let btId = SQLite.Expression<String>("id")
    private let btName = SQLite.Expression<String>("name")
    private let btUuid = SQLite.Expression<String>("uuid")
    private let btRssi = SQLite.Expression<Int>("rssi")
    
    // Поля для LAN
    private let lanId = SQLite.Expression<String>("id")
    private let lanIpAddress = SQLite.Expression<String>("ipAddress")
    private let lanMacAddress = SQLite.Expression<String?>("macAddress")
    private let lanDeviceName = SQLite.Expression<String?>("deviceName")

    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/devices.sqlite3")
            createTables()
        } catch {
            print("Ошибка подключения к БД: \(error)")
        }
    }

    private func createTables() {
        do {
            try db?.run(bluetoothTable.create(ifNotExists: true) { t in
                t.column(btId, primaryKey: true)
                t.column(btName)
                t.column(btUuid)
                t.column(btRssi)
            })
            
            try db?.run(lanTable.create(ifNotExists: true) { t in
                t.column(lanIpAddress, primaryKey: true)
                t.column(lanDeviceName)
                t.column(lanMacAddress)
            })
        } catch {
            print("Ошибка создания таблиц: \(error)")
        }
    }

    func saveBluetoothDevices(_ devices: [BluetoothDevice]) {
        do {
            for device in devices {
                let insert = bluetoothTable.insert(or: .replace,
                    btId <- device.id.uuidString,
                    btName <- device.name,
                    btUuid <- device.uuid,
                    btRssi <- device.rssi
                )
                try db?.run(insert)
                print("Успешшно!")
            }
        } catch {
            print("Ошибка сохранения Bluetooth-устройств: \(error)")
        }
    }

    func saveLANDevices(_ devices: [DeviceInfo]) {
        do {
            for device in devices {
                let insert = lanTable.insert(or: .replace,
                    lanIpAddress <- device.ipAddress,
                    lanDeviceName <- device.deviceName ?? "Unknown",
                    lanMacAddress <- device.macAddress
                )
                try db?.run(insert)
                print("Успешшно!")
            }
        } catch {
            print("Ошибка сохранения LAN-устройств: \(error)")
        }
    }

    func fetchBluetoothDevices() -> [BluetoothDevice] {
        var devices: [BluetoothDevice] = []
        do {
            for row in try db!.prepare(bluetoothTable) {
                let device = BluetoothDevice(
                    id: UUID(uuidString: row[btId])!,
                    name: row[btName],
                    uuid: row[btUuid],
                    rssi: row[btRssi]
                )
                devices.append(device)
            }
        } catch {
            print("Ошибка загрузки Bluetooth-устройств: \(error)")
        }
        return devices
    }

    func fetchLANDevices() -> [DeviceInfo] {
        var devices: [DeviceInfo] = []
        do {
            for row in try db!.prepare(lanTable) {
                let device = DeviceInfo(
                    ipAddress: row[lanIpAddress],
                    macAddress: row[lanMacAddress],
                    deviceName: row[lanDeviceName]
                )
                devices.append(device)
            }
        } catch {
            print("Ошибка загрузки LAN-устройств: \(error)")
        }
        return devices
    }
    
    func clearDevices(from table: String) {
         do {
             let delete: Table
             // Выбор таблицы для очистки
             if table == "bluetooth_devices" {
                 delete = bluetoothTable
             } else if table == "lan_devices" {
                 delete = lanTable
             } else {
                 print("Неизвестная таблица: \(table)")
                 return
             }
             
             // Удаление всех записей из выбранной таблицы
             let deleteQuery = delete.delete()
             try db?.run(deleteQuery)
             print("Все данные удалены из таблицы \(table).")
         } catch {
             print("Ошибка при удалении данных из таблицы \(table): \(error)")
         }
     }
    
     func clearAllDevices() {
         clearDevices(from: "bluetooth_devices")
         clearDevices(from: "lan_devices")
     }
}
