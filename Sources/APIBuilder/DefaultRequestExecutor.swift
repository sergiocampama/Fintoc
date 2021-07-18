import Foundation
import NIO

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class DefaultRequestExecutor: RequestExecutor {
    let urlSession = URLSession(configuration: .default)
    let group: EventLoopGroup

    public init(group: EventLoopGroup) {
        self.group = group
    }

    public func execute(_ request: URLRequest) -> EventLoopFuture<Response> {
        let promise = group.next().makePromise(of: Response.self)
        urlSession.dataTask(with: request) { data, response, error in
            let result: Result<Response, Error>
            if let error = error {
                result = .failure(StringError("\(error)"))
            } else if let response = response as? HTTPURLResponse, let data = data {
                result = .success(Response(httpResponse: response, data: data))
            } else {
                result = .failure(StringError("Unknown error"))
            }
            promise.completeWith(result)
        }.resume()
        return promise.futureResult
    }

    #if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 12.0, *)
    public func execute(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StringError("Unknown error")
        }

        return Response(httpResponse: httpResponse, data: data)
    }
    #endif
}
