package com.calcyoulater.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material.icons.filled.SettingsBrightness
import androidx.compose.material.icons.filled.SwapHoriz
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.calcyoulater.android.CalcViewModel
import com.calcyoulater.android.theme.AppearanceMode
import com.calcyoulater.android.theme.CornerCutShape
import com.calcyoulater.android.theme.CylTheme

@Composable
fun Toolbar(
    vm: CalcViewModel,
    onToggleHistory: () -> Unit,
    onToggleConverter: () -> Unit,
    modifier: Modifier = Modifier
) {
    val p = CylTheme.palette
    var appearanceMenu by remember { mutableStateOf(false) }

    Row(
        modifier = modifier.fillMaxWidth().padding(horizontal = 14.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Appearance menu
        Box {
            val icon = when (vm.appearance) {
                AppearanceMode.LIGHT -> Icons.Filled.LightMode
                AppearanceMode.DARK -> Icons.Filled.DarkMode
                AppearanceMode.SYSTEM -> Icons.Filled.SettingsBrightness
            }
            iconChip(icon, active = false) { appearanceMenu = true }
            DropdownMenu(expanded = appearanceMenu, onDismissRequest = { appearanceMenu = false }) {
                DropdownMenuItem(text = { Text("System Default") }, onClick = {
                    vm.changeAppearance(AppearanceMode.SYSTEM); appearanceMenu = false
                })
                DropdownMenuItem(text = { Text("Light") }, onClick = {
                    vm.changeAppearance(AppearanceMode.LIGHT); appearanceMenu = false
                })
                DropdownMenuItem(text = { Text("Dark") }, onClick = {
                    vm.changeAppearance(AppearanceMode.DARK); appearanceMenu = false
                })
            }
        }

        // NeonBlade toggle
        neonBladeToggle(vm)

        Box(Modifier.weight(1f))

        textToggle("Sci", active = vm.isScientific) { vm.toggleScientific() }
        iconChip(Icons.Filled.History, active = false) { onToggleHistory() }
        iconChip(Icons.Filled.SwapHoriz, active = false) { onToggleConverter() }
    }
}

@Composable
private fun neonBladeToggle(vm: CalcViewModel) {
    val p = CylTheme.palette
    val on = p.isNeonBlade
    val shape: Shape = if (on) CornerCutShape(6f) else RoundedCornerShape(6.dp)
    var mod = Modifier.size(width = if (on) 44.dp else 30.dp, height = 30.dp)
        .background(
            if (on) p.neonCyan.copy(alpha = 0.15f) else p.controlBackground, shape
        )
    if (on) mod = mod.border(1.dp, p.neonCyan.copy(alpha = 0.7f), shape)
    mod = mod.clickable { vm.toggleNeonBlade() }
    Box(mod, contentAlignment = Alignment.Center) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            Icon(
                Icons.Filled.Bolt, contentDescription = "NeonBlade",
                tint = if (on) p.neonCyan else p.secondaryText,
                modifier = Modifier.size(16.dp)
            )
            if (on) Text("NB", color = p.neonCyan, fontSize = 9.sp,
                fontWeight = FontWeight.Bold, fontFamily = FontFamily.Monospace)
        }
    }
}

@Composable
private fun iconChip(icon: ImageVector, active: Boolean, onClick: () -> Unit) {
    val p = CylTheme.palette
    val shape: Shape = if (p.isNeonBlade) CornerCutShape(6f) else RoundedCornerShape(6.dp)
    val bg = if (p.isNeonBlade) {
        if (active) p.neonCyan.copy(alpha = 0.18f) else p.functionButton
    } else {
        if (active) p.operatorButton.copy(alpha = 0.25f) else p.controlBackground
    }
    var mod = Modifier.size(30.dp).background(bg, shape)
    if (p.isNeonBlade) {
        mod = mod.border(1.dp, if (active) p.neonCyan.copy(alpha = 0.8f) else androidx.compose.ui.graphics.Color(0xFF1e3258), shape)
    }
    mod = mod.clickable { onClick() }
    Box(mod, contentAlignment = Alignment.Center) {
        Icon(icon, contentDescription = null,
            tint = if (p.isNeonBlade) (if (active) p.neonCyan else p.secondaryText) else p.primaryText,
            modifier = Modifier.size(16.dp))
    }
}

@Composable
private fun textToggle(label: String, active: Boolean, onClick: () -> Unit) {
    val p = CylTheme.palette
    val shape: Shape = if (p.isNeonBlade) CornerCutShape(5f) else RoundedCornerShape(6.dp)
    val bg = if (p.isNeonBlade) {
        if (active) p.neonCyan.copy(alpha = 0.18f) else p.functionButton
    } else {
        if (active) p.operatorButton.copy(alpha = 0.25f) else p.controlBackground
    }
    var mod = Modifier.background(bg, shape)
    if (p.isNeonBlade) {
        mod = mod.border(1.dp, if (active) p.neonCyan.copy(alpha = 0.8f) else Color(0xFF1e3258), shape)
    }
    mod = mod.clickable { onClick() }.padding(horizontal = 10.dp, vertical = 6.dp)
    Box(mod, contentAlignment = Alignment.Center) {
        Text(label, fontSize = 11.sp, fontWeight = FontWeight.SemiBold,
            fontFamily = if (p.isNeonBlade) FontFamily.Monospace else FontFamily.Default,
            color = if (p.isNeonBlade) (if (active) p.neonCyan else p.secondaryText)
                    else (if (active) p.operatorButton else p.primaryText))
    }
}
