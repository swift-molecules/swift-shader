// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-shader",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Shader", targets: ["Shader"]),
        .library(name: "Shader Metal", targets: ["Shader Metal"]),
    ],
    dependencies: [.package(url: "https://github.com/swift-atoms/swift-numeric.git", branch: "main")],
    targets: [
        .target(
            name: "Shader",
            dependencies: [
                .product(name: "Numeric", package: "swift-numeric")
            ],
            swiftSettings: [.enableExperimentalFeature("Extern")]
        ),
        .target(
            name: "Shader Metal",
            dependencies: [
                .target(name: "Shader")
            ]
        ),
        .testTarget(
            name: "Shader Tests",
            dependencies: [
                .target(name: "Shader")
            ]
        ),
        .testTarget(
            name: "Shader Metal Tests",
            dependencies: [
                .target(name: "Shader"),
                .target(name: "Shader Metal"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
