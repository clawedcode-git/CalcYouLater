package com.calcyoulater.android.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

/** Button category — mirrors CalcButtonKind in ContentView.swift. */
enum class CalcButtonKind { NUMBER, OPERATOR, FUNCTION, EQUALS, MEMORY, SCIENTIFIC }

/** Theme variants — mirrors ThemeMode in AppTheme.swift. */
enum class ThemeMode(val displayName: String) {
    STANDARD("Standard"),
    NEON_BLADE("NeonBlade");

    val isNeonBlade: Boolean get() = this == NEON_BLADE
}

/** Appearance for the Standard theme (NeonBlade always forces dark). */
enum class AppearanceMode { SYSTEM, LIGHT, DARK }

private fun hex(s: String): Color {
    val clean = s.removePrefix("#")
    val v = clean.toLong(16)
    return Color(
        red = ((v shr 16) and 0xFF) / 255f,
        green = ((v shr 8) and 0xFF) / 255f,
        blue = (v and 0xFF) / 255f,
        alpha = 1f
    )
}

/**
 * Resolved colour palette for the active theme. The Standard palette is supplied by
 * the caller (derived from Material 3 / system dark|light); the NeonBlade palette is the
 * exact hex set from AppTheme.swift.
 */
class CylPalette(
    val mode: ThemeMode,
    val dark: Boolean,
    // backgrounds
    val windowBackground: Color,
    val sidebarBackground: Color,
    val displayBackground: Color,
    val controlBackground: Color,
    // button fills
    val numberButton: Color,
    val functionButton: Color,
    val operatorButton: Color,
    val equalsButton: Color,
    val memoryButton: Color,
    val scientificButton: Color,
    // text
    val primaryText: Color,
    val secondaryText: Color,
    val tertiaryText: Color,
) {
    val isNeonBlade: Boolean get() = mode.isNeonBlade

    // Neon accents (constant regardless of theme; only used when NeonBlade).
    val neonCyan = hex("#00d4ff")
    val neonPink = hex("#ff0066")
    val neonViolet = hex("#a020f0")
    val neonBlue = hex("#0066ff")

    val memoryIndicatorColor: Color get() = if (isNeonBlade) neonViolet else Color(0xFF9C27B0)

    fun neonGlow(kind: CalcButtonKind): Color {
        if (!isNeonBlade) return Color.Transparent
        return when (kind) {
            CalcButtonKind.OPERATOR -> neonCyan.copy(alpha = 0.8f)
            CalcButtonKind.EQUALS -> neonPink.copy(alpha = 0.9f)
            CalcButtonKind.MEMORY -> neonViolet.copy(alpha = 0.8f)
            CalcButtonKind.SCIENTIFIC -> neonBlue.copy(alpha = 0.8f)
            else -> neonCyan.copy(alpha = 0.15f)
        }
    }

    fun neonBorder(kind: CalcButtonKind): Color {
        if (!isNeonBlade) return Color.Transparent
        return when (kind) {
            CalcButtonKind.OPERATOR -> neonCyan
            CalcButtonKind.EQUALS -> neonPink
            CalcButtonKind.MEMORY -> neonViolet
            CalcButtonKind.SCIENTIFIC -> neonBlue
            CalcButtonKind.FUNCTION -> hex("#1e3258")
            else -> hex("#162040")
        }
    }

    /** Foreground/text colour for a button by kind (NeonBlade only; Standard handled inline). */
    fun neonForeground(kind: CalcButtonKind): Color = when (kind) {
        CalcButtonKind.OPERATOR -> neonCyan
        CalcButtonKind.EQUALS -> neonPink
        CalcButtonKind.MEMORY -> neonViolet
        CalcButtonKind.SCIENTIFIC -> neonBlue
        CalcButtonKind.FUNCTION -> hex("#8ab0cc")
        else -> primaryText
    }

    companion object {
        fun neonBlade(): CylPalette = CylPalette(
            mode = ThemeMode.NEON_BLADE,
            dark = true,
            windowBackground = hex("#080b14"),
            sidebarBackground = hex("#060810"),
            displayBackground = hex("#04060e"),
            controlBackground = hex("#0c1020"),
            numberButton = hex("#0d1424"),
            functionButton = hex("#141c30"),
            operatorButton = hex("#003a4a"),
            equalsButton = hex("#4a0022"),
            memoryButton = hex("#220047"),
            scientificButton = hex("#001047"),
            primaryText = hex("#d8f0ff"),
            secondaryText = hex("#3a6a88"),
            tertiaryText = hex("#1e3a50"),
        )

        /** Standard palette derived from system dark/light. */
        fun standard(dark: Boolean): CylPalette {
            return if (dark) CylPalette(
                mode = ThemeMode.STANDARD,
                dark = true,
                windowBackground = hex("#1c1c1e"),
                sidebarBackground = hex("#161618"),
                displayBackground = Color.Transparent,
                controlBackground = hex("#2c2c2e"),
                numberButton = hex("#3a3a3c"),
                functionButton = hex("#4a4a4e"),
                operatorButton = hex("#ff9f0a"),
                equalsButton = hex("#ff9f0a"),
                memoryButton = hex("#7c3aed"),
                scientificButton = hex("#4338ca"),
                primaryText = Color.White,
                secondaryText = hex("#a0a0a8"),
                tertiaryText = hex("#6c6c70"),
            ) else CylPalette(
                mode = ThemeMode.STANDARD,
                dark = false,
                windowBackground = hex("#f2f2f7"),
                sidebarBackground = hex("#ffffff"),
                displayBackground = Color.Transparent,
                controlBackground = hex("#ffffff"),
                numberButton = hex("#ffffff"),
                functionButton = hex("#d1d1d6"),
                operatorButton = hex("#ff9f0a"),
                equalsButton = hex("#ff9f0a"),
                memoryButton = hex("#7c3aed"),
                scientificButton = hex("#4338ca"),
                primaryText = hex("#000000"),
                secondaryText = hex("#6c6c70"),
                tertiaryText = hex("#aeaeb2"),
            )
        }
    }
}

val LocalCylPalette = staticCompositionLocalOf { CylPalette.standard(dark = true) }

object CylTheme {
    val palette: CylPalette
        @Composable get() = LocalCylPalette.current
}
