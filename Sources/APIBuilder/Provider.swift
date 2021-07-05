import Foundation
@_implementationOnly import WebLinking

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

    public func syncRequest<T: Codable>(_ endpoint: APIEndpoint<Paged<T>>) throws -> Paged<T> {
        var result: Result<Paged<T>, Error>? = nil
        request(endpoint) { innerResult in
            result = innerResult
        }
        while result == nil && RunLoop.current.run(mode: .default, before: .distantPast) {
            usleep(1)
        }
        return try result!.get()
    }

    #if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 12.0, *)
    public func asyncRequest(_ endpoint: APIEndpoint<Void>) async throws {
        let request = requestForEndpoint(endpoint)
        let response = try await requestExecutor.execute(request)
        try validate(response: response)
    }

    @available(swift 5.5)
    @available(macOS 12.0, *)
    public func asyncRequest<T: Codable>(_ endpoint: APIEndpoint<T>) async throws -> T {
        let request = requestForEndpoint(endpoint)
        let response = try await requestExecutor.execute(request)
        return try unpack(response: response)
    }

    @available(swift 5.5)
    @available(macOS 12.0, *)
    public func asyncRequest<T: Codable>(_ endpoint: APIEndpoint<Paged<T>>) async throws -> Paged<T> {
        let request = requestForEndpoint(endpoint)
        let response = try await requestExecutor.execute(request)
        let data = try unpack(response: response) as T

        let pageLinks = self.pageLinks(from: response.httpResponse, for: endpoint)
        return Paged(data: data, pageLinks: pageLinks)
    }
    #endif

    public func request(_ endpoint: APIEndpoint<Void>, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = requestForEndpoint(endpoint)
        requestExecutor.execute(request) { result in
            let newResult: Result<Void, Error> = result.flatMap { response in
                do {
                    try self.validate(response: response)
                    return .success(())
                } catch {
                    return .failure(error)
                }
            }
            completion(newResult)
        }
    }

    public func request<T: Codable>(_ endpoint: APIEndpoint<T>, completion: @escaping (Result<T, Error>) -> Void) {
        let request = requestForEndpoint(endpoint)
        requestExecutor.execute(request) { result in
            let newResult: Result<T, Error> = result.flatMap { response in
                do {
                    return try .success(self.unpack(response: response))
                } catch {
                    return .failure(error)
                }
            }
            completion(newResult)
        }
    }

    public func request<T: Codable>(
        _ endpoint: APIEndpoint<Paged<T>>,
        completion: @escaping (Result<Paged<T>, Error>) -> Void
    ) {
        let request = requestForEndpoint(endpoint)
        requestExecutor.execute(request) { result in
            let newResult: Result<Paged<T>, Error> = result.flatMap { response in
                do {
                    let data = try self.unpack(response: response) as T
                    let pageLinks = self.pageLinks(from: response.httpResponse, for: endpoint)
                    return .success(Paged(data: data, pageLinks: pageLinks))

                } catch {
                    return .failure(error)
                }
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

    private func validate(response: Response) throws {
        guard response.statusCode >= 200 && response.statusCode < 300 else {
            let body = String(decoding: response.data, as: UTF8.self)
            throw StringError("Received status code \(response.statusCode): \(body)")
        }
    }

    private func unpack<T: Codable>(response: Response) throws -> T {
        try validate(response: response)
        do {
            let decoded = try JSONDecoder().decode(T.self, from: response.data)
            return decoded
        } catch {
            let body = String(decoding: response.data, as: UTF8.self)
            throw StringError("Error decoding: \(error) \(body)")
        }
    }

    private func pageLinks<T>(
        from response: HTTPURLResponse,
        for endpoint: APIEndpoint<Paged<T>>
    ) -> [String: APIEndpoint<Paged<T>>] {
        response.links.filter { link in
            link.relationType != nil
        }.reduce(into: [:]) { dictionary, link in
            let components = URLComponents(string: link.uri)!
            let parameters = (components.queryItems ?? []).reduce(into: [String: Any]()) { $0[$1.name] = $1.value }
            dictionary[link.relationType!] = endpoint.replacing(path: components.path, parameters: parameters)
        }
    }
}
