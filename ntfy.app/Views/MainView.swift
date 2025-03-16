import SwiftUI
import SwiftData

struct MainView: View {
    @State var isVisible = false
    @Environment(\.modelContext) private var modelContext
    @Query private var topics: [Topic]
    @State var topicName = ""
    @State var showAlert = false
    @State var alertMessage = ""

    var body: some View {
        NavigationSplitView {
            if topics.isEmpty {
                VStack {
                    Spacer()
                    Text("You don't have any topics yet")
                        .multilineTextAlignment(.center)
                }.padding()
            }
            List {
                ForEach(topics) { item in
                    NavigationLink {
                        TopicDetailsView(topic: item)
                    } label: {
                        Text(item.name)
                    }
                }
                .onDelete(perform: deleteTopics)
            }
            .navigationTitle("Ntfy.app")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .labelStyle(IconOnlyLabelStyle())
                }
                ToolbarItem {
                    Button {
                        isVisible.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isVisible) {
                VStack(spacing: 20) {
                    Text("Add a new topic")
                        .font(.title)
                    Spacer()
                    HStack {
                        Text("https://ntfy.sh/")
                        TextField("topic", text: $topicName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(minWidth: 200)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }.padding()
                    Button(action: {
                        checkAndAddTopic(name: topicName)
                    }, label: {
                        Text("Add")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    })
                    Spacer()
                }.navigationTitle("Add Topic")
                .padding(40)
            }.background(.regularMaterial)
        } detail: {
            Text("Select an item")
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func checkAndAddTopic(name: String) {
        ApiService.shared.validateTopic(baseUrl: "https://ntfy.sh", topic: name, user: nil as String?) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Topic is valid, adding topic: \(name)")
                    addTopic(name: name)
                    $topicName.wrappedValue = ""
                    isVisible.toggle()
                case .failure(let error):
                    switch error {
                    case .unauthorized:
                        print("Unauthorized for topic")
                        alertMessage = "Unauthorized for topic"
                    case .networkError(let message):
                        print("Error checking topic: \(message)")
                        alertMessage = "Invalid topic: \(message)"
                    default:
                        print("Unknown error")
                        alertMessage = "Unknown error"
                    }
                    showAlert = true
                }
            }
        }
    }

    private func addTopic(name: String) {
        withAnimation {
            let newTopic = Topic(name: name)
            modelContext.insert(newTopic)
            do {
                try modelContext.save()
                print("Topic added successfully: \(name)")
            } catch {
                print("Failed to save topic: \(error.localizedDescription)")
                alertMessage = "Failed to save topic"
                showAlert = true
            }
        }
    }

    private func deleteTopics(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(topics[index])
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: Topic.self, inMemory: true)
}
