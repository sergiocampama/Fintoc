import APIBuilder
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class MockRequestExecutor: RequestExecutor {
    public let group: EventLoopGroup

    public let expectedResult: Result<Response, Error>

    public init(group: EventLoopGroup, expectedResult: Result<Response, Error>) {
        self.group = group
        self.expectedResult = expectedResult
    }

    public func execute(_ request: URLRequest) -> EventLoopFuture<Response> {
        return group.next().makeCompletedFuture(expectedResult)
    }

    #if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 12.0, *)
    public func execute(_ request: URLRequest) async throws -> Response {
        return try expectedResult.get()
    }
    #endif
}

extension Response {
    public init(statusCode: Int, data: Data) {
        self.init(
            httpResponse: HTTPURLResponse(
                url: URL(string: "http://some.data")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!,
            data: data
        )
    }
}
