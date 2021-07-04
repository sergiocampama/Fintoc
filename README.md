# Fintoc Swift

Swift bindings for the [Fintoc](https://fintoc.com) API.

## Example usage

```swift
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
```

You can also check out the `ft` tool which has some basic usages of the API.

## Acknowledgments

The API infrastructure was designed pretty much verbatim (with some _very_ minor differences) from the one in
[AvdLee/appstoreconnect-swift-sdk](https://github.com/AvdLee/appstoreconnect-swift-sdk). They do say copying is the 
sincerest form of flattery :) 
 
