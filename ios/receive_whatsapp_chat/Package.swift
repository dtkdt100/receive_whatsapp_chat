// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "receive_whatsapp_chat",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "receive-whatsapp-chat", targets: ["receive_whatsapp_chat"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "receive_whatsapp_chat",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [],
            cSettings: [
                .headerSearchPath("include/receive_whatsapp_chat")
            ]
        )
    ]
)
