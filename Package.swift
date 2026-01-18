 // swift-tools-version: 6.0
 import PackageDescription

 let package = Package(
     name: "NeckSusModules",
     platforms: [.iOS(.v17)],
     products: [
         .library(name: "NeckSusShared", targets: ["NeckSusShared"]),
         .library(name: "NeckSusCore", targets: ["NeckSusCore"]),
         .library(name: "NeckSusFeatures", targets: ["NeckSusFeatures"])
     ],
     dependencies: [],
     targets: [
         .target(name: "NeckSusShared", path: "Shared"),
         .target(name: "NeckSusCore", dependencies: ["NeckSusShared"], path: "Core"),
         .target(name: "NeckSusFeatures", dependencies: ["NeckSusCore", "NeckSusShared"], path: "Features")
     ]
 )