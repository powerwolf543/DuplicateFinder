// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FileExplorer",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "FileExplorer", targets: ["FileExplorer"]),
    ],
    targets: [
        .target(name: "FileExplorer", dependencies: []),
        .testTarget(name: "FileExplorerTests", dependencies: ["FileExplorer"]),
    ]
)
