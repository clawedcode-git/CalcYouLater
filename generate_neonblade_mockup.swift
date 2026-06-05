#!/usr/bin/env swift
import AppKit

// ── Canvas & Scale ─────────────────────────────────────────────────────────
let SCALE: CGFloat = 2          // retina
let W: CGFloat = 316            // points (matches real app)
let H: CGFloat = 556            // points

let PW = Int(W * SCALE), PH = Int(H * SCALE)
let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
    pixelsWide: PW, pixelsHigh: PH, bitsPerSample: 8, samplesPerPixel: 4,
    hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: W, height: H)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
ctx.scaleBy(x: SCALE, y: SCALE)

// ── Palette ────────────────────────────────────────────────────────────────
func rgb(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat,_ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: r, green: g, blue: b, alpha: a)
}
let bgDeep    = rgb(0.031, 0.043, 0.078)   // #080b14
let bgDisplay = rgb(0.016, 0.024, 0.055)   // #04060e
let numFill   = rgb(0.051, 0.078, 0.141)   // #0d1424
let fnFill    = rgb(0.078, 0.110, 0.188)   // #141c30
let opFill    = rgb(0.000, 0.200, 0.260)   // operator bg
let memFill   = rgb(0.130, 0.000, 0.240)   // memory bg
let sciFill   = rgb(0.000, 0.060, 0.200)   // scientific bg
let cyan      = rgb(0.000, 0.831, 1.000)   // #00d4ff
let cyanDim   = rgb(0.000, 0.831, 1.000, 0.55)
let cyanGhost = rgb(0.000, 0.831, 1.000, 0.18)
let pink      = rgb(1.000, 0.000, 0.400)   // #ff0066
let pinkDim   = rgb(1.000, 0.000, 0.400, 0.55)
let violet    = rgb(0.627, 0.125, 0.941)   // #a020f0
let blue      = rgb(0.000, 0.400, 1.000)   // #0066ff
let textPri   = rgb(0.875, 0.941, 1.000)   // #d8f0ff
let textSec   = rgb(0.227, 0.416, 0.533)   // #3a6a88
let borderDim = rgb(0.090, 0.130, 0.250)

// ── Corner-cut path ─────────────────────────────────────────────────────────
func cc(_ r: NSRect, cut: CGFloat = 7) -> NSBezierPath {
    let p = NSBezierPath()
    p.move(to: NSPoint(x: r.minX + cut, y: r.maxY))
    p.line(to: NSPoint(x: r.maxX,       y: r.maxY))
    p.line(to: NSPoint(x: r.maxX,       y: r.minY + cut))
    p.line(to: NSPoint(x: r.maxX - cut, y: r.minY))
    p.line(to: NSPoint(x: r.minX,       y: r.minY))
    p.line(to: NSPoint(x: r.minX,       y: r.maxY - cut))
    p.close()
    return p
}

// ── Glow helper ───────────────────────────────────────────────────────────
func glow(_ color: NSColor, radius: CGFloat) {
    ctx.setShadow(offset: .zero, blur: radius, color: color.cgColor)
}

// ── Text helpers ──────────────────────────────────────────────────────────
func monoAttrs(sz: CGFloat, color: NSColor, weight: NSFont.Weight = .regular) -> [NSAttributedString.Key: Any] {
    [.font: NSFont.monospacedSystemFont(ofSize: sz, weight: weight), .foregroundColor: color]
}
func drawCentered(_ s: String, in r: NSRect, attrs: [NSAttributedString.Key: Any]) {
    let sz = (s as NSString).size(withAttributes: attrs)
    (s as NSString).draw(at: NSPoint(x: r.midX - sz.width/2, y: r.midY - sz.height/2), withAttributes: attrs)
}
func drawRight(_ s: String, rightX: CGFloat, y: CGFloat, attrs: [NSAttributedString.Key: Any]) {
    let sz = (s as NSString).size(withAttributes: attrs)
    (s as NSString).draw(at: NSPoint(x: rightX - sz.width, y: y), withAttributes: attrs)
}

// ── Draw a NeonBlade button ───────────────────────────────────────────────
func btn(_ r: NSRect, fill: NSColor, border: NSColor, label: String,
         labelColor: NSColor, fs: CGFloat = 14, glowR: CGFloat = 0, cut: CGFloat = 7) {
    let path = cc(r, cut: cut)
    // glow halo
    if glowR > 0 {
        ctx.saveGState()
        glow(border.withAlphaComponent(0.65), radius: glowR)
        fill.setFill(); path.fill()
        ctx.restoreGState()
    } else {
        fill.setFill(); path.fill()
    }
    // border
    border.withAlphaComponent(0.75).setStroke()
    path.lineWidth = 0.85; path.stroke()
    // label
    drawCentered(label, in: r, attrs: monoAttrs(sz: fs, color: labelColor, weight: .medium))
}

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND
// ═══════════════════════════════════════════════════════════════════════════
bgDeep.setFill()
NSBezierPath(rect: NSRect(x:0, y:0, width:W, height:H)).fill()

// Subtle dot grid
rgb(0.05, 0.15, 0.28, 0.14).setFill()
var gx: CGFloat = 14
while gx < W {
    var gy: CGFloat = 14
    while gy < H {
        NSBezierPath(ovalIn: NSRect(x: gx-0.6, y: gy-0.6, width: 1.2, height: 1.2)).fill()
        gy += 20
    }
    gx += 20
}

// Radial ambient glow (center-bottom, cyan)
ctx.saveGState()
let grad = NSGradient(starting: cyan.withAlphaComponent(0.06),
                      ending: cyan.withAlphaComponent(0))!
grad.draw(in: NSRect(x: W*0.1, y: 0, width: W*0.8, height: H*0.5),
          relativeCenterPosition: NSPoint(x: 0.5, y: 0.2))
ctx.restoreGState()

// ═══════════════════════════════════════════════════════════════════════════
// TOOLBAR  (y = top)
// ═══════════════════════════════════════════════════════════════════════════
let tbY: CGFloat = H - 44

// — Appearance button (moon icon, inactive)
fnFill.setFill()
let apR = NSRect(x: 14, y: tbY+5, width: 24, height: 24)
cc(apR, cut: 5).fill()
borderDim.setStroke(); cc(apR, cut: 5).lineWidth = 0.8; cc(apR, cut: 5).stroke()
rgb(0.20, 0.38, 0.50).setFill()
NSBezierPath(ovalIn: NSRect(x: 20, y: tbY+11, width: 10, height: 10)).fill()
bgDeep.setFill()
NSBezierPath(ovalIn: NSRect(x: 23, y: tbY+13, width: 9, height: 9)).fill()

// — NeonBlade bolt button (ACTIVE)
let nbR = NSRect(x: 46, y: tbY+5, width: 46, height: 24)
ctx.saveGState()
glow(cyan.withAlphaComponent(0.55), radius: 9)
cyanGhost.setFill(); cc(nbR, cut: 5).fill()
ctx.restoreGState()
cyan.withAlphaComponent(0.9).setStroke(); cc(nbR, cut: 5).lineWidth = 0.9; cc(nbR, cut: 5).stroke()
ctx.saveGState()
glow(cyan.withAlphaComponent(0.5), radius: 4)
let nbAttrs = monoAttrs(sz: 9.5, color: cyan, weight: .bold)
("⚡ NB" as NSString).draw(at: NSPoint(x: 53, y: tbY+13), withAttributes: nbAttrs)
ctx.restoreGState()

// — Right toggles: Sci (active), History, Converter
let togY = tbY + 5
// Sci ACTIVE
let sciTR = NSRect(x: W-118, y: togY, width: 34, height: 24)
ctx.saveGState()
glow(cyan.withAlphaComponent(0.45), radius: 6)
cyanGhost.setFill(); cc(sciTR, cut: 5).fill()
ctx.restoreGState()
cyan.withAlphaComponent(0.85).setStroke(); cc(sciTR, cut: 5).lineWidth = 0.85; cc(sciTR, cut: 5).stroke()
ctx.saveGState()
glow(cyan.withAlphaComponent(0.4), radius: 3)
drawCentered("Sci", in: sciTR, attrs: monoAttrs(sz: 10, color: cyan, weight: .semibold))
ctx.restoreGState()

// History + Converter inactive
for xp: CGFloat in [W-78, W-50] {
    let tr = NSRect(x: xp, y: togY, width: 24, height: 24)
    fnFill.setFill(); cc(tr, cut: 5).fill()
    borderDim.setStroke(); cc(tr, cut: 5).lineWidth = 0.8; cc(tr, cut: 5).stroke()
    drawCentered(xp == W-78 ? "⏱" : "⇄", in: tr,
                 attrs: monoAttrs(sz: 9, color: textSec))
}

// ═══════════════════════════════════════════════════════════════════════════
// DISPLAY PANEL
// ═══════════════════════════════════════════════════════════════════════════
let dR = NSRect(x: 12, y: H - 168, width: W - 24, height: 114)

// Outer glow
ctx.saveGState()
glow(cyan.withAlphaComponent(0.1), radius: 18)
bgDisplay.setFill(); cc(dR, cut: 16).fill()
ctx.restoreGState()

// Fill
bgDisplay.setFill(); cc(dR, cut: 16).fill()

// Scanlines
var sl = dR.minY
while sl < dR.maxY {
    rgb(0,0,0,0.07).setFill()
    NSBezierPath(rect: NSRect(x: dR.minX, y: sl, width: dR.width, height: 1)).fill()
    sl += 3
}

// Border
ctx.saveGState()
glow(cyan.withAlphaComponent(0.25), radius: 5)
cyan.withAlphaComponent(0.42).setStroke()
cc(dR, cut: 16).lineWidth = 0.9; cc(dR, cut: 16).stroke()
ctx.restoreGState()

// Corner accent ticks
cyan.withAlphaComponent(0.6).setStroke()
let tick: CGFloat = 8
// top-left tick
let tlTick = NSBezierPath()
tlTick.move(to: NSPoint(x: dR.minX, y: dR.maxY - 24))
tlTick.line(to: NSPoint(x: dR.minX, y: dR.maxY - 16 - tick))
tlTick.lineWidth = 1.2; tlTick.stroke()
// bottom-right tick
let brTick = NSBezierPath()
brTick.move(to: NSPoint(x: dR.maxX, y: dR.minY + 24))
brTick.line(to: NSPoint(x: dR.maxX, y: dR.minY + 16 + tick))
brTick.lineWidth = 1.2; brTick.stroke()

// Expression line
let exprStr = "sin(π÷4) × 100"
ctx.saveGState()
glow(cyan.withAlphaComponent(0.4), radius: 4)
drawRight(exprStr, rightX: dR.maxX - 14, y: dR.maxY - 30,
          attrs: monoAttrs(sz: 11.5, color: cyan.withAlphaComponent(0.7)))
ctx.restoreGState()

// Main number — large, glowing white
ctx.saveGState()
glow(cyan.withAlphaComponent(0.28), radius: 10)
drawRight("70.7107", rightX: dR.maxX - 14, y: dR.minY + 26,
          attrs: monoAttrs(sz: 44, color: textPri, weight: .thin))
ctx.restoreGState()

// Memory indicator
ctx.saveGState()
glow(violet.withAlphaComponent(0.9), radius: 5)
("▸ M: 42" as NSString).draw(at: NSPoint(x: dR.minX + 14, y: dR.minY + 10),
    withAttributes: monoAttrs(sz: 10, color: violet, weight: .medium))
ctx.restoreGState()

// ═══════════════════════════════════════════════════════════════════════════
// SCIENTIFIC KEYPAD  (4 rows × 4 cols)
// ═══════════════════════════════════════════════════════════════════════════
let sciLabels: [[String]] = [
    ["sin","cos","tan","π"],
    ["asin","acos","atan","e"],
    ["log","ln","√","x²"],
    ["xʸ","n!","1/x","∛x"],
]
let sbGap: CGFloat = 4
let sbW = (W - 24 - CGFloat(3) * sbGap) / 4
let sbH: CGFloat = 30
let sciBottom: CGFloat = H - 180   // top of sci keypad block

for (ri, row) in sciLabels.enumerated() {
    for (ci, lbl) in row.enumerated() {
        let r = NSRect(x: 12 + CGFloat(ci)*(sbW+sbGap),
                       y: sciBottom - CGFloat(ri+1)*(sbH+sbGap),
                       width: sbW, height: sbH)
        let isActive = (lbl == "sin")   // highlight first button as if just pressed
        ctx.saveGState()
        if isActive { glow(blue.withAlphaComponent(0.9), radius: 8) }
        btn(r, fill: isActive ? blue.withAlphaComponent(0.35) : sciFill,
            border: isActive ? blue : blue.withAlphaComponent(0.42),
            label: lbl,
            labelColor: isActive ? rgb(0.6, 0.8, 1.0) : blue.withAlphaComponent(0.75),
            fs: 11, cut: 5)
        ctx.restoreGState()
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// STANDARD KEYPAD
// ═══════════════════════════════════════════════════════════════════════════
let kGap: CGFloat = 6
let kPad: CGFloat = 12
let kW4 = (W - kPad*2 - kGap*3) / 4    // width of a standard 1-unit button
let sciPadBottom = sciBottom - CGFloat(sciLabels.count) * (sbH + sbGap) - 4

// Helper to place a standard row
var kY: CGFloat = kPad

// Row 5 (bottom) — wide 0, dot, equals
let row5W = (W - kPad*2 - kGap*2) / 4
let zeroR  = NSRect(x: kPad, y: kY, width: row5W*2+kGap, height: 46)
let dotR   = NSRect(x: kPad + row5W*2+kGap*2, y: kY, width: row5W, height: 46)
let eqR    = NSRect(x: kPad + row5W*3+kGap*3, y: kY, width: row5W, height: 46)

btn(zeroR, fill: numFill, border: borderDim, label: "0", labelColor: textPri, fs: 18)
btn(dotR,  fill: numFill, border: borderDim, label: ".", labelColor: textPri, fs: 18)
// Equals — hot pink glowing
ctx.saveGState()
glow(pink.withAlphaComponent(0.85), radius: 12)
pinkDim.withAlphaComponent(0.22).setFill(); cc(eqR).fill()
ctx.restoreGState()
pink.withAlphaComponent(0.9).setStroke(); cc(eqR).lineWidth = 0.9; cc(eqR).stroke()
ctx.saveGState()
glow(pink.withAlphaComponent(0.6), radius: 5)
drawCentered("=", in: eqR, attrs: monoAttrs(sz: 20, color: pink, weight: .medium))
ctx.restoreGState()
kY += 46 + kGap

// Rows 1–4 (reversed — we're building bottom-up)
struct KBtn { let lbl: String; let fill, border, fg: NSColor; let g: CGFloat }
let stdRows: [[KBtn]] = [
    // row 4
    [KBtn(lbl:"1",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"2",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"3",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"+",fill:opFill,border:cyan,fg:cyan,g:7)],
    // row 3
    [KBtn(lbl:"4",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"5",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"6",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"−",fill:opFill,border:cyan,fg:cyan,g:7)],
    // row 2
    [KBtn(lbl:"7",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"8",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"9",fill:numFill,border:borderDim,fg:textPri,g:0),
     KBtn(lbl:"×",fill:opFill,border:cyan,fg:cyan,g:7)],
    // row 1
    [KBtn(lbl:"AC",fill:fnFill,border:borderDim,fg:textSec,g:0),
     KBtn(lbl:"+/−",fill:fnFill,border:borderDim,fg:textSec,g:0),
     KBtn(lbl:"%",fill:fnFill,border:borderDim,fg:textSec,g:0),
     KBtn(lbl:"÷",fill:opFill,border:cyan,fg:cyan,g:7)],
]

for row in stdRows {
    for (ci, b) in row.enumerated() {
        let r = NSRect(x: kPad + CGFloat(ci)*(kW4+kGap), y: kY, width: kW4, height: 46)
        ctx.saveGState()
        if b.g > 0 { glow(b.border.withAlphaComponent(0.65), radius: b.g) }
        btn(r, fill: b.fill, border: b.border, label: b.lbl,
            labelColor: b.fg, fs: b.lbl.count > 1 ? 14 : 18, glowR: 0)
        ctx.restoreGState()
    }
    kY += 46 + kGap
}

// Memory row (slim)
let mLabels = ["MC","MR","M+","M−"]
let mW = (W - kPad*2 - kGap*3) / 4
for (ci, lbl) in mLabels.enumerated() {
    let r = NSRect(x: kPad + CGFloat(ci)*(mW+kGap), y: kY, width: mW, height: 30)
    btn(r, fill: memFill, border: violet.withAlphaComponent(0.6),
        label: lbl, labelColor: violet.withAlphaComponent(0.9), fs: 11, cut: 5)
}
kY += 30 + kGap

// ═══════════════════════════════════════════════════════════════════════════
// WINDOW CHROME — slim title bar at top
// ═══════════════════════════════════════════════════════════════════════════
let chromeH: CGFloat = 28
let chromeY = H - chromeH

// Chrome bar background
rgb(0.020, 0.030, 0.060).setFill()
NSBezierPath(rect: NSRect(x:0, y:chromeY, width:W, height:chromeH)).fill()

// Separator line
cyan.withAlphaComponent(0.18).setStroke()
let sepLine = NSBezierPath()
sepLine.move(to: NSPoint(x: 0, y: chromeY)); sepLine.line(to: NSPoint(x: W, y: chromeY))
sepLine.lineWidth = 0.5; sepLine.stroke()

// Traffic light dots (macOS style)
let dotColors: [NSColor] = [
    rgb(1.00, 0.23, 0.19),   // red close
    rgb(1.00, 0.74, 0.07),   // yellow minimise
    rgb(0.16, 0.78, 0.25),   // green fullscreen
]
for (i, dc) in dotColors.enumerated() {
    let cx = CGFloat(14 + i * 20)
    let cy = chromeY + chromeH/2
    dc.setFill()
    NSBezierPath(ovalIn: NSRect(x: cx-5, y: cy-5, width: 10, height: 10)).fill()
}

// App title centred in chrome
ctx.saveGState()
glow(cyan.withAlphaComponent(0.3), radius: 5)
drawCentered("CalcYouLater", in: NSRect(x: 0, y: chromeY, width: W, height: chromeH),
             attrs: monoAttrs(sz: 11, color: cyan.withAlphaComponent(0.7), weight: .medium))
ctx.restoreGState()

// Top border glow
ctx.saveGState()
glow(cyan.withAlphaComponent(0.35), radius: 6)
cyan.withAlphaComponent(0.5).setStroke()
let topLine = NSBezierPath()
topLine.move(to: NSPoint(x: 0, y: H)); topLine.line(to: NSPoint(x: W, y: H))
topLine.lineWidth = 0.8; topLine.stroke()
ctx.restoreGState()

// ── Finish ─────────────────────────────────────────────────────────────────
NSGraphicsContext.restoreGraphicsState()

let data = rep.representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: "screenshots/neonblade.png"))
print("✓ screenshots/neonblade.png  (\(PW)×\(PH)px)")
