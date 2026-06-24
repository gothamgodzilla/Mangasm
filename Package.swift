// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mangasm",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MangasmApp", targets: ["MangasmApp"]),
        .executable(name: "MangasmPreview", targets: ["MangasmPreview"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "MangasmApp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ],
            resources: [.process("Resources")]
        ),
        .executableTarget(name: "MangasmPreview", dependencies: ["MangasmApp"]),
        .testTarget(name: "MangasmAppTests", dependencies: ["MangasmApp"]),
    ]
)