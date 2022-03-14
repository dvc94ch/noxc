// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "noxc",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/krzyzanowskim/openssl", from: "1.0.0"),
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
            dependencies: [
                "corecrypto",
                .product(name: "OpenSSL", package: "openssl")
            ],
            path: "altsign",
            cSettings: [
                .headerSearchPath("altsign/include"),
                .headerSearchPath(".."),
                .define("CORECRYPTO_DONOT_USE_TRANSPARENT_UNION", to: "1")
            ]
        ),
        .target(
            name: "corecrypto",
            path: "corecrypto",
            cSettings: [
                .headerSearchPath(".."),
                .define("CORECRYPTO_DONOT_USE_TRANSPARENT_UNION", to: "1")
            ]
        )
    ]
)
