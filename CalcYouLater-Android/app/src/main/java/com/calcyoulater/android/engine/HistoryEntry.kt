package com.calcyoulater.android.engine

import java.util.UUID

/** One saved calculation. Mirrors HistoryEntry in the SwiftUI app. */
data class HistoryEntry(
    val expression: String,
    val result: String,
    val timestamp: Long = System.currentTimeMillis(),
    val id: String = UUID.randomUUID().toString()
)
