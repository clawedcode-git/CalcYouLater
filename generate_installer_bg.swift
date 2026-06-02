#!/usr/bin/swift
import AppKit
import CoreGraphics

// Installer background: 620×413 (standard macOS installer canvas)
let W = 620.0, H = 413.0
let image = NSImage(size: NSSize(width: W, height: H))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
let cs  = CGColorSpaceCreateDeviceRGB()

// Background gradient — matching the app icon palette
let bgGrad = CGGradient(
    colorsSpace: cs,
    colors: [
        CGColor(red: 0.08, green: 0.04, blue: 0.22, alpha: 1),
        CGColor(red: 0.14, green: 0.05, blue: 0.32, alpha: 1),
    ] as CFArray,
    locations: [0.0, 1.0])!
ctx.drawLinearGradient(bgGrad,
    start: CGPoint(x: 0, y: H),
    end:   CGPoint(x: W, y: 0),
    options: [])

// Subtle grid of tiny dots
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.04))
let dotSpacing = 28.0
var gy = dotSpacing / 2
while gy < H {
    var gx = dotSpacing / 2
    while gx < W * 0.5 {   // only left half (right half is the installer form)
        let dot = CGRect(x: gx - 1, y: gy - 1, width: 2, height: 2)
        ctx.fillEllipse(in: dot)
        gx += dotSpacing
    }
    gy += dotSpacing
}

// Large faint calculator icon silhouette (left side)
func roundedRect(_ rect: CGRect, r: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: r, cornerHeight: r, transform: nil)
}

let calcX = 42.0, calcY = 60.0, calcW = 200.0, calcH = 280.0
let body = roundedRect(CGRect(x: calcX, y: calcY, width: calcW, height: calcH), r: 28)
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.05))
ctx.addPath(body)
ctx.fillPath()
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.12))
ctx.setLineWidth(1.5)
ctx.addPath(body)
ctx.strokePath()

// Mini display on silhouette
let dispPath = roundedRect(CGRect(x: calcX + 14, y: calcY + calcH - 54, width: calcW - 28, height: 38), r: 6)
ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.3))
ctx.addPath(dispPath)
ctx.fillPath()

// Mini buttons — 4×4 grid
let bW = 34.0, bH = 26.0, bGap = 8.0
for row in 0..<4 {
    for col in 0..<4 {
        let bx = calcX + 14 + Double(col) * (bW + bGap)
        let by = calcY + 16 + Double(3 - row) * (bH + bGap)
        let isOp = col == 3
        let isEq = col == 3 && row == 0
        let alpha = isEq ? 0.9 : (isOp ? 0.7 : 0.15)
        let r2 = isOp ? 1.0 : 1.0
        let g2 = isOp ? 0.56 : 1.0
        let b2 = isOp ? 0.0 : 1.0
        ctx.setFillColor(CGColor(red: r2, green: g2, blue: b2, alpha: alpha))
        ctx.addPath(roundedRect(CGRect(x: bx, y: by, width: bW, height: bH), r: 5))
        ctx.fillPath()
    }
}

// App name — large, left side
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 34, weight: .thin),
    .foregroundColor: NSColor.white,
    .kern: -0.5
]
let title = NSAttributedString(string: "CalcYouLater", attributes: titleAttrs)
title.draw(at: NSPoint(x: 42, y: H - 52))

// Tagline
let tagAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 13, weight: .ultraLight),
    .foregroundColor: NSColor.white.withAlphaComponent(0.5)
]
let tag = NSAttributedString(string: "The calculator that waits for you.", attributes: tagAttrs)
tag.draw(at: NSPoint(x: 44, y: H - 72))

// Version badge
let vBadgeRect = CGRect(x: 42, y: 20, width: 60, height: 20)
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.08))
ctx.addPath(roundedRect(vBadgeRect, r: 10))
ctx.fillPath()

let verAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 11, weight: .medium),
    .foregroundColor: NSColor.white.withAlphaComponent(0.55)
]
let ver = NSAttributedString(string: "v 1.0", attributes: verAttrs)
ver.draw(at: NSPoint(x: 52, y: 23))

image.unlockFocus()

let tiff   = image.tiffRepresentation!
let bitmap = NSBitmapImageRep(data: tiff)!
let png    = bitmap.representation(using: .png, properties: [:])!
let out    = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/installer_bg.png"
try! png.write(to: URL(fileURLWithPath: out))
print("✓ Background saved to \(out)")
