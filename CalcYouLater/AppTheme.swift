import SwiftUI
import AppKit

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Corner-Cut Shape (NeonBlade signature geometry)
//
//  Top-left + bottom-right corners are diagonally clipped —
//  the classic "blade" aesthetic used throughout NeonBlade UI.

struct CornerCutShape: Shape {
    var cutSize: CGFloat = 9

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: cutSize,           y: 0))
        p.addLine(to: CGPoint(x: rect.width,     y: 0))
        p.addLine(to: CGPoint(x: rect.width,     y: rect.height - cutSize))
        p.addLine(to: CGPoint(x: rect.width - cutSize, y: rect.height))
        p.addLine(to: CGPoint(x: 0,              y: rect.height))
        p.addLine(to: CGPoint(x: 0,              y: cutSize))
        p.closeSubpath()
        return p
    }
}

// MARK: - Theme Mode

enum ThemeMode: String, CaseIterable {
    case standard  = "standard"
    case neonBlade = "neonBlade"

    var displayName: String {
        switch self {
        case .standard:  return "Standard"
        case .neonBlade: return "NeonBlade"
        }
    }
}

// MARK: - AppTheme (Observable object injected at app root)

final class AppTheme: ObservableObject {

    @Published var mode: ThemeMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: "appTheme") }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? "standard"
        mode = ThemeMode(rawValue: saved) ?? .standard
    }

    var isNeonBlade: Bool { mode == .neonBlade }

    // ── Backgrounds ──────────────────────────────────────────

    var windowBackground: Color {
        isNeonBlade ? Color(hex: "#080b14") : Color(NSColor.windowBackgroundColor)
    }

    var sidebarBackground: Color {
        isNeonBlade ? Color(hex: "#060810") : Color(NSColor.windowBackgroundColor)
    }

    var displayBackground: Color {
        isNeonBlade ? Color(hex: "#04060e") : Color.clear
    }

    var controlBackground: Color {
        isNeonBlade ? Color(hex: "#0c1020") : Color(NSColor.controlBackgroundColor)
    }

    // ── Button Fill Colors ────────────────────────────────────

    var numberButton: Color {
        isNeonBlade ? Color(hex: "#0d1424") : Color(NSColor.controlColor)
    }

    var functionButton: Color {
        isNeonBlade ? Color(hex: "#141c30") : Color(NSColor.tertiaryLabelColor)
    }

    var operatorButton: Color {
        isNeonBlade ? Color(hex: "#003a4a") : .orange
    }

    var equalsButton: Color {
        isNeonBlade ? Color(hex: "#4a0022") : .orange
    }

    var memoryButton: Color {
        isNeonBlade ? Color(hex: "#220047") : .purple
    }

    var scientificButton: Color {
        isNeonBlade ? Color(hex: "#001047") : .indigo
    }

    // ── Neon Accent Colors ────────────────────────────────────

    /// Operator / toolbar accent — electric cyan
    var neonCyan: Color   { Color(hex: "#00d4ff") }
    /// Equals / highlight — hot pink
    var neonPink: Color   { Color(hex: "#ff0066") }
    /// Memory — electric violet
    var neonViolet: Color { Color(hex: "#a020f0") }
    /// Scientific — electric blue
    var neonBlue: Color   { Color(hex: "#0066ff") }

    // ── Text Colors ───────────────────────────────────────────

    var primaryText: Color {
        isNeonBlade ? Color(hex: "#d8f0ff") : .primary
    }

    var secondaryText: Color {
        isNeonBlade ? Color(hex: "#3a6a88") : .secondary
    }

    var tertiaryText: Color {
        isNeonBlade ? Color(hex: "#1e3a50") : Color(NSColor.tertiaryLabelColor)
    }

    var memoryIndicatorColor: Color {
        isNeonBlade ? neonViolet : .purple
    }

    // ── Per-kind Neon Glow & Border ───────────────────────────

    func neonGlow(for kind: CalcButtonKind) -> Color {
        guard isNeonBlade else { return .clear }
        switch kind {
        case .operatorKey: return neonCyan.opacity(0.8)
        case .equals:      return neonPink.opacity(0.9)
        case .memory:      return neonViolet.opacity(0.8)
        case .scientific:  return neonBlue.opacity(0.8)
        default:           return neonCyan.opacity(0.15)
        }
    }

    func neonBorder(for kind: CalcButtonKind) -> Color {
        guard isNeonBlade else { return .clear }
        switch kind {
        case .operatorKey: return neonCyan
        case .equals:      return neonPink
        case .memory:      return neonViolet
        case .scientific:  return neonBlue
        case .function_:   return Color(hex: "#1e3258")
        default:           return Color(hex: "#162040")
        }
    }

    func neonSciBorder() -> Color {
        isNeonBlade ? neonBlue : .clear
    }

    func neonSciGlow() -> Color {
        isNeonBlade ? neonBlue.opacity(0.7) : .clear
    }
}
