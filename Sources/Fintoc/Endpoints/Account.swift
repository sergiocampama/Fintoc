import APIBuilder

public extension APIEndpoint where T == [Account] {
    static func getAccounts() -> Self {
        APIEndpoint {
            "/v1/accounts"
            HTTPMethod.get
        }
    }
}

public extension APIEndpoint where T == Account {
    static func getAccount(accountID: String) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)"
            HTTPMethod.get
        }
    }
}
