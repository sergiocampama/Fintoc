import Foundation

public struct Movement: Codable {
    public let id: String
    public let object: String
    public let amount: Int
    public let post_date: String
    public let description: String
    public let transaction_date: String
    public let currency: String
    public let reference_id: String
    public let type: String
    public let pending: Bool
    public let recipient_account: TransferAccount
    public let sender_account: TransferAccount
    public let comment: String
}

public struct TransferAccount: Codable {
    public let holder_id: String
    public let holder_name: String
    public let number: String
    public let institution: Institution
}
