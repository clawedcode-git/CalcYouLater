import SwiftUI

struct ScientificKeypad: View {
    @EnvironmentObject var engine: CalculatorEngine

    private let rows: [[SciKey]] = [
        [.fn("sin"), .fn("cos"), .fn("tan"), .const("π")],
        [.fn("asin"), .fn("acos"), .fn("atan"), .const("e")],
        [.fn("log"), .fn("ln"), .fn("sqrt", label: "√"), .fn("x²")],
        [.op("xʸ"), .fn("n!", label: "n!"), .fn("1/x"), .fn("cbrt", label: "∛x")],
    ]

    var body: some View {
        VStack(spacing: 5) {
            ForEach(rows.indices, id: \.self) { r in
                HStack(spacing: 5) {
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
            case .fn(let fn, _):    engine.applyScientific(fn)
            case .const(let c):     engine.inputConstant(c)
            case .op(let op):       engine.inputOperator(op)
            }
        } label: {
            Text(key.label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
        }
        .buttonStyle(SciButtonStyle())
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
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.indigo.opacity(configuration.isPressed ? 0.5 : (isHovering ? 0.72 : 0.62))
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
            .onHover { isHovering = $0 }
    }
}
