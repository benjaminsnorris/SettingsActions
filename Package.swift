// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SettingsActions",
    platforms: [
        .iOS("12.0"),
        .watchOS("7.0"),
        .tvOS("14.0")
    ],
    products: [
        .library(
            name: "SettingsActions",
            targets: ["SettingsActions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/benjaminsnorris/DeviceInfo.git", .upToNextMajor(from: "4.2.0"))
    ],
    targets: [
        .target(
            name: "SettingsActions",
            dependencies: [
                .product(name: "DeviceInfo", package: "DeviceInfo")
            ]),
        .testTarget(
            name: "SettingsActionsTests",
            dependencies: ["SettingsActions"]),
    ]
)
