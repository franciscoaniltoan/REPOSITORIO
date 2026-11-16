// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AuraBRCore",
    platforms: [.iOS(.v17)],
    products: [.library(name: "AuraBRCore", targets: ["AuraBRCore"])],
    targets: [
        .target(name: "AuraBRCore", path: "Sources/AuraBRCore"),
        .testTarget(name: "AuraBRCoreTests", dependencies: ["AuraBRCore"], path: "Tests/AuraBRCoreTests")
    ]
)
