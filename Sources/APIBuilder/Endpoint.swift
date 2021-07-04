import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct APIEndpoint<T> {
    let path: String
    let method: HTTPMethod
    let parameters: [String: String]?
    let body: Data?
    let contentType: String?

    public init(@APIEndpointBuilder<T> builder: () -> APIEndpoint) {
        self = builder()
    }

    public init(
        path: String,
        method: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        contentType: String? = nil
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.body = body
        self.contentType = contentType
    }
}

@resultBuilder
public struct APIEndpointBuilder<T> {
    public static func buildBlock(
        _ path: String,
        _ method: HTTPMethod = .get,
        _ parameters: [String: String]? = nil,
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
}
