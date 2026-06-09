package com.calcyoulater.android.engine

import kotlin.math.PI
import kotlin.math.E
import kotlin.math.abs
import kotlin.math.acos
import kotlin.math.asin
import kotlin.math.atan
import kotlin.math.cbrt
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.log10
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.tan

/**
 * Immutable snapshot of engine-visible state, consumed by the UI layer.
 */
data class EngineState(
    val display: String,
    val expression: String,
    val history: List<HistoryEntry>,
    val memory: Double,
    val hasMemory: Boolean,
    val clearLabel: String
)

/**
 * Pure-Kotlin port of CalculatorEngine.swift. No Android / Compose dependencies,
 * so it is fully unit-testable on the JVM. The UI wraps this via a ViewModel and
 * reads [snapshot] after each mutating call.
 *
 * Unicode operators are preserved exactly to match macOS/iOS history strings:
 *   "−" U+2212, "×" U+00D7, "÷" U+00F7, "xʸ".
 */
class CalculatorEngine {

    var display: String = "0"; private set
    var expression: String = ""; private set
    val history: MutableList<HistoryEntry> = mutableListOf()
    var memory: Double = 0.0; private set
    var hasMemory: Boolean = false; private set

    private var leftOperand: Double? = null
    private var pendingOperator: String? = null
    private var lastOperand: Double? = null
    private var lastOperator: String? = null
    private var shouldResetDisplay = false
    private var justEvaluated = false

    private val displayValue: Double
        get() = display.replace(",", "").toDoubleOrNull() ?: 0.0

    fun snapshot(): EngineState = EngineState(
        display = display,
        expression = expression,
        history = history.toList(),
        memory = memory,
        hasMemory = hasMemory,
        clearLabel = clearLabel
    )

    // MARK: - Digit / Decimal Input

    fun inputDigit(digit: String) {
        if (shouldResetDisplay) {
            display = digit
            shouldResetDisplay = false
            if (justEvaluated) {
                leftOperand = null
                pendingOperator = null
                lastOperand = null
                lastOperator = null
                justEvaluated = false
            }
        } else if (display == "0") {
            display = digit
        } else {
            if (display.length >= 15) return
            display += digit
        }
    }

    fun inputDecimal() {
        if (shouldResetDisplay || justEvaluated) {
            display = "0."
            shouldResetDisplay = false
            justEvaluated = false
        } else if (!display.contains(".")) {
            display += "."
        }
    }

    fun backspace() {
        if (justEvaluated || shouldResetDisplay) return
        if (display.length > 1) {
            display = display.dropLast(1)
            if (display == "-") display = "0"
        } else {
            display = "0"
        }
    }

    // MARK: - Operators

    fun inputOperator(op: String) {
        val current = displayValue
        val left = leftOperand
        val pending = pendingOperator

        if (justEvaluated) {
            leftOperand = current
            justEvaluated = false
        } else if (left != null && pending != null && !shouldResetDisplay) {
            val result = compute(left, pending, current)
            addToHistory("${fmt(left)} $pending ${fmt(current)}", fmt(result))
            display = fmt(result)
            leftOperand = result
        } else {
            leftOperand = current
        }

        pendingOperator = op
        expression = "${fmt(leftOperand!!)} $op"
        shouldResetDisplay = true
    }

    fun equals() {
        if (justEvaluated) {
            val left = leftOperand ?: return
            val op = lastOperator ?: return
            val right = lastOperand ?: return
            val result = compute(left, op, right)
            addToHistory("${fmt(left)} $op ${fmt(right)} =", fmt(result))
            expression = "${fmt(left)} $op ${fmt(right)} ="
            display = fmt(result)
            leftOperand = result
            return
        }

        val current = displayValue
        val left = leftOperand
        val op = pendingOperator
        if (left == null || op == null) {
            val lop = lastOperator
            val right = lastOperand
            if (lop != null && right != null) {
                val result = compute(current, lop, right)
                addToHistory("${fmt(current)} $lop ${fmt(right)} =", fmt(result))
                expression = "${fmt(current)} $lop ${fmt(right)} ="
                display = fmt(result)
                leftOperand = result
                shouldResetDisplay = true
                justEvaluated = true
            }
            return
        }

        lastOperand = current
        lastOperator = op
        val result = compute(left, op, current)
        addToHistory("${fmt(left)} $op ${fmt(current)} =", fmt(result))
        expression = "${fmt(left)} $op ${fmt(current)} ="
        display = fmt(result)
        leftOperand = result
        pendingOperator = null
        shouldResetDisplay = true
        justEvaluated = true
    }

    // MARK: - Clear

    fun clear() {
        if (display != "0" && !justEvaluated) {
            display = "0"
        } else {
            allClear()
        }
    }

    fun allClear() {
        display = "0"
        expression = ""
        leftOperand = null
        pendingOperator = null
        lastOperand = null
        lastOperator = null
        shouldResetDisplay = false
        justEvaluated = false
    }

    val clearLabel: String
        get() = if ((leftOperand == null && !justEvaluated) || display == "0") "AC" else "C"

    // MARK: - Quick Functions

    fun toggleSign() {
        val v = displayValue
        display = fmt(-v)
        if (justEvaluated) leftOperand = -v
    }

    fun percent() {
        val v = displayValue
        val left = leftOperand
        if (left != null && pendingOperator != null) {
            display = fmt(left * v / 100)
        } else {
            display = fmt(v / 100)
        }
    }

    // MARK: - Scientific

    fun applyScientific(fn: String) {
        val v = displayValue
        val result: Double = when (fn) {
            "sin" -> sin(v * PI / 180)
            "cos" -> cos(v * PI / 180)
            "tan" -> tan(v * PI / 180)
            "asin" -> asin(v) * 180 / PI
            "acos" -> acos(v) * 180 / PI
            "atan" -> atan(v) * 180 / PI
            "log" -> log10(v)
            "ln" -> ln(v)
            "sqrt" -> sqrt(v)
            "cbrt" -> cbrt(v)
            "x²" -> v * v
            "x³" -> v * v * v
            "1/x" -> 1.0 / v
            "n!" -> factorial(abs(v).toInt())
            "abs" -> abs(v)
            "e^x" -> exp(v)
            "10^x" -> 10.0.pow(v)
            else -> return
        }

        addToHistory("$fn(${fmt(v)})", fmt(result))
        expression = "$fn(${fmt(v)}) ="
        display = fmt(result)
        leftOperand = null
        pendingOperator = null
        shouldResetDisplay = true
        justEvaluated = true
    }

    fun inputConstant(c: String) {
        when (c) {
            "π" -> display = fmt(PI)
            "e" -> display = fmt(E)
            else -> return
        }
        shouldResetDisplay = true
        justEvaluated = false
    }

    // MARK: - Memory

    fun memoryClear() { memory = 0.0; hasMemory = false }
    fun memoryRecall() { display = fmt(memory); shouldResetDisplay = true }
    fun memoryAdd() { memory += displayValue; hasMemory = true }
    fun memorySubtract() { memory -= displayValue; hasMemory = memory != 0.0 }

    // MARK: - History

    fun recallHistory(entry: HistoryEntry) {
        display = entry.result
        shouldResetDisplay = true
        leftOperand = null
        pendingOperator = null
        expression = entry.expression
        justEvaluated = false
    }

    fun clearHistory() { history.clear() }

    /** Restore persisted history (newest-first ordering preserved). */
    fun loadHistory(entries: List<HistoryEntry>) {
        history.clear()
        history.addAll(entries.take(200))
    }

    fun restoreMemory(value: Double, has: Boolean) {
        memory = value
        hasMemory = has
    }

    // MARK: - Private

    private fun compute(a: Double, op: String, b: Double): Double = when (op) {
        "+" -> a + b
        "−" -> a - b
        "×" -> a * b
        "÷" -> if (b == 0.0) (if (a >= 0) Double.POSITIVE_INFINITY else Double.NEGATIVE_INFINITY) else a / b
        "xʸ" -> a.pow(b)
        else -> b
    }

    private fun factorial(n: Int): Double {
        if (n < 0) return Double.NaN
        if (n > 20) return Double.POSITIVE_INFINITY
        return if (n == 0) 1.0 else n.toDouble() * factorial(n - 1)
    }

    private fun addToHistory(expression: String, result: String) {
        if (result == "Error") return
        history.add(0, HistoryEntry(expression = expression, result = result))
        if (history.size > 200) history.removeAt(history.size - 1)
    }
}
