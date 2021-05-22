---
title: Home
homepage: true
description: Elegant Swift Networking with Combine
layout: page
navorder: 0
---

# Ombi
Elegant reactive networking with Combine and Swift

[![release](https://img.shields.io/github/v/release/vsanthanam/Ombi)](https://github.com/vsanthanam/Ombi/releases)
[![license](https://img.shields.io/github/license/vsanthanam/Ombi.svg)](https://en.wikipedia.org/wiki/MIT_License)
[![documentation](https://docs.ombi.network/badge.svg)](https://docs.ombi.network)
[![swift-version](https://img.shields.io/badge/Swift-5.4-orange)](https://www.swift.org)

Ombi is a simple library built on top of `URLSession` and `Combine` that makes it very easy to make asynchronous network requests with reactive programming.
It requires Combine to work correctly, and does not support Swift runtime environments that do not support Combine.

## Installation

Ombi uses the [The Swift Package Manager](https://swift.org/package-manager/) for distrubition. For now, this is the only supported method of installation, but others will be added soon.

Add `Ombi` to your `Package.swift` file like so:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/Ombi.git", .upToNextMajor(from: "1.0"))
]
```

## Getting Started

See the [quick start guide](https://ombi.network/quick-start.html) for the latest stable release.
For version-specific guides, see the project [README file](https://github.com/vsanthanam/Ombi/blob/main/README.md), or take a look at the 

## Documentation

The documentation for the latest stable release is available at [docs.ombi.network](https://docs.ombi.network).
For version-specific docs, generate them yourself using `jazzy` and the included script:

```
$ cd path/to/repo/
$ ./gen-docs.sh
```
