// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FTMSTrainer",
    platforms: [
        .macOS(.v10_14), .iOS(.v10), .watchOS(.v4)
    ],
    products: [
        .library(
            name: "FTMSTrainer",
            targets: ["FTMSTrainer"]),
        .library(
            name: "FTMSModels",
            targets: ["FTMSModels"])
    ],
    dependencies: [
        .package(url: "https://github.com/i-mobility/RxBluetoothKit", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "FTMSModels",
            dependencies: []),
        .target(
            name: "FTMSTrainer",
            dependencies: ["FTMSModels", "RxBluetoothKit"]),
        .testTarget(
            name: "FTMSTrainerTests",
            dependencies: ["FTMSTrainer"]),
    ]
)
