import SwiftUI

@main
struct AuraBRApp: App {
    @StateObject private var themes = AuraThemeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themes)
                .preferredColorScheme(.light)
        }
    }
}
