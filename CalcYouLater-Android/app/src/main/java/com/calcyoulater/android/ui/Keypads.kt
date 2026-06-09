package com.calcyoulater.android.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.calcyoulater.android.CalcViewModel
import com.calcyoulater.android.engine.EngineState
import com.calcyoulater.android.theme.CalcButtonKind
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
