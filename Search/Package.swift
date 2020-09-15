// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Search",
    platforms: [
        .macOS(.v10_10),
    ],
    products: [
        .library(name: "Search", targets: ["Search"]),
    ],
    targets: [
        .target(name: "Search", dependencies: []),
        .testTarget(name: "SearchTests", dependencies: ["Search"]),
    ]
)
