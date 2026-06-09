package com.calcyoulater.android.engine

import java.util.Locale
import kotlin.math.abs

/**
 * Number formatting — a 1:1 port of CalculatorEngine.fmt() from the SwiftUI app.
 *
 *  - NaN          -> "Error"
 *  - ±Infinity    -> "∞" / "-∞"
 *  - |v| >= 1e15  or  0 < |v| < 1e-9  -> scientific notation, 8 significant digits
 *  - whole number -> integer form (no decimals)
 *  - otherwise    -> up to 10 significant digits ("%.10g")
 */
fun fmt(value: Double): String {
    if (value.isNaN()) return "Error"
    if (value.isInfinite()) return if (value > 0) "∞" else "-∞"

    val absVal = abs(value)
    if (absVal >= 1e15 || (absVal < 1e-9 && absVal > 0)) {
        return scientific(value)
    }

    // Integer form for whole numbers within Long range.
    if (value == kotlin.math.truncate(value) && absVal < 1e15) {
        val asLong = value.toLong()
        if (asLong.toDouble() == value) return asLong.toString()
    }

    // %.10g, then strip trailing zeros / dangling decimal point the way Swift does.
    return trimG(String.format(Locale.US, "%.10g", value))
}

/** Scientific notation with 8 significant digits, e.g. "1.2345678E15". */
private fun scientific(value: Double): String {
    // %.7e gives 7 digits after the point = 8 significant digits total.
    var s = String.format(Locale.US, "%.7e", value)
    // Normalise: strip trailing zeros in the mantissa, uppercase exponent, drop +/leading zeros.
    val parts = s.split("e", "E")
    if (parts.size == 2) {
        var mantissa = parts[0]
        if (mantissa.contains('.')) {
            mantissa = mantissa.trimEnd('0').trimEnd('.')
        }
        var exp = parts[1].toInt()
        s = mantissa + "E" + exp
    }
    return s
}

/** Mimic Swift's "%.10g": trim trailing zeros but keep significant digits. */
private fun trimG(raw: String): String {
    var s = raw
    if (s.contains('e') || s.contains('E')) {
        // Java may emit exponential form for %g; normalise like scientific().
        val parts = s.split("e", "E")
        if (parts.size == 2) {
            var mantissa = parts[0]
            if (mantissa.contains('.')) mantissa = mantissa.trimEnd('0').trimEnd('.')
            s = mantissa + "E" + parts[1].toInt()
        }
        return s
    }
    if (s.contains('.')) {
        s = s.trimEnd('0').trimEnd('.')
    }
    return s
}
