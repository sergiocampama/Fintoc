import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class DefaultRequestExecutor: RequestExecutor {
    let urlSession = URLSession(configuration: .default)

    public init() {}

    public func execute(_ request: URLRequest, completion: @escaping (Result<Response, Error>) -> Void) {
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(StringError("\(error)")))
            } else if let response = response as? HTTPURLResponse, let data = data {
                completion(.success(Response(statusCode: response.statusCode, data: data)))
            } else {
                completion(.failure(StringError("Unknown error")))
            }
        }.resume()
    }

    #if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 12.0, *)
    public func execute(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StringError("Unknown error")
        }

        return Response(statusCode: httpResponse.statusCode, data: data)
    }
    #endif
}
