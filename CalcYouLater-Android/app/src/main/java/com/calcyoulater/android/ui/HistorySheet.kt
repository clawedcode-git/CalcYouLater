package com.calcyoulater.android.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Divider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.calcyoulater.android.CalcViewModel
import com.calcyoulater.android.engine.HistoryEntry
import com.calcyoulater.android.theme.CylTheme
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun HistorySheet(vm: CalcViewModel, onRecall: () -> Unit) {
    val p = CylTheme.palette
    val history = vm.state.history
    Column(Modifier.fillMaxWidth().padding(bottom = 12.dp)) {
        Row(
            Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                "History",
                color = if (p.isNeonBlade) p.neonCyan else p.primaryText,
                fontSize = 18.sp, fontWeight = FontWeight.SemiBold,
                fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default
            )
            Box(Modifier.weight(1f))
            Text(
                "Clear",
                color = if (p.isNeonBlade) p.neonPink else androidx.compose.ui.graphics.Color(0xFFE53935),
                fontSize = 14.sp,
                modifier = Modifier.clickable { vm.clearHistory() }
            )
        }
        Divider(color = if (p.isNeonBlade) p.neonCyan.copy(alpha = 0.2f) else p.tertiaryText.copy(alpha = 0.3f))

        if (history.isEmpty()) {
            Box(Modifier.fillMaxWidth().padding(40.dp), contentAlignment = Alignment.Center) {
                Text(
                    if (p.isNeonBlade) "// NO DATA //" else "No calculations yet",
                    color = p.secondaryText, fontSize = 13.sp,
                    fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default
                )
            }
        } else {
            LazyColumn(Modifier.fillMaxWidth().heightIn(max = 420.dp)) {
                items(history, key = { it.id }) { entry ->
                    HistoryRow(entry, p) { vm.recallHistory(entry); onRecall() }
                    Divider(color = p.tertiaryText.copy(alpha = 0.15f))
                }
            }
        }
    }
}

@Composable
private fun HistoryRow(entry: HistoryEntry, p: com.calcyoulater.android.theme.CylPalette, onClick: () -> Unit) {
    Column(
        Modifier.fillMaxWidth().clickable { onClick() }.padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalAlignment = Alignment.End
    ) {
        Text(
            entry.expression,
            color = if (p.isNeonBlade) p.neonCyan.copy(alpha = 0.65f) else p.secondaryText,
            fontSize = 11.sp, fontFamily = FontFamily.Monospace,
            maxLines = 1, overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth()
        )
        Text(
            entry.result,
            color = p.primaryText, fontSize = 17.sp, fontWeight = FontWeight.SemiBold,
            fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default,
            maxLines = 1, overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth()
        )
        Text(
            timeFormat.format(Date(entry.timestamp)),
            color = p.tertiaryText, fontSize = 10.sp,
            fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default
        )
    }
}

private val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
