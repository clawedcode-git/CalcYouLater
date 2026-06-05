import SwiftUI

// MARK: - Unit Data

enum ConvCategory: String, CaseIterable, Identifiable {
    case length      = "Length"
    case weight      = "Weight"
    case temperature = "Temperature"
    case area        = "Area"
    case volume      = "Volume"
    case speed       = "Speed"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .length:      return "ruler"
        case .weight:      return "scalemass"
        case .temperature: return "thermometer"
        case .area:        return "square"
        case .volume:      return "drop"
        case .speed:       return "gauge.with.dots.needle.67percent"
        }
    }

    var units: [String] {
        switch self {
        case .length:      return ["m","km","cm","mm","mi","ft","in","yd"]
        case .weight:      return ["kg","g","lb","oz","t","mg"]
        case .temperature: return ["°C","°F","K"]
        case .area:        return ["m²","km²","cm²","ft²","in²","ha","acre"]
        case .volume:      return ["L","mL","gal","fl oz","cup","tbsp","tsp","m³"]
        case .speed:       return ["m/s","km/h","mph","knot","ft/s"]
        }
    }
}

// MARK: - Converter View

struct ConverterView: View {
    @EnvironmentObject var engine: CalculatorEngine
    @EnvironmentObject var theme:  AppTheme
    @State private var category: ConvCategory = .length
    @State private var fromUnit = "m"
    @State private var toUnit   = "ft"
    @State private var input    = ""
    @State private var result   = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            neonDivider
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    categoryPicker
                    unitPickers
                    inputRow
                    if !result.isEmpty { resultBox }
                }
                .padding(14)
            }
        }
        .background(theme.sidebarBackground)
        .onChange(of: category) { _ in resetUnits(); convert() }
        .onChange(of: fromUnit) { _ in convert() }
        .onChange(of: toUnit)   { _ in convert() }
        .onChange(of: input)    { _ in convert() }
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
            Label("Convert", systemImage: "arrow.left.arrow.right")
                .font(.system(.headline, design: theme.isNeonBlade ? .monospaced : .default))
                .foregroundStyle(theme.isNeonBlade ? theme.neonCyan : Color.primary)
                .shadow(color: theme.isNeonBlade ? theme.neonCyan.opacity(0.6) : .clear,
                        radius: 5)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(theme.isNeonBlade ? "// CATEGORY" : "Category")
                .font(.system(size: 11, design: theme.isNeonBlade ? .monospaced : .default))
                .foregroundStyle(theme.secondaryText)
            Picker("", selection: $category) {
                ForEach(ConvCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
    }

    private var unitPickers: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(theme.isNeonBlade ? "// UNITS" : "Units")
                .font(.system(size: 11, design: theme.isNeonBlade ? .monospaced : .default))
                .foregroundStyle(theme.secondaryText)
            HStack(spacing: 8) {
                Picker("From", selection: $fromUnit) {
                    ForEach(category.units, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden()
                .pickerStyle(.menu)

                Image(systemName: "arrow.right")
                    .foregroundStyle(theme.isNeonBlade ? theme.neonCyan.opacity(0.7) : Color.secondary)

                Picker("To", selection: $toUnit) {
                    ForEach(category.units, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }
        }
    }

    private var inputRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(theme.isNeonBlade ? "// VALUE" : "Value")
                .font(.system(size: 11, design: theme.isNeonBlade ? .monospaced : .default))
                .foregroundStyle(theme.secondaryText)
            HStack(spacing: 6) {
                TextField("Enter value", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13, design: theme.isNeonBlade ? .monospaced : .default))
                Button {
                    input = engine.display
                } label: {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 12))
                }
                .help("Use calculator display value")
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    private var resultBox: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(theme.isNeonBlade ? "// OUTPUT" : "Result")
                .font(.system(size: 11, design: theme.isNeonBlade ? .monospaced : .default))
                .foregroundStyle(theme.secondaryText)
            Text(result)
                .font(.system(size: 22, weight: .semibold,
                              design: theme.isNeonBlade ? .monospaced : .rounded))
                .foregroundStyle(theme.isNeonBlade ? theme.neonCyan : Color.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .shadow(
                    color: theme.isNeonBlade ? theme.neonCyan.opacity(0.5) : .clear,
                    radius: 5
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            theme.isNeonBlade
                ? AnyView(CornerCutShape(cutSize: 10)
                    .fill(theme.controlBackground)
                    .overlay(CornerCutShape(cutSize: 10)
                        .stroke(theme.neonCyan.opacity(0.35), lineWidth: 1)))
                : AnyView(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor)))
        )
    }

    // MARK: - Conversion Logic

    private func resetUnits() {
        let units = category.units
        fromUnit = units[0]
        toUnit = units.count > 1 ? units[1] : units[0]
    }

    private func convert() {
        guard let value = Double(input.replacingOccurrences(of: ",", with: ".")) else {
            result = ""; return
        }
        let base = toBase(value, unit: fromUnit)
        let out  = fromBase(base, unit: toUnit)

        if out.isNaN || out.isInfinite { result = "—"; return }

        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumSignificantDigits = 8
        result = (f.string(from: NSNumber(value: out)) ?? "\(out)") + " \(toUnit)"
    }

    private func toBase(_ v: Double, unit: String) -> Double {
        switch category {
        case .length:
            switch unit {
            case "m": return v; case "km": return v*1000; case "cm": return v/100
            case "mm": return v/1000; case "mi": return v*1609.344; case "ft": return v*0.3048
            case "in": return v*0.0254; case "yd": return v*0.9144; default: return v
            }
        case .weight:
            switch unit {
            case "kg": return v; case "g": return v/1000; case "lb": return v*0.453592
            case "oz": return v*0.0283495; case "t": return v*1000; case "mg": return v/1e6
            default: return v
            }
        case .temperature:
            switch unit {
            case "°C": return v; case "°F": return (v-32)*5/9; case "K": return v-273.15
            default: return v
            }
        case .area:
            switch unit {
            case "m²": return v; case "km²": return v*1e6; case "cm²": return v/1e4
            case "ft²": return v*0.092903; case "in²": return v*0.00064516
            case "ha": return v*10000; case "acre": return v*4046.86; default: return v
            }
        case .volume:
            switch unit {
            case "L": return v; case "mL": return v/1000; case "gal": return v*3.78541
            case "fl oz": return v*0.0295735; case "cup": return v*0.236588
            case "tbsp": return v*0.0147868; case "tsp": return v*0.00492892
            case "m³": return v*1000; default: return v
            }
        case .speed:
            switch unit {
            case "m/s": return v; case "km/h": return v/3.6; case "mph": return v*0.44704
            case "knot": return v*0.514444; case "ft/s": return v*0.3048; default: return v
            }
        }
    }

    private func fromBase(_ v: Double, unit: String) -> Double {
        switch category {
        case .length:
            switch unit {
            case "m": return v; case "km": return v/1000; case "cm": return v*100
            case "mm": return v*1000; case "mi": return v/1609.344; case "ft": return v/0.3048
            case "in": return v/0.0254; case "yd": return v/0.9144; default: return v
            }
        case .weight:
            switch unit {
            case "kg": return v; case "g": return v*1000; case "lb": return v/0.453592
            case "oz": return v/0.0283495; case "t": return v/1000; case "mg": return v*1e6
            default: return v
            }
        case .temperature:
            switch unit {
            case "°C": return v; case "°F": return v*9/5+32; case "K": return v+273.15
            default: return v
            }
        case .area:
            switch unit {
            case "m²": return v; case "km²": return v/1e6; case "cm²": return v*1e4
            case "ft²": return v/0.092903; case "in²": return v/0.00064516
            case "ha": return v/10000; case "acre": return v/4046.86; default: return v
            }
        case .volume:
            switch unit {
            case "L": return v; case "mL": return v*1000; case "gal": return v/3.78541
            case "fl oz": return v/0.0295735; case "cup": return v/0.236588
            case "tbsp": return v/0.0147868; case "tsp": return v/0.00492892
            case "m³": return v/1000; default: return v
            }
        case .speed:
            switch unit {
            case "m/s": return v; case "km/h": return v*3.6; case "mph": return v/0.44704
            case "knot": return v/0.514444; case "ft/s": return v/0.3048; default: return v
            }
        }
    }
}
