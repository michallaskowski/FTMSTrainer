//  Created by Laskowski, Michal on 26/02/2021.
//

import CoreBluetooth

public enum UUIDs {
    // useful codes here: https://github.com/gamma/FTMS-Bluetooth/blob/master/Sources/FTMS%20Bluetooth/FTMSUUIDs.swift
    public static let fitnessMachineCharacteristicPowerRangeId = CBUUID(string: "0x2AD8")
    public static let fitnessMachineCharacteristicIndoorBikeDataId = CBUUID(string: "0x2AD2")
    public static let fitnessMachineCharacteristicControlPointId = CBUUID(string: "0x2AD9")
    public static let fitnessMachineServiceUUID = CBUUID(string: "0x1826")
}
