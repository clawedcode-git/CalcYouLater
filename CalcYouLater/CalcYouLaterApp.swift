import SwiftUI

@main
struct CalcYouLaterApp: App {
    @StateObject private var engine = CalculatorEngine()
    @AppStorage("appearanceMode") private var appearanceMode = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
                .preferredColorScheme(resolvedScheme)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appInfo) {
                Button("Clear History") { engine.clearHistory() }
                    .keyboardShortcut("k", modifiers: [.command, .shift])
            }
        }
    }

    private var resolvedScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }
}
