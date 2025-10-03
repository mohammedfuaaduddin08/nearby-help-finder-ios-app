import SwiftUI
import SwiftData

@main
struct NearbyHelperFinderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Favor.self)
        }
    }
}
