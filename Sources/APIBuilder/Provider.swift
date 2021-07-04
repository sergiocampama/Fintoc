import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class APIProvider {
    let configuration: APIConfiguration
    let requestExecutor: RequestExecutor

    public init(
        configuration: APIConfiguration,
        requestExecutor: RequestExecutor = DefaultRequestExecutor()
    ) {
        self.configuration = configuration
        self.requestExecutor = requestExecutor
    }

    public func syncRequest(_ endpoint: APIEndpoint<Void>) throws {
        var result: Result<Void, Error>? = nil
        request(endpoint) { innerResult in
            result = innerResult
        }
        while result == nil && RunLoop.current.run(mode: .default, before: .distantPast) {
            usleep(1)
        }
        try result!.get()
    }

    public func syncRequest<T: Codable>(_ endpoint: APIEndpoint<T>) throws -> T {
        var result: Result<T, Error>? = nil
        request(endpoint) { innerResult in
            result = innerResult
        }
        while result == nil && RunLoop.current.run(mode: .default, before: .distantPast) {
            usleep(1)
        }
        return try result!.get()
    }

    public func request<T: Codable>(_ endpoint: APIEndpoint<T>, completion: @escaping (Result<T, Error>) -> Void) {
        let request = requestForEndpoint(endpoint)
        requestExecutor.execute(request) { result in
            let newResult: Result<T, Error> = result.flatMap { response in
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    let body = String(decoding: response.data, as: UTF8.self)
                    return .failure(StringError("Received status code \(response.statusCode): \(body)"))
                }
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: response.data)
                    return .success(decoded)
                } catch {
                    return .failure(error)
                }
            }
            completion(newResult)
        }
    }

    public func request(_ endpoint: APIEndpoint<Void>, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = requestForEndpoint(endpoint)
        requestExecutor.execute(request) { result in
            let newResult: Result<Void, Error> = result.flatMap { response in
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    let body = String(decoding: response.data, as: UTF8.self)
                    return .failure(StringError("Received status code \(response.statusCode): \(body)"))
                }
                return .success(())
            }
            completion(newResult)
        }
    }

    public func requestForEndpoint<T>(_ endpoint: APIEndpoint<T>) -> URLRequest {
        var components = URLComponents()
        components.host = configuration.host.host
        components.scheme = configuration.host.scheme
        components.path = endpoint.path
        if let parameters = endpoint.parameters {
            components.queryItems = parameters.map { key, value in URLQueryItem(name: key, value: value) }
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.method.rawValue

        configuration.requestHeaders.forEach { header, value in
            request.setValue(value, forHTTPHeaderField: header)
        }
        if let contentType = endpoint.contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        if let body = endpoint.body {
            request.httpBody = body
        }

        return request
    }
}
