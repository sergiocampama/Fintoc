import APIBuilder
import TestHelpers
import XCTest

final class ProviderTests: XCTestCase {
    let configuration = MockConfiguration(host: URL(string: "https://some.api.com")!)
    let group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

    struct SomeCodable: Codable, Equatable {
        let message: String
    }

    func testVoidRequest() throws {
        let expectedResponse = Response(statusCode: 200, data: Data())
        let mockExecutor = MockRequestExecutor(group: group, expectedResult: .success(expectedResponse))
        let endpoint = APIEndpoint<Void>(path: "/someResource")

        let apiProvider = APIProvider(configuration: configuration, group: group, requestExecutor: mockExecutor)

        let expectation = XCTestExpectation(description: "Response")
        apiProvider.request(endpoint).whenComplete { result in
            XCTAssertTrue(result.isSuccess)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testDataRequest() throws {
        let expectedMessage = SomeCodable(message: "hello, world!")

        let expectedResponse = try Response(statusCode: 200, data: JSONEncoder().encode(expectedMessage))
        let mockExecutor = MockRequestExecutor(group: group, expectedResult: .success(expectedResponse))
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")

        let apiProvider = APIProvider(configuration: configuration, group: group, requestExecutor: mockExecutor)

        let expectation = XCTestExpectation(description: "Response")
        apiProvider.request(endpoint).whenComplete { result in
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
        let mockExecutor = MockRequestExecutor(group: group, expectedResult: .success(expectedResponse))
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")

        let apiProvider = APIProvider(configuration: configuration, group: group, requestExecutor: mockExecutor)

        let response = try apiProvider.request(endpoint).wait()
        XCTAssertEqual(response, expectedMessage)
    }

    #if swift(>=5.5)
    @available(swift 5.5)
    @available(macOS 12.0, *)
    func testAsyncDataRequest() async throws {
        let expectedMessage = SomeCodable(message: "hello, world!")

        let expectedResponse = try Response(statusCode: 200, data: JSONEncoder().encode(expectedMessage))
        let mockExecutor = MockRequestExecutor(group: group, expectedResult: .success(expectedResponse))
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")

        let apiProvider = APIProvider(configuration: configuration, group: group, requestExecutor: mockExecutor)

        let response = try await apiProvider.asyncRequest(endpoint)
        XCTAssertEqual(response, expectedMessage)
    }
    #endif

    func testBasicEndpointRequest() throws {
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")
        let apiProvider = APIProvider(configuration: configuration, group: group)
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

        let apiProvider = APIProvider(configuration: configuration, group: group)
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
        let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")
        let apiProvider = APIProvider(configuration: configuration, group: group)
        let urlRequest = apiProvider.requestForEndpoint(endpoint)
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://some.api.com/someResource")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Authorization"), "my_api_token")
    }
}
