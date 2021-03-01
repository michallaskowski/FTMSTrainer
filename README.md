# FTMSTrainer

## About the project

An implementation of an FTMS protocol client. Could be useful for apps that would like to communicate with FTMSTrainers.  
Mine does and it works. Will post a link here once it is published.

### Built with

FTMSModels - no libraries, but honorable mentions to other sources on GitHub:

* https://github.com/gamma/FTMS-Bluetooth/blob/master/Sources/FTMS%20Bluetooth/Utils/Fields.swift
* https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
* https://github.com/gamma/FTMS-Bluetooth/blob/master/Sources/FTMS%20Bluetooth/FTMSUUIDs.swift

FTMSTrainer - uses FTMSModels and:

* [RxBluetoothKit](https://github.com/Polidea/RxBluetoothKit)
* [RxSwift](https://github.com/ReactiveX/RxSwift)

## Getting started

To use the decoders in your project, add this Swift Package in your project. You can choose the model layer only `FTMSModels`, or classes to communicate with the trainer `FTMSTrainer`.

## Usage

Simple example for demonstration:

```
import FTMSModels
import FTMSTrainer

let scanner = TrainerScanner()
let trainer = scanner.scan()
    .filter { $0.count > 0 }
    .take(1)
    .flatMap { trainers -> FTMSConnectedTrainer in
        trainers[0].connect()
    }

let disposeBag = DisposeBag()

trainer.controlPointError
    .subscribe(onNext: { error in
        print("Control point error: %@", error)
    }).disposed(by: disposeBag)

let command = TrainingCommand.resume // check Commands.swift for a list of commands
trainer.send(command: command)
   .subscribe()
   .disposed(by: disposeBag)
```

## Roadmap

1. Need to add tests. The project was written quickly, trying with a real trainer what works and what doesn't when communicating with turbo trainer.
2. Improving together with my own app, as needed.
3. Awaiting potential requests/bug fixes.

## Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## License

Distributed under the MIT License. See `LICENSE` for more information.
