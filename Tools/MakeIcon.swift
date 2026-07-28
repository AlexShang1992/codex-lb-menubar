import AppKit

// Renders the CodexBar icon: a blue→purple puffy cloud with a white glyph.
//   MakeIcon <out.png> <size> <bar|app> [glyph]
//     bar   : transparent background (menu-bar item)
//     app   : rounded dark tile (Finder / launcher app icon)
//     glyph : "LB" (default) or "term" (a >_ terminal prompt)

func mapRect(_ nx: CGFloat, _ ny: CGFloat, _ nw: CGFloat, _ nh: CGFloat, in R: CGRect) -> CGRect {
    CGRect(x: R.minX + nx * R.width, y: R.minY + ny * R.height,
           width: nw * R.width, height: nh * R.height)
}

func puff(_ path: NSBezierPath, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, in R: CGRect) {
    let d = 2 * r
    path.appendOval(in: mapRect(cx - r, cy - r, d, d, in: R))
}

/// Draw the cloud with a glyph inside rect R.
/// - glyph: `"term"` draws a terminal prompt `>_`; anything else is drawn as text
///   (e.g. `"LB"`).
func drawCloud(in R: CGRect, glyph: String) {
    let cloud = NSBezierPath()
    cloud.appendRoundedRect(mapRect(0.16, 0.20, 0.68, 0.42, in: R),
                            xRadius: 0.20 * R.width, yRadius: 0.20 * R.height)
    puff(cloud, 0.50, 0.60, 0.24, in: R)
    puff(cloud, 0.31, 0.52, 0.17, in: R)
    puff(cloud, 0.69, 0.52, 0.17, in: R)
    puff(cloud, 0.40, 0.64, 0.15, in: R)
    puff(cloud, 0.61, 0.64, 0.15, in: R)
    puff(cloud, 0.22, 0.42, 0.14, in: R)
    puff(cloud, 0.78, 0.42, 0.14, in: R)
    cloud.windingRule = .nonZero

    NSGraphicsContext.saveGraphicsState()
    cloud.addClip()
    let top = NSColor(srgbRed: 0.482, green: 0.560, blue: 1.000, alpha: 1)
    let bottom = NSColor(srgbRed: 0.560, green: 0.360, blue: 0.960, alpha: 1)
    NSGradient(starting: top, ending: bottom)!.draw(in: R, angle: -70)
    NSGradient(colors: [NSColor(white: 1, alpha: 0.30), NSColor(white: 1, alpha: 0.0)])!
        .draw(in: mapRect(0.18, 0.48, 0.64, 0.38, in: R), angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    if glyph == "term" {
        drawTerminal(in: R)
    } else {
        drawText(glyph, in: R)
    }
}

/// White terminal prompt `>_` (a chevron + underscore), like the Codex icon.
func drawTerminal(in R: CGRect) {
    func pt(_ nx: CGFloat, _ ny: CGFloat) -> NSPoint {
        NSPoint(x: R.minX + nx * R.width, y: R.minY + ny * R.height)
    }
    let stroke = NSBezierPath()
    stroke.lineWidth = 0.085 * R.width
    stroke.lineCapStyle = .round
    stroke.lineJoinStyle = .round
    stroke.move(to: pt(0.34, 0.635))   // chevron ">"
    stroke.line(to: pt(0.515, 0.50))
    stroke.line(to: pt(0.34, 0.365))
    stroke.move(to: pt(0.55, 0.355))   // underscore "_"
    stroke.line(to: pt(0.70, 0.355))

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    shadow.shadowBlurRadius = 0.03 * R.height
    shadow.shadowOffset = NSSize(width: 0, height: -0.01 * R.height)
    shadow.set()
    NSColor.white.setStroke()
    stroke.stroke()
    NSGraphicsContext.restoreGraphicsState()
}

/// White centered text (e.g. `LB`).
func drawText(_ string: String, in R: CGRect) {
    let text = string as NSString
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    shadow.shadowBlurRadius = 0.03 * R.height
    shadow.shadowOffset = NSSize(width: 0, height: -0.01 * R.height)
    let para = NSMutableParagraphStyle(); para.alignment = .center
    let font = NSFont.systemFont(ofSize: 0.40 * R.height, weight: .heavy)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font, .foregroundColor: NSColor.white,
        .paragraphStyle: para, .shadow: shadow, .kern: -0.01 * R.height
    ]
    let tsize = text.size(withAttributes: attrs)
    let trect = CGRect(x: R.minX, y: R.midY - tsize.height / 2 + 0.005 * R.height,
                       width: R.width, height: tsize.height)
    text.draw(in: trect, withAttributes: attrs)
}

func drawTile(_ S: CGFloat) {
    // Apple-style squircle inset from the full canvas.
    let inset = 0.085 * S
    let side = S - 2 * inset
    let tile = NSBezierPath(roundedRect: CGRect(x: inset, y: inset, width: side, height: side),
                            xRadius: 0.2237 * side, yRadius: 0.2237 * side)
    NSGraphicsContext.saveGraphicsState()
    tile.addClip()
    let dTop = NSColor(srgbRed: 0.17, green: 0.17, blue: 0.20, alpha: 1)
    let dBot = NSColor(srgbRed: 0.06, green: 0.06, blue: 0.08, alpha: 1)
    NSGradient(starting: dTop, ending: dBot)!.draw(in: CGRect(x: 0, y: 0, width: S, height: S), angle: -90)
    NSGraphicsContext.restoreGraphicsState()
    // subtle top edge highlight
    tile.lineWidth = 0.006 * S
    NSColor(white: 1, alpha: 0.06).setStroke()
    tile.stroke()
}

// MARK: - GitHub mark (rendered from the official Octicons SVG path)

/// Tokenise an SVG path's `d` string into command letters and numbers,
/// correctly splitting forms like `-.17` and `.4.07`.
func tokenizeSVG(_ d: String) -> [String] {
    var out: [String] = []
    var num = ""
    func flush() { if !num.isEmpty { out.append(num); num = "" } }
    for ch in d {
        if ch.isLetter {
            flush(); out.append(String(ch))
        } else if ch == "-" {
            if num.isEmpty || num.last == "e" || num.last == "E" { num.append(ch) }
            else { flush(); num = "-" }
        } else if ch == "." {
            if num.contains(".") { flush(); num = "." } else { num.append(ch) }
        } else if ch.isNumber || ch == "e" || ch == "E" {
            num.append(ch)
        } else {
            flush() // separators
        }
    }
    flush()
    return out
}

/// Approximate an SVG elliptical arc with cubic Béziers (points mapped via `flip`).
func appendArc(_ path: NSBezierPath, from p0: NSPoint, to p1: NSPoint,
               rx: CGFloat, ry: CGFloat, rotationDeg: CGFloat,
               largeArc: Bool, sweep: Bool, flip: (NSPoint) -> NSPoint) {
    if rx == 0 || ry == 0 { path.line(to: flip(p1)); return }
    let phi = rotationDeg * .pi / 180
    let cosPhi = cos(phi), sinPhi = sin(phi)
    let dx = (p0.x - p1.x) / 2, dy = (p0.y - p1.y) / 2
    let x1p =  cosPhi * dx + sinPhi * dy
    let y1p = -sinPhi * dx + cosPhi * dy
    var rxx = abs(rx), ryy = abs(ry)
    let lambda = (x1p * x1p) / (rxx * rxx) + (y1p * y1p) / (ryy * ryy)
    if lambda > 1 { let s = sqrt(lambda); rxx *= s; ryy *= s }
    let sign: CGFloat = (largeArc != sweep) ? 1 : -1
    let numer = max(0, rxx*rxx*ryy*ryy - rxx*rxx*y1p*y1p - ryy*ryy*x1p*x1p)
    let denom = rxx*rxx*y1p*y1p + ryy*ryy*x1p*x1p
    let coef = sign * sqrt(numer / denom)
    let cxp =  coef * (rxx * y1p / ryy)
    let cyp = -coef * (ryy * x1p / rxx)
    let cx = cosPhi * cxp - sinPhi * cyp + (p0.x + p1.x) / 2
    let cy = sinPhi * cxp + cosPhi * cyp + (p0.y + p1.y) / 2
    func ang(_ ux: CGFloat, _ uy: CGFloat, _ vx: CGFloat, _ vy: CGFloat) -> CGFloat {
        let dot = ux*vx + uy*vy
        let len = sqrt((ux*ux + uy*uy) * (vx*vx + vy*vy))
        var a = acos(max(-1, min(1, dot / len)))
        if ux*vy - uy*vx < 0 { a = -a }
        return a
    }
    let theta1 = ang(1, 0, (x1p - cxp) / rxx, (y1p - cyp) / ryy)
    var dtheta = ang((x1p - cxp) / rxx, (y1p - cyp) / ryy, (-x1p - cxp) / rxx, (-y1p - cyp) / ryy)
    if !sweep && dtheta > 0 { dtheta -= 2 * .pi }
    if sweep && dtheta < 0 { dtheta += 2 * .pi }
    let segs = max(1, Int(ceil(abs(dtheta) / (.pi / 2))))
    let delta = dtheta / CGFloat(segs)
    let t = 4.0 / 3.0 * tan(delta / 4)
    func E(_ a: CGFloat) -> NSPoint {
        NSPoint(x: cosPhi * rxx * cos(a) - sinPhi * ryy * sin(a) + cx,
                y: sinPhi * rxx * cos(a) + cosPhi * ryy * sin(a) + cy)
    }
    func dE(_ a: CGFloat) -> NSPoint {
        NSPoint(x: -cosPhi * rxx * sin(a) - sinPhi * ryy * cos(a),
                y: -sinPhi * rxx * sin(a) + cosPhi * ryy * cos(a))
    }
    var a = theta1
    for _ in 0..<segs {
        let p1e = E(a), p2e = E(a + delta)
        let d1 = dE(a), d2 = dE(a + delta)
        let c1 = NSPoint(x: p1e.x + t * d1.x, y: p1e.y + t * d1.y)
        let c2 = NSPoint(x: p2e.x - t * d2.x, y: p2e.y - t * d2.y)
        path.curve(to: flip(p2e), controlPoint1: flip(c1), controlPoint2: flip(c2))
        a += delta
    }
}

/// The GitHub "mark" (octocat), fit into rect R with SVG's y-axis flipped.
func githubPath(in R: CGRect) -> NSBezierPath {
    let d = "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"
    let s = R.width / 16.0
    func flip(_ p: NSPoint) -> NSPoint { NSPoint(x: R.minX + p.x * s, y: R.maxY - p.y * s) }
    let path = NSBezierPath()
    let toks = tokenizeSVG(d)
    var i = 0, cmd = ""
    var cur = NSPoint.zero, start = NSPoint.zero
    func n() -> CGFloat { defer { i += 1 }; return CGFloat(Double(toks[i]) ?? 0) }
    while i < toks.count {
        if let f = toks[i].first, f.isLetter {
            cmd = toks[i]; i += 1
            if cmd == "Z" || cmd == "z" { path.close(); cur = start; continue }
        }
        switch cmd {
        case "M": let p = NSPoint(x: n(), y: n()); cur = p; start = p; path.move(to: flip(p)); cmd = "L"
        case "m": let p = NSPoint(x: cur.x + n(), y: cur.y + n()); cur = p; start = p; path.move(to: flip(p)); cmd = "l"
        case "L": let p = NSPoint(x: n(), y: n()); cur = p; path.line(to: flip(p))
        case "l": let p = NSPoint(x: cur.x + n(), y: cur.y + n()); cur = p; path.line(to: flip(p))
        case "C":
            let c1 = NSPoint(x: n(), y: n()), c2 = NSPoint(x: n(), y: n()), e = NSPoint(x: n(), y: n())
            path.curve(to: flip(e), controlPoint1: flip(c1), controlPoint2: flip(c2)); cur = e
        case "c":
            let c1 = NSPoint(x: cur.x + n(), y: cur.y + n())
            let c2 = NSPoint(x: cur.x + n(), y: cur.y + n())
            let e = NSPoint(x: cur.x + n(), y: cur.y + n())
            path.curve(to: flip(e), controlPoint1: flip(c1), controlPoint2: flip(c2)); cur = e
        case "A", "a":
            let rx = n(), ry = n(), rot = n(), laf = n(), sf = n()
            let e = cmd == "A" ? NSPoint(x: n(), y: n()) : NSPoint(x: cur.x + n(), y: cur.y + n())
            appendArc(path, from: cur, to: e, rx: rx, ry: ry, rotationDeg: rot,
                      largeArc: laf != 0, sweep: sf != 0, flip: flip)
            cur = e
        default: i += 1
        }
    }
    return path
}

// ---- main ----
let args = CommandLine.arguments
guard args.count >= 4, let S = Double(args[2]) else {
    FileHandle.standardError.write(Data("usage: MakeIcon <out.png> <size> <bar|app>\n".utf8)); exit(2)
}
let out = args[1]
let canvas = CGFloat(S)
let mode = args[3]
let glyph = args.count >= 5 ? args[4] : "LB"

// Cloud bounding box within the rect passed to drawCloudLB (measured from its layout).
let bbW: CGFloat = 0.84, bbH: CGFloat = 0.64, bbCX: CGFloat = 0.50, bbCY: CGFloat = 0.52

// Output pixel dimensions: square tile for the app icon; a tight, cloud-shaped
// (wider-than-tall) frame for the menu bar so it isn't padded down in size.
var Wpx = Int(canvas), Hpx = Int(canvas)
var glyphRect = CGRect(x: 0.19 * canvas, y: 0.17 * canvas, width: 0.62 * canvas, height: 0.62 * canvas)
if mode == "bar" {
    let H = canvas
    let pad = 0.05 * H                     // small margin around the cloud
    let Rside = (H - 2 * pad) / bbH         // uniform scale so cloud height fills H
    let W = bbW * Rside + 2 * pad
    Wpx = Int(ceil(W)); Hpx = Int(H)
    glyphRect = CGRect(x: CGFloat(Wpx) / 2 - bbCX * Rside,
                       y: H / 2 - bbCY * Rside,
                       width: Rside, height: Rside)
}

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Wpx, pixelsHigh: Hpx,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current!.cgContext.clear(CGRect(x: 0, y: 0, width: CGFloat(Wpx), height: CGFloat(Hpx)))

if mode == "github" {
    // Solid octocat, centred — used as a template image (tinted by the button).
    let inset = 0.06 * canvas
    let R = CGRect(x: inset, y: inset, width: canvas - 2 * inset, height: canvas - 2 * inset)
    NSColor.black.setFill()
    githubPath(in: R).fill()
} else {
    if mode == "app" {
        drawTile(canvas)
    }
    drawCloud(in: glyphRect, glyph: glyph)
}

NSGraphicsContext.restoreGraphicsState()
guard let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("PNG encode failed\n".utf8)); exit(1)
}
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out) \(Int(canvas))px \(mode) [\(glyph)]")
