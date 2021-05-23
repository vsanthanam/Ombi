# Ombi
Elegant reactive networking with Combine and Swift

[![Build status](https://badge.buildkite.com/b9d11bcf2e169433c44387dc05dba1d7455f0eb8752ca7b9c2.svg)](https://buildkite.com/varun-santhanam/ombi)
[![release](https://img.shields.io/github/v/release/vsanthanam/Ombi)](https://github.com/vsanthanam/Ombi/releases)
[![license](https://img.shields.io/github/license/vsanthanam/Ombi.svg)](https://en.wikipedia.org/wiki/MIT_License)
[![documentation](https://docs.ombi.network/badge.svg)](https://docs.ombi.network)
[![swift-version](https://img.shields.io/badge/Swift-5.4-orange)](https://www.swift.org)

## Introduction

Ombi is a simple library built on top of `URLSession` and `Combine` that makes it very easy to make asynchronous network requests with reactive programming.
It requires Combine to work correctly, and does not support Swift runtime environments that do not support Combine.

### Installation

Ombi uses the [The Swift Package Manager](https://swift.org/package-manager/) for distrubition. For now, this is the only supported method of installation, but others will be added soon.

Add `Ombi` to your `Package.swift` file like so:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/Ombi.git", .upToNextMajor(from: "1.0"))
]
```

### Documentation

You can view the documentation for the latest stable release at [docs.ombi.network](https://docs.ombi.network). For any given copy of the repository, you can generate version specific docs using [jazzy](https://github.com/realm/jazzy) and the included script:

```
$ cd path to repo
$ ./gen-docs.sh
```

## Basic Usage

Making a network request with ombi is pretty straight forward.
Create a `Requestable`, initialize a `RequestManager`, and invoke the `makeRequest` method using your `Requestable`
You will recieve a `Publisher` which will allow you to handle network responses or errors as they occur.

There are two main ways to use the framework: Creating your own types that conform to `Requestable`, or using the provided `ComposableRequest` type, which already conform to `Requestable`. This document will cover both strategies.

### Requestable Interface

The  `Requestable`  protocol defines everything the `RequestManager` needs to make the HTTP request.

See this example for a "POST" request to "/posts/update" that sends an `AnyJSON` body and expects a `String` response:

```swift

// Define `Requestable`
struct MyRequest: Requestable {

    typealias RequestBody == AnyJSON
    typealias ResponseBody == String
    typealias ResponseError == HTTPError

    var path: String {
        "/posts/update"
    }
    
    var method: RequestMethod {
        .post
    }
    
    var headers: RequestHeaders {
        [
            .contentType: .contentType(.json),
            .acceptType: .contentType(.json)
        ]
    }
    
    var body: AnyJSON {
        [
            "title" : "My New Post",
            "body" : "lorem ipsum dolor sit amit"
        ]
    }
}

// Initialize `Requestable`
let request = MyRequest()

// Initialize `RequestManager`
let requestManager = MyRequestManager(host: "https://api.myapp.com")

// Invoke `makeRequest(_:retries:sla:on:fallbackResponse:)` and observe
let cancellable = requestManager.makeRequest(request)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            // ... handle error here ...
        }
    }, recieveValue: { response in
        // ... handle response here ...
    })
```

The `Requestable` protocol has many other fields that aren't included in the example, but many of them are implemented for you by default. The main choice you need to make is what types you need to use to express `RequestBody` and `ResponseBody`. The `Requestable` protocol requires you to provide `BodyEncoder` and `BodyDecoder` for the two types choose, respectively.  These are provided for you by default if you use any of the following types:

- `String`
- `Data`
- `AnyJSON`
- Any `Codable` type

If you are using a type not mentioned above, but still do not want to provide a encoder or decoder, make that type conform to `AutomaticBodyCoding`, and `Requestable` will generate the appropropriate encoder / decoder for you. A failure to use a type that doesn't provide its own encoder / decore, in conjunction with a failure to specify one within the `Requestable` itself will result in a compile time error.

You can create a single type for every request you might make, or you can create parameterized, reusable types:

```swift
struct LoginRequest: Requestable

    init(username: String, password: String) {
        body = RequestBody(username: username, password: password)
    }

    struct RequestBody: Codable {
        let username: String
        let password: String
    }
    
    struct ResponseBody: Codable {
        let token: String
    }
    
    typealias ResponseError = HTTPError
    
    let path: String = "/login"
    
    let method: RequestMethod = .get
    
    var headers: RequestHeaders {
        [
            .acceptType: .contentType(.json),
            .contentType: .contentType(.json)
            "My-Custom-Header": "My-Value"
        ]
    }
    
    let body: RequestBody
}

let request = LoginRequest(username: "MyUserName", password: "MyPassword")
let manager = RequestManager(host: "https://api.myapp.com")

var token: String?

let cancellable = manager.makeRequest(request)
    .replaceError(with: .empty)
    .map(\.body.token)
    .sink { token in
        self.token = token
    }
```

### RequestManager

While most of the properties of the request are definied within the `Requestable` a few are properties of the request manager, and a few other are additional parameters in the `makeRequest` method.

In addition to providing the host URL, the request manager can automatically inject headers, setup retries counts, setup a response SLA, and more.

```swift
/// Custom Log
let myLog = OSLog(subsystem: "com.developer.subsystem", category: "api.myapp.com")

let manager = RequestManager(host: "https://api.myapp.com", log: myLog)

// Inject custom headers
let manager.additionalHeaders = [
    .authorization: .authorization(type: .bearer, token: "MyToken")
] // these headers will be added to every request

let request = MyRequest() // conforms to `Requestable`
let cancellable = manager.sendRequest(request,
                                      retries: 1,
                                      sla: .seconds(60),
                                      on: DispatchQueue.main) // specify sla, retry count, and dispatch queue
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            // ... handle error ...
        }
    }, receiveValue: { response in
        // ... handle response ...
    })
```

## Responses, Errors and Validation

The publisher returned by `makeRequest` uses a generic types for its `Output` and its `Error`. The output is a `RequestResponse`, a generic type specialized using the `Requestable`'s `ResponseBody` constraint. The error is a `RequestError` specialized using the `Requestable`'s `ResponseError` containt.

### RequestResponse

If the request doesnt fail, the publisher will emit a single `RequestResponse` value before completing. This value type contains the URL, headers, status code, and decoded body content of the request. 

### RequestError and Validation

The `RequestError` type describes a number of errors that could occur when making a request, from a broken connection, to failed encoding // decoding, to timeouts and SLA violations.

However, a request could complete and still fail. Once a `RequestResponse` is generated, the `Requestable`(s) `responseValidator` is used to examine the contents of the request for `ResponseError`(s). The default response validator allows any request to complete, regardless of its content. If you specialize your `Requestable` with `ResponseError == HTTPError`, the default response validator will perform basic validation based on the HTTP status code. If you choose to provide your own error model, remember to provide a `ResponseValidator` with the `Requestable` as well.

All `RequestResponse`(s), including ones provided by the `RequestManager`'s `fallbackResponse` parameter, will go through validation step. This means that even your backup response provided from disk could still result in an error, for example, of that response's status code is 404 and the `Requestable` has been specialized with a `ResponseError` of type `HTTPError`.

If you don't want to bother with validation at all, just specialize your `Requestable` with `Error`, and every completed `RequestResponse` will be allowed to pass.

## ComposableRequest

If you don't want to create your own types that conform to `Requestable`, Ombi provides a reusable generic value type, `ComposableRequest`, that you dynamically configure at runtime. `ComposableRequest` has a closure-based syntax that allows your instance to capture unrelated values. The closures are not executed until the request is actually made. The first example in this document, written with a custom `Requestable` type, might look like this when expressed with a `ComposableRequest`

```swift
let cancellable = ComposableRequest<AnyJSON, String, HTTPError>()
    .path("/posts/update")
    .method(.post)
    .headers {
        // ... capture some things or do some work ...
        [
            .contentType: .contentType(.json),
            .acceptType: .contentType(.json)
        ]
    }
    .body {
        // ... capture some things or do some work ...
        [
            "title" : "My New Post",
            "body" : "lorem ipsum dolor sit amit"
        ]
    }
    .send(on: "https://api.myapp.com")
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            // ... handle error here ...
        }
    }, recieveValue: { response in
        // ... handle response here ...
    })
```
