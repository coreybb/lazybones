// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lazybones",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "lazybones",
            targets: ["lazybones"]),
    ],
    targets: [
        .target(
            name: "lazybones"),

    ]
)
