import APIBuilder

extension APIEndpoint where T == Paged<[Movement]> {
    public static func getMovements(linkKey: String, accountID: String, page: Int = 1, perPage: Int = 30) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)/movements"
            HTTPMethod.get
            [
                "link_token": linkKey,
                "per_page": perPage,
                "page": page,
            ]
        }
    }
}

extension APIEndpoint where T == Movement {
    public static func getMovement(linkKey: String, accountID: String, movementID: String) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)/movements/\(movementID)"
            HTTPMethod.get
            ["link_token": linkKey]
        }
    }
}
