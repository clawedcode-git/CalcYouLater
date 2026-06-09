package com.calcyoulater.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.foundation.clickable
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalClipboardManager
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
    modifier: Modifier = Modifier
) {
    val p = CylTheme.palette
    val clipboard = LocalClipboardManager.current
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

        // Main number — tap to copy
        Text(
            text = state.display,
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

        // Memory indicator
        Box(modifier = Modifier.fillMaxWidth().heightIn(min = 16.dp)) {
            if (state.hasMemory) {
                Text(
                    text = (if (p.isNeonBlade) "▸ " else "") + "M: ${fmt(state.memory)}",
                    color = p.memoryIndicatorColor,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    fontFamily = if (mono) FontFamily.Monospace else FontFamily.Default,
                    modifier = Modifier.align(Alignment.CenterStart)
                )
            }
        }
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
