import SwiftUI

@main
struct CalcYouLaterApp: App {
    @StateObject private var engine = CalculatorEngine()
    @StateObject private var theme  = AppTheme()
    @AppStorage("appearanceMode") private var appearanceMode = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
                .environmentObject(theme)
                .preferredColorScheme(resolvedScheme)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appInfo) {
                Button("Clear History") { engine.clearHistory() }
                    .keyboardShortcut("k", modifiers: [.command, .shift])
                Divider()
                Button("Toggle NeonBlade Theme") {
                    theme.mode = theme.isNeonBlade ? .standard : .neonBlade
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }

    private var resolvedScheme: ColorScheme? {
        // NeonBlade always forces dark — it's a night-born aesthetic
        if theme.isNeonBlade { return .dark }
        switch appearanceMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }
}
