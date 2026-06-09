package com.calcyoulater.android.engine

import java.util.Locale

/** Unit-conversion categories — mirrors ConvCategory in the SwiftUI app. */
enum class ConvCategory(val displayName: String, val units: List<String>) {
    LENGTH("Length", listOf("m", "km", "cm", "mm", "mi", "ft", "in", "yd")),
    WEIGHT("Weight", listOf("kg", "g", "lb", "oz", "t", "mg")),
    TEMPERATURE("Temperature", listOf("°C", "°F", "K")),
    AREA("Area", listOf("m²", "km²", "cm²", "ft²", "in²", "ha", "acre")),
    VOLUME("Volume", listOf("L", "mL", "gal", "fl oz", "cup", "tbsp", "tsp", "m³")),
    SPEED("Speed", listOf("m/s", "km/h", "mph", "knot", "ft/s"));
}

/**
 * Two-step conversion (value -> base unit -> target unit), a direct port of the
 * toBase / fromBase switch statements in ConverterView.swift.
 */
object Converter {

    /** Returns formatted "value unit" string, or null if [input] is not a number. */
    fun convert(category: ConvCategory, input: String, fromUnit: String, toUnit: String): String? {
        val value = input.replace(",", ".").toDoubleOrNull() ?: return null
        val base = toBase(category, value, fromUnit)
        val out = fromBase(category, base, toUnit)
        if (out.isNaN() || out.isInfinite()) return "—"
        return formatResult(out) + " " + toUnit
    }

    /** 8 significant digits, decimal style (Locale.US, no grouping). */
    private fun formatResult(v: Double): String {
        var s = String.format(Locale.US, "%.8g", v)
        if (s.contains('e') || s.contains('E')) {
            val parts = s.split("e", "E")
            if (parts.size == 2) {
                var m = parts[0]
                if (m.contains('.')) m = m.trimEnd('0').trimEnd('.')
                return m + "E" + parts[1].toInt()
            }
        }
        if (s.contains('.')) s = s.trimEnd('0').trimEnd('.')
        return s
    }

    fun toBase(category: ConvCategory, v: Double, unit: String): Double = when (category) {
        ConvCategory.LENGTH -> when (unit) {
            "m" -> v; "km" -> v * 1000; "cm" -> v / 100; "mm" -> v / 1000
            "mi" -> v * 1609.344; "ft" -> v * 0.3048; "in" -> v * 0.0254; "yd" -> v * 0.9144
            else -> v
        }
        ConvCategory.WEIGHT -> when (unit) {
            "kg" -> v; "g" -> v / 1000; "lb" -> v * 0.453592; "oz" -> v * 0.0283495
            "t" -> v * 1000; "mg" -> v / 1e6
            else -> v
        }
        ConvCategory.TEMPERATURE -> when (unit) {
            "°C" -> v; "°F" -> (v - 32) * 5 / 9; "K" -> v - 273.15
            else -> v
        }
        ConvCategory.AREA -> when (unit) {
            "m²" -> v; "km²" -> v * 1e6; "cm²" -> v / 1e4; "ft²" -> v * 0.092903
            "in²" -> v * 0.00064516; "ha" -> v * 10000; "acre" -> v * 4046.86
            else -> v
        }
        ConvCategory.VOLUME -> when (unit) {
            "L" -> v; "mL" -> v / 1000; "gal" -> v * 3.78541; "fl oz" -> v * 0.0295735
            "cup" -> v * 0.236588; "tbsp" -> v * 0.0147868; "tsp" -> v * 0.00492892
            "m³" -> v * 1000
            else -> v
        }
        ConvCategory.SPEED -> when (unit) {
            "m/s" -> v; "km/h" -> v / 3.6; "mph" -> v * 0.44704
            "knot" -> v * 0.514444; "ft/s" -> v * 0.3048
            else -> v
        }
    }

    fun fromBase(category: ConvCategory, v: Double, unit: String): Double = when (category) {
        ConvCategory.LENGTH -> when (unit) {
            "m" -> v; "km" -> v / 1000; "cm" -> v * 100; "mm" -> v * 1000
            "mi" -> v / 1609.344; "ft" -> v / 0.3048; "in" -> v / 0.0254; "yd" -> v / 0.9144
            else -> v
        }
        ConvCategory.WEIGHT -> when (unit) {
            "kg" -> v; "g" -> v * 1000; "lb" -> v / 0.453592; "oz" -> v / 0.0283495
            "t" -> v / 1000; "mg" -> v * 1e6
            else -> v
        }
        ConvCategory.TEMPERATURE -> when (unit) {
            "°C" -> v; "°F" -> v * 9 / 5 + 32; "K" -> v + 273.15
            else -> v
        }
        ConvCategory.AREA -> when (unit) {
            "m²" -> v; "km²" -> v / 1e6; "cm²" -> v * 1e4; "ft²" -> v / 0.092903
            "in²" -> v / 0.00064516; "ha" -> v / 10000; "acre" -> v / 4046.86
            else -> v
        }
        ConvCategory.VOLUME -> when (unit) {
            "L" -> v; "mL" -> v * 1000; "gal" -> v / 3.78541; "fl oz" -> v / 0.0295735
            "cup" -> v / 0.236588; "tbsp" -> v / 0.0147868; "tsp" -> v / 0.00492892
            "m³" -> v / 1000
            else -> v
        }
        ConvCategory.SPEED -> when (unit) {
            "m/s" -> v; "km/h" -> v * 3.6; "mph" -> v / 0.44704
            "knot" -> v / 0.514444; "ft/s" -> v / 0.3048
            else -> v
        }
    }
}
