import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct APIEndpoint<T>: Equatable {
    public let path: String
    public let method: HTTPMethod
    public let parameters: [String: String]?
    public let body: Data?
    public let contentType: String?

    public init(@APIEndpointBuilder<T> builder: () -> APIEndpoint) {
        self = builder()
    }

    public init(
        path: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        body: Data? = nil,
        contentType: String? = nil
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters?.mapValues { "\($0)" }
        self.body = body
        self.contentType = contentType
    }

    func replacing(path: String, parameters: [String: Any]? = nil) -> Self {
        return APIEndpoint(
            path: path,
            method: method,
            parameters: parameters?.mapValues { "\($0)" },
            body: body,
            contentType: contentType
        )
    }
}

public struct Paged<T> {
    public let data: T
    public let pageLinks: [String: APIEndpoint<Paged<T>>]
}

@resultBuilder
public struct APIEndpointBuilder<T> {
    public static func buildBlock(
        _ path: String,
        _ method: HTTPMethod = .get,
        _ parameters: [String: Any]? = nil,
        _ body: Data? = nil,
        _ contentType: String? = nil
    ) -> APIEndpoint<T> {
        return APIEndpoint(
            path: path,
            method: method,
            parameters: parameters,
            body: body,
            contentType: contentType
        )
    }

    public static func buildBlock(
        _ path: String,
        _ parameters: [String: Any],
        _ body: Data? = nil,
        _ contentType: String? = nil
    ) -> APIEndpoint<T> {
        return APIEndpoint(
            path: path,
            method: .get,
            parameters: parameters,
            body: body,
            contentType: contentType
        )
    }

    public static func buildBlock(
        _ path: String,
        _ body: Data?,
        _ contentType: String?
    ) -> APIEndpoint<T> {
        return APIEndpoint(
            path: path,
            method: .get,
            parameters: nil,
            body: body,
            contentType: contentType
        )
    }
}
