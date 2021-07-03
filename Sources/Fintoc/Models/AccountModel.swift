import Foundation

public struct Account: Codable {
    public let id: String
    public let object: String
    public let name: String
    public let official_name: String
    public let number: String
    public let holder_id: String
    public let holder_name: String
    public let type: String
    public let currency: String
    public let balance: Balance
    public let refreshed_at: String?
}

public struct Balance: Codable {
    public let available: Int
    public let current: Int
    public let limit: Int
}
