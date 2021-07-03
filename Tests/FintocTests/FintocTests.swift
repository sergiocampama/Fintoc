import APIBuilder
import Fintoc
import TestHelpers
import XCTest

final class FintocTests: XCTestCase {
    func testConfiguration() throws {
        let configuration = FintocAPIConfiguration(authToken: "my_api_token")
        let endpoint = APIEndpoint<Void>(path: "/someResource", method: .get)
        let apiProvider = APIProvider(configuration: configuration)
        let urlRequest = apiProvider.requestForEndpoint(endpoint)
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.fintoc.com/someResource")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Authorization"), "my_api_token")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Accept"), "application/json")
    }
}
