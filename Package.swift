// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HeyListen",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "HeyListen",
            targets: ["HeyListen"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "HeyListen",
            dependencies: [],
            path: "Sources/Listen"
        )
    ]
)