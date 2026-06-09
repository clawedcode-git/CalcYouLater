package com.calcyoulater.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.calcyoulater.android.CalcViewModel
import com.calcyoulater.android.theme.AppearanceMode
import com.calcyoulater.android.theme.CylPalette
import com.calcyoulater.android.theme.LocalCylPalette

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CalcYouLaterApp(vm: CalcViewModel) {
    val systemDark = isSystemInDarkTheme()
    val palette = remember(vm.themeMode, vm.appearance, systemDark) {
        if (vm.themeMode.isNeonBlade) {
            CylPalette.neonBlade()
        } else {
            val dark = when (vm.appearance) {
                AppearanceMode.LIGHT -> false
                AppearanceMode.DARK -> true
                AppearanceMode.SYSTEM -> systemDark
            }
            CylPalette.standard(dark)
        }
    }

    var showHistory by remember { mutableStateOf(false) }
    var showConverter by remember { mutableStateOf(false) }

    CompositionLocalProvider(LocalCylPalette provides palette) {
        Box(
            Modifier.fillMaxSize().background(palette.windowBackground).systemBarsPadding()
        ) {
            BoxWithConstraints(Modifier.fillMaxSize()) {
                val landscape = maxWidth > maxHeight
                if (landscape) {
                    LandscapeLayout(vm, { showHistory = true }, { showConverter = true })
                } else {
                    PortraitLayout(vm, { showHistory = true }, { showConverter = true })
                }
            }

            if (showHistory) {
                ModalBottomSheet(onDismissRequest = { showHistory = false },
                    sheetState = rememberModalBottomSheetState(true),
                    containerColor = palette.sidebarBackground) {
                    HistorySheet(vm) { showHistory = false }
                }
            }
            if (showConverter) {
                ModalBottomSheet(onDismissRequest = { showConverter = false },
                    sheetState = rememberModalBottomSheetState(true),
                    containerColor = palette.sidebarBackground) {
                    ConverterSheet(vm)
                }
            }
        }
    }
}

@Composable
private fun PortraitLayout(vm: CalcViewModel, onHistory: () -> Unit, onConverter: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(horizontal = 12.dp)) {
        Toolbar(vm, onHistory, onConverter)
        Display(vm.state, vm::fmt, Modifier.padding(top = 6.dp, bottom = 4.dp))
        if (vm.isScientific) {
            ScientificKeypad(vm, buttonHeight = 44.dp, modifier = Modifier.padding(vertical = 8.dp))
        }
        Spacer(Modifier.weight(1f))
        StandardKeypad(
            vm = vm,
            state = vm.state,
            buttonHeight = 64.dp,
            memoryHeight = 44.dp,
            modifier = Modifier.padding(bottom = 12.dp)
        )
    }
}

@Composable
private fun LandscapeLayout(vm: CalcViewModel, onHistory: () -> Unit, onConverter: () -> Unit) {
    Column(Modifier.fillMaxSize()) {
        Toolbar(vm, onHistory, onConverter)
        Row(Modifier.fillMaxSize().padding(horizontal = 12.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Column(Modifier.weight(1f).fillMaxHeight(), verticalArrangement = Arrangement.Center) {
                Display(vm.state, vm::fmt)
            }
            if (vm.isScientific) {
                Column(Modifier.weight(1f).fillMaxHeight().verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.Center) {
                    ScientificKeypad(vm, buttonHeight = 40.dp)
                }
            }
            Column(Modifier.weight(1f).fillMaxHeight(), verticalArrangement = Arrangement.Center) {
                StandardKeypad(vm, vm.state, buttonHeight = 42.dp, memoryHeight = 30.dp)
            }
        }
    }
}
