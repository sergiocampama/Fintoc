import APIBuilder
import TestHelpers
import XCTest

final class ProviderTests: XCTestCase {
    let configuration = MockConfiguration(host: URL(string: "https://some.api.com")!)

    struct SomeCodable: Codable, Equatable {
        let message: String
    }

    func testVoidRequest() throws {
        let expectedResponse = Response(statusCode: 200, data: Data())
        let mockExecutor = MockRequestExecutor(expectedResult: .success(expectedResponse))
        let endpoint = APIEndpoint<Void>(path: "/someResource", method: .get)

        let apiProvider = APIProvider(configuration: configuration, requestExecutor: mockExecutor)

        let expectation = XCTestExpectation(description: "Response")
        apiProvider.request(endpoint) { result in
            XCTAssertTrue(result.isSuccess)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

    }

    func testDataRequest() throws {
        let expectedMessage = SomeCodable(message: "hello, world!")

        let expectedResponse = try Response(statusCode: 200, data: JSONEncoder().encode(expectedMessage))
        let mockExecutor = MockRequestExecutor(expectedResult: .success(expectedResponse))
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource", method: .get)

        let apiProvider = APIProvider(configuration: configuration, requestExecutor: mockExecutor)

        let expectation = XCTestExpectation(description: "Response")
        apiProvider.request(endpoint) { result in
            XCTAssertTrue(result.isSuccess)
            let response = try! result.get()
            XCTAssertEqual(response, expectedMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSyncDataRequest() throws {
        let expectedMessage = SomeCodable(message: "hello, world!")

        let expectedResponse = try Response(statusCode: 200, data: JSONEncoder().encode(expectedMessage))
        let mockExecutor = MockRequestExecutor(expectedResult: .success(expectedResponse))
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource", method: .get)

        let apiProvider = APIProvider(configuration: configuration, requestExecutor: mockExecutor)

        let response = try apiProvider.syncRequest(endpoint)
        XCTAssertEqual(response, expectedMessage)
    }

    func testBasicEndpointRequest() throws {
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource", method: .get)
        let apiProvider = APIProvider(configuration: configuration)
        let urlRequest = apiProvider.requestForEndpoint(endpoint)
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://some.api.com/someResource")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
    }

    func testComplexEndpointRequest() throws {
        let endpoint = APIEndpoint<SomeCodable>(
            path: "/someResource",
            method: .post,
            parameters: ["query": "item"],
            body: Data([1, 2, 3]),
            contentType: "application/octet-stream"
        )

        let apiProvider = APIProvider(configuration: configuration)
        let urlRequest = apiProvider.requestForEndpoint(endpoint)
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://some.api.com/someResource?query=item")
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.httpBody, Data([1, 2, 3]))
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
    }

    func testConfiguration() throws {
        let configuration = MockConfiguration(
            host: URL(string: "https://some.api.com")!,
            requestHeaders: ["Authorization": "my_api_token"]
        )
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource", method: .get)
        let apiProvider = APIProvider(configuration: configuration)
        let urlRequest = apiProvider.requestForEndpoint(endpoint)
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://some.api.com/someResource")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Authorization"), "my_api_token")
    }
}
