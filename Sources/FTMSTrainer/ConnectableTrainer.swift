//  Created by Laskowski, Michal on 26/02/2021.
//

import Foundation
import RxBluetoothKit
import RxSwift
import FTMSModels

public protocol ConnectableTrainer: AnyObject {
    var name: String? { get }
    func establishConnection() -> Observable<BluetoothConnectedTrainer>
    var id: UUID { get }
}

public enum EstablishConnectionError: Error {
    case ftmsServiceNotAvailable
    case controlPointCharacterisicNotAvailable
}

extension ScannedPeripheral: ConnectableTrainer {
    public var name: String? {
        advertisementData.localName
    }

    public func establishConnection() -> Observable<BluetoothConnectedTrainer> {
        peripheral.establishConnection()
            .flatMap { (peripheral: Peripheral) in
                peripheral.discoverServices([UUIDs.fitnessMachineServiceUUID])
                    .map { services -> Service in
                        guard services.count == 1 else {
                            throw EstablishConnectionError.ftmsServiceNotAvailable
                        }
                        return services[0]
                    }.flatMap { (service: Service) -> Single<[Characteristic]> in
                        service.discoverCharacteristics(
                            [UUIDs.fitnessMachineCharacteristicControlPointId,
                             UUIDs.fitnessMachineCharacteristicIndoorBikeDataId]
                        )
                    }
                    .flatMap { (characteristics: [Characteristic]) in
                        guard characteristics.count == 2 else {
                            throw EstablishConnectionError.controlPointCharacterisicNotAvailable
                        }
                        return Single.zip(characteristics[0].discoverDescriptors(),
                                          .just(characteristics))
                    }.map { (_: [Descriptor], characteristics: [Characteristic]) in
                        BluetoothConnectedTrainer(peripheral: peripheral,
                                                  controlPoint: characteristics.first(where: { $0.uuid ==  UUIDs.fitnessMachineCharacteristicControlPointId})!,
                                                  bikeData: characteristics.first(where: { $0.uuid == UUIDs.fitnessMachineCharacteristicIndoorBikeDataId})!)
                    }
            }
    }

    public var id: UUID {
        peripheral.identifier
    }
}
