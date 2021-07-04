import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Response: Equatable {
    public let statusCode: Int
    public let data: Data

    public init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }
}

public protocol RequestExecutor {
    func execute(_ request: URLRequest, completion: @escaping (Result<Response, Error>) -> Void)

    #if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 12.0, *)
    func execute(_ request: URLRequest) async throws -> Response
    #endif
}
