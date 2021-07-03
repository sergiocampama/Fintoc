import Foundation

public protocol APIConfiguration {
    var host: URL { get }
    var requestHeaders: [String: String] { get }
}
