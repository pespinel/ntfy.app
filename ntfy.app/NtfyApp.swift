import SwiftUI
import SwiftData

@main
struct NtfyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Topic.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }.modelContainer(sharedModelContainer)
    }
}
