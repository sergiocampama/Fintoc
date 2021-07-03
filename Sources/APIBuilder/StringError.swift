public struct StringError: Error {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}
