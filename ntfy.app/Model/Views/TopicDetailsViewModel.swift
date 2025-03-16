import SwiftUI

class TopicDetailsViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var newMessageText = ""

    var topic: String

    init(topic: String) {
        self.topic = topic
        loadMessages()
        subscribeToMessages()
    }

    func subscribeToMessages() {
        ApiService.shared.subscribeToMessages(topic: topic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self?.mergeMessages([message])
                case .failure(let error):
                    self?.alertMessage = "Failed to subscribe to messages: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }

    func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        ApiService.shared.sendMessage(newMessageText, to: topic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.newMessageText = ""
                case .failure(let error):
                    self?.alertMessage = "Failed to send message: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }

    private func saveMessages() {
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: "messages_\(topic)")
        }
    }

    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: "messages_\(topic)"),
           let savedMessages = try? JSONDecoder().decode([Message].self, from: data) {
            messages = savedMessages
        }
    }

    private func mergeMessages(_ newMessages: [Message]) {
        let existingMessageIDs = Set(messages.map { $0.id })
        let uniqueNewMessages = newMessages.filter { !existingMessageIDs.contains($0.id) }
        messages.append(contentsOf: uniqueNewMessages)
        saveMessages()
    }
}
