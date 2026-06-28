package com.calcyoulater.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.foundation.clickable
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Backspace
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.calcyoulater.android.engine.EngineState
import com.calcyoulater.android.theme.CornerCutShape
import com.calcyoulater.android.theme.CylTheme

@Composable
fun Display(
    state: EngineState,
    fmt: (Double) -> String,
    onBackspace: () -> Unit,
    modifier: Modifier = Modifier
) {
    val p = CylTheme.palette
    val clipboard = LocalClipboardManager.current
    val haptic = LocalHapticFeedback.current
    val mono = p.isNeonBlade

    var container = modifier.fillMaxWidth()
    if (p.isNeonBlade) {
        val shape = CornerCutShape(14f)
        container = container
            .clip(shape)
            .background(p.displayBackground, shape)
            .scanlines()
            .border(1.dp, p.neonCyan.copy(alpha = 0.4f), shape)
            .padding(horizontal = 16.dp, vertical = 8.dp)
    } else {
        container = container.padding(horizontal = 16.dp)
    }

    Column(
        modifier = container,
        horizontalAlignment = Alignment.End
    ) {
        // Expression line
        Text(
            text = state.expression.ifEmpty { " " },
            color = if (p.isNeonBlade) p.neonCyan.copy(alpha = 0.7f) else p.secondaryText,
            fontSize = 14.sp,
            fontFamily = FontFamily.Monospace,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.End,
            modifier = Modifier.fillMaxWidth()
        )

        // Main number — tap to copy (grouped for display; clipboard gets the raw value)
        Text(
            text = com.calcyoulater.android.engine.groupThousands(state.display),
            color = p.primaryText,
            fontSize = 52.sp,
            fontWeight = FontWeight.Light,
            fontFamily = if (mono) FontFamily.Monospace else FontFamily.Default,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.End,
            modifier = Modifier
                .fillMaxWidth()
                .clickable { clipboard.setText(AnnotatedString(state.display)) }
        )

        // Memory indicator + backspace
        Row(
            modifier = Modifier.fillMaxWidth().heightIn(min = 36.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (state.hasMemory) {
                Text(
                    text = (if (p.isNeonBlade) "▸ " else "") + "M: ${fmt(state.memory)}",
                    color = p.memoryIndicatorColor,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    fontFamily = if (mono) FontFamily.Monospace else FontFamily.Default
                )
            }
            Box(Modifier.weight(1f))
            BackspaceButton(p) {
                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                onBackspace()
            }
        }
    }
}

/** Small themed ⌫ affordance for correcting the current entry. */
@Composable
private fun BackspaceButton(p: com.calcyoulater.android.theme.CylPalette, onClick: () -> Unit) {
    val shape: Shape = if (p.isNeonBlade) CornerCutShape(6f) else RoundedCornerShape(8.dp)
    var mod = Modifier.size(width = 48.dp, height = 32.dp)
        .clip(shape)
        .background(if (p.isNeonBlade) p.neonCyan.copy(alpha = 0.10f) else p.controlBackground, shape)
    if (p.isNeonBlade) mod = mod.border(1.dp, p.neonCyan.copy(alpha = 0.45f), shape)
    mod = mod.clickable { onClick() }
    Box(mod, contentAlignment = Alignment.Center) {
        Icon(
            Icons.AutoMirrored.Filled.Backspace,
            contentDescription = "Backspace",
            tint = if (p.isNeonBlade) p.neonCyan else p.secondaryText,
            modifier = Modifier.size(18.dp)
        )
    }
}

/** CRT scanline overlay: faint horizontal lines every 3px. */
private fun Modifier.scanlines(): Modifier = drawWithContent {
    drawContent()
    var y = 0f
    val line = Color.Black.copy(alpha = 0.08f)
    while (y < size.height) {
        drawRect(color = line, topLeft = androidx.compose.ui.geometry.Offset(0f, y),
            size = androidx.compose.ui.geometry.Size(size.width, 1f))
        y += 3f
    }
}
