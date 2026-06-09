package com.calcyoulater.android.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.clickable
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.calcyoulater.android.theme.CalcButtonKind
import com.calcyoulater.android.theme.CornerCutShape
import com.calcyoulater.android.theme.CylTheme

/**
 * Themed calculator button. Standard = rounded rect; NeonBlade = corner-cut blade with
 * neon border + glow. Medium haptic on press mirrors the iOS app.
 */
@Composable
fun CalcButton(
    label: String,
    kind: CalcButtonKind,
    modifier: Modifier = Modifier,
    fontSize: Int = 22,
    onClick: () -> Unit
) {
    val p = CylTheme.palette
    val haptic = LocalHapticFeedback.current
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val scale by animateFloatAsState(if (pressed) 0.93f else 1f, tween(80), label = "scale")

    val mono = p.isNeonBlade
    val shape: Shape = if (p.isNeonBlade) CornerCutShape(9f) else RoundedCornerShape(12.dp)

    val fill = buttonFill(kind, pressed)
    val fg = buttonForeground(kind)

    var box = modifier
        .scale(scale)

    if (p.isNeonBlade) {
        val glow = p.neonGlow(kind)
        box = box.shadow(
            elevation = if (pressed) 12.dp else 4.dp,
            shape = shape,
            ambientColor = glow,
            spotColor = glow
        )
    }

    box = box
        .clip(shape)
        .background(fill, shape)

    if (p.isNeonBlade) {
        box = box.border(1.dp, p.neonBorder(kind).copy(alpha = 0.65f), shape)
    }

    box = box.clickable(
        interactionSource = interaction,
        indication = null
    ) {
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        onClick()
    }

    Box(modifier = box, contentAlignment = Alignment.Center) {
        Text(
            text = label,
            color = fg,
            fontSize = fontSize.sp,
            fontWeight = if (kind == CalcButtonKind.NUMBER) FontWeight.Normal else FontWeight.Medium,
            fontFamily = if (mono) FontFamily.Monospace else FontFamily.Default,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun buttonFill(kind: CalcButtonKind, pressed: Boolean): Color {
    val p = CylTheme.palette
    val dim = if (pressed) (if (p.isNeonBlade) 0.55f else 0.65f) else 1f
    return when (kind) {
        CalcButtonKind.NUMBER -> p.numberButton.copy(alpha = dim)
        CalcButtonKind.OPERATOR -> p.operatorButton.copy(alpha = dim)
        CalcButtonKind.FUNCTION ->
            if (p.isNeonBlade) p.functionButton.copy(alpha = dim)
            else p.functionButton.copy(alpha = if (pressed) 0.7f else 1f)
        CalcButtonKind.EQUALS -> p.equalsButton.copy(alpha = dim)
        CalcButtonKind.MEMORY -> p.memoryButton.copy(alpha = if (p.isNeonBlade) dim else (if (pressed) 0.55f else 1f))
        CalcButtonKind.SCIENTIFIC -> p.scientificButton.copy(alpha = if (p.isNeonBlade) dim else (if (pressed) 0.55f else 1f))
    }
}

@Composable
private fun buttonForeground(kind: CalcButtonKind): Color {
    val p = CylTheme.palette
    if (p.isNeonBlade) return p.neonForeground(kind)
    return when (kind) {
        CalcButtonKind.NUMBER, CalcButtonKind.FUNCTION -> p.primaryText
        else -> Color.White
    }
}
