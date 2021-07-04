import APIBuilder

public extension APIEndpoint where T == [Movement] {
    static func getMovements(linkKey: String, accountID: String) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)/movements"
            HTTPMethod.get
            ["link_token": linkKey]
        }
    }
}

public extension APIEndpoint where T == Movement {
    static func getMovement(linkKey: String, accountID: String, movementID: String) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)/movements/\(movementID)"
            HTTPMethod.get
            ["link_token": linkKey]
        }
    }
}
