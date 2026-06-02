import Foundation
import Combine

struct HistoryEntry: Identifiable {
    let id = UUID()
    let expression: String
    let result: String
    let timestamp: Date
}

class CalculatorEngine: ObservableObject {
    @Published var display: String = "0"
    @Published var expression: String = ""
    @Published var history: [HistoryEntry] = []
    @Published var memory: Double = 0
    @Published var hasMemory: Bool = false

    private var leftOperand: Double?
    private var pendingOperator: String?
    private var lastOperand: Double?
    private var lastOperator: String?
    private var shouldResetDisplay = false
    private var justEvaluated = false

    var displayValue: Double { Double(display.replacingOccurrences(of: ",", with: "")) ?? 0 }

    // MARK: - Digit / Decimal Input

    func inputDigit(_ digit: String) {
        if shouldResetDisplay {
            display = digit
            shouldResetDisplay = false
            if justEvaluated {
                leftOperand = nil
                pendingOperator = nil
                lastOperand = nil
                lastOperator = nil
                justEvaluated = false
            }
        } else if display == "0" {
            display = digit
        } else {
            guard display.count < 15 else { return }
            display += digit
        }
    }

    func inputDecimal() {
        if shouldResetDisplay || justEvaluated {
            display = "0."
            shouldResetDisplay = false
            justEvaluated = false
        } else if !display.contains(".") {
            display += "."
        }
    }

    func backspace() {
        guard !justEvaluated, !shouldResetDisplay else { return }
        if display.count > 1 {
            display = String(display.dropLast())
            if display == "-" { display = "0" }
        } else {
            display = "0"
        }
    }

    // MARK: - Operators

    func inputOperator(_ op: String) {
        let current = displayValue

        if justEvaluated {
            leftOperand = current
            justEvaluated = false
        } else if let left = leftOperand, let pending = pendingOperator, !shouldResetDisplay {
            let result = compute(left, pending, current)
            addToHistory(expression: "\(fmt(left)) \(pending) \(fmt(current))", result: fmt(result))
            display = fmt(result)
            leftOperand = result
        } else {
            leftOperand = current
        }

        pendingOperator = op
        expression = "\(fmt(leftOperand!)) \(op)"
        shouldResetDisplay = true
    }

    func equals() {
        if justEvaluated {
            guard let left = leftOperand, let op = lastOperator, let right = lastOperand else { return }
            let result = compute(left, op, right)
            addToHistory(expression: "\(fmt(left)) \(op) \(fmt(right)) =", result: fmt(result))
            expression = "\(fmt(left)) \(op) \(fmt(right)) ="
            display = fmt(result)
            leftOperand = result
            return
        }

        let current = displayValue
        guard let left = leftOperand, let op = pendingOperator else {
            if let op = lastOperator, let right = lastOperand {
                let result = compute(current, op, right)
                addToHistory(expression: "\(fmt(current)) \(op) \(fmt(right)) =", result: fmt(result))
                expression = "\(fmt(current)) \(op) \(fmt(right)) ="
                display = fmt(result)
                leftOperand = result
                shouldResetDisplay = true
                justEvaluated = true
            }
            return
        }

        lastOperand = current
        lastOperator = op
        let result = compute(left, op, current)
        addToHistory(expression: "\(fmt(left)) \(op) \(fmt(current)) =", result: fmt(result))
        expression = "\(fmt(left)) \(op) \(fmt(current)) ="
        display = fmt(result)
        leftOperand = result
        pendingOperator = nil
        shouldResetDisplay = true
        justEvaluated = true
    }

    // MARK: - Clear

    func clear() {
        if display != "0" && !justEvaluated {
            display = "0"
        } else {
            allClear()
        }
    }

    func allClear() {
        display = "0"
        expression = ""
        leftOperand = nil
        pendingOperator = nil
        lastOperand = nil
        lastOperator = nil
        shouldResetDisplay = false
        justEvaluated = false
    }

    var clearLabel: String { (leftOperand == nil && !justEvaluated) || display == "0" ? "AC" : "C" }

    // MARK: - Quick Functions

    func toggleSign() {
        let val = displayValue
        display = fmt(-val)
        if justEvaluated { leftOperand = -val }
    }

    func percent() {
        let val = displayValue
        if let left = leftOperand, let _ = pendingOperator {
            display = fmt(left * val / 100)
        } else {
            display = fmt(val / 100)
        }
    }

    // MARK: - Scientific

    func applyScientific(_ fn: String) {
        let val = displayValue
        let result: Double

        switch fn {
        case "sin":   result = sin(val * .pi / 180)
        case "cos":   result = cos(val * .pi / 180)
        case "tan":   result = tan(val * .pi / 180)
        case "asin":  result = asin(val) * 180 / .pi
        case "acos":  result = acos(val) * 180 / .pi
        case "atan":  result = atan(val) * 180 / .pi
        case "log":   result = log10(val)
        case "ln":    result = log(val)
        case "sqrt":  result = sqrt(val)
        case "cbrt":  result = cbrt(val)
        case "x²":    result = val * val
        case "x³":    result = val * val * val
        case "1/x":   result = 1.0 / val
        case "n!":    result = factorial(Int(abs(val)))
        case "abs":   result = abs(val)
        case "e^x":   result = exp(val)
        case "10^x":  result = pow(10, val)
        default: return
        }

        addToHistory(expression: "\(fn)(\(fmt(val)))", result: fmt(result))
        expression = "\(fn)(\(fmt(val))) ="
        display = fmt(result)
        leftOperand = nil
        pendingOperator = nil
        shouldResetDisplay = true
        justEvaluated = true
    }

    func inputConstant(_ c: String) {
        switch c {
        case "π": display = fmt(Double.pi)
        case "e": display = fmt(M_E)
        default: return
        }
        shouldResetDisplay = true
        justEvaluated = false
    }

    // MARK: - Memory

    func memoryClear()    { memory = 0; hasMemory = false }
    func memoryRecall()   { display = fmt(memory); shouldResetDisplay = true }
    func memoryAdd()      { memory += displayValue; hasMemory = true }
    func memorySubtract() { memory -= displayValue; hasMemory = memory != 0 }

    // MARK: - History

    func recallHistory(_ entry: HistoryEntry) {
        display = entry.result
        shouldResetDisplay = true
        leftOperand = nil
        pendingOperator = nil
        expression = entry.expression
        justEvaluated = false
    }

    func clearHistory() { history.removeAll() }

    // MARK: - Formatting

    func fmt(_ value: Double) -> String {
        if value.isNaN { return "Error" }
        if value.isInfinite { return value > 0 ? "∞" : "-∞" }

        let absVal = abs(value)
        if absVal >= 1e15 || (absVal < 1e-9 && absVal > 0) {
            let f = NumberFormatter()
            f.numberStyle = .scientific
            f.maximumSignificantDigits = 8
            return f.string(from: NSNumber(value: value)) ?? "\(value)"
        }

        if value == value.rounded(.towardZero) && absVal < 1e15 {
            if let i = Int64(exactly: value) { return "\(i)" }
        }

        return String(format: "%.10g", value)
    }

    // MARK: - Private

    private func compute(_ a: Double, _ op: String, _ b: Double) -> Double {
        switch op {
        case "+":  return a + b
        case "−":  return a - b
        case "×":  return a * b
        case "÷":  return b == 0 ? (a >= 0 ? .infinity : -.infinity) : a / b
        case "xʸ": return pow(a, b)
        default:   return b
        }
    }

    private func factorial(_ n: Int) -> Double {
        guard n >= 0 else { return .nan }
        if n > 20 { return .infinity }
        return n == 0 ? 1 : Double(n) * factorial(n - 1)
    }

    private func addToHistory(expression: String, result: String) {
        guard result != "Error" else { return }
        history.insert(HistoryEntry(expression: expression, result: result, timestamp: Date()), at: 0)
        if history.count > 200 { history.removeLast() }
    }
}
