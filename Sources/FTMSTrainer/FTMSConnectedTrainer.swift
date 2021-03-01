//  Created by Laskowski, Michal on 06/11/2020.
//

import Foundation
import RxBluetoothKit
import RxSwift
import os.log
import FTMSModels

private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "FTMSBluetoothCommands")

public struct FTMSConnectedTrainer {
    let controlPoint: Characteristic
    let bikeData: Characteristic

    public let id: UUID
    private let disposeBag = DisposeBag()

    public init(peripheral: Peripheral, controlPoint: Characteristic, bikeData: Characteristic) {
        self.controlPoint = controlPoint
        self.bikeData = bikeData
        self.id = peripheral.identifier

        controlPointIndications.subscribe(onNext: { data in
            os_log("BT recv: %@", log: logger, type: .debug, data.toHex())
        }).disposed(by: disposeBag)
    }

    public var controlPointIndications: Observable<Data> {
        controlPoint.observeValueUpdateAndSetNotification().flatMapLatest { (characteristic: Characteristic) -> Observable<Data> in
            guard let data = characteristic.value else {
                return .empty()
            }
            return .just(data)
        }
    }

    public var controlPointError: Observable<BluetoothCommandError> {
        controlPointIndications.flatMapLatest { data -> Observable<BluetoothCommandError> in
            if let error = BluetoothCommandError(from: data) {
                return .just(error)
            } else {
                return .empty()
            }
        }
    }

    public var indoorBikeDataNotification: Observable<IndoorBikeDataRepresentation> {
        bikeData.observeValueUpdateAndSetNotification().flatMapLatest { (characteristic: Characteristic) -> Observable<IndoorBikeDataRepresentation> in
            guard let data = characteristic.value else {
                return .empty()
            }
            let bikeData = IndoorBikeDataRepresentation(from: data)
            return .just(bikeData)
        }
    }

    public func send(command: Command) -> Single<Void> {
        let data = command.data

        let writeIndicationCheck: Single<Void> = controlPointIndications
            .filter { data in
                command.isCommandResponse(data: data)
            }
            .take(1).asSingle()
            .timeout(.seconds(5), scheduler: MainScheduler.instance)
            .map { data in
                if let error = BluetoothCommandError(from: data) {
                    throw error
                }
            }

        let write: Single<Void> = Single<Void>.just(())
            .do(onSuccess: {
                os_log("BT send: %@", log: logger, type: .debug, data.toHex())
            }).flatMap {
                controlPoint.writeValue(data, type: .withResponse).map { _ in () }
            }

        return Single<Void>.zip(
            write,
            writeIndicationCheck,
            resultSelector: { _, _ in
                ()
            })
    }
}

private extension Data {
    func toHex() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
