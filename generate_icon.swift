#!/usr/bin/swift
import AppKit
import CoreGraphics

let S = 1024.0
let image = NSImage(size: NSSize(width: S, height: S))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

// ── Clipping mask: rounded square ────────────────────────────
let bgPath = CGPath(roundedRect: CGRect(x: 0, y: 0, width: S, height: S),
                    cornerWidth: 226, cornerHeight: 226, transform: nil)
ctx.addPath(bgPath)
ctx.clip()

// ── Background gradient: deep indigo → rich purple ───────────
let cs = CGColorSpaceCreateDeviceRGB()
let bgGrad = CGGradient(
    colorsSpace: cs,
    colors: [
        CGColor(red: 0.08, green: 0.04, blue: 0.22, alpha: 1),
        CGColor(red: 0.16, green: 0.06, blue: 0.38, alpha: 1),
    ] as CFArray,
    locations: [0.0, 1.0])!
ctx.drawLinearGradient(bgGrad,
    start: CGPoint(x: 0, y: 0),
    end: CGPoint(x: S, y: S),
    options: [])

// Subtle diagonal sheen
let sheenGrad = CGGradient(
    colorsSpace: cs,
    colors: [
        CGColor(red: 1, green: 1, blue: 1, alpha: 0.06),
        CGColor(red: 1, green: 1, blue: 1, alpha: 0.0),
    ] as CFArray,
    locations: [0.0, 1.0])!
ctx.drawLinearGradient(sheenGrad,
    start: CGPoint(x: 0, y: S),
    end: CGPoint(x: S * 0.6, y: S * 0.3),
    options: [])

// ── Calculator body ──────────────────────────────────────────
let cX = 148.0, cY = 80.0, cW = 728.0, cH = 864.0
let bodyPath = CGPath(
    roundedRect: CGRect(x: cX, y: cY, width: cW, height: cH),
    cornerWidth: 100, cornerHeight: 100, transform: nil)

ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.055))
ctx.addPath(bodyPath)
ctx.fillPath()

ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.15))
ctx.setLineWidth(3.5)
ctx.addPath(bodyPath)
ctx.strokePath()

// ── Display screen ───────────────────────────────────────────
let dX = 196.0, dY = 778.0, dW = 632.0, dH = 116.0
let dispPath = CGPath(
    roundedRect: CGRect(x: dX, y: dY, width: dW, height: dH),
    cornerWidth: 18, cornerHeight: 18, transform: nil)

// Dark glass effect
let dispGrad = CGGradient(
    colorsSpace: cs,
    colors: [
        CGColor(red: 0, green: 0, blue: 0, alpha: 0.55),
        CGColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 0.45),
    ] as CFArray,
    locations: [0.0, 1.0])!
ctx.saveGState()
ctx.addPath(dispPath)
ctx.clip()
ctx.drawLinearGradient(dispGrad,
    start: CGPoint(x: dX, y: dY + dH),
    end: CGPoint(x: dX, y: dY),
    options: [])
ctx.restoreGState()

ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.12))
ctx.setLineWidth(2)
ctx.addPath(dispPath)
ctx.strokePath()

// Display text — expression (top line)
let exprAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.monospacedSystemFont(ofSize: 24, weight: .ultraLight),
    .foregroundColor: NSColor.white.withAlphaComponent(0.45)
]
let exprStr = NSAttributedString(string: "6 × 7  =", attributes: exprAttrs)
exprStr.draw(at: NSPoint(
    x: dX + dW - exprStr.size().width - 18,
    y: dY + dH - 34))

// Display text — main number
let numAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.monospacedSystemFont(ofSize: 76, weight: .ultraLight),
    .foregroundColor: NSColor.white
]
let numStr = NSAttributedString(string: "42", attributes: numAttrs)
numStr.draw(at: NSPoint(
    x: dX + dW - numStr.size().width - 18,
    y: dY + 6))

// ── Button grid ───────────────────────────────────────────────
// 4 columns, 6 rows (1 memory + 4 standard + 1 bottom)
let bX = 196.0, bY = 108.0
let bAreaW = 632.0, bAreaH = 640.0
let cols = 4, rows = 6
let bGapX = 16.0, bGapY = 14.0
let bW = (bAreaW - Double(cols - 1) * bGapX) / Double(cols)   // ≈ 138
let bH = (bAreaH - Double(rows - 1) * bGapY) / Double(rows)   // ≈ 95

func drawBtn(col: Int, row: Int, r: Double, g: Double, b: Double, a: Double,
             wMult: Double = 1, label: String = "", labelSize: Double = 0) {
    let x = bX + Double(col) * (bW + bGapX)
    let y = bY + bAreaH - Double(row + 1) * bH - Double(row) * bGapY
    let w = bW * wMult + (wMult > 1 ? bGapX * (wMult - 1) : 0)

    let path = CGPath(roundedRect: CGRect(x: x, y: y, width: w, height: bH),
                      cornerWidth: 18, cornerHeight: 18, transform: nil)
    ctx.setFillColor(CGColor(red: r, green: g, blue: b, alpha: a))
    ctx.addPath(path)
    ctx.fillPath()

    if !label.isEmpty, labelSize > 0 {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: labelSize, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let s = NSAttributedString(string: label, attributes: attrs)
        s.draw(at: NSPoint(x: x + (w - s.size().width) / 2,
                           y: y + (bH - s.size().height) / 2))
    }
}

// Row 0 — memory (purple)
for c in 0..<4 { drawBtn(col: c, row: 0, r: 0.52, g: 0.18, b: 0.88, a: 0.65) }

// Row 1 — functions (light glass)
for c in 0..<3 { drawBtn(col: c, row: 1, r: 1, g: 1, b: 1, a: 0.08) }
drawBtn(col: 3, row: 1, r: 1, g: 0.56, b: 0.0, a: 0.88)   // ÷ orange

// Rows 2–4 — numbers + operators
for row in 2...4 {
    for c in 0..<3 { drawBtn(col: c, row: row, r: 1, g: 1, b: 1, a: 0.09) }
    drawBtn(col: 3, row: row, r: 1, g: 0.56, b: 0.0, a: 0.88)
}

// Row 5 — bottom: wide 0, dot, glowing = (orange)
// Wide 0
let w0Path = CGPath(roundedRect: CGRect(x: bX, y: bY, width: bW * 2 + bGapX, height: bH),
                    cornerWidth: 18, cornerHeight: 18, transform: nil)
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.09))
ctx.addPath(w0Path)
ctx.fillPath()

// Dot
let dotX = bX + bW * 2 + bGapX * 2
let dotPath = CGPath(roundedRect: CGRect(x: dotX, y: bY, width: bW, height: bH),
                     cornerWidth: 18, cornerHeight: 18, transform: nil)
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.09))
ctx.addPath(dotPath)
ctx.fillPath()

// = button — bright orange with soft glow
let eqX = dotX + bW + bGapX
let eqRect = CGRect(x: eqX, y: bY, width: bW, height: bH)

// Outer glow
ctx.setShadow(offset: .zero, blur: 28,
              color: CGColor(red: 1, green: 0.56, blue: 0, alpha: 0.6))
let eqPath = CGPath(roundedRect: eqRect, cornerWidth: 18, cornerHeight: 18, transform: nil)
ctx.setFillColor(CGColor(red: 1, green: 0.56, blue: 0.0, alpha: 1.0))
ctx.addPath(eqPath)
ctx.fillPath()
ctx.setShadow(offset: .zero, blur: 0, color: nil)

// = label
let eqAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 58, weight: .semibold),
    .foregroundColor: NSColor.white
]
let eqStr = NSAttributedString(string: "=", attributes: eqAttrs)
eqStr.draw(at: NSPoint(x: eqX + (bW - eqStr.size().width) / 2,
                        y: bY + (bH - eqStr.size().height) / 2))

// ── Subtle π watermark top-right ─────────────────────────────
let piAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 42, weight: .ultraLight),
    .foregroundColor: NSColor.white.withAlphaComponent(0.08)
]
let piStr = NSAttributedString(string: "π", attributes: piAttrs)
piStr.draw(at: NSPoint(x: S - 80, y: S - 72))

image.unlockFocus()

// ── Save as PNG ───────────────────────────────────────────────
let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "/tmp/calcyoulater_icon_1024.png"

let tiff   = image.tiffRepresentation!
let bitmap = NSBitmapImageRep(data: tiff)!
let png    = bitmap.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: outputPath))
print("✓ Icon saved to \(outputPath)")
