---
title: Home
homepage: true
description: Elegant Swift Networking with Combine
layout: page
navorder: 0
---

# Ombi
Elegant reactive networking with Combine and Swift

[![Build status](https://badge.buildkite.com/b9d11bcf2e169433c44387dc05dba1d7455f0eb8752ca7b9c2.svg)](https://buildkite.com/varun-santhanam/ombi)
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
    .package(url: "https://github.com/vsanthanam/Ombi.git", .upToNextMajor(from: "1.0.0"))
]
```

## Documentation

You can view the documentation for the latest stable release at [docs.ombi.network](https://docs.ombi.network). For any given copy of the repository, you can generate version specific docs using [jazzy](https://github.com/realm/jazzy) and the included script:

```
$ cd path to repo
$ ./gen-docs.sh
```
