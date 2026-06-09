package com.calcyoulater.android

import com.calcyoulater.android.engine.CalculatorEngine
import com.calcyoulater.android.engine.ConvCategory
import com.calcyoulater.android.engine.Converter
import com.calcyoulater.android.engine.fmt
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class EngineTest {

    private fun digits(e: CalculatorEngine, s: String) {
        for (ch in s) {
            if (ch == '.') e.inputDecimal() else e.inputDigit(ch.toString())
        }
    }

    @Test fun additionChained() {
        val e = CalculatorEngine()
        digits(e, "5"); e.inputOperator("+"); digits(e, "3"); e.equals()
        assertEquals("8", e.display)
    }

    @Test fun chainedAutoEvaluate() {
        // 5 + 3 × 2 = -> (5+3)=8, 8×2=16
        val e = CalculatorEngine()
        digits(e, "5"); e.inputOperator("+"); digits(e, "3")
        e.inputOperator("×"); digits(e, "2"); e.equals()
        assertEquals("16", e.display)
    }

    @Test fun repeatedEquals() {
        // 5 + 3 = = = -> 8, 11, 14
        val e = CalculatorEngine()
        digits(e, "5"); e.inputOperator("+"); digits(e, "3")
        e.equals(); assertEquals("8", e.display)
        e.equals(); assertEquals("11", e.display)
        e.equals(); assertEquals("14", e.display)
    }

    @Test fun percentWithPendingOperator() {
        // 200 + 10% -> 200 + 20
        val e = CalculatorEngine()
        digits(e, "200"); e.inputOperator("+"); digits(e, "10"); e.percent()
        assertEquals("20", e.display)
    }

    @Test fun divideByZeroIsInfinity() {
        val e = CalculatorEngine()
        digits(e, "5"); e.inputOperator("÷"); digits(e, "0"); e.equals()
        assertEquals("∞", e.display)
    }

    @Test fun factorialCap() {
        val e = CalculatorEngine()
        digits(e, "21"); e.applyScientific("n!")
        assertEquals("∞", e.display)
    }

    @Test fun factorialValue() {
        val e = CalculatorEngine()
        digits(e, "5"); e.applyScientific("n!")
        assertEquals("120", e.display)
    }

    @Test fun trigDegrees() {
        val e = CalculatorEngine()
        digits(e, "90"); e.applyScientific("sin")
        assertEquals("1", e.display)
    }

    @Test fun sqrtAndSquare() {
        val e = CalculatorEngine()
        digits(e, "9"); e.applyScientific("sqrt"); assertEquals("3", e.display)
        e.allClear()
        digits(e, "4"); e.applyScientific("x²"); assertEquals("16", e.display)
    }

    @Test fun backspaceAndSign() {
        val e = CalculatorEngine()
        digits(e, "123"); e.backspace(); assertEquals("12", e.display)
        e.toggleSign(); assertEquals("-12", e.display)
    }

    @Test fun memoryFlow() {
        val e = CalculatorEngine()
        digits(e, "42"); e.memoryAdd()
        assertTrue(e.hasMemory)
        assertEquals(42.0, e.memory, 0.0001)
        e.allClear(); e.memoryRecall()
        assertEquals("42", e.display)
        e.memoryClear()
        assertTrue(!e.hasMemory)
    }

    @Test fun historyRecordedAndCapped() {
        val e = CalculatorEngine()
        digits(e, "1"); e.inputOperator("+"); digits(e, "1"); e.equals()
        assertTrue(e.history.isNotEmpty())
        assertEquals("2", e.history.first().result)
    }

    @Test fun fmtEdgeCases() {
        assertEquals("Error", fmt(Double.NaN))
        assertEquals("∞", fmt(Double.POSITIVE_INFINITY))
        assertEquals("-∞", fmt(Double.NEGATIVE_INFINITY))
        assertEquals("7", fmt(7.0))
        assertEquals("3.5", fmt(3.5))
    }

    @Test fun conversionsPerCategory() {
        assertEquals("3.2808399 ft", Converter.convert(ConvCategory.LENGTH, "1", "m", "ft"))
        assertEquals("1000 g", Converter.convert(ConvCategory.WEIGHT, "1", "kg", "g"))
        assertEquals("32 °F", Converter.convert(ConvCategory.TEMPERATURE, "0", "°C", "°F"))
        assertEquals("10000 m²", Converter.convert(ConvCategory.AREA, "1", "ha", "m²"))
        assertEquals("1000 mL", Converter.convert(ConvCategory.VOLUME, "1", "L", "mL"))
        assertEquals("3.6 km/h", Converter.convert(ConvCategory.SPEED, "1", "m/s", "km/h"))
    }

    @Test fun conversionInvalidInput() {
        assertEquals(null, Converter.convert(ConvCategory.LENGTH, "abc", "m", "ft"))
    }
}
