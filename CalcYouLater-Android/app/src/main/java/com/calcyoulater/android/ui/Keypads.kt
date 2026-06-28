package com.calcyoulater.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.calcyoulater.android.CalcViewModel
import com.calcyoulater.android.engine.AngleMode
import com.calcyoulater.android.engine.EngineState
import com.calcyoulater.android.theme.CalcButtonKind
import com.calcyoulater.android.theme.CornerCutShape
import com.calcyoulater.android.theme.CylTheme

/** Standard 6-row keypad: memory row + AC/±/%/÷ … wide-0/./= */
@Composable
fun StandardKeypad(
    vm: CalcViewModel,
    state: EngineState,
    buttonHeight: Dp,
    memoryHeight: Dp,
    modifier: Modifier = Modifier
) {
    val gap = if (CylTheme.palette.isNeonBlade) 6.dp else 8.dp
    Column(modifier = modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(gap)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(gap)) {
            key("MC", CalcButtonKind.MEMORY, memoryHeight, 13) { vm.memoryClear() }
            key("MR", CalcButtonKind.MEMORY, memoryHeight, 13) { vm.memoryRecall() }
            key("M+", CalcButtonKind.MEMORY, memoryHeight, 13) { vm.memoryAdd() }
            key("M−", CalcButtonKind.MEMORY, memoryHeight, 13) { vm.memorySubtract() }
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(gap)) {
            key(state.clearLabel, CalcButtonKind.FUNCTION, buttonHeight, 17) { vm.clear() }
            key("+/−", CalcButtonKind.FUNCTION, buttonHeight, 17) { vm.toggleSign() }
            key("%", CalcButtonKind.FUNCTION, buttonHeight, 17) { vm.percent() }
            key("÷", CalcButtonKind.OPERATOR, buttonHeight, 22) { vm.op("÷") }
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(gap)) {
            key("7", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("7") }
            key("8", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("8") }
            key("9", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("9") }
            key("×", CalcButtonKind.OPERATOR, buttonHeight, 22) { vm.op("×") }
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(gap)) {
            key("4", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("4") }
            key("5", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("5") }
            key("6", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("6") }
            key("−", CalcButtonKind.OPERATOR, buttonHeight, 22) { vm.op("−") }
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(gap)) {
            key("1", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("1") }
            key("2", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("2") }
            key("3", CalcButtonKind.NUMBER, buttonHeight, 22) { vm.digit("3") }
            key("+", CalcButtonKind.OPERATOR, buttonHeight, 22) { vm.op("+") }
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(gap)) {
            CalcButton("0", CalcButtonKind.NUMBER, Modifier.weight(2f).height(buttonHeight), 22) { vm.digit("0") }
            CalcButton(".", CalcButtonKind.NUMBER, Modifier.weight(1f).height(buttonHeight), 22) { vm.decimal() }
            CalcButton("=", CalcButtonKind.EQUALS, Modifier.weight(1f).height(buttonHeight), 22) { vm.equals() }
        }
    }
}

@Composable
private fun RowScope.key(
    label: String,
    kind: CalcButtonKind,
    height: Dp,
    fontSize: Int,
    onClick: () -> Unit
) {
    CalcButton(label, kind, Modifier.weight(1f).height(height), fontSize, onClick)
}

/** 4×4 scientific grid. */
@Composable
fun ScientificKeypad(
    vm: CalcViewModel,
    buttonHeight: Dp,
    modifier: Modifier = Modifier
) {
    val gap = if (CylTheme.palette.isNeonBlade) 4.dp else 5.dp
    // label, internal-name, kind
    data class SK(val label: String, val name: String, val kind: CalcButtonKind)
    val rows = listOf(
        listOf(SK("sin", "sin", CalcButtonKind.SCIENTIFIC), SK("cos", "cos", CalcButtonKind.SCIENTIFIC), SK("tan", "tan", CalcButtonKind.SCIENTIFIC), SK("π", "π", CalcButtonKind.SCIENTIFIC)),
        listOf(SK("sin⁻¹", "asin", CalcButtonKind.SCIENTIFIC), SK("cos⁻¹", "acos", CalcButtonKind.SCIENTIFIC), SK("tan⁻¹", "atan", CalcButtonKind.SCIENTIFIC), SK("e", "e", CalcButtonKind.SCIENTIFIC)),
        listOf(SK("log", "log", CalcButtonKind.SCIENTIFIC), SK("ln", "ln", CalcButtonKind.SCIENTIFIC), SK("√", "sqrt", CalcButtonKind.SCIENTIFIC), SK("x²", "x²", CalcButtonKind.SCIENTIFIC)),
        listOf(SK("xʸ", "xʸ", CalcButtonKind.SCIENTIFIC), SK("n!", "n!", CalcButtonKind.SCIENTIFIC), SK("1/x", "1/x", CalcButtonKind.SCIENTIFIC), SK("∛x", "cbrt", CalcButtonKind.SCIENTIFIC)),
    )
    Column(modifier = modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(gap)) {
        // DEG / RAD angle-mode toggle
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
            AngleModeToggle(vm.angleMode) { vm.toggleAngleMode() }
        }
        rows.forEach { row ->
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(gap)) {
                row.forEach { sk ->
                    CalcButton(sk.label, sk.kind, Modifier.weight(1f).height(buttonHeight), 13) {
                        when (sk.name) {
                            "π", "e" -> vm.constant(sk.name)
                            "xʸ" -> vm.op("xʸ")
                            else -> vm.scientific(sk.name)
                        }
                    }
                }
            }
        }
    }
}

/** Compact DEG/RAD switch shown above the scientific grid. */
@Composable
private fun AngleModeToggle(mode: AngleMode, onToggle: () -> Unit) {
    val p = CylTheme.palette
    val shape: Shape = if (p.isNeonBlade) CornerCutShape(5f) else RoundedCornerShape(6.dp)
    val accent = if (p.isNeonBlade) p.neonBlue else p.scientificButton
    var mod = Modifier
        .background(if (p.isNeonBlade) accent.copy(alpha = 0.15f) else accent.copy(alpha = 0.18f), shape)
    if (p.isNeonBlade) mod = mod.border(1.dp, accent.copy(alpha = 0.7f), shape)
    mod = mod.clickable { onToggle() }.padding(horizontal = 10.dp, vertical = 4.dp)
    Box(mod, contentAlignment = Alignment.Center) {
        Text(
            text = if (mode == AngleMode.DEG) "DEG" else "RAD",
            color = if (p.isNeonBlade) p.neonBlue else p.primaryText,
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold,
            fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default
        )
    }
}
