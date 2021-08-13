# Fintoc Swift

[![Fintoc Swift CI](https://github.com/sergiocampama/Fintoc/actions/workflows/ci.yml/badge.svg)](https://github.com/sergiocampama/Fintoc/actions/workflows/ci.yml)

Swift bindings for the [Fintoc](https://fintoc.com) API.

## Example usage

```swift
import Fintoc

let configuration = FintocAPIConfiguration(authToken: "<API Key>")
let provider = APIProvider(configuration: configuration)

// Async API (non-blocking)
provider.request(.getLinks()) { result in
    switch result {
    case .success(let links):
        print(links)
    case .failure(let error):
        print(error)
    }
}

// Sync API (blocking)
let links = try provider.syncRequest(.getLinks())

// Async API (awaiting, only available with Swift 5.5)
let links = try await provider.asyncRequest(.getLinks())
```

You can also check out the `ft` tool which has some basic usages of the API.
