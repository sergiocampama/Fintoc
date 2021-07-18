import Foundation
@_exported import NIO
@_implementationOnly import WebLinking

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class APIProvider {
    let configuration: APIConfiguration
    let requestExecutor: RequestExecutor
    let group: EventLoopGroup

    public init(
        configuration: APIConfiguration,
        group: EventLoopGroup,
        requestExecutor: RequestExecutor? = nil
    ) {
        self.configuration = configuration
        self.group = group
        self.requestExecutor = requestExecutor ?? DefaultRequestExecutor(group: group)
    }

    public func request(_ endpoint: APIEndpoint<Void>) -> EventLoopFuture<Void> {
        let request = requestForEndpoint(endpoint)
        return requestExecutor.execute(request).flatMapThrowing { response in
            try self.validate(response: response)
            return ()
        }
    }

    public func request<T: Codable>(_ endpoint: APIEndpoint<T>) -> EventLoopFuture<T> {
        let request = requestForEndpoint(endpoint)
        return requestExecutor.execute(request).flatMapThrowing { response in
            return try self.unpack(response: response)
        }
    }

    public func request<T: Codable>(_ endpoint: APIEndpoint<Paged<T>>) -> EventLoopFuture<Paged<T>> {
        let request = requestForEndpoint(endpoint)
        return requestExecutor.execute(request).flatMapThrowing { response in
            let data = try self.unpack(response: response) as T
            let pageLinks = self.pageLinks(from: response.httpResponse, for: endpoint)
            return Paged(data: data, pageLinks: pageLinks)
        }
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
    public func asyncRequest<T: Codable>(
      _ endpoint: APIEndpoint<Paged<T>>
    ) async throws -> Paged<T> {
        let request = requestForEndpoint(endpoint)
        let response = try await requestExecutor.execute(request)
        let data = try unpack(response: response) as T

        let pageLinks = self.pageLinks(from: response.httpResponse, for: endpoint)
        return Paged(data: data, pageLinks: pageLinks)
    }
    #endif

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
