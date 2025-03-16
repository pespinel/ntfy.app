import Testing
@testable import ntfy_app

struct ApiServiceTests {

    @Test func testValidateTopicSuccess() async throws {
        ApiService.shared.validateTopic(baseUrl: "https://ntfy.sh", topic: "test-topic", user: nil) { result in
            switch result {
            case .success:
                #expect(true)
            case .failure:
                #expect(Bool(false), "Expected success but got failure")
            }
        }
    }

    @Test func testValidateTopicUnauthorized() async throws {
        ApiService.shared.validateTopic(baseUrl: "https://ntfy.sh", topic: "unauthorized-topic", user: "invalidUser") { result in
            switch result {
            case .success:
                #expect(Bool(false), "Expected failure but got success")
            case .failure(let error):
                #expect(error == ApiError.unauthorized)
            }
        }
    }

    @Test func testGetMessagesSuccess() async throws {
        ApiService.shared.getMessages(for: "test-topic") { result in
            switch result {
            case .success(let messages):
                #expect(!messages.isEmpty)
            case .failure:
                #expect(Bool(false), "Expected success but got failure")
            }
        }
    }

    @Test func testSendMessageSuccess() async throws {
        ApiService.shared.sendMessage("Test message", to: "test-topic") { result in
            switch result {
            case .success:
                #expect(true)
            case .failure:
                #expect(Bool(false), "Expected success but got failure")
            }
        }
    }

    @Test func testSubscribeToMessagesSuccess() async throws {
        ApiService.shared.subscribeToMessages(topic: "test-topic") { result in
            switch result {
            case .success(let message):
                #expect(message != nil)
            case .failure:
                #expect(Bool(false), "Expected success but got failure")
            }
        }
    }
}
