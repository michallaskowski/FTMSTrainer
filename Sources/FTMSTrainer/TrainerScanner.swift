//
//  TrainerScanner.swift
//  WatchTrainer WatchKit Extension
//
//  Created by Laskowski, Michal on 31/10/2020.
//

import Foundation
import RxBluetoothKit
import RxSwift
import FTMSModels

public final class TrainerScanner {

    private let manager: CentralManager

    public init(manager: CentralManager = CentralManager(queue: .main)) {
        self.manager = manager
    }

    public func scan() -> Observable<[ConnectableTrainer]> {
        manager.observeState()
            .startWith(manager.state)
            .filter {
                $0 == .poweredOn
            }
            .take(1)
            .timeout(.seconds(4), scheduler: MainScheduler.instance)
            .flatMapFirst { _ in
                self.manager.scanForPeripherals(withServices: [
                    UUIDs.fitnessMachineServiceUUID
                ])
            }
            .scan(into: [ConnectableTrainer](), accumulator: { (accumulator, peripheral) in
                if !accumulator.contains(where: {
                    $0.id == peripheral.id
                }) {
                    accumulator.append(peripheral)
                }
            })

            // todo: sort by rssi?
    }
}
