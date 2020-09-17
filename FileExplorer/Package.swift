// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "FileExplorer",
    platforms: [
        .macOS(.v10_10),
    ],
    products: [
        .library(name: "FileExplorer", targets: ["FileExplorer"]),
    ],
    targets: [
        .target(name: "FileExplorer", dependencies: []),
        .testTarget(name: "FileExplorerTests", dependencies: ["FileExplorer"]),
    ]
)
