import APIBuilder
import Foundation

extension APIEndpoint where T == [Link] {
    public static func getLinks() -> APIEndpoint {
        APIEndpoint { "/v1/links" }
    }
}

extension APIEndpoint where T == Link {
    public static func getLink(linkKey: String) -> Self {
        APIEndpoint { "/v1/links/\(linkKey)" }
    }

    public static func updateLink(linkKey: String, active: Bool) -> Self {
        let body = try! JSONEncoder().encode(["active": active])
        return APIEndpoint {
            "/v1/links/\(linkKey)"
            body
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
