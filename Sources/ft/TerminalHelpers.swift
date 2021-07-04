import APIBuilder
import Foundation

enum TerminalHelpers {
    static func agree(prompt: String) throws -> Bool {
        while true {
            print(prompt, "[Y/n]: ", terminator: "")
            guard let input = readLine(strippingNewline: true) else {
                throw StringError("Couldn't read input from user")
            }

            switch input.lowercased() {
            case "y", "yes":
                return true
            case "n", "no":
                return false
            default:
                break
            }
        }
    }

    static func choose(prompt: String, options: [String]) throws -> Int {
        guard options.count > 1 else {
            throw StringError("Requested choice for too few options")
        }

        options.enumerated().forEach { option in
            print("[\(option.offset + 1)]", option.element)
        }

        while true {
            print(prompt, "[1-\(options.count)]: ", terminator: "")
            guard let input = readLine(strippingNewline: true) else {
                throw StringError("Couldn't read input from user")
            }

            guard let index = Int(input), index > 0, index <= options.count else {
                continue
            }

            return index - 1
        }
    }

    static func requestSecret(prompt: String) throws -> String {
        guard let cString = getpass(prompt) else {
            throw StringError("Could not read value from input")
        }

        return String(cString: cString)
    }
}
