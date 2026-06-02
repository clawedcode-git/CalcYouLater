import SwiftUI
import AppKit

// MARK: - Button Style Enum

enum CalcButtonKind {
    case number, operatorKey, function_, equals, memory, scientific
}

// MARK: - CalcButton

struct CalcButton: View {
    let label: String
    let kind: CalcButtonKind
    var isWide: Bool = false
    var height: CGFloat = 52
    let action: () -> Void

    @State private var isHovering = false

    init(_ label: String, kind: CalcButtonKind, isWide: Bool = false, height: CGFloat = 52, action: @escaping () -> Void) {
        self.label = label
        self.kind = kind
        self.isWide = isWide
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(labelFont)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: isWide ? 0 : 64, maxWidth: isWide ? .infinity : nil)
        .frame(height: height)
        .buttonStyle(CYLButtonStyle(kind: kind, isHovering: isHovering))
        .onHover { isHovering = $0 }
    }

    private var labelFont: Font {
        switch kind {
        case .operatorKey, .equals: return .system(size: 22, weight: .medium)
        case .memory, .scientific:  return .system(size: 13, weight: .medium, design: .rounded)
        case .function_:            return .system(size: 17, weight: .medium)
        default:                    return .system(size: 22, weight: .regular)
        }
    }
}

struct CYLButtonStyle: ButtonStyle {
    let kind: CalcButtonKind
    let isHovering: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(background(pressed: configuration.isPressed))
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }

    private func background(pressed: Bool) -> Color {
        let opacity = pressed ? 0.65 : (isHovering ? 0.88 : 1.0)
        switch kind {
        case .number:      return Color(NSColor.controlColor).opacity(opacity)
        case .operatorKey: return .orange.opacity(opacity)
        case .function_:   return Color(NSColor.tertiaryLabelColor).opacity(pressed ? 0.4 : (isHovering ? 0.28 : 0.22))
        case .equals:      return .orange.opacity(opacity)
        case .memory:      return Color.purple.opacity(pressed ? 0.55 : (isHovering ? 0.7 : 0.6))
        case .scientific:  return Color.indigo.opacity(pressed ? 0.55 : (isHovering ? 0.7 : 0.6))
        }
    }

    private var foreground: Color {
        switch kind {
        case .number, .function_: return .primary
        default:                  return .white
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var engine: CalculatorEngine
    @AppStorage("isScientific")    private var isScientific = false
    @AppStorage("appearanceMode")  private var appearanceMode = "system"
    @State private var showHistory   = false
    @State private var showConverter = false
    @State private var keyMonitor: Any?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // ── Main Calculator ──────────────────────────────────
            VStack(spacing: 0) {
                toolbar
                displayArea
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                if isScientific {
                    ScientificKeypad()
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                standardKeypad
                    .padding(12)
            }
            .frame(width: 316)

            // ── Optional Sidebars ────────────────────────────────
            if showHistory {
                Divider()
                HistoryView()
                    .frame(width: 228)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            if showConverter {
                Divider()
                ConverterView()
                    .frame(width: 228)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .animation(.easeInOut(duration: 0.22), value: showHistory)
        .animation(.easeInOut(duration: 0.22), value: showConverter)
        .animation(.easeInOut(duration: 0.22), value: isScientific)
        .onAppear { setupKeyboard() }
        .onDisappear { teardownKeyboard() }
    }

    // MARK: Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            // Appearance
            Menu {
                Button("System Default") { appearanceMode = "system" }
                Button("Light")          { appearanceMode = "light"  }
                Button("Dark")           { appearanceMode = "dark"   }
            } label: {
                Image(systemName: appearanceIcon)
                    .frame(width: 26, height: 26)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("Appearance")

            Spacer()

            toolbarToggle("Sci", isOn: $isScientific)
                .help("Scientific mode")

            toolbarToggle(icon: "clock.arrow.circlepath", isOn: $showHistory) {
                if showHistory { showConverter = false }
            }
            .help("History")

            toolbarToggle(icon: "arrow.left.arrow.right", isOn: $showConverter) {
                if showConverter { showHistory = false }
            }
            .help("Unit Converter")
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private func toolbarToggle(_ label: String, isOn: Binding<Bool>, onChange: (() -> Void)? = nil) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            onChange?()
        } label: {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isOn.wrappedValue ? Color.accentColor.opacity(0.25) : Color(NSColor.controlColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private func toolbarToggle(icon: String, isOn: Binding<Bool>, onChange: (() -> Void)? = nil) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            onChange?()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13))
                .frame(width: 26, height: 26)
                .background(isOn.wrappedValue ? Color.accentColor.opacity(0.25) : Color(NSColor.controlColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private var appearanceIcon: String {
        switch appearanceMode {
        case "light": return "sun.max.fill"
        case "dark":  return "moon.fill"
        default:      return "circle.lefthalf.filled"
        }
    }

    // MARK: Display

    private var displayArea: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(engine.expression.isEmpty ? " " : engine.expression)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.head)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text(engine.display)
                .font(.system(size: 50, weight: .thin, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.35)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentShape(Rectangle())
                .onTapGesture { copyToClipboard(engine.display) }
                .help("Tap to copy")

            HStack {
                if engine.hasMemory {
                    Text("M: \(engine.fmt(engine.memory))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.purple)
                }
                Spacer()
            }
            .frame(height: 14)
        }
        .frame(height: 100)
    }

    // MARK: Standard Keypad

    private var standardKeypad: some View {
        VStack(spacing: 8) {
            // Memory row
            HStack(spacing: 8) {
                CalcButton("MC",  kind: .memory, height: 36) { engine.memoryClear() }
                CalcButton("MR",  kind: .memory, height: 36) { engine.memoryRecall() }
                CalcButton("M+",  kind: .memory, height: 36) { engine.memoryAdd() }
                CalcButton("M−",  kind: .memory, height: 36) { engine.memorySubtract() }
            }

            // Row 1
            HStack(spacing: 8) {
                CalcButton(engine.clearLabel, kind: .function_) { engine.clear() }
                CalcButton("+/−", kind: .function_)  { engine.toggleSign() }
                CalcButton("%",   kind: .function_)  { engine.percent() }
                CalcButton("÷",   kind: .operatorKey) { engine.inputOperator("÷") }
            }
            // Row 2
            HStack(spacing: 8) {
                CalcButton("7", kind: .number) { engine.inputDigit("7") }
                CalcButton("8", kind: .number) { engine.inputDigit("8") }
                CalcButton("9", kind: .number) { engine.inputDigit("9") }
                CalcButton("×", kind: .operatorKey) { engine.inputOperator("×") }
            }
            // Row 3
            HStack(spacing: 8) {
                CalcButton("4", kind: .number) { engine.inputDigit("4") }
                CalcButton("5", kind: .number) { engine.inputDigit("5") }
                CalcButton("6", kind: .number) { engine.inputDigit("6") }
                CalcButton("−", kind: .operatorKey) { engine.inputOperator("−") }
            }
            // Row 4
            HStack(spacing: 8) {
                CalcButton("1", kind: .number) { engine.inputDigit("1") }
                CalcButton("2", kind: .number) { engine.inputDigit("2") }
                CalcButton("3", kind: .number) { engine.inputDigit("3") }
                CalcButton("+", kind: .operatorKey) { engine.inputOperator("+") }
            }
            // Row 5 — wide zero
            HStack(spacing: 8) {
                CalcButton("0", kind: .number, isWide: true) { engine.inputDigit("0") }
                CalcButton(".", kind: .number) { engine.inputDecimal() }
                CalcButton("=", kind: .equals) { engine.equals() }
            }
        }
    }

    // MARK: Keyboard

    private func setupKeyboard() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak engine] event in
            guard let engine = engine else { return event }
            let key = event.charactersIgnoringModifiers ?? ""
            let mods = event.modifierFlags

            if mods.contains(.command) { return event }

            switch key {
            case "0","1","2","3","4","5","6","7","8","9":
                engine.inputDigit(key)
            case ".": engine.inputDecimal()
            case "+": engine.inputOperator("+")
            case "-": engine.inputOperator("−")
            case "*": engine.inputOperator("×")
            case "/": engine.inputOperator("÷")
            case "=", "\r": engine.equals()
            case "%": engine.percent()
            case "c", "C": engine.clear()
            case "\u{7F}": engine.backspace()   // delete key
            case "\u{1B}": engine.allClear()    // escape
            default: return event
            }
            return nil
        }
    }

    private func teardownKeyboard() {
        if let m = keyMonitor { NSEvent.removeMonitor(m); keyMonitor = nil }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
