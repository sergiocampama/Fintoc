import APIBuilder
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class MockRequestExecutor: RequestExecutor {
    public let expectedResult: Result<Response, Error>

    public init(expectedResult: Result<Response, Error>) {
        self.expectedResult = expectedResult
    }

    public func execute(_ request: URLRequest, completion: @escaping (Result<Response, Error>) -> Void) {
        DispatchQueue.main.async {
            completion(self.expectedResult)
        }
    }
}
