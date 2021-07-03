import Foundation

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
}
