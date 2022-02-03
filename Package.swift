// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CoreOSC",
    defaultLocalization: "en",
    products: [
        .library(
            name: "CoreOSC",
            targets: ["CoreOSC"])
    ],
    targets: [
        .target(
            name: "CoreOSC",
            dependencies: [],
            resources: [
                .process("LICENSE.md")
            ]),
        .testTarget(
            name: "CoreOSCTests",
            dependencies: ["CoreOSC"])
    ]
)
