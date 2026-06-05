import SwiftUI
import AppKit

// MARK: - Button Style Enum

enum CalcButtonKind {
    case number, operatorKey, function_, equals, memory, scientific
}

// MARK: - CalcButton

struct CalcButton: View {
    @EnvironmentObject var theme: AppTheme

    let label: String
    let kind: CalcButtonKind
    var isWide: Bool = false
    var height: CGFloat = 52
    let action: () -> Void

    @State private var isHovering = false

    init(_ label: String, kind: CalcButtonKind, isWide: Bool = false,
         height: CGFloat = 52, action: @escaping () -> Void) {
        self.label   = label
        self.kind    = kind
        self.isWide  = isWide
        self.height  = height
        self.action  = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(labelFont)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: isWide ? 0 : 64, maxWidth: isWide ? .infinity : nil)
        .frame(height: height)
        .buttonStyle(CYLButtonStyle(kind: kind, isHovering: isHovering, theme: theme))
        .onHover { isHovering = $0 }
    }

    private var labelFont: Font {
        let design: Font.Design = theme.isNeonBlade ? .monospaced : .default
        switch kind {
        case .operatorKey, .equals:
            return .system(size: 22, weight: .medium, design: design)
        case .memory, .scientific:
            return .system(size: 13, weight: .medium, design: theme.isNeonBlade ? .monospaced : .rounded)
        case .function_:
            return .system(size: 17, weight: .medium, design: design)
        default:
            return .system(size: 22, weight: .regular, design: design)
        }
    }
}

// MARK: - CYL Button Style (Standard + NeonBlade)

struct CYLButtonStyle: ButtonStyle {
    let kind: CalcButtonKind
    let isHovering: Bool
    let theme: AppTheme

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        if theme.isNeonBlade {
            neonBody(configuration: configuration, pressed: pressed)
        } else {
            standardBody(configuration: configuration, pressed: pressed)
        }
    }

    // Standard rounded style (unchanged from original)
    private func standardBody(configuration: Configuration, pressed: Bool) -> some View {
        configuration.label
            .background(standardBackground(pressed: pressed))
            .foregroundStyle(standardForeground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(pressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }

    private func standardBackground(pressed: Bool) -> Color {
        let opacity = pressed ? 0.65 : (isHovering ? 0.88 : 1.0)
        switch kind {
        case .number:      return Color(NSColor.controlColor).opacity(opacity)
        case .operatorKey: return .orange.opacity(opacity)
        case .function_:   return Color(NSColor.tertiaryLabelColor)
                               .opacity(pressed ? 0.4 : (isHovering ? 0.28 : 0.22))
        case .equals:      return .orange.opacity(opacity)
        case .memory:      return Color.purple.opacity(pressed ? 0.55 : (isHovering ? 0.7 : 0.6))
        case .scientific:  return Color.indigo.opacity(pressed ? 0.55 : (isHovering ? 0.7 : 0.6))
        }
    }

    private var standardForeground: Color {
        switch kind {
        case .number, .function_: return .primary
        default:                  return .white
        }
    }

    // NeonBlade corner-cut style with glow
    @ViewBuilder
    private func neonBody(configuration: Configuration, pressed: Bool) -> some View {
        let fill   = neonFill(pressed: pressed)
        let border = theme.neonBorder(for: kind)
        let glow   = theme.neonGlow(for: kind)
        let glowR: CGFloat = isHovering ? 9 : (pressed ? 12 : 4)

        configuration.label
            .foregroundStyle(neonForeground)
            .background(fill)
            .clipShape(CornerCutShape())
            .overlay(
                CornerCutShape()
                    .stroke(border.opacity(isHovering ? 1.0 : 0.65), lineWidth: 1)
            )
            .shadow(color: glow, radius: glowR, x: 0, y: 0)
            .scaleEffect(pressed ? 0.93 : 1.0)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }

    private func neonFill(pressed: Bool) -> Color {
        let dim = pressed ? 0.55 : (isHovering ? 0.85 : 1.0)
        switch kind {
        case .number:      return theme.numberButton.opacity(dim)
        case .operatorKey: return theme.operatorButton.opacity(dim)
        case .function_:   return theme.functionButton.opacity(dim)
        case .equals:      return theme.equalsButton.opacity(dim)
        case .memory:      return theme.memoryButton.opacity(dim)
        case .scientific:  return theme.scientificButton.opacity(dim)
        }
    }

    private var neonForeground: Color {
        switch kind {
        case .operatorKey: return theme.neonCyan
        case .equals:      return theme.neonPink
        case .memory:      return theme.neonViolet
        case .scientific:  return theme.neonBlue
        case .function_:   return Color(hex: "#8ab0cc")
        default:           return theme.primaryText
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var engine: CalculatorEngine
    @EnvironmentObject var theme:  AppTheme
    @AppStorage("isScientific")   private var isScientific  = false
    @AppStorage("appearanceMode") private var appearanceMode = "system"
    @State private var showHistory   = false
    @State private var showConverter = false
    @State private var keyMonitor: Any?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // ── Main Calculator ──────────────────────────────────
            VStack(spacing: 0) {
                toolbar
                displayContainer
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
                neonDivider
                HistoryView()
                    .frame(width: 228)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            if showConverter {
                neonDivider
                ConverterView()
                    .frame(width: 228)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .background(theme.windowBackground)
        .animation(.easeInOut(duration: 0.22), value: showHistory)
        .animation(.easeInOut(duration: 0.22), value: showConverter)
        .animation(.easeInOut(duration: 0.22), value: isScientific)
        .animation(.easeInOut(duration: 0.3),  value: theme.mode)
        .onAppear { setupKeyboard() }
        .onDisappear { teardownKeyboard() }
    }

    @ViewBuilder
    private var neonDivider: some View {
        if theme.isNeonBlade {
            Rectangle()
                .fill(theme.neonCyan.opacity(0.25))
                .frame(width: 1)
        } else {
            Divider()
        }
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
                    .foregroundStyle(theme.isNeonBlade ? theme.secondaryText : .primary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("Appearance")

            // NeonBlade theme toggle
            neonBladeToggle

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

    private var neonBladeToggle: some View {
        Button {
            theme.mode = theme.isNeonBlade ? .standard : .neonBlade
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                if theme.isNeonBlade {
                    Text("NB")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                }
            }
            .frame(width: theme.isNeonBlade ? 40 : 26, height: 26)
            .background(
                theme.isNeonBlade
                    ? AnyView(CornerCutShape(cutSize: 6)
                        .fill(theme.neonCyan.opacity(0.15))
                        .overlay(CornerCutShape(cutSize: 6)
                            .stroke(theme.neonCyan.opacity(0.7), lineWidth: 1)))
                    : AnyView(RoundedRectangle(cornerRadius: 6)
                        .fill(Color(NSColor.controlColor)))
            )
            .foregroundStyle(theme.isNeonBlade ? theme.neonCyan : Color.secondary)
            .shadow(color: theme.isNeonBlade ? theme.neonCyan.opacity(0.6) : .clear, radius: 5)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: theme.isNeonBlade)
        .help(theme.isNeonBlade ? "Disable NeonBlade theme" : "Enable NeonBlade theme (⌘⇧T)")
    }

    private func toolbarToggle(_ label: String, isOn: Binding<Bool>,
                                onChange: (() -> Void)? = nil) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            onChange?()
        } label: {
            Text(label)
                .font(.system(size: 11, weight: .semibold,
                              design: theme.isNeonBlade ? .monospaced : .default))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    theme.isNeonBlade
                        ? AnyView(CornerCutShape(cutSize: 5)
                            .fill(isOn.wrappedValue
                                  ? theme.neonCyan.opacity(0.18)
                                  : theme.functionButton)
                            .overlay(CornerCutShape(cutSize: 5)
                                .stroke(isOn.wrappedValue
                                        ? theme.neonCyan.opacity(0.8)
                                        : Color(hex: "#1e3258"), lineWidth: 1)))
                        : AnyView(RoundedRectangle(cornerRadius: 6)
                            .fill(isOn.wrappedValue
                                  ? Color.accentColor.opacity(0.25)
                                  : Color(NSColor.controlColor)))
                )
                .foregroundStyle(
                    theme.isNeonBlade
                        ? (isOn.wrappedValue ? theme.neonCyan : theme.secondaryText)
                        : (isOn.wrappedValue ? Color.accentColor : Color.primary)
                )
                .shadow(color: (theme.isNeonBlade && isOn.wrappedValue)
                        ? theme.neonCyan.opacity(0.5) : .clear, radius: 4)
        }
        .buttonStyle(.plain)
    }

    private func toolbarToggle(icon: String, isOn: Binding<Bool>,
                                onChange: (() -> Void)? = nil) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            onChange?()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13))
                .frame(width: 26, height: 26)
                .background(
                    theme.isNeonBlade
                        ? AnyView(CornerCutShape(cutSize: 6)
                            .fill(isOn.wrappedValue
                                  ? theme.neonCyan.opacity(0.18)
                                  : theme.functionButton)
                            .overlay(CornerCutShape(cutSize: 6)
                                .stroke(isOn.wrappedValue
                                        ? theme.neonCyan.opacity(0.8)
                                        : Color(hex: "#1e3258"), lineWidth: 1)))
                        : AnyView(RoundedRectangle(cornerRadius: 6)
                            .fill(isOn.wrappedValue
                                  ? Color.accentColor.opacity(0.25)
                                  : Color(NSColor.controlColor)))
                )
                .foregroundStyle(
                    theme.isNeonBlade
                        ? (isOn.wrappedValue ? theme.neonCyan : theme.secondaryText)
                        : (isOn.wrappedValue ? Color.accentColor : Color.primary)
                )
                .shadow(color: (theme.isNeonBlade && isOn.wrappedValue)
                        ? theme.neonCyan.opacity(0.5) : .clear, radius: 4)
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

    // MARK: Display Container

    @ViewBuilder
    private var displayContainer: some View {
        if theme.isNeonBlade {
            displayArea
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        // Deep dark panel
                        CornerCutShape(cutSize: 14)
                            .fill(theme.displayBackground)
                        // Scanlines overlay
                        GeometryReader { geo in
                            Canvas { ctx, size in
                                var y: CGFloat = 0
                                while y < size.height {
                                    ctx.fill(
                                        Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                                        with: .color(Color.black.opacity(0.08))
                                    )
                                    y += 3
                                }
                            }
                            .clipShape(CornerCutShape(cutSize: 14))
                            .frame(width: geo.size.width, height: geo.size.height)
                        }
                        // Cyan border glow
                        CornerCutShape(cutSize: 14)
                            .stroke(theme.neonCyan.opacity(0.4), lineWidth: 1)
                    }
                )
                .shadow(color: theme.neonCyan.opacity(0.12), radius: 10)
                .padding(.horizontal, 12)
        } else {
            displayArea
                .padding(.horizontal, 16)
        }
    }

    // MARK: Display

    private var displayArea: some View {
        VStack(alignment: .trailing, spacing: 2) {
            // Expression line
            Text(engine.expression.isEmpty ? " " : engine.expression)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(
                    theme.isNeonBlade ? theme.neonCyan.opacity(0.7) : Color.secondary
                )
                .lineLimit(1)
                .truncationMode(.head)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Main number display
            Text(engine.display)
                .font(.system(
                    size: 50, weight: .thin,
                    design: theme.isNeonBlade ? .monospaced : .rounded
                ))
                .foregroundStyle(
                    theme.isNeonBlade ? theme.primaryText : Color.primary
                )
                .lineLimit(1)
                .minimumScaleFactor(0.35)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentShape(Rectangle())
                .onTapGesture { copyToClipboard(engine.display) }
                .help("Tap to copy")
                .shadow(
                    color: theme.isNeonBlade ? theme.neonCyan.opacity(0.3) : .clear,
                    radius: 6
                )

            // Memory indicator
            HStack {
                if engine.hasMemory {
                    HStack(spacing: 3) {
                        if theme.isNeonBlade {
                            Text("▸")
                                .font(.system(size: 9, design: .monospaced))
                        }
                        Text("M: \(engine.fmt(engine.memory))")
                            .font(.system(size: 11, weight: .medium,
                                          design: theme.isNeonBlade ? .monospaced : .default))
                    }
                    .foregroundStyle(theme.memoryIndicatorColor)
                    .shadow(
                        color: theme.isNeonBlade ? theme.neonViolet.opacity(0.8) : .clear,
                        radius: 4
                    )
                }
                Spacer()
            }
            .frame(height: 14)
        }
        .frame(height: 100)
    }

    // MARK: Standard Keypad

    private var standardKeypad: some View {
        VStack(spacing: theme.isNeonBlade ? 6 : 8) {
            // Memory row
            HStack(spacing: theme.isNeonBlade ? 6 : 8) {
                CalcButton("MC",  kind: .memory, height: 36) { engine.memoryClear()    }
                CalcButton("MR",  kind: .memory, height: 36) { engine.memoryRecall()   }
                CalcButton("M+",  kind: .memory, height: 36) { engine.memoryAdd()      }
                CalcButton("M−",  kind: .memory, height: 36) { engine.memorySubtract() }
            }
            // Row 1
            HStack(spacing: theme.isNeonBlade ? 6 : 8) {
                CalcButton(engine.clearLabel, kind: .function_) { engine.clear()           }
                CalcButton("+/−", kind: .function_)             { engine.toggleSign()      }
                CalcButton("%",   kind: .function_)             { engine.percent()          }
                CalcButton("÷",   kind: .operatorKey)           { engine.inputOperator("÷") }
            }
            // Row 2
            HStack(spacing: theme.isNeonBlade ? 6 : 8) {
                CalcButton("7", kind: .number) { engine.inputDigit("7")  }
                CalcButton("8", kind: .number) { engine.inputDigit("8")  }
                CalcButton("9", kind: .number) { engine.inputDigit("9")  }
                CalcButton("×", kind: .operatorKey) { engine.inputOperator("×") }
            }
            // Row 3
            HStack(spacing: theme.isNeonBlade ? 6 : 8) {
                CalcButton("4", kind: .number) { engine.inputDigit("4")  }
                CalcButton("5", kind: .number) { engine.inputDigit("5")  }
                CalcButton("6", kind: .number) { engine.inputDigit("6")  }
                CalcButton("−", kind: .operatorKey) { engine.inputOperator("−") }
            }
            // Row 4
            HStack(spacing: theme.isNeonBlade ? 6 : 8) {
                CalcButton("1", kind: .number) { engine.inputDigit("1")  }
                CalcButton("2", kind: .number) { engine.inputDigit("2")  }
                CalcButton("3", kind: .number) { engine.inputDigit("3")  }
                CalcButton("+", kind: .operatorKey) { engine.inputOperator("+") }
            }
            // Row 5 — wide zero
            HStack(spacing: theme.isNeonBlade ? 6 : 8) {
                CalcButton("0", kind: .number, isWide: true) { engine.inputDigit("0") }
                CalcButton(".", kind: .number)               { engine.inputDecimal()   }
                CalcButton("=", kind: .equals)               { engine.equals()          }
            }
        }
    }

    // MARK: Keyboard

    private func setupKeyboard() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak engine] event in
            guard let engine = engine else { return event }
            let key  = event.charactersIgnoringModifiers ?? ""
            let mods = event.modifierFlags
            if mods.contains(.command) { return event }
            switch key {
            case "0","1","2","3","4","5","6","7","8","9": engine.inputDigit(key)
            case ".":      engine.inputDecimal()
            case "+":      engine.inputOperator("+")
            case "-":      engine.inputOperator("−")
            case "*":      engine.inputOperator("×")
            case "/":      engine.inputOperator("÷")
            case "=", "\r": engine.equals()
            case "%":      engine.percent()
            case "c", "C": engine.clear()
            case "\u{7F}": engine.backspace()
            case "\u{1B}": engine.allClear()
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
