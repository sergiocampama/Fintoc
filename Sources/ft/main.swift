import ArgumentParser
import Fintoc
import Foundation

#if os(macOS)
import KeychainAccess
#endif

struct FintocTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ft",
        abstract: "Tool to interface with the Fintoc API"
    )

    func run() throws {
        let configuration = try FintocAPIConfiguration(
            authToken: getSecret("apiKey", prompt: "Enter your Fintoc API key")
        )
        let provider = APIProvider(configuration: configuration)

        let links = try provider.syncRequest(.getLinks())

        let sparseLink: Link
        if links.isEmpty {
            print("No links were found")
            return
        } else if links.count > 1 {
            let index = try TerminalHelpers.choose(
                prompt: "Which link do you want work with?",
                options: links.map(\.institution.name)
            )
            sparseLink = links[index]
        } else {
            sparseLink = links[0]
            print("Using link for \(sparseLink.institution.name)")
        }

        let linkKey = try getSecret(
            sparseLink.id,
            prompt: "Enter the link key for \(sparseLink.institution.name)"
        )

        let link = try provider.syncRequest(.getLink(linkKey: linkKey))

        guard let accounts = link.accounts, !accounts.isEmpty else {
            print("No accounts found for \(link.institution.name)")
            return
        }

        let account: Account
        if accounts.count == 1 {
            account = accounts[0]
            print("Using account \(account.name)")
        } else {
            let index = try TerminalHelpers.choose(
                prompt: "Which account do you want work with?",
                options: accounts.map { "\($0.name) - \($0.number) - \($0.official_name)" }
            )
            account = accounts[index]
        }

        print(account.name, account.balance.available, account.currency)

        guard try TerminalHelpers.agree(prompt: "Would you like to see your movements?") else {
            return
        }

        let movements = try provider.syncRequest(.getMovements(linkKey: linkKey, accountID: account.id))

        if movements.isEmpty {
            print("No movements to display")
        } else {
            movements.forEach {
                print($0.comment)
            }
        }
    }

    private func getSecret(_ key: String, prompt: String) throws -> String {
        #if os(macOS)
        let keychain = Keychain(service: "fintoc").accessibility(.alwaysThisDeviceOnly)
        if let apiKey = keychain[key] {
            return apiKey
        }
        #endif

        let inputKey = try TerminalHelpers.requestSecret(prompt: "\(prompt): ")

        #if os(macOS)
        keychain[key] = inputKey
        #endif

        return inputKey
    }
}

FintocTool.main()
