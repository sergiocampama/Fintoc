import APIBuilder
import Foundation

public struct MockConfiguration: APIConfiguration {
    public let host: URL
    public let requestHeaders: [String: String]

    public init(host: URL, requestHeaders: [String: String] = [:]) {
        self.host = host
        self.requestHeaders = requestHeaders
    }
}
