package com.calcyoulater.android.engine

/**
 * Hardware-keyboard support: the result of mapping a typed character to a calculator
 * action. Special keys (Enter, Backspace, Delete, Escape) are handled separately at the
 * Compose layer since they carry no printable character.
 */
sealed interface KeyAction {
    data class Digit(val d: String) : KeyAction
    data object Decimal : KeyAction
    data class Op(val op: String) : KeyAction
    data object Equals : KeyAction
    data object Percent : KeyAction
    data object Clear : KeyAction
}

/**
 * Map a typed character to a [KeyAction], mirroring the macOS app's keyboard bindings
 * (`ContentView.setupKeyboard`) plus a few Android-friendly aliases:
 *  - `,` also enters a decimal (locale keyboards)
 *  - `x` / `X` also multiply, `^` starts a power (xʸ)
 *
 * Operator tokens use the exact Unicode the engine/history expect: `−` U+2212, `×` U+00D7,
 * `÷` U+00F7. Returns null for characters the calculator ignores.
 */
fun keyActionForChar(c: Char): KeyAction? = when (c) {
    in '0'..'9' -> KeyAction.Digit(c.toString())
    '.', ',' -> KeyAction.Decimal
    '+' -> KeyAction.Op("+")
    '-' -> KeyAction.Op("−")
    '*', 'x', 'X' -> KeyAction.Op("×")
    '/' -> KeyAction.Op("÷")
    '^' -> KeyAction.Op("xʸ")
    '=' -> KeyAction.Equals
    '%' -> KeyAction.Percent
    'c', 'C' -> KeyAction.Clear
    else -> null
}
