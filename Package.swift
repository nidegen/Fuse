// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Fuse",
  platforms: [.iOS("13.0"), .macOS("10.15"), .tvOS("13.0"), .watchOS("6.0")],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "Fuse",
      targets: ["Fuse", "FuseMock"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "Fuse",
      dependencies: []),
    .target(
      name: "FuseMock",
      dependencies: ["Fuse"]),
    .testTarget(
      name: "FuseMockTests",
      dependencies: ["FuseMock"]),
    .testTarget(
      name: "FuseTests",
      dependencies: ["Fuse", "FuseMock"]),
  ]
)
