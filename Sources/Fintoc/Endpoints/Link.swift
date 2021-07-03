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
    static func getLink(linkID: String) -> Self {
        APIEndpoint {
            "/v1/links/\(linkID)"
            HTTPMethod.get
        }
    }

    static func updateLink(linkID: String, active: Bool) -> Self {
        APIEndpoint {
            "/v1/links/\(linkID)"
            HTTPMethod.get
            [String: String]()
            try! JSONEncoder().encode(["active": active])
            "application/json"
        }
    }
}

public extension APIEndpoint where T == Void {
    static func deleteLink(linkID: String) -> Self {
        APIEndpoint {
            "/v1/links/\(linkID)"
            HTTPMethod.delete
        }
    }
}
