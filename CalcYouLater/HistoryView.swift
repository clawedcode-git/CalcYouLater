import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var engine: CalculatorEngine
    @EnvironmentObject var theme:  AppTheme

    var body: some View {
        VStack(spacing: 0) {
            header
            neonDivider
            if engine.history.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(theme.sidebarBackground)
    }

    @ViewBuilder
    private var neonDivider: some View {
        if theme.isNeonBlade {
            Rectangle()
                .fill(theme.neonCyan.opacity(0.2))
                .frame(height: 1)
        } else {
            Divider()
        }
    }

    private var header: some View {
        HStack {
            Label("History", systemImage: "clock.arrow.circlepath")
                .font(.system(.headline, design: theme.isNeonBlade ? .monospaced : .default))
                .foregroundStyle(theme.isNeonBlade ? theme.neonCyan : Color.primary)
                .shadow(color: theme.isNeonBlade ? theme.neonCyan.opacity(0.6) : .clear,
                        radius: 5)
            Spacer()
            Button("Clear") { engine.clearHistory() }
                .foregroundStyle(
                    theme.isNeonBlade ? theme.neonPink : Color.red
                )
                .shadow(color: theme.isNeonBlade ? theme.neonPink.opacity(0.5) : .clear,
                        radius: 4)
                .buttonStyle(.plain)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 28))
                .foregroundStyle(theme.isNeonBlade ? theme.neonCyan.opacity(0.3) : Color(NSColor.tertiaryLabelColor))
                .shadow(color: theme.isNeonBlade ? theme.neonCyan.opacity(0.3) : .clear,
                        radius: 8)
            Text(theme.isNeonBlade ? "// NO DATA //" : "No calculations yet")
                .font(.system(size: theme.isNeonBlade ? 10 : 12,
                              design: theme.isNeonBlade ? .monospaced : .default))
                .foregroundStyle(theme.isNeonBlade ? theme.secondaryText : Color.secondary)
                .padding(.top, 6)
            Spacer()
        }
    }

    private var list: some View {
        List {
            ForEach(engine.history) { entry in
                VStack(alignment: .trailing, spacing: 3) {
                    Text(entry.expression)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(
                            theme.isNeonBlade ? theme.neonCyan.opacity(0.65) : Color.secondary
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                        .truncationMode(.head)

                    Text(entry.result)
                        .font(.system(size: 17, weight: .semibold,
                                      design: theme.isNeonBlade ? .monospaced : .rounded))
                        .foregroundStyle(theme.isNeonBlade ? theme.primaryText : Color.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .shadow(
                            color: theme.isNeonBlade ? theme.neonCyan.opacity(0.25) : .clear,
                            radius: 3
                        )

                    Text(entry.timestamp, style: .time)
                        .font(.system(size: 10, design: theme.isNeonBlade ? .monospaced : .default))
                        .foregroundStyle(theme.tertiaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { engine.recallHistory(entry) }
                .help("Tap to recall \(entry.result)")
                .listRowBackground(
                    theme.isNeonBlade
                        ? Color(hex: "#070a12")
                        : Color(NSColor.controlBackgroundColor).opacity(0)
                )
            }
            .onDelete { engine.history.remove(atOffsets: $0) }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.sidebarBackground)
    }
}
