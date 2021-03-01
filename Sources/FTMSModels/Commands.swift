//  Created by Laskowski, Michal on 01/11/2020.
//

import Foundation

public protocol Command {
    var data: Data { get }
    var operationCode: CommandOperationCode { get }
}

extension Command {
    public func isCommandResponse(data: Data) -> Bool {
        guard data.count == 3 else {
            return false
        }
        let bytes = data.map { $0 }
        return bytes[0...1] == [0x80, operationCode.rawValue]
    }
}

public struct BluetoothCommandError: LocalizedError {
    public let opCodeValue: UInt8
    public var operationCode: CommandOperationCode? {
        CommandOperationCode(rawValue: opCodeValue)
    }
    public var errorCode: UInt8

    public var errorDescription: String? {
        String(format: "Error code: 0x80 %02hhx %02hhx", opCodeValue, errorCode)
    }

    // returns nil if response is not an error
    public init?(from data: Data) {
        guard data.count == 3 else {
            return nil
        }
        let bytes = data.map { $0 }
        guard bytes[0] == 0x80, bytes[2] != 0x01 else {
            return nil
        }

        opCodeValue = bytes[1]
        errorCode = bytes[2]
    }
}

public enum CommandOperationCode: UInt8 {
    case requestControl          = 0x00
    case reset                   = 0x01
    case changeResistance        = 0x04
    case changePower             = 0x05
    case resumeTraining          = 0x07
    case stopTraining            = 0x08
    case setSimulationParameters = 0x11
}

private enum Constants: UInt8 {
    case ok = 0x80

    var data: Data {
        return Data(bytes: [self.rawValue], count: 1)
    }
}

public struct RequestControlCommand: Command {
    public let operationCode: CommandOperationCode = .requestControl
    public let data: Data = Data(uint8Bytes: [CommandOperationCode.requestControl.rawValue])
    public init() {}
}

public struct ResetCommand: Command {
    public let operationCode: CommandOperationCode = .reset
    public let data: Data = Data(uint8Bytes: [CommandOperationCode.reset.rawValue])
    public init() {}
}

public enum TrainingCommand: Command {
    case resume
    case stop
    case pause

    public var operationCode: CommandOperationCode {
        switch self {
        case .resume: return .resumeTraining
        case .stop, .pause: return .stopTraining
        }
    }

    public var data: Data {
        switch self {
        case .resume: return Data(uint8Bytes: [operationCode.rawValue])
        case .stop: return Data(uint8Bytes: [operationCode.rawValue, 0x01])
        case .pause: return Data(uint8Bytes: [operationCode.rawValue, 0x02])
        }
    }
}

public struct ControlPowerCommand: Command {
    public let operationCode: CommandOperationCode = .changePower
    public let power: Int16

    public var data: Data {
        let powerBytes = withUnsafeBytes(of: power.littleEndian, Array.init)
        let dataBytes = ([operationCode.rawValue] as [UInt8]) + powerBytes
        return Data(bytes: dataBytes, count: 3)
    }
    public init(power: Int16) {
        self.power = power
    }
}

public struct ControlResistanceCommand: Command {
    public let operationCode: CommandOperationCode = .changeResistance
    public let resistance: UInt8

    public var data: Data {
        let resistanceBytes = withUnsafeBytes(of: resistance.littleEndian, Array.init)
        let dataBytes = ([operationCode.rawValue] as [UInt8]) + resistanceBytes
        return Data(bytes: dataBytes, count: 3)
    }
    public init(resistance: UInt8) {
        self.resistance = resistance
    }
}

public struct ControlSimulationParametersCommand: Command {
    public let operationCode: CommandOperationCode = .setSimulationParameters
    public let inclination: Int16
    public let crr: UInt8 // coefficient of rolling resistance
    public let cw: UInt8 // wind resistance coefficient

    public var data: Data {
        let inclinationBytes = withUnsafeBytes(of: inclination.littleEndian, Array.init)
        let crrBytes = withUnsafeBytes(of: crr.littleEndian, Array.init)
        let cwBytes = withUnsafeBytes(of: cw.littleEndian, Array.init)
        let dataBytes = ([operationCode.rawValue] as [UInt8]) + inclinationBytes + crrBytes + cwBytes
        return Data(bytes: dataBytes, count: 3)
    }

    public init(inclination: Int16, crr: UInt8, cw: UInt8) {
        self.inclination = inclination
        self.crr = crr
        self.cw = cw
    }
}

private extension Data {
    init(uint8Bytes: [UInt8]) {
        self.init(bytes: uint8Bytes, count: uint8Bytes.count)
    }
}
