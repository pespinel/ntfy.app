import SwiftUI

struct TopicDetailsView: View {
    @StateObject private var viewModel: TopicDetailsViewModel

    init(topic: Topic) {
        _viewModel = StateObject(wrappedValue: TopicDetailsViewModel(topic: topic.name))
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                List(viewModel.messages, id: \.id) { message in
                    VStack(alignment: .leading) {
                        Text(timestampToDate(timestamp: message.time))
                            .font(.caption)
                        Text(message.message)
                    }
                    .padding(.vertical)
                    .listRowInsets(.init())
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 0)
                .onChange(of: viewModel.messages) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
                HStack {
                    TextField("Enter message", text: $viewModel.newMessageText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    Button {
                        viewModel.sendMessage()
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    } label: {
                        Text("Send")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("\(viewModel.topic)")
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    NavigationView {
        TopicDetailsView(topic: Topic(name: "test"))
    }
}
