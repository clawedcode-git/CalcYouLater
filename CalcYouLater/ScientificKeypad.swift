import SwiftUI

struct ScientificKeypad: View {
    @EnvironmentObject var engine: CalculatorEngine
    @EnvironmentObject var theme:  AppTheme

    private let rows: [[SciKey]] = [
        [.fn("sin"),  .fn("cos"),         .fn("tan"),        .const("π")],
        [.fn("asin"), .fn("acos"),         .fn("atan"),       .const("e")],
        [.fn("log"),  .fn("ln"),           .fn("sqrt", label: "√"), .fn("x²")],
        [.op("xʸ"),   .fn("n!", label: "n!"), .fn("1/x"),    .fn("cbrt", label: "∛x")],
    ]

    var body: some View {
        VStack(spacing: theme.isNeonBlade ? 4 : 5) {
            ForEach(rows.indices, id: \.self) { r in
                HStack(spacing: theme.isNeonBlade ? 4 : 5) {
                    ForEach(rows[r]) { key in
                        sciButton(key)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sciButton(_ key: SciKey) -> some View {
        Button {
            switch key {
            case .fn(let fn, _): engine.applyScientific(fn)
            case .const(let c):  engine.inputConstant(c)
            case .op(let op):    engine.inputOperator(op)
            }
        } label: {
            Text(key.label)
                .font(.system(size: 13, weight: .medium,
                              design: theme.isNeonBlade ? .monospaced : .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
        }
        .buttonStyle(SciButtonStyle(theme: theme))
    }
}

private enum SciKey: Identifiable, Hashable {
    case fn(String, label: String? = nil)
    case const(String)
    case op(String)

    var id: String { label }

    var label: String {
        switch self {
        case .fn(let fn, let l): return l ?? fn
        case .const(let c):      return c
        case .op(let op):        return op
        }
    }
}

private struct SciButtonStyle: ButtonStyle {
    let theme: AppTheme
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        if theme.isNeonBlade {
            neonBody(configuration: configuration, pressed: pressed)
        } else {
            standardBody(configuration: configuration, pressed: pressed)
        }
    }

    private func standardBody(configuration: Configuration, pressed: Bool) -> some View {
        configuration.label
            .background(
                Color.indigo.opacity(pressed ? 0.5 : (isHovering ? 0.72 : 0.62))
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(pressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.08), value: pressed)
            .onHover { isHovering = $0 }
    }

    @ViewBuilder
    private func neonBody(configuration: Configuration, pressed: Bool) -> some View {
        let fillOpacity = pressed ? 0.5 : (isHovering ? 0.85 : 1.0)
        let glowRadius: CGFloat = isHovering ? 8 : (pressed ? 10 : 3)

        configuration.label
            .foregroundStyle(
                isHovering
                    ? theme.neonBlue
                    : Color(hex: "#5577cc")
            )
            .background(theme.scientificButton.opacity(fillOpacity))
            .clipShape(CornerCutShape(cutSize: 7))
            .overlay(
                CornerCutShape(cutSize: 7)
                    .stroke(theme.neonBlue.opacity(isHovering ? 0.9 : 0.45), lineWidth: 1)
            )
            .shadow(color: theme.neonBlue.opacity(isHovering ? 0.7 : 0.2), radius: glowRadius)
            .scaleEffect(pressed ? 0.93 : 1.0)
            .animation(.easeOut(duration: 0.08), value: pressed)
            .onHover { isHovering = $0 }
    }
}
