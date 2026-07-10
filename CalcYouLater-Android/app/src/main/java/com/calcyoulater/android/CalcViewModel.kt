package com.calcyoulater.android

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.datastore.preferences.core.doublePreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.calcyoulater.android.engine.AngleMode
import com.calcyoulater.android.engine.CalculatorEngine
import com.calcyoulater.android.engine.EngineState
import com.calcyoulater.android.engine.EngineWorkState
import com.calcyoulater.android.engine.HistoryEntry
import com.calcyoulater.android.theme.AppearanceMode
import com.calcyoulater.android.theme.ThemeMode
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import android.content.Context

private val Context.dataStore by preferencesDataStore(name = "calcyoulater_settings")

private object Keys {
    val THEME = stringPreferencesKey("themeMode")
    val APPEARANCE = stringPreferencesKey("appearanceMode")
    val IS_SCI = stringPreferencesKey("isScientific")
    val MEMORY = doublePreferencesKey("memory")
    val HAS_MEMORY = stringPreferencesKey("hasMemory")
    val HISTORY = stringPreferencesKey("history")
    val ANGLE = stringPreferencesKey("angleMode")
    val WORKSTATE = stringPreferencesKey("workState")
}

/**
 * Holds the [CalculatorEngine] and surfaces an immutable [EngineState] plus user
 * settings to Compose. Persists settings + history via DataStore.
 */
class CalcViewModel(app: Application) : AndroidViewModel(app) {

    private val engine = CalculatorEngine()

    var state by mutableStateOf(engine.snapshot()); private set
    var themeMode by mutableStateOf(ThemeMode.STANDARD); private set
    var appearance by mutableStateOf(AppearanceMode.SYSTEM); private set
    var isScientific by mutableStateOf(false); private set
    var angleMode by mutableStateOf(AngleMode.DEG); private set

    private var loaded = false

    init {
        viewModelScope.launch {
            val prefs = getApplication<Application>().dataStore.data.first()
            themeMode = if (prefs[Keys.THEME] == "neonBlade") ThemeMode.NEON_BLADE else ThemeMode.STANDARD
            appearance = when (prefs[Keys.APPEARANCE]) {
                "light" -> AppearanceMode.LIGHT
                "dark" -> AppearanceMode.DARK
                else -> AppearanceMode.SYSTEM
            }
            isScientific = prefs[Keys.IS_SCI] == "true"
            angleMode = if (prefs[Keys.ANGLE] == "RAD") AngleMode.RAD else AngleMode.DEG
            engine.angleMode = angleMode
            val mem = prefs[Keys.MEMORY] ?: 0.0
            val hasMem = prefs[Keys.HAS_MEMORY] == "true"
            engine.restoreMemory(mem, hasMem)
            prefs[Keys.HISTORY]?.let { engine.loadHistory(decodeHistory(it)) }
            prefs[Keys.WORKSTATE]?.let { decodeWorkState(it)?.let(engine::restoreWorkState) }
            loaded = true
            refresh()
        }
    }

    private fun refresh() {
        state = engine.snapshot()
        persistWorkState()
    }

    // ── Engine dispatch ──────────────────────────────────────────
    fun digit(d: String) { engine.inputDigit(d); refresh() }
    fun decimal() { engine.inputDecimal(); refresh() }
    fun backspace() { engine.backspace(); refresh() }
    fun op(o: String) { engine.inputOperator(o); refresh(); persistHistory() }
    fun equals() { engine.equals(); refresh(); persistHistory() }
    fun clear() { engine.clear(); refresh() }
    fun allClear() { engine.allClear(); refresh() }
    fun toggleSign() { engine.toggleSign(); refresh() }
    fun percent() { engine.percent(); refresh() }
    fun paste(text: String) { engine.paste(text); refresh() }
    fun scientific(fn: String) { engine.applyScientific(fn); refresh(); persistHistory() }
    fun constant(c: String) { engine.inputConstant(c); refresh() }
    fun memoryClear() { engine.memoryClear(); refresh(); persistMemory() }
    fun memoryRecall() { engine.memoryRecall(); refresh() }
    fun memoryAdd() { engine.memoryAdd(); refresh(); persistMemory() }
    fun memorySubtract() { engine.memorySubtract(); refresh(); persistMemory() }
    fun recallHistory(e: HistoryEntry) { engine.recallHistory(e); refresh() }
    fun clearHistory() { engine.clearHistory(); refresh(); persistHistory() }
    fun deleteHistory(e: HistoryEntry) { engine.deleteHistory(e); refresh(); persistHistory() }

    fun fmt(v: Double): String = com.calcyoulater.android.engine.fmt(v)

    // ── Settings ─────────────────────────────────────────────────
    fun toggleNeonBlade() {
        themeMode = if (themeMode.isNeonBlade) ThemeMode.STANDARD else ThemeMode.NEON_BLADE
        persist(Keys.THEME, if (themeMode.isNeonBlade) "neonBlade" else "standard")
    }

    fun changeAppearance(mode: AppearanceMode) {
        appearance = mode
        persist(Keys.APPEARANCE, mode.name.lowercase())
    }

    fun toggleScientific() {
        isScientific = !isScientific
        persist(Keys.IS_SCI, isScientific.toString())
    }

    fun toggleAngleMode() {
        angleMode = if (angleMode == AngleMode.DEG) AngleMode.RAD else AngleMode.DEG
        engine.angleMode = angleMode
        persist(Keys.ANGLE, angleMode.name)
    }

    // ── Persistence helpers ──────────────────────────────────────
    private fun persist(key: androidx.datastore.preferences.core.Preferences.Key<String>, value: String) {
        if (!loaded) return
        viewModelScope.launch {
            getApplication<Application>().dataStore.edit { it[key] = value }
        }
    }

    private fun persistMemory() {
        if (!loaded) return
        viewModelScope.launch {
            getApplication<Application>().dataStore.edit {
                it[Keys.MEMORY] = state.memory
                it[Keys.HAS_MEMORY] = state.hasMemory.toString()
            }
        }
    }

    private fun persistHistory() {
        if (!loaded) return
        val json = encodeHistory(engine.history)
        viewModelScope.launch {
            getApplication<Application>().dataStore.edit { it[Keys.HISTORY] = json }
        }
    }

    private fun persistWorkState() {
        if (!loaded) return
        val json = encodeWorkState(engine.workState())
        viewModelScope.launch {
            getApplication<Application>().dataStore.edit { it[Keys.WORKSTATE] = json }
        }
    }

    private fun encodeWorkState(s: EngineWorkState): String = JSONObject().apply {
        put("display", s.display)
        put("expression", s.expression)
        put("leftOperand", s.leftOperand ?: JSONObject.NULL)
        put("pendingOperator", s.pendingOperator ?: JSONObject.NULL)
        put("lastOperand", s.lastOperand ?: JSONObject.NULL)
        put("lastOperator", s.lastOperator ?: JSONObject.NULL)
        put("shouldResetDisplay", s.shouldResetDisplay)
        put("justEvaluated", s.justEvaluated)
    }.toString()

    private fun decodeWorkState(s: String): EngineWorkState? = runCatching {
        val o = JSONObject(s)
        EngineWorkState(
            display = o.optString("display", "0"),
            expression = o.optString("expression", ""),
            leftOperand = if (o.isNull("leftOperand")) null else o.getDouble("leftOperand"),
            pendingOperator = if (o.isNull("pendingOperator")) null else o.getString("pendingOperator"),
            lastOperand = if (o.isNull("lastOperand")) null else o.getDouble("lastOperand"),
            lastOperator = if (o.isNull("lastOperator")) null else o.getString("lastOperator"),
            shouldResetDisplay = o.optBoolean("shouldResetDisplay", false),
            justEvaluated = o.optBoolean("justEvaluated", false)
        )
    }.getOrNull()

    private fun encodeHistory(entries: List<HistoryEntry>): String {
        val arr = JSONArray()
        entries.forEach { e ->
            arr.put(JSONObject().apply {
                put("expression", e.expression)
                put("result", e.result)
                put("timestamp", e.timestamp)
                put("id", e.id)
            })
        }
        return arr.toString()
    }

    private fun decodeHistory(s: String): List<HistoryEntry> {
        return runCatching {
            val arr = JSONArray(s)
            (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                HistoryEntry(
                    expression = o.getString("expression"),
                    result = o.getString("result"),
                    timestamp = o.optLong("timestamp", System.currentTimeMillis()),
                    id = o.optString("id")
                )
            }
        }.getOrDefault(emptyList())
    }
}
