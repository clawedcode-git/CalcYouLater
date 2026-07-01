package com.calcyoulater.android.engine

/**
 * A short, human-friendly age for a history entry: "just now", "5m ago", "2h ago", "3d ago".
 *
 * Returns null for timestamps a week or more old — or in the future (clock skew / bad data) —
 * where the caller should fall back to an absolute date. Pure and JVM-testable: `now` is
 * passed in rather than read from the system clock.
 */
fun relativeTimeLabel(nowMs: Long, thenMs: Long): String? {
    val diff = nowMs - thenMs
    if (diff < 0) return null
    val sec = diff / 1000
    val min = sec / 60
    val hr = min / 60
    val day = hr / 24
    return when {
        sec < 60 -> "just now"
        min < 60 -> "${min}m ago"
        hr < 24 -> "${hr}h ago"
        day < 7 -> "${day}d ago"
        else -> null
    }
}
