//  Created by Laskowski, Michal on 07/11/2020.
//

import Foundation

// based on FTMS documentation and https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
struct IndoorBikeDataOptions: OptionSet {
    let rawValue: UInt16

    static let moreDataNotPresent  = IndoorBikeDataOptions(rawValue: 1 << 0)
    static let averageSpeed        = IndoorBikeDataOptions(rawValue: 1 << 1)
    static let instantCadence      = IndoorBikeDataOptions(rawValue: 1 << 2)
    static let averageCadence      = IndoorBikeDataOptions(rawValue: 1 << 3)
    static let totalDistance       = IndoorBikeDataOptions(rawValue: 1 << 4)
    static let resistanceLevel     = IndoorBikeDataOptions(rawValue: 1 << 5)
    static let instantPower        = IndoorBikeDataOptions(rawValue: 1 << 6)
    static let averagePower        = IndoorBikeDataOptions(rawValue: 1 << 7)
    static let expendedEnergy      = IndoorBikeDataOptions(rawValue: 1 << 8)
    static let heartRate           = IndoorBikeDataOptions(rawValue: 1 << 9)
    static let metabolicEquivalent = IndoorBikeDataOptions(rawValue: 1 << 10)
    static let elapsedTime         = IndoorBikeDataOptions(rawValue: 1 << 11)
    static let remainingTime       = IndoorBikeDataOptions(rawValue: 1 << 12)
}

public struct IndoorBikeData {
    public var instantSpeed: UInt16?   // resolution: 0.01, km/h
    public var averageSpeed: UInt16?   // resolution: 0.5   km/h
    public var instantCadence: UInt16? // resolution: 0.01  rpm
    public var averageCadence: UInt16? // resolution: 0.5   rpm
    public var totalDistance: UInt32?  // really UInt24, meters
    public var resistanceLevel: Int16?
    public var instantPower: Int16?    // watts
    public var averagePower: Int16?    // watts

    // energy under one option, expendedEnergy
    public var totalEnergy: UInt16?    // kcal
    public var energyPerHour: UInt16?
    public var energyPerMinute: UInt8?

    public var heartRate: UInt8?           // bpm
    public var metabolicEquivalent: UInt8? // resolution, 0.1, kcal
    public var elapsedTime: UInt16?        // seconds
    public var remainingTime: UInt16?      // seconds
}

public struct IndoorBikeDataRepresentation {
    public var instantSpeed: Double?
    public var averageSpeed: Double?   // km/h
    public var instantCadence: Double?
    public var averageCadence: Double? // rpm
    public var totalDistance: UInt32?  // meters
    public var resistanceLevel: Int16?
    public var instantPower: Int16?    // watts
    public var averagePower: Int16?    // watts

    public var totalEnergy: UInt16?    // kcal
    public var energyPerHour: UInt16?
    public var energyPerMinute: UInt8?

    public var heartRate: UInt8?           // bpm
    public var metabolicEquivalent: Double?
    public var elapsedTime: UInt16?        // seconds
    public var remainingTime: UInt16?      // seconds
}

extension IndoorBikeDataRepresentation {
    public init(from data: IndoorBikeData) {
        instantSpeed = data.instantSpeed?.toDouble(multiplier: 0.01)
        averageSpeed = data.averageSpeed?.toDouble(multiplier: 0.01)
        instantCadence = data.instantCadence?.toDouble(multiplier: 0.5)
        averageCadence = data.averageCadence?.toDouble(multiplier: 0.5)
        totalDistance = data.totalDistance
        resistanceLevel = data.resistanceLevel
        instantPower = data.instantPower
        averagePower = data.averagePower
        totalEnergy = data.totalEnergy
        energyPerHour = data.energyPerHour
        energyPerMinute = data.energyPerMinute
        heartRate = data.heartRate
        metabolicEquivalent = data.metabolicEquivalent?.toDouble(multiplier: 0.1)
        elapsedTime = data.elapsedTime
        remainingTime = data.remainingTime
    }

    public init(from data: Data) {
        let data = IndoorBikeData(from: data)
        self.init(from: data)
    }
}

private extension FixedWidthInteger {
    func toDouble(multiplier: Double) -> Double {
        Double(self) * multiplier
    }
}

extension IndoorBikeData {
    public init(from data: Data) {
        var fields = Fields(data)
        let options = IndoorBikeDataOptions(rawValue: fields.flags)

        instantSpeed = options.contains(.moreDataNotPresent) ? nil : fields.get()
        averageSpeed = options.contains(.averageSpeed) ? fields.get() : nil
        instantCadence = options.contains(.instantCadence) ? fields.get() : nil
        averageCadence = options.contains(.averageCadence) ? fields.get() : nil

        if options.contains(.totalDistance) {
            let remainder: UInt16 = fields.get()
            let value: UInt8 = fields.get()
            totalDistance = UInt32(value << 16) + UInt32(remainder)
        }

        resistanceLevel = options.contains(.resistanceLevel) ? fields.get() : nil
        instantPower = options.contains(.instantPower) ? fields.get() : nil
        averagePower = options.contains(.averagePower) ? fields.get() : nil

        if options.contains(.expendedEnergy) {
            totalEnergy = fields.get()
            energyPerHour = fields.get()
            energyPerMinute = fields.get()
        }

        heartRate = options.contains(.heartRate) ? fields.get() : nil
        metabolicEquivalent = options.contains(.metabolicEquivalent) ? fields.get() : nil
        elapsedTime = options.contains(.elapsedTime) ? fields.get() : nil
        remainingTime = options.contains(.remainingTime) ? fields.get() : nil
    }
}
