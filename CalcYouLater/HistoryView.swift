import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var engine: CalculatorEngine

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if engine.history.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var header: some View {
        HStack {
            Label("History", systemImage: "clock.arrow.circlepath")
                .font(.headline)
            Spacer()
            Button("Clear") { engine.clearHistory() }
                .foregroundStyle(.red)
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
                .foregroundStyle(.tertiary)
            Text("No calculations yet")
                .font(.caption)
                .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                        .truncationMode(.head)

                    Text(entry.result)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(entry.timestamp, style: .time)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { engine.recallHistory(entry) }
                .help("Tap to recall \(entry.result)")
            }
            .onDelete { engine.history.remove(atOffsets: $0) }
        }
        .listStyle(.plain)
    }
}
