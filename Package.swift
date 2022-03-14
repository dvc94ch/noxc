// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "noxc",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "noxc",
            dependencies: [
                "altsign",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "src"
        ),
        .target(
            name: "altsign",
            path: "altsign",
            cSettings: [
                .headerSearchPath("altsign/include"),
                .headerSearchPath("..")
            ]
        ),
    ]
)
