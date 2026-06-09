package com.calcyoulater.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.calcyoulater.android.CalcViewModel
import com.calcyoulater.android.engine.ConvCategory
import com.calcyoulater.android.engine.Converter
import com.calcyoulater.android.theme.CornerCutShape
import com.calcyoulater.android.theme.CylTheme

@Composable
fun ConverterSheet(vm: CalcViewModel) {
    val p = CylTheme.palette
    var category by remember { mutableStateOf(ConvCategory.LENGTH) }
    var fromUnit by remember { mutableStateOf(category.units[0]) }
    var toUnit by remember { mutableStateOf(category.units[1]) }
    var input by remember { mutableStateOf("") }

    fun resetUnits(c: ConvCategory) {
        fromUnit = c.units[0]
        toUnit = if (c.units.size > 1) c.units[1] else c.units[0]
    }

    val result = Converter.convert(category, input, fromUnit, toUnit)

    Column(Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        Text(
            "Convert",
            color = if (p.isNeonBlade) p.neonCyan else p.primaryText,
            fontSize = 18.sp, fontWeight = FontWeight.SemiBold,
            fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default
        )

        label(if (p.isNeonBlade) "// CATEGORY" else "Category")
        DropdownPicker(
            current = category.displayName,
            options = ConvCategory.entries.map { it.displayName }
        ) { idx ->
            category = ConvCategory.entries[idx]
            resetUnits(category)
        }

        label(if (p.isNeonBlade) "// UNITS" else "Units")
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Box(Modifier.weight(1f)) {
                DropdownPicker(current = fromUnit, options = category.units) { fromUnit = category.units[it] }
            }
            Icon(Icons.Filled.ArrowForward, contentDescription = null,
                tint = if (p.isNeonBlade) p.neonCyan.copy(alpha = 0.7f) else p.secondaryText)
            Box(Modifier.weight(1f)) {
                DropdownPicker(current = toUnit, options = category.units) { toUnit = category.units[it] }
            }
        }

        label(if (p.isNeonBlade) "// VALUE" else "Value")
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedTextField(
                value = input,
                onValueChange = { input = it },
                placeholder = { Text("Enter value") },
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                modifier = Modifier.weight(1f)
            )
            Text(
                "↓ use display",
                color = if (p.isNeonBlade) p.neonCyan else p.operatorButton,
                fontSize = 12.sp,
                modifier = Modifier.clickable { input = vm.state.display }
            )
        }

        if (!result.isNullOrEmpty()) {
            label(if (p.isNeonBlade) "// OUTPUT" else "Result")
            val shape: Shape = if (p.isNeonBlade) CornerCutShape(10f) else RoundedCornerShape(10.dp)
            var box = Modifier.fillMaxWidth().clip(shape).background(p.controlBackground, shape)
            if (p.isNeonBlade) box = box.border(1.dp, p.neonCyan.copy(alpha = 0.35f), shape)
            Box(box.padding(12.dp)) {
                Text(
                    result,
                    color = if (p.isNeonBlade) p.neonCyan else p.primaryText,
                    fontSize = 22.sp, fontWeight = FontWeight.SemiBold,
                    fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default
                )
            }
        }
    }
}

@Composable
private fun label(text: String) {
    val p = CylTheme.palette
    Text(text, color = p.secondaryText, fontSize = 11.sp,
        fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default)
}

@Composable
private fun DropdownPicker(current: String, options: List<String>, onSelect: (Int) -> Unit) {
    val p = CylTheme.palette
    var expanded by remember { mutableStateOf(false) }
    val shape: Shape = if (p.isNeonBlade) CornerCutShape(6f) else RoundedCornerShape(8.dp)
    Box {
        Row(
            Modifier.fillMaxWidth()
                .clip(shape)
                .background(p.controlBackground, shape)
                .border(1.dp, if (p.isNeonBlade) p.neonCyan.copy(alpha = 0.3f) else p.tertiaryText.copy(alpha = 0.4f), shape)
                .clickable { expanded = true }
                .padding(horizontal = 12.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(current, color = p.primaryText, fontSize = 14.sp,
                fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default)
            Box(Modifier.weight(1f))
            Icon(Icons.Filled.KeyboardArrowDown, contentDescription = null, tint = p.secondaryText)
        }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            options.forEachIndexed { i, opt ->
                DropdownMenuItem(text = { Text(opt) }, onClick = { onSelect(i); expanded = false })
            }
        }
    }
}
