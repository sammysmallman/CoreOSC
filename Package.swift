// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "CoreOSC",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
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
                .process("LICENSE.md"),
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "CoreOSCTests",
            dependencies: ["CoreOSC"])
    ]
)
