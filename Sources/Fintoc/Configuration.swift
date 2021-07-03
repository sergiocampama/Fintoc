import APIBuilder
import Foundation

public struct FintocAPIConfiguration: APIConfiguration {
    public let host: URL
    public let requestHeaders: [String: String]

    public init(authToken: String, host: URL = URL(string: "https://api.fintoc.com")!) {
        self.host = host
        self.requestHeaders = [
            "Authorization": authToken,
            "Accept": "application/json",
        ]
    }
}
