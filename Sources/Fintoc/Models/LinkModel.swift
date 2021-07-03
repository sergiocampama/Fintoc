import Foundation

public struct Link: Codable {
    public let id: String
    public let object: String
    public let username: String
    public let link_token: String?
    public let holder_type: String
    public let created_at: String
    public let institution: Institution
    public let mode: String
    public let active: Bool
    public let status: String
    public let accounts: [Account]?
}
