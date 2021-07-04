import APIBuilder
import Foundation

public extension APIEndpoint where T == [Link] {
    static func getLinks() -> APIEndpoint {
        APIEndpoint {
            "/v1/links"
            HTTPMethod.get
        }
    }
}

public extension APIEndpoint where T == Link {
    static func getLink(linkKey: String) -> Self {
        APIEndpoint {
            "/v1/links/\(linkKey)"
            HTTPMethod.get
        }
    }

    static func updateLink(linkKey: String, active: Bool) -> Self {
        APIEndpoint {
            "/v1/links/\(linkKey)"
            HTTPMethod.get
            [String: String]()
            try! JSONEncoder().encode(["active": active])
            "application/json"
        }
    }
}

public extension APIEndpoint where T == Void {
    static func deleteLink(linkKey: String) -> Self {
        APIEndpoint {
            "/v1/links/\(linkKey)"
            HTTPMethod.delete
        }
    }
}
