#!/usr/bin/swift
import AppKit
import CoreGraphics

// ─── helpers ────────────────────────────────────────────────
func rr(_ r: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}
func fill(_ ctx: CGContext, _ path: CGPath, r: Double, g: Double, b: Double, a: Double = 1) {
    ctx.setFillColor(CGColor(red: r, green: g, blue: b, alpha: a)); ctx.addPath(path); ctx.fillPath()
}
func attr(_ s: String, _ font: NSFont, _ color: NSColor) -> NSAttributedString {
    NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: color])
}
func drawCentered(_ s: NSAttributedString, in rect: CGRect) {
    let sz = s.size()
    s.draw(at: NSPoint(x: rect.midX - sz.width/2, y: rect.midY - sz.height/2))
}
func save(_ img: NSImage, to path: String) {
    let bmp = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! bmp.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

// ─── Palette ─────────────────────────────────────────────────
struct Pal {
    let dark: Bool
    var bg:    (Double,Double,Double) { dark ? (0.09,0.09,0.09)  : (0.96,0.96,0.97) }
    var nav:   (Double,Double,Double) { dark ? (0.11,0.11,0.12)  : (0.99,0.99,1.00) }
    var num:   (Double,Double,Double) { dark ? (0.28,0.28,0.30)  : (1,1,1) }
    var fn:    (Double,Double,Double) { dark ? (0.20,0.20,0.22)  : (0.82,0.82,0.86) }
    var sci:   (Double,Double,Double) { dark ? (0.18,0.14,0.36)  : (0.88,0.85,0.99) }
    var mem:   (Double,Double,Double) { dark ? (0.26,0.08,0.42)  : (0.90,0.82,1.00) }
    var disp:  NSColor                { dark ? .white             : .black }
    var sec:   NSColor                { dark ? NSColor(white:1,alpha:0.42) : NSColor(white:0,alpha:0.38) }
    var sheet: (Double,Double,Double) { dark ? (0.13,0.13,0.15)  : (0.97,0.97,0.99) }
}

// ─── iPhone frame ────────────────────────────────────────────
// Portrait 390×844 @1x (iPhone 14 proportions)
let PW: CGFloat = 390, PH: CGFloat = 844
let CORNER: CGFloat = 50
let NOTCH_W: CGFloat = 120, NOTCH_H: CGFloat = 34

func drawPhone(ctx: CGContext, pal: Pal) {
    // Outer shell
    let shell = rr(CGRect(x: 0, y: 0, width: PW, height: PH), CORNER)
    fill(ctx, shell, r: pal.bg.0, g: pal.bg.1, b: pal.bg.2)
    // Border
    ctx.setStrokeColor(CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.25))
    ctx.setLineWidth(1.5); ctx.addPath(shell); ctx.strokePath()
    // Dynamic island
    let di = CGRect(x: (PW-NOTCH_W)/2, y: PH-NOTCH_H-10, width: NOTCH_W, height: NOTCH_H)
    fill(ctx, rr(di, 17), r: 0, g: 0, b: 0)
}

// ─── Toolbar ─────────────────────────────────────────────────
func drawToolbar(ctx: CGContext, pal: Pal, sciOn: Bool = false) {
    let y = PH - NOTCH_H - 10 - 44
    // Title
    let tf = NSFont.systemFont(ofSize: 17, weight: .semibold)
    attr("CalcYouLater", tf, pal.disp).draw(at: NSPoint(x: 20, y: y+12))
    // Sci chip
    let chipR = CGRect(x: PW-70, y: y+10, width: 48, height: 24)
    ctx.setFillColor(sciOn
        ? CGColor(red: 0.36, green: 0.20, blue: 0.86, alpha: 0.22)
        : CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.14))
    ctx.addPath(rr(chipR, 12)); ctx.fillPath()
    attr("Sci", NSFont.systemFont(ofSize: 12, weight: .bold),
         sciOn ? NSColor(red:0.5,green:0.3,blue:1,alpha:1) : pal.sec)
        .draw(at: NSPoint(x: chipR.minX+11, y: chipR.minY+4))
    // Icon buttons
    for (i, sym) in ["clock.arrow.circlepath","arrow.left.arrow.right.circle"].enumerated() {
        let iconR = CGRect(x: PW-130+CGFloat(i)*36, y: y+9, width: 26, height: 26)
        ctx.setFillColor(CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.12))
        ctx.addPath(rr(iconR, 7)); ctx.fillPath()
        // draw a simple symbolic glyph placeholder
        _ = sym  // just the background chip is enough at this scale
    }
}

// ─── Display ─────────────────────────────────────────────────
func drawDisplay(ctx: CGContext, pal: Pal, expr: String, value: String,
                 memText: String? = nil, top: CGFloat) {
    let exprF = NSFont.monospacedSystemFont(ofSize: 16, weight: .ultraLight)
    let exprS = NSAttributedString(string: expr, attributes: [.font: exprF, .foregroundColor: pal.sec])
    let exprW = exprS.size().width
    exprS.draw(at: NSPoint(x: PW - 24 - exprW, y: top + 28))

    let numF = NSFont.systemFont(ofSize: 68, weight: .thin)
    let numS = NSAttributedString(string: value, attributes: [.font: numF, .foregroundColor: pal.disp])
    let numW = numS.size().width
    numS.draw(at: NSPoint(x: PW - 24 - numW, y: top - 14))

    if let mem = memText {
        let mf = NSFont.systemFont(ofSize: 12, weight: .medium)
        attr(mem, mf, NSColor(red:0.6,green:0.2,blue:0.9,alpha:1)).draw(at: NSPoint(x: 24, y: top - 14))
    }
}

// ─── Keypad ───────────────────────────────────────────────────
struct BRow { var labels: [String]; var kinds: [String] }

func drawKeypad(ctx: CGContext, pal: Pal, pad: CGFloat = 16, gap: CGFloat = 10,
                bottom: CGFloat = 36, highlight: String? = nil) {
    let cols: CGFloat = 4
    let bw = (PW - 2*pad - (cols-1)*gap) / cols
    let bh = bw * 0.84
    let mh = bh * 0.62

    let rows: [(labels:[String], kinds:[String])] = [
        (["MC","MR","M+","M−"], ["m","m","m","m"]),
        (["AC","+/−","%","÷"],   ["f","f","f","o"]),
        (["7","8","9","×"],      ["n","n","n","o"]),
        (["4","5","6","−"],      ["n","n","n","o"]),
        (["1","2","3","+"],      ["n","n","n","o"]),
    ]

    var cy = bottom
    // bottom row
    let lbr = CGRect(x: pad, y: cy, width: bw*2+gap, height: bh)  // wide 0
    fill(ctx, rr(lbr, 16), r: pal.num.0, g: pal.num.1, b: pal.num.2)
    attr("0", NSFont.systemFont(ofSize: 28), pal.disp).draw(at: NSPoint(x: pad+18, y: cy+(bh-32)/2))

    let dotR = CGRect(x: pad+bw*2+gap*2, y: cy, width: bw, height: bh)
    fill(ctx, rr(dotR, 16), r: pal.num.0, g: pal.num.1, b: pal.num.2)
    drawCentered(attr(".", NSFont.systemFont(ofSize: 28), pal.disp), in: dotR)

    let eqX = pad+bw*3+gap*3
    let eqR = CGRect(x: eqX, y: cy, width: bw, height: bh)
    ctx.setShadow(offset:.zero, blur:14, color:CGColor(red:1,green:0.56,blue:0,alpha:0.45))
    fill(ctx, rr(eqR, 16), r:1, g:0.56, b:0)
    ctx.setShadow(offset:.zero, blur:0, color:nil)
    drawCentered(attr("=", NSFont.systemFont(ofSize:28, weight:.medium), .white), in: eqR)

    cy += bh + gap

    for row in rows.reversed() {
        let rowH = row.kinds[0] == "m" ? mh : bh
        for (ci, (lbl, kind)) in zip(row.labels, row.kinds).enumerated() {
            let bx = pad + CGFloat(ci)*(bw+gap)
            let br = CGRect(x: bx, y: cy, width: bw, height: rowH)
            let isHl = lbl == (highlight ?? "")
            let col: (Double,Double,Double)
            let fg: NSColor
            switch kind {
            case "o": col=(1,0.56,0); fg = .white
            case "f": col=pal.fn;     fg = pal.disp
            case "m": col=pal.mem;    fg = NSColor(red:0.8,green:0.65,blue:1,alpha:1)
            default:  col=pal.num;    fg = pal.disp
            }
            let a = isHl ? 0.55 : 1.0
            fill(ctx, rr(br, 16), r:col.0, g:col.1, b:col.2, a:a)
            let fs: CGFloat = kind == "m" ? 13 : 22
            drawCentered(attr(lbl, NSFont.systemFont(ofSize:fs, weight: kind=="o" ? .medium : .regular), fg), in: br)
        }
        cy += rowH + gap
    }
}

// ─── Scientific rows ──────────────────────────────────────────
func drawSciPanel(ctx: CGContext, pal: Pal, pad: CGFloat = 16, gap: CGFloat = 8, bottom: CGFloat) {
    let cols: CGFloat = 4
    let bw = (PW - 2*pad - (cols-1)*gap) / cols
    let bh = bw * 0.54
    let sciRows = [
        ["sin","cos","tan","π"],
        ["sin⁻¹","cos⁻¹","tan⁻¹","e"],
        ["log","ln","√","x²"],
        ["xʸ","n!","1/x","∛x"],
    ]
    var cy = bottom
    for row in sciRows.reversed() {
        for (ci, lbl) in row.enumerated() {
            let bx = pad + CGFloat(ci)*(bw+gap)
            let br = CGRect(x: bx, y: cy, width: bw, height: bh)
            fill(ctx, rr(br, 12), r: pal.sci.0, g: pal.sci.1, b: pal.sci.2)
            let c = pal.dark ? NSColor(red:0.65,green:0.55,blue:1,alpha:1) : NSColor(red:0.35,green:0.15,blue:0.75,alpha:1)
            drawCentered(attr(lbl, NSFont.systemFont(ofSize:12, weight:.medium), c), in: br)
        }
        cy += bh + gap
    }
}

// ─── Sheet overlay ────────────────────────────────────────────
func drawSheet(ctx: CGContext, pal: Pal, title: String, rows: [(String,String)]) {
    let sheetY: CGFloat = 160
    let sheetH = PH - sheetY
    let sheetPath = rr(CGRect(x: 0, y: 0, width: PW, height: sheetH), 20)
    fill(ctx, sheetPath, r: pal.sheet.0, g: pal.sheet.1, b: pal.sheet.2)
    // Handle
    let handle = rr(CGRect(x: PW/2-20, y: sheetH-12, width: 40, height: 5), 3)
    fill(ctx, handle, r: 0.5, g: 0.5, b: 0.5, a: 0.35)
    // Title
    attr(title, NSFont.systemFont(ofSize:17, weight:.semibold), pal.disp)
        .draw(at: NSPoint(x:20, y:sheetH-48))
    attr("Done", NSFont.systemFont(ofSize:17, weight:.semibold), NSColor(red:0.36,green:0.20,blue:0.86,alpha:1))
        .draw(at: NSPoint(x:PW-58, y:sheetH-48))
    // Divider
    ctx.setFillColor(CGColor(red:0.5,green:0.5,blue:0.5,alpha:0.18))
    ctx.fill(CGRect(x:0, y:sheetH-56, width:PW, height:0.5))
    // Rows
    var ry = sheetH - 70
    for (expr, result) in rows {
        ry -= 12
        attr(expr, NSFont.monospacedSystemFont(ofSize:12, weight:.regular), pal.sec)
            .draw(at: NSPoint(x:PW-24-attr(expr,.monospacedSystemFont(ofSize:12,weight:.regular),.white).size().width, y:ry))
        ry -= 24
        let rf = NSFont.systemFont(ofSize:22, weight:.semibold)
        let rs = attr(result, rf, pal.disp)
        rs.draw(at: NSPoint(x:PW-24-rs.size().width, y:ry))
        ry -= 10
        ctx.setFillColor(CGColor(red:0.5,green:0.5,blue:0.5,alpha:0.15))
        ctx.fill(CGRect(x:16, y:ry, width:PW-32, height:0.5))
    }
}

// ─── Render all mockups ───────────────────────────────────────
let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/ios_mockups"
try! FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

struct Spec {
    let name: String; let pal: Pal
    let expr: String; let value: String
    let sci: Bool; let sheet: (String,[(String,String)])?
    let mem: String?; let highlight: String?
}

let specs: [Spec] = [
    Spec(name:"portrait_dark",   pal:Pal(dark:true),  expr:"6 × 7 =",   value:"42",      sci:false, sheet:nil, mem:nil, highlight:"="),
    Spec(name:"portrait_light",  pal:Pal(dark:false), expr:"π",          value:"3.14159", sci:false, sheet:nil, mem:nil, highlight:nil),
    Spec(name:"scientific_dark", pal:Pal(dark:true),  expr:"sin(30) =",  value:"0.5",     sci:true,  sheet:nil, mem:nil, highlight:nil),
    Spec(name:"history_dark",    pal:Pal(dark:true),  expr:"6 × 7 =",    value:"42",      sci:false,
         sheet:("History",[("6 × 7 =","42"),("√144 =","12"),("100 − 58 =","42"),("2^8 =","256"),("355 ÷ 113 =","3.141593")]),
         mem:nil, highlight:nil),
    Spec(name:"memory_light",    pal:Pal(dark:false), expr:"M+",         value:"100",     sci:false, sheet:nil, mem:"M: 100", highlight:"M+"),
]

for spec in specs {
    let img = NSImage(size: NSSize(width: PW, height: PH))
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext

    drawPhone(ctx: ctx, pal: spec.pal)
    drawToolbar(ctx: ctx, pal: spec.pal, sciOn: spec.sci)

    if let (title, rows) = spec.sheet {
        // draw blurred-out calc behind sheet
        let dispTop = PH - NOTCH_H - 10 - 44 - 120
        drawDisplay(ctx:ctx, pal:spec.pal, expr:spec.expr, value:spec.value, top:dispTop)
        // sheet on top
        ctx.saveGState()
        ctx.translateBy(x: 0, y: 160)
        drawSheet(ctx: ctx, pal: spec.pal, title: title, rows: rows)
        ctx.restoreGState()
    } else {
        let gap: CGFloat = 10, pad: CGFloat = 16
        let cols: CGFloat = 4
        let bw = (PW - 2*pad - (cols-1)*gap) / cols
        let bh = bw * 0.84
        let mh = bh * 0.62
        let stdRows = 5, sciRowCount = spec.sci ? 4 : 0
        let sciH: CGFloat = spec.sci ? bw * 0.54 * 4 + gap * 3 + gap : 0
        let keypadH = mh + gap + CGFloat(stdRows)*bh + CGFloat(stdRows)*gap + sciH
        let keypadBottom: CGFloat = 34
        let keypadTop = keypadBottom + keypadH

        if spec.sci {
            let sciBottom = keypadBottom + bh*5 + mh + gap*6
            drawSciPanel(ctx:ctx, pal:spec.pal, bottom: sciBottom)
        }
        drawKeypad(ctx:ctx, pal:spec.pal, bottom:keypadBottom, highlight:spec.highlight)

        let dispTop = keypadTop + 16
        drawDisplay(ctx:ctx, pal:spec.pal, expr:spec.expr, value:spec.value, memText:spec.mem, top:dispTop)
    }

    img.unlockFocus()
    save(img, to: "\(outDir)/\(spec.name).png")
    print("✓ \(spec.name).png")
}
print("All iOS mockups done.")
