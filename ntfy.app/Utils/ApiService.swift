import Foundation

class ApiService {
    static let shared = ApiService()

    func validateTopic(baseUrl: String, topic: String, user: String?, completion: @escaping (Result<Void, ApiError>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/\(topic)/json?since=all&poll=1") else {
            completion(.failure(.networkError("Invalid URL")))
            return
        }

        var request = URLRequest(url: url)
        if let user = user {
            request.setValue("Basic \(Data("\(user):".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }

            switch httpResponse.statusCode {
            case 200:
                completion(.success(()))
            case 401:
                completion(.failure(.unauthorized))
            default:
                completion(.failure(.networkError("HTTP status code: \(httpResponse.statusCode)")))
            }
        }
        task.resume()
    }

    func getMessages(for topic: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        guard let url = URL(string: "https://ntfy.sh/\(topic)/json?since=all&poll=1") else {
            completion(.failure(ApiError.networkError("Invalid URL")))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ApiError.networkError("No data received")))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            } else {
                print("Failed to convert data to string")
            }

            do {
                let jsonStrings = String(data: data, encoding: .utf8)?.components(separatedBy: "\n").filter { !$0.isEmpty } ?? []
                let messages = try jsonStrings.map { jsonString -> Message in
                    let jsonData = Data(jsonString.utf8)
                    return try JSONDecoder().decode(Message.self, from: jsonData)
                }
                completion(.success(messages))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func sendMessage(_ message: String, to topic: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://ntfy.sh/\(topic)") else {
            completion(.failure(ApiError.networkError("Invalid URL")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = message.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        task.resume()
    }

    func subscribeToMessages(topic: String, completion: @escaping (Result<Message, Error>) -> Void) {
        guard let url = URL(string: "https://ntfy.sh/\(topic)/json?since=all") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        Task {
            do {
                let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)

                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP request failed with status code \(httpResponse.statusCode)"])
                }

                var buffer = Data()

                for try await byte in asyncBytes {
                    buffer.append(byte)

                    if let jsonString = String(data: buffer, encoding: .utf8), jsonString.contains("\n") {
                        if let data = jsonString.data(using: .utf8) {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    let time = json["time"] as? Int ?? 0
                                    let topic = json["topic"] as? String ?? ""
                                    let priority = json["priority"] as? Int ?? 0
                                    let message = json["message"] as? String ?? ""

                                    let newMessage = Message(time: time, message: message, topic: topic, priority: priority, tags: json["tags"] as? [String], click: json["click"] as? String)
                                    completion(.success(newMessage))
                                } else {
                                    completion(.failure(ApiError.jsonParsingError("Failed to parse JSON: \(jsonString)")))
                                }
                            } catch {
                                completion(.failure(error))
                            }
                        }
                        buffer = Data()
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
