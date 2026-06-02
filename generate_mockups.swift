#!/usr/bin/swift
import AppKit
import CoreGraphics

// ─────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────

func rr(_ r: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

extension CGContext {
    func fill(_ path: CGPath, r: Double, g: Double, b: Double, a: Double = 1) {
        setFillColor(CGColor(red: r, green: g, blue: b, alpha: a))
        addPath(path); fillPath()
    }
    func stroke(_ path: CGPath, r: Double, g: Double, b: Double, a: Double, w: CGFloat) {
        setStrokeColor(CGColor(red: r, green: g, blue: b, alpha: a))
        setLineWidth(w); addPath(path); strokePath()
    }
}

func drawText(_ s: String, font: NSFont, color: NSColor, at pt: CGPoint) {
    let a: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    NSAttributedString(string: s, attributes: a).draw(at: pt)
}

func textSize(_ s: String, font: NSFont) -> CGSize {
    let a: [NSAttributedString.Key: Any] = [.font: font]
    return NSAttributedString(string: s, attributes: a).size()
}

func save(_ img: NSImage, to path: String) {
    let tiff = img.tiffRepresentation!
    let bmp  = NSBitmapImageRep(data: tiff)!
    let png  = bmp.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: path))
}

// ─────────────────────────────────────────────────────────────
// Color palettes
// ─────────────────────────────────────────────────────────────

struct Palette {
    let isDark: Bool
    var bg:      (Double,Double,Double) { isDark ? (0.11,0.11,0.12)  : (0.94,0.94,0.96) }
    var surface: (Double,Double,Double) { isDark ? (0.18,0.18,0.20)  : (1,1,1) }
    var numBtn:  (Double,Double,Double) { isDark ? (0.30,0.30,0.32)  : (1,1,1) }
    var fnBtn:   (Double,Double,Double) { isDark ? (0.22,0.22,0.24)  : (0.84,0.84,0.88) }
    var sciBtn:  (Double,Double,Double) { isDark ? (0.22,0.16,0.42)  : (0.84,0.80,0.98) }
    var memBtn:  (Double,Double,Double) { isDark ? (0.28,0.10,0.45)  : (0.88,0.80,1.00) }
    var display: (Double,Double,Double) { isDark ? (0.08,0.08,0.10)  : (0.88,0.88,0.92) }
    var primary: NSColor                { isDark ? .white              : .black }
    var secondary: NSColor              { isDark ? NSColor(white:1, alpha:0.45) : NSColor(white:0, alpha:0.4) }
    var border:  (Double,Double,Double) { isDark ? (1,1,1)            : (0,0,0) }
    var borderA: Double                 { isDark ? 0.10               : 0.08 }
}

// ─────────────────────────────────────────────────────────────
// Core calculator renderer
// ─────────────────────────────────────────────────────────────

struct CalcLayout {
    // window
    var W: CGFloat = 318
    var H: CGFloat = 530
    // toolbar
    var toolH: CGFloat = 44
    // display
    var dispH: CGFloat = 100
    // pad around buttons
    var pad:   CGFloat = 12
    // button gap
    var bGap:  CGFloat = 8
    var memH:  CGFloat = 36

    var btnW: CGFloat { (W - 2*pad - 3*bGap) / 4 }
    var stdH: CGFloat { 52 }

    var bX: CGFloat { pad }
    // y origin for buttons (from bottom)
    var bY: CGFloat { pad }
    var sciRowH: CGFloat { 34 }
    var sciGap:  CGFloat { 6 }
}

func drawWindow(ctx: CGContext, pal: Palette, lo: CalcLayout,
                display: String, expr: String,
                hasMem: Bool = false,
                sciMode: Bool = false,
                historyEntries: [(String,String)]? = nil,
                convMode: Bool = false,
                highlightOp: String? = nil) {

    let W = lo.W + (historyEntries != nil || convMode ? 228 : 0)
    let H = lo.H + (sciMode ? (lo.sciRowH*4 + lo.sciGap*3 + 8) : 0)

    // ── Window chrome ─────────────────────────────────────────
    let winPath = rr(CGRect(x: 0, y: 0, width: W, height: H), radius: 12)
    ctx.fill(winPath, r: pal.bg.0, g: pal.bg.1, b: pal.bg.2)
    ctx.stroke(winPath, r: pal.border.0, g: pal.border.1, b: pal.border.2, a: pal.borderA, w: 1)

    // ── Toolbar ───────────────────────────────────────────────
    let tbY = H - lo.toolH
    // Appearance icon (left)
    let icon = pal.isDark ? "🌙" : "☀️"
    drawText(icon, font: .systemFont(ofSize: 14), color: pal.secondary, at: CGPoint(x: 14, y: tbY+12))

    // Sci chip
    let sciColor = sciMode
        ? NSColor(red: 0.36, green: 0.20, blue: 0.86, alpha: 0.22)
        : NSColor(white: pal.isDark ? 1 : 0, alpha: 0.08)
    let sciChipRect = CGRect(x: lo.W - 142, y: tbY+10, width: 34, height: 22)
    sciColor.setFill(); NSBezierPath(roundedRect: sciChipRect, xRadius: 6, yRadius: 6).fill()
    drawText("Sci", font: .systemFont(ofSize: 11, weight: .semibold), color: pal.primary, at: CGPoint(x: sciChipRect.minX+7, y: sciChipRect.minY+4))

    // Clock chip
    let histOn = historyEntries != nil
    let histColor = histOn
        ? NSColor(red: 0.36, green: 0.20, blue: 0.86, alpha: 0.22)
        : NSColor(white: pal.isDark ? 1 : 0, alpha: 0.08)
    let histChipRect = CGRect(x: lo.W - 104, y: tbY+10, width: 30, height: 22)
    histColor.setFill(); NSBezierPath(roundedRect: histChipRect, xRadius: 6, yRadius: 6).fill()
    drawText("🕐", font: .systemFont(ofSize: 13), color: pal.primary, at: CGPoint(x: histChipRect.minX+6, y: histChipRect.minY+3))

    // Arrows chip
    let convOn = convMode
    let convColor = convOn
        ? NSColor(red: 0.36, green: 0.20, blue: 0.86, alpha: 0.22)
        : NSColor(white: pal.isDark ? 1 : 0, alpha: 0.08)
    let convChipRect = CGRect(x: lo.W - 70, y: tbY+10, width: 30, height: 22)
    convColor.setFill(); NSBezierPath(roundedRect: convChipRect, xRadius: 6, yRadius: 6).fill()
    drawText("⇄", font: .systemFont(ofSize: 14), color: pal.primary, at: CGPoint(x: convChipRect.minX+7, y: convChipRect.minY+3))

    // ── Scientific panel ──────────────────────────────────────
    var sciPanelBottom = H - lo.toolH
    if sciMode {
        let sciLabels = [
            ["sin","cos","tan","π"],
            ["sin⁻¹","cos⁻¹","tan⁻¹","e"],
            ["log","ln","√","x²"],
            ["xʸ","n!","1/x","∛x"],
        ]
        let sBW = (lo.W - 2*lo.pad - 3*lo.sciGap) / 4
        var sy = H - lo.toolH - 8 - lo.sciRowH
        for row in sciLabels {
            for (ci, lbl) in row.enumerated() {
                let sx = lo.pad + CGFloat(ci) * (sBW + lo.sciGap)
                let sr = CGRect(x: sx, y: sy, width: sBW, height: lo.sciRowH)
                let sp = rr(sr, radius: 8)
                let (r,g,b) = pal.sciBtn
                ctx.fill(sp, r: r, g: g, b: b, a: pal.isDark ? 1 : 1)
                let lf = NSFont.systemFont(ofSize: 12, weight: .medium)
                let ls = textSize(lbl, font: lf)
                drawText(lbl, font: lf, color: pal.isDark ? NSColor(red:0.7,green:0.6,blue:1,alpha:1) : NSColor(red:0.35,green:0.15,blue:0.7,alpha:1),
                         at: CGPoint(x: sx+(sBW-ls.width)/2, y: sy+(lo.sciRowH-ls.height)/2))
            }
            sy -= lo.sciRowH + lo.sciGap
        }
        sciPanelBottom = sy + lo.sciGap
    }

    // ── Display area ──────────────────────────────────────────
    let dispY = sciPanelBottom - lo.dispH - 4
    // expression line
    let exprFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .ultraLight)
    let exprSz = textSize(expr, font: exprFont)
    drawText(expr, font: exprFont, color: pal.secondary,
             at: CGPoint(x: lo.W - lo.pad - exprSz.width, y: dispY + lo.dispH - 24))
    // main number
    let numFont = NSFont.systemFont(ofSize: 48, weight: .thin)
    let numSz = textSize(display, font: numFont)
    drawText(display, font: numFont, color: pal.primary,
             at: CGPoint(x: lo.W - lo.pad - numSz.width, y: dispY + 10))
    // memory indicator
    if hasMem {
        drawText("M: 100", font: .systemFont(ofSize: 11, weight: .medium),
                 color: NSColor(red:0.6,green:0.2,blue:0.9,alpha:1),
                 at: CGPoint(x: lo.pad, y: dispY + 4))
    }

    // ── Button grid ───────────────────────────────────────────
    let btnAreaTop = dispY - 4
    let rows: [[(String, (Double,Double,Double), Double)]] = [
        // label, color, alpha
        [("MC",pal.memBtn,1),("MR",pal.memBtn,1),("M+",pal.memBtn,1),("M−",pal.memBtn,1)],
        [("AC",pal.fnBtn,1),("+/−",pal.fnBtn,1),("%",pal.fnBtn,1),("÷",(1,0.56,0),1)],
        [("7",pal.numBtn,1),("8",pal.numBtn,1),("9",pal.numBtn,1),("×",(1,0.56,0),1)],
        [("4",pal.numBtn,1),("5",pal.numBtn,1),("6",pal.numBtn,1),("−",(1,0.56,0),1)],
        [("1",pal.numBtn,1),("2",pal.numBtn,1),("3",pal.numBtn,1),("+",(1,0.56,0),1)],
    ]

    let bW = lo.btnW
    let memRowH: CGFloat = lo.memH
    let stdRowH: CGFloat = lo.stdH
    let lastRowH: CGFloat = lo.stdH

    // total height: 1 mem + 4 std + 1 bottom + 5 gaps
    let totalBtnH = memRowH + 4*stdRowH + lastRowH + 5*lo.bGap
    var currentY = lo.bY

    // bottom row first (row 5): 0(wide), ., =
    let r5y = currentY
    // wide 0
    let w0 = CGRect(x: lo.pad, y: r5y, width: bW*2+lo.bGap, height: lastRowH)
    let (nr,ng,nb) = pal.numBtn
    ctx.fill(rr(w0, radius:10), r:nr, g:ng, b:nb)
    let zf = NSFont.systemFont(ofSize: 20)
    let zs = textSize("0", font: zf)
    drawText("0", font: zf, color: pal.primary, at: CGPoint(x: w0.midX-zs.width/2, y: r5y+(lastRowH-zs.height)/2))
    // dot
    let dotX = lo.pad + bW*2 + lo.bGap*2
    let dotR = CGRect(x: dotX, y: r5y, width: bW, height: lastRowH)
    ctx.fill(rr(dotR, radius:10), r:nr, g:ng, b:nb)
    let dotS = textSize(".", font: zf)
    drawText(".", font: zf, color: pal.primary, at: CGPoint(x: dotX+(bW-dotS.width)/2, y: r5y+(lastRowH-dotS.height)/2))
    // = (orange glow)
    let eqX = dotX + bW + lo.bGap
    let eqR = CGRect(x: eqX, y: r5y, width: bW, height: lastRowH)
    ctx.setShadow(offset: .zero, blur: 12, color: CGColor(red:1,green:0.56,blue:0,alpha:0.5))
    ctx.fill(rr(eqR, radius:10), r:1, g:0.56, b:0)
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    let ef = NSFont.systemFont(ofSize: 22, weight: .medium)
    let es = textSize("=", font: ef)
    drawText("=", font: ef, color: .white, at: CGPoint(x: eqX+(bW-es.width)/2, y: r5y+(lastRowH-es.height)/2))

    currentY += lastRowH + lo.bGap

    // rows 4..0 (from bottom)
    for (ri, row) in rows.reversed().enumerated() {
        let rowH: CGFloat = ri == rows.count-1 ? memRowH : stdRowH
        for (ci, (lbl, col, _)) in row.enumerated() {
            let bx = lo.pad + CGFloat(ci) * (bW + lo.bGap)
            let br = CGRect(x: bx, y: currentY, width: bW, height: rowH)
            let isOp = (lbl == "÷" || lbl == "×" || lbl == "−" || lbl == "+")
            let isMem = (lbl == "MC" || lbl == "MR" || lbl == "M+" || lbl == "M−")
            let isHighlight = lbl == (highlightOp ?? "")
            let finalAlpha: Double = isHighlight ? 0.55 : 1.0
            ctx.fill(rr(br, radius:10), r:col.0, g:col.1, b:col.2, a: finalAlpha)
            let lblFont = NSFont.systemFont(ofSize: ri == 0 ? 13 : 19,
                                            weight: isOp ? .medium : .regular)
            let lblSz = textSize(lbl, font: lblFont)
            let lblColor: NSColor = isOp ? .white : isMem
                ? (pal.isDark ? NSColor(red:0.8,green:0.65,blue:1,alpha:1) : NSColor(red:0.45,green:0.1,blue:0.8,alpha:1))
                : pal.primary
            drawText(lbl, font: lblFont, color: lblColor,
                     at: CGPoint(x: bx+(bW-lblSz.width)/2, y: currentY+(rowH-lblSz.height)/2))
        }
        currentY += rowH + lo.bGap
    }

    // ── History sidebar ───────────────────────────────────────
    if let entries = historyEntries {
        let sx = lo.W
        let divPath = CGPath(rect: CGRect(x: sx, y: 0, width: 1, height: H), transform: nil)
        ctx.fill(divPath, r: pal.border.0, g: pal.border.1, b: pal.border.2, a: pal.borderA*2)

        // Header
        drawText("History", font: .systemFont(ofSize: 15, weight: .semibold), color: pal.primary,
                 at: CGPoint(x: sx+14, y: H-38))
        let clrFont = NSFont.systemFont(ofSize: 12)
        let clrS = textSize("Clear", font: clrFont)
        drawText("Clear", font: clrFont, color: NSColor(red:1,green:0.27,blue:0.23,alpha:1),
                 at: CGPoint(x: sx+228-14-clrS.width, y: H-38))

        // Divider
        ctx.fill(CGPath(rect: CGRect(x: sx, y: H-lo.toolH, width: 228, height: 1), transform: nil),
                 r: pal.border.0, g: pal.border.1, b: pal.border.2, a: pal.borderA)

        // Entries
        var ey = H - lo.toolH - 14
        for (expr2, result) in entries {
            ey -= 14
            let ef2 = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            let es2 = textSize(expr2, font: ef2)
            drawText(expr2, font: ef2, color: pal.secondary,
                     at: CGPoint(x: sx+228-14-es2.width, y: ey))
            ey -= 20
            let rf = NSFont.systemFont(ofSize: 18, weight: .semibold)
            let rs = textSize(result, font: rf)
            drawText(result, font: rf, color: pal.primary,
                     at: CGPoint(x: sx+228-14-rs.width, y: ey))
            ey -= 14
            ctx.fill(CGPath(rect: CGRect(x: sx+14, y: ey, width: 200, height: 0.5), transform: nil),
                     r: pal.border.0, g: pal.border.1, b: pal.border.2, a: pal.borderA)
        }
    }

    // ── Converter sidebar ─────────────────────────────────────
    if convMode {
        let sx = lo.W
        ctx.fill(CGPath(rect: CGRect(x: sx, y: 0, width: 1, height: H), transform: nil),
                 r: pal.border.0, g: pal.border.1, b: pal.border.2, a: pal.borderA*2)

        drawText("Convert", font: .systemFont(ofSize: 15, weight: .semibold), color: pal.primary,
                 at: CGPoint(x: sx+14, y: H-38))
        ctx.fill(CGPath(rect: CGRect(x: sx, y: H-lo.toolH, width: 228, height: 1), transform: nil),
                 r: pal.border.0, g: pal.border.1, b: pal.border.2, a: pal.borderA)

        let items: [(String,String)] = [
            ("Category", "Length"),
            ("From",     "miles (mi)"),
            ("To",       "kilometers (km)"),
            ("Value",    "26.2"),
        ]
        var cy = H - lo.toolH - 18
        for (label, value) in items {
            cy -= 16
            drawText(label, font: .systemFont(ofSize: 10), color: pal.secondary,
                     at: CGPoint(x: sx+14, y: cy))
            cy -= 18
            let vr = CGRect(x: sx+14, y: cy, width: 200, height: 24)
            ctx.fill(rr(vr, radius:6), r: pal.display.0, g: pal.display.1, b: pal.display.2)
            drawText(value, font: .systemFont(ofSize: 12), color: pal.primary,
                     at: CGPoint(x: sx+20, y: cy+5))
            cy -= 6
        }

        // Result box
        cy -= 14
        let resR = CGRect(x: sx+14, y: cy-52, width: 200, height: 52)
        ctx.fill(rr(resR, radius:10), r: pal.display.0, g: pal.display.1, b: pal.display.2)
        drawText("Result", font: .systemFont(ofSize: 10), color: pal.secondary,
                 at: CGPoint(x: sx+24, y: cy-18))
        drawText("42.165 km", font: .systemFont(ofSize: 20, weight: .semibold), color: pal.primary,
                 at: CGPoint(x: sx+24, y: cy-42))
    }
}

// ─────────────────────────────────────────────────────────────
// Render each mockup
// ─────────────────────────────────────────────────────────────

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/mockups"
try! FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

struct Mockup {
    let name: String
    let pal: Palette
    let display: String
    let expr: String
    let hasMem: Bool
    let sci: Bool
    let history: [(String,String)]?
    let conv: Bool
    let op: String?
    var extraH: CGFloat { sci ? (34*4 + 6*3 + 8) : 0 }
    var extraW: CGFloat { history != nil || conv ? 228 : 0 }
}

let mockups: [Mockup] = [
    Mockup(name:"standard_dark",  pal:Palette(isDark:true),  display:"1,618",   expr:"3 × 7 + 597 =",hasMem:false,sci:false,history:nil,conv:false,op:nil),
    Mockup(name:"standard_light", pal:Palette(isDark:false), display:"3.14159", expr:"π",           hasMem:false,sci:false,history:nil,conv:false,op:nil),
    Mockup(name:"scientific_dark", pal:Palette(isDark:true),  display:"0.5",     expr:"sin(30) =",   hasMem:false,sci:true, history:nil,conv:false,op:nil),
    Mockup(name:"history_dark",   pal:Palette(isDark:true),  display:"42",      expr:"6 × 7 =",     hasMem:false,sci:false,
           history:[("6 × 7 =","42"),("√144 =","12"),("100 − 58 =","42"),("2 ^ 8 =","256"),("355 ÷ 113 =","3.141593")],
           conv:false,op:nil),
    Mockup(name:"converter_light",pal:Palette(isDark:false), display:"26.2",    expr:"",            hasMem:false,sci:false,history:nil,conv:true,op:nil),
    Mockup(name:"memory_dark",    pal:Palette(isDark:true),  display:"100",     expr:"M+",          hasMem:true, sci:false,history:nil,conv:false,op:nil),
]

let lo = CalcLayout()

for m in mockups {
    let W = lo.W + m.extraW
    let H = lo.H + m.extraH
    let scale: CGFloat = 2  // @2x for retina

    let img = NSImage(size: NSSize(width: W, height: H))
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.scaleBy(x: 1, y: 1)

    drawWindow(ctx: ctx, pal: m.pal, lo: lo,
               display: m.display, expr: m.expr,
               hasMem: m.hasMem, sciMode: m.sci,
               historyEntries: m.history,
               convMode: m.conv,
               highlightOp: m.op)

    img.unlockFocus()
    save(img, to: "\(outDir)/\(m.name).png")
    print("✓ \(m.name).png  (\(Int(W))×\(Int(H)))")
}
