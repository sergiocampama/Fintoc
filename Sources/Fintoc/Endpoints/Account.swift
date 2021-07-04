import APIBuilder

extension APIEndpoint where T == [Account] {
    public static func getAccounts() -> Self {
        APIEndpoint {
            "/v1/accounts"
            HTTPMethod.get
        }
    }
}

extension APIEndpoint where T == Account {
    public static func getAccount(accountID: String) -> Self {
        APIEndpoint {
            "/v1/accounts/\(accountID)"
            HTTPMethod.get
        }
    }
}
