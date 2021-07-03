import APIBuilder
import ArgumentParser
import Fintoc
import Foundation
import KeychainAccess

struct FintocTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ft",
        abstract: "Tool to interface with the Fintoc API"
    )

    func run() throws {
        let configuration = try FintocAPIConfiguration(
            authToken: getAPIKey()
        )
        let provider = APIProvider(configuration: configuration)

        let link = try provider.syncRequest(.getLinks())[0]

        let linkKey = try getLinkKey(for: link)

        let linkDetails = try provider.syncRequest(.getLink(linkID: linkKey))

        linkDetails.accounts?.forEach {
            print($0.name, $0.id, $0.currency, $0.balance.current)
        }

        for account in linkDetails.accounts ?? [] {
            let movements = try provider.syncRequest(.getMovements(linkID: linkKey, accountID: account.id))
            print("Movements for: ", account.name)
            print(movements)
        }
    }

    private func getLinkKey(for link: Link) throws -> String {
        let keychain = Keychain(service: "fintoc")
        if let linkKey = keychain[link.id] {
            return linkKey
        }
        let inputKey = try promptForSecret(prompt: "Enter the link key for \(link.institution.name): ")
        keychain[link.id] = inputKey
        return inputKey
    }

    private func getAPIKey() throws -> String {
        let keychain = Keychain(service: "fintoc")
        if let apiKey = keychain["apiKey"] {
            return apiKey
        }
        let inputKey = try promptForSecret(prompt: "Enter your Fintoc API key: ")
        keychain["apiKey"] = inputKey
        return inputKey
    }

    private func promptForSecret(prompt: String) throws -> String {
        guard let cString = getpass(prompt) else {
            throw StringError("Could not read value from input")
        }

        return String(cString: cString)
    }
}

FintocTool.main()
