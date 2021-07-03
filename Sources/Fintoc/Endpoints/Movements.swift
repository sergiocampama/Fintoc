import APIBuilder

public extension APIEndpoint where T == [Movement] {
    static func getMovements(linkID: String, accountID: String) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)/movements"
            HTTPMethod.get
            ["link_token": linkID]
        }
    }
}

public extension APIEndpoint where T == Movement {
    static func getMovement(linkID: String, accountID: String, movementID: String) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)/movements/\(movementID)"
            HTTPMethod.get
            ["link_token": linkID]
        }
    }
}
