import APIBuilder
import Foundation

extension APIEndpoint where T == [Link] {
    public static func getLinks() -> APIEndpoint {
        APIEndpoint {
            "/v1/links"
            HTTPMethod.get
        }
    }
}

extension APIEndpoint where T == Link {
    public static func getLink(linkKey: String) -> Self {
        APIEndpoint {
            "/v1/links/\(linkKey)"
            HTTPMethod.get
        }
    }

    public static func updateLink(linkKey: String, active: Bool) -> Self {
        APIEndpoint {
            "/v1/links/\(linkKey)"
            HTTPMethod.get
            [String: String]()
            try! JSONEncoder().encode(["active": active])
            "application/json"
        }
    }
}

extension APIEndpoint where T == Void {
    public static func deleteLink(linkKey: String) -> Self {
        APIEndpoint {
            "/v1/links/\(linkKey)"
            HTTPMethod.delete
        }
    }
}
