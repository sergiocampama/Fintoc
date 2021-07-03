import Foundation

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
}
