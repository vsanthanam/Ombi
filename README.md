# Ombi
Elegent reactive networking with Combine and Swift

## Introduction

Ombi is a simple library built on top of `URLSession` and `Combine` that makes it very easy to make asynchronous network requests with reactive programming.

## Basics

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
    
    typealias ResponseError == HTTPError
    
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
let myLog = OSLog(subsystem: "com.developer.subsystem", category: "api.myapp")

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

### RequestResponse

### RequestError and Validation

## ComposableRequest
