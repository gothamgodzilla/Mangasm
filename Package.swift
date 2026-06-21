// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mangasm",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MangasmApp", targets: ["MangasmApp"]),
        .executable(name: "MangasmPreview", targets: ["MangasmPreview"]),
    ],
    targets: [
        .target(name: "MangasmApp", resources: [.process("Resources")]),
        .executableTarget(name: "MangasmPreview", dependencies: ["MangasmApp"]),
        .testTarget(name: "MangasmAppTests", dependencies: ["MangasmApp"]),
    ]
)
