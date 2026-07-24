import AppKit

// Renders the CodexBar icon: a blue→purple puffy cloud with white "LB".
//   MakeIcon <out.png> <size> <bar|app>
//     bar : transparent background (menu-bar item)
//     app : rounded dark tile (Finder / launcher app icon)

func mapRect(_ nx: CGFloat, _ ny: CGFloat, _ nw: CGFloat, _ nh: CGFloat, in R: CGRect) -> CGRect {
    CGRect(x: R.minX + nx * R.width, y: R.minY + ny * R.height,
           width: nw * R.width, height: nh * R.height)
}

func puff(_ path: NSBezierPath, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, in R: CGRect) {
    let d = 2 * r
    path.appendOval(in: mapRect(cx - r, cy - r, d, d, in: R))
}

/// Draw the cloud + LB inside rect R (glyph area).
func drawCloudLB(in R: CGRect) {
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

    let text = "LB" as NSString
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

// ---- main ----
let args = CommandLine.arguments
guard args.count >= 4, let S = Double(args[2]) else {
    FileHandle.standardError.write(Data("usage: MakeIcon <out.png> <size> <bar|app>\n".utf8)); exit(2)
}
let out = args[1]
let canvas = CGFloat(S)
let mode = args[3]

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

if mode == "app" {
    drawTile(canvas)
}
drawCloudLB(in: glyphRect)

NSGraphicsContext.restoreGraphicsState()
guard let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("PNG encode failed\n".utf8)); exit(1)
}
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out) \(Int(canvas))px \(mode)")
