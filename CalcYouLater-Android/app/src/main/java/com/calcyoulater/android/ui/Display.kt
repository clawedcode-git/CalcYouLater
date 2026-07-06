package com.calcyoulater.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Backspace
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import android.content.Intent
import android.widget.Toast
import com.calcyoulater.android.engine.EngineState
import com.calcyoulater.android.theme.CornerCutShape
import com.calcyoulater.android.theme.CylTheme

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun Display(
    state: EngineState,
    fmt: (Double) -> String,
    onBackspace: () -> Unit,
    onClearAll: () -> Unit,
    modifier: Modifier = Modifier
) {
    val p = CylTheme.palette
    val clipboard = LocalClipboardManager.current
    val haptic = LocalHapticFeedback.current
    val context = LocalContext.current
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

        // Main number — auto-shrinks to fit (no ellipsis); tap to copy the raw value
        AutoSizeNumber(
            text = com.calcyoulater.android.engine.groupThousands(state.display),
            color = p.primaryText,
            fontFamily = if (mono) FontFamily.Monospace else FontFamily.Default,
            modifier = Modifier
                .fillMaxWidth()
                .combinedClickable(
                    onClick = {
                        clipboard.setText(AnnotatedString(state.display))
                        haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                        Toast.makeText(context, "Copied ${state.display}", Toast.LENGTH_SHORT).show()
                    },
                    onLongClick = {
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                        val send = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, state.display)
                        }
                        context.startActivity(Intent.createChooser(send, "Share result"))
                    }
                )
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
            BackspaceButton(
                p = p,
                onClick = {
                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    onBackspace()
                },
                onLongClick = {
                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    Toast.makeText(context, "Cleared", Toast.LENGTH_SHORT).show()
                    onClearAll()
                }
            )
        }
    }
}

/**
 * Right-aligned single-line number that shrinks its font (52sp → 22sp) until it fits the
 * available width, instead of ellipsizing. Mirrors SwiftUI's `minimumScaleFactor`, so long
 * results show every digit rather than being cut off with "…".
 */
@Composable
private fun AutoSizeNumber(
    text: String,
    color: Color,
    fontFamily: FontFamily,
    modifier: Modifier = Modifier,
    maxSp: Int = 52,
    minSp: Int = 22
) {
    val measurer = rememberTextMeasurer()
    BoxWithConstraints(modifier, contentAlignment = Alignment.CenterEnd) {
        val maxWidthPx = constraints.maxWidth
        val fontSize = remember(text, maxWidthPx, fontFamily) {
            var sp = maxSp
            while (sp > minSp) {
                val w = measurer.measure(
                    text = AnnotatedString(text),
                    style = TextStyle(
                        fontSize = sp.sp,
                        fontWeight = FontWeight.Light,
                        fontFamily = fontFamily
                    ),
                    maxLines = 1,
                    softWrap = false
                ).size.width
                if (w <= maxWidthPx) break
                sp -= 2
            }
            sp
        }
        Text(
            text = text,
            color = color,
            fontSize = fontSize.sp,
            fontWeight = FontWeight.Light,
            fontFamily = fontFamily,
            maxLines = 1,
            softWrap = false,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.End,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

/**
 * Small themed ⌫ affordance. Tap deletes the last digit; long-press clears everything (AC),
 * mirroring the physical-calculator habit of holding backspace to wipe the entry.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun BackspaceButton(
    p: com.calcyoulater.android.theme.CylPalette,
    onClick: () -> Unit,
    onLongClick: () -> Unit
) {
    val shape: Shape = if (p.isNeonBlade) CornerCutShape(6f) else RoundedCornerShape(8.dp)
    var mod = Modifier.size(width = 48.dp, height = 32.dp)
        .clip(shape)
        .background(if (p.isNeonBlade) p.neonCyan.copy(alpha = 0.10f) else p.controlBackground, shape)
    if (p.isNeonBlade) mod = mod.border(1.dp, p.neonCyan.copy(alpha = 0.45f), shape)
    mod = mod.combinedClickable(onClick = onClick, onLongClick = onLongClick)
    Box(mod, contentAlignment = Alignment.Center) {
        Icon(
            Icons.AutoMirrored.Filled.Backspace,
            contentDescription = "Backspace (long-press to clear all)",
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
