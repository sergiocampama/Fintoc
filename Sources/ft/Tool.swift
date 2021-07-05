import ArgumentParser
import Fintoc
import Foundation

#if os(macOS)
import KeychainAccess
#endif

@main
struct FintocTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ft",
        abstract: "Tool to interface with the Fintoc API"
    )

    @Option()
    var movementsPerPage = 30

    func run() async throws {
        let configuration = try FintocAPIConfiguration(
            authToken: getSecret("apiKey", prompt: "Enter your Fintoc API key")
        )
        let provider = APIProvider(configuration: configuration)

        let links = try await provider.asyncRequest(.getLinks())

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

        let link = try await provider.asyncRequest(.getLink(linkKey: linkKey))

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

        var endpoint: APIEndpoint? = APIEndpoint.getMovements(
            linkKey: linkKey,
            accountID: account.id,
            perPage: movementsPerPage
        )

        repeat {
            let movements = try await provider.asyncRequest(endpoint!)

            movements.data.forEach {
                print($0.description, $0.amount)
            }

            guard try movements.last != endpoint && TerminalHelpers.agree(prompt: "Continue?") else {
                break
            }
            endpoint = movements.next
        } while endpoint != nil
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
