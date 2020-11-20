// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Utils",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Utils", targets: ["Utils"]),
    ],
    targets: [
        .target(name: "Utils", dependencies: []),
        .testTarget(name: "UtilsTests", dependencies: ["Utils"]),
    ]
)
