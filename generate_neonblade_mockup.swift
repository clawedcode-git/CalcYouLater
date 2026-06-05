#!/usr/bin/env swift
import AppKit

// ── Palette ────────────────────────────────────────────────────────────────
let bgDeep       = NSColor(srgbRed: 0.031, green: 0.043, blue: 0.078, alpha: 1)
let displayBg    = NSColor(srgbRed: 0.016, green: 0.024, blue: 0.055, alpha: 1)
let numBtn       = NSColor(srgbRed: 0.051, green: 0.078, blue: 0.141, alpha: 1)
let fnBtn        = NSColor(srgbRed: 0.078, green: 0.110, blue: 0.188, alpha: 1)
let opBtn        = NSColor(srgbRed: 0.000, green: 0.227, blue: 0.290, alpha: 1)
let cyan         = NSColor(srgbRed: 0.000, green: 0.831, blue: 1.000, alpha: 1)
let hotpink      = NSColor(srgbRed: 1.000, green: 0.000, blue: 0.400, alpha: 1)
let violet       = NSColor(srgbRed: 0.627, green: 0.125, blue: 0.941, alpha: 1)
let electricBlue = NSColor(srgbRed: 0.000, green: 0.400, blue: 1.000, alpha: 1)
let textPrimary  = NSColor(srgbRed: 0.875, green: 0.941, blue: 1.000, alpha: 1)
let textSec      = NSColor(srgbRed: 0.227, green: 0.416, blue: 0.533, alpha: 1)
let borderDim    = NSColor(srgbRed: 0.090, green: 0.130, blue: 0.250, alpha: 1)

// ── Corner-cut shape ───────────────────────────────────────────────────────
func ccPath(_ r: NSRect, cut: CGFloat = 7) -> NSBezierPath {
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

func drawBtn(_ ctx: CGContext, r: NSRect, fill: NSColor, border: NSColor,
             label: String, labelColor: NSColor, fs: CGFloat = 13, glow: CGFloat = 0) {
    let path = ccPath(r)
    ctx.saveGState()
    if glow > 0 { ctx.setShadow(offset: .zero, blur: glow, color: border.withAlphaComponent(0.7).cgColor) }
    fill.setFill(); path.fill()
    ctx.restoreGState()
    border.withAlphaComponent(0.7).setStroke(); path.lineWidth = 0.8; path.stroke()
    let ps = NSMutableParagraphStyle(); ps.alignment = .center
    let a: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: fs, weight: .medium),
        .foregroundColor: labelColor, .paragraphStyle: ps
    ]
    let s = label as NSString; let sz = s.size(withAttributes: a)
    s.draw(at: NSPoint(x: r.midX - sz.width/2, y: r.midY - sz.height/2), withAttributes: a)
}

func mono(_ s: String, sz: CGFloat, color: NSColor, weight: NSFont.Weight = .regular) -> [NSAttributedString.Key: Any] {
    [.font: NSFont.monospacedSystemFont(ofSize: sz, weight: weight), .foregroundColor: color]
}

// ── Canvas setup ───────────────────────────────────────────────────────────
let W: CGFloat = 316; let H: CGFloat = 530

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W*2), pixelsHigh: Int(H*2),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: W, height: H)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
ctx.scaleBy(x: 2, y: 2)

// ── Background ─────────────────────────────────────────────────────────────
bgDeep.setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: W, height: H)).fill()

// Grid dots
NSColor(srgbRed: 0.05, green: 0.15, blue: 0.25, alpha: 0.18).setFill()
var gx: CGFloat = 12
while gx < W {
    var gy: CGFloat = 12
    while gy < H {
        NSBezierPath(ovalIn: NSRect(x: gx-0.5, y: gy-0.5, width: 1, height: 1)).fill()
        gy += 18
    }
    gx += 18
}

// ── Toolbar ────────────────────────────────────────────────────────────────
let tbY: CGFloat = H - 46

// Appearance button (inactive)
fnBtn.setFill()
let tbIconPath = ccPath(NSRect(x: 14, y: tbY+6, width: 22, height: 22), cut: 4)
tbIconPath.fill()
borderDim.setStroke(); tbIconPath.lineWidth = 0.8; tbIconPath.stroke()
NSColor(srgbRed: 0.23, green: 0.42, blue: 0.53, alpha: 1).setFill()
NSBezierPath(ovalIn: NSRect(x: 21, y: tbY+13, width: 8, height: 8)).fill()

// NeonBlade bolt (ACTIVE — glowing cyan)
let boltR = NSRect(x: 44, y: tbY+6, width: 44, height: 22)
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 8, color: cyan.withAlphaComponent(0.6).cgColor)
cyan.withAlphaComponent(0.15).setFill()
ccPath(boltR, cut: 5).fill()
ctx.restoreGState()
cyan.withAlphaComponent(0.85).setStroke(); ccPath(boltR, cut: 5).lineWidth = 0.85
ccPath(boltR, cut: 5).stroke()
("⚡ NB" as NSString).draw(at: NSPoint(x: 51, y: tbY+12), withAttributes: mono("", sz: 9, color: cyan, weight: .bold))

// Sci toggle (active)
let sciTR = NSRect(x: W-118, y: tbY+6, width: 32, height: 22)
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 5, color: cyan.withAlphaComponent(0.5).cgColor)
cyan.withAlphaComponent(0.18).setFill(); ccPath(sciTR, cut: 4).fill()
ctx.restoreGState()
cyan.withAlphaComponent(0.8).setStroke(); ccPath(sciTR, cut: 4).lineWidth = 0.8; ccPath(sciTR, cut: 4).stroke()
("Sci" as NSString).draw(at: NSPoint(x: W-113, y: tbY+12), withAttributes: mono("", sz: 10, color: cyan, weight: .semibold))

// History + Converter (inactive)
for xpos in [W-82, W-54] as [CGFloat] {
    let tr = NSRect(x: xpos, y: tbY+6, width: 22, height: 22)
    fnBtn.setFill(); ccPath(tr, cut: 4).fill()
    borderDim.setStroke(); ccPath(tr, cut: 4).lineWidth = 0.8; ccPath(tr, cut: 4).stroke()
}

// ── Display Panel ──────────────────────────────────────────────────────────
let dR = NSRect(x: 12, y: H-168, width: W-24, height: 112)
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 14, color: cyan.withAlphaComponent(0.12).cgColor)
displayBg.setFill(); ccPath(dR, cut: 14).fill()
ctx.restoreGState()
// Scanlines
var sl = dR.minY
while sl < dR.maxY {
    NSColor.black.withAlphaComponent(0.07).setFill()
    NSBezierPath(rect: NSRect(x: dR.minX, y: sl, width: dR.width, height: 1)).fill()
    sl += 3
}
cyan.withAlphaComponent(0.38).setStroke(); ccPath(dR, cut: 14).lineWidth = 0.8; ccPath(dR, cut: 14).stroke()

// Expression
let exprStr = "6 × 7"
let exprA = mono("", sz: 12, color: cyan.withAlphaComponent(0.65))
let exprSz = (exprStr as NSString).size(withAttributes: exprA)
(exprStr as NSString).draw(at: NSPoint(x: dR.maxX - exprSz.width - 14, y: dR.maxY - 26), withAttributes: exprA)

// Number
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 9, color: cyan.withAlphaComponent(0.3).cgColor)
let numA = mono("", sz: 50, color: textPrimary, weight: .thin)
let numSz = ("42" as NSString).size(withAttributes: numA)
("42" as NSString).draw(at: NSPoint(x: dR.maxX - numSz.width - 14, y: dR.minY + 20), withAttributes: numA)
ctx.restoreGState()

// Memory
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 5, color: violet.withAlphaComponent(0.8).cgColor)
("▸ M: 6" as NSString).draw(at: NSPoint(x: dR.minX + 12, y: dR.minY + 8),
    withAttributes: mono("", sz: 10, color: violet))
ctx.restoreGState()

// ── Scientific Keypad ──────────────────────────────────────────────────────
let sciRows = [["sin","cos","tan","π"],["asin","acos","atan","e"],
               ["log","ln","√","x²"],["xʸ","n!","1/x","∛x"]]
let sbW = (W - 24 - 12) / 4; let sbH: CGFloat = 31
let sciTop: CGFloat = H - 290
for (ri, row) in sciRows.enumerated() {
    for (ci, lbl) in row.enumerated() {
        let r = NSRect(x: 12 + CGFloat(ci)*(sbW+4), y: sciTop - CGFloat(ri)*(sbH+4), width: sbW, height: sbH)
        drawBtn(ctx, r: r, fill: opBtn.withAlphaComponent(0.45),
                border: electricBlue.withAlphaComponent(0.5),
                label: lbl, labelColor: electricBlue.withAlphaComponent(0.8), fs: 11, glow: 2)
    }
}

// ── Standard Keypad ────────────────────────────────────────────────────────
struct Btn { let lbl: String; let fill, border, fg: NSColor; let glow: CGFloat }

let rows: [[Btn]] = [
    [Btn(lbl:"MC",fill:opBtn.withAlphaComponent(0.4),border:violet,fg:violet,glow:0),
     Btn(lbl:"MR",fill:opBtn.withAlphaComponent(0.4),border:violet,fg:violet,glow:0),
     Btn(lbl:"M+",fill:opBtn.withAlphaComponent(0.4),border:violet,fg:violet,glow:0),
     Btn(lbl:"M−",fill:opBtn.withAlphaComponent(0.4),border:violet,fg:violet,glow:0)],
    [Btn(lbl:"AC",fill:fnBtn,border:borderDim,fg:textSec,glow:0),
     Btn(lbl:"+/−",fill:fnBtn,border:borderDim,fg:textSec,glow:0),
     Btn(lbl:"%",fill:fnBtn,border:borderDim,fg:textSec,glow:0),
     Btn(lbl:"÷",fill:opBtn,border:cyan,fg:cyan,glow:6)],
    [Btn(lbl:"7",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"8",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"9",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"×",fill:opBtn,border:cyan,fg:cyan,glow:6)],
    [Btn(lbl:"4",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"5",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"6",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"−",fill:opBtn,border:cyan,fg:cyan,glow:6)],
    [Btn(lbl:"1",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"2",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"3",fill:numBtn,border:borderDim,fg:textPrimary,glow:0),
     Btn(lbl:"+",fill:opBtn,border:cyan,fg:cyan,glow:6)],
]

let kbH: CGFloat = 46; let kbH0: CGFloat = 31
let btnW = (W - 24 - 18) / 4; let gap: CGFloat = 6
var kY: CGFloat = 14

// Bottom row: wide 0, dot, =
let r5bW = (W - 24 - 16) / 4
// Wide 0
drawBtn(ctx, r: NSRect(x: 12, y: kY, width: r5bW*2+gap, height: kbH),
        fill: numBtn, border: borderDim, label: "0", labelColor: textPrimary)
// Dot
drawBtn(ctx, r: NSRect(x: 12+r5bW*2+gap*2, y: kY, width: r5bW, height: kbH),
        fill: numBtn, border: borderDim, label: ".", labelColor: textPrimary)
// Equals (hot pink glow)
let eR = NSRect(x: 12+r5bW*3+gap*3, y: kY, width: r5bW, height: kbH)
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 10, color: hotpink.withAlphaComponent(0.85).cgColor)
hotpink.withAlphaComponent(0.18).setFill(); ccPath(eR).fill()
ctx.restoreGState()
hotpink.setStroke(); ccPath(eR).lineWidth = 0.9; ccPath(eR).stroke()
let eSz = ("=" as NSString).size(withAttributes: mono("", sz: 20, color: hotpink, weight: .medium))
("=" as NSString).draw(at: NSPoint(x: eR.midX-eSz.width/2, y: eR.midY-eSz.height/2),
    withAttributes: mono("", sz: 20, color: hotpink, weight: .medium))
kY += kbH + gap

// Rows 1-5
for rowData in rows.reversed() {
    let rh: CGFloat = (rowData[0].lbl == "MC") ? kbH0 : kbH
    let rw = btnW
    for (ci, b) in rowData.enumerated() {
        let r = NSRect(x: 12 + CGFloat(ci)*(rw+gap), y: kY, width: rw, height: rh)
        drawBtn(ctx, r: r, fill: b.fill, border: b.border, label: b.lbl,
                labelColor: b.fg, glow: b.glow)
    }
    kY += rh + gap
}

NSGraphicsContext.restoreGraphicsState()

let data = rep.representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: "screenshots/neonblade.png"))
print("✓ screenshots/neonblade.png")
