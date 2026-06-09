package com.calcyoulater.android.theme

import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.LayoutDirection

/**
 * NeonBlade signature geometry — top-left and bottom-right corners are diagonally
 * clipped (the "blade" look). Direct port of CornerCutShape in AppTheme.swift.
 */
class CornerCutShape(private val cutSizePx: Float = 9f) : Shape {
    override fun createOutline(
        size: Size,
        layoutDirection: LayoutDirection,
        density: Density
    ): Outline {
        val c = cutSizePx
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(c, 0f)
            lineTo(w, 0f)
            lineTo(w, h - c)
            lineTo(w - c, h)
            lineTo(0f, h)
            lineTo(0f, c)
            close()
        }
        return Outline.Generic(path)
    }
}
