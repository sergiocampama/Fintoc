import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Response: Equatable {
    public let httpResponse: HTTPURLResponse
    public let data: Data

    public init(httpResponse: HTTPURLResponse, data: Data) {
        self.httpResponse = httpResponse
        self.data = data
    }

    var statusCode: Int {
        httpResponse.statusCode
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
