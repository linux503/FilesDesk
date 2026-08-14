import AppKit
import Foundation

// FilesDesk mark: teal desk + white document + amber rename arrow.
// Small sizes drop the fold and extra sheets so the glyph stays readable.

struct Palette {
    static let bgTop = NSColor(srgbRed: 0.18, green: 0.62, blue: 0.72, alpha: 1)
    static let bgMid = NSColor(srgbRed: 0.10, green: 0.46, blue: 0.62, alpha: 1)
    static let bgBottom = NSColor(srgbRed: 0.05, green: 0.28, blue: 0.46, alpha: 1)
    static let sheen = NSColor(srgbRed: 0.55, green: 0.88, blue: 0.96, alpha: 0.22)
    static let paper = NSColor(srgbRed: 0.99, green: 0.995, blue: 1.0, alpha: 1)
    static let paperEdge = NSColor(srgbRed: 0.78, green: 0.88, blue: 0.93, alpha: 1)
    static let fold = NSColor(srgbRed: 0.86, green: 0.93, blue: 0.96, alpha: 1)
    static let ink = NSColor(srgbRed: 0.12, green: 0.32, blue: 0.42, alpha: 0.28)
    static let amber = NSColor(srgbRed: 1.0, green: 0.72, blue: 0.22, alpha: 1)
    static let amberDeep = NSColor(srgbRed: 0.93, green: 0.48, blue: 0.08, alpha: 1)
}

func bitmap(_ w: Int, _ h: Int) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: w,
        pixelsHigh: h,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: w, height: h)
    return rep
}

func withContext(_ rep: NSBitmapImageRep, _ draw: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.shouldAntialias = true
    NSGraphicsContext.current?.imageInterpolation = .high
    draw()
    NSGraphicsContext.restoreGraphicsState()
}

func writePNG(_ rep: NSBitmapImageRep, _ path: String) {
    guard let data = rep.representation(using: .png, properties: [:]) else { return }
    try! data.write(to: URL(fileURLWithPath: path))
}

func squircle(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func roundedRect(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawIcon(size: CGFloat) {
    let s = size
    let pad = s * 0.04
    let board = NSRect(x: pad, y: pad, width: s - pad * 2, height: s - pad * 2)
    let radius = s * 0.223
    let detailed = s >= 64

    let bg = squircle(board, radius: radius)
    NSGradient(colors: [Palette.bgTop, Palette.bgMid, Palette.bgBottom])!
        .draw(in: bg, angle: 248)

    let sheenRect = NSRect(
        x: board.minX + s * 0.06,
        y: board.midY + s * 0.02,
        width: board.width * 0.88,
        height: board.height * 0.46
    )
    Palette.sheen.setFill()
    squircle(sheenRect, radius: radius * 0.72).fill()

    if detailed {
        let back = NSRect(x: s * 0.30, y: s * 0.24, width: s * 0.42, height: s * 0.50)
        Palette.paperEdge.withAlphaComponent(0.55).setFill()
        roundedRect(back, radius: s * 0.04).fill()

        let mid = NSRect(x: s * 0.26, y: s * 0.20, width: s * 0.44, height: s * 0.52)
        NSColor(srgbRed: 0.93, green: 0.96, blue: 0.98, alpha: 0.9).setFill()
        roundedRect(mid, radius: s * 0.042).fill()
    }

    let front = NSRect(
        x: s * (detailed ? 0.20 : 0.22),
        y: s * (detailed ? 0.16 : 0.20),
        width: s * (detailed ? 0.46 : 0.44),
        height: s * (detailed ? 0.56 : 0.52)
    )
    let frontPath = roundedRect(front, radius: s * 0.05)
    Palette.paper.setFill()
    frontPath.fill()

    if detailed {
        let foldSize = s * 0.11
        let fold = NSBezierPath()
        fold.move(to: NSPoint(x: front.maxX - foldSize, y: front.maxY))
        fold.line(to: NSPoint(x: front.maxX, y: front.maxY))
        fold.line(to: NSPoint(x: front.maxX, y: front.maxY - foldSize))
        fold.close()
        Palette.fold.setFill()
        fold.fill()
        Palette.paperEdge.setStroke()
        fold.lineWidth = max(0.6, s * 0.006)
        fold.stroke()
    }

    Palette.ink.setStroke()
    let lineCount = detailed ? 3 : 2
    for i in 0..<lineCount {
        let y = front.minY + s * (0.14 + CGFloat(i) * 0.08)
        let line = NSBezierPath()
        line.lineCapStyle = .round
        line.lineWidth = max(0.9, s * 0.018)
        let inset: CGFloat = detailed ? 0.07 : 0.08
        let widthFactor: CGFloat = i == lineCount - 1 ? 0.22 : 0.30
        line.move(to: NSPoint(x: front.minX + s * inset, y: y))
        line.line(to: NSPoint(x: front.minX + s * inset + s * widthFactor, y: y))
        line.stroke()
    }

    let badgeR = s * (detailed ? 0.175 : 0.19)
    let badgeCenter = NSPoint(x: s * 0.70, y: s * 0.66)
    let badgeRect = NSRect(
        x: badgeCenter.x - badgeR,
        y: badgeCenter.y - badgeR,
        width: badgeR * 2,
        height: badgeR * 2
    )
    let badge = NSBezierPath(ovalIn: badgeRect)
    NSColor.black.withAlphaComponent(0.16).setFill()
    NSBezierPath(ovalIn: badgeRect.offsetBy(dx: 0, dy: -s * 0.012)).fill()
    NSGradient(colors: [Palette.amber, Palette.amberDeep])!.draw(in: badge, angle: 128)

    let highlight = NSBezierPath(ovalIn: NSRect(
        x: badgeCenter.x - badgeR * 0.55,
        y: badgeCenter.y + badgeR * 0.18,
        width: badgeR * 1.05,
        height: badgeR * 0.55
    ))
    NSColor.white.withAlphaComponent(0.18).setFill()
    highlight.fill()

    let arrow = NSBezierPath()
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    arrow.lineWidth = max(1.6, s * 0.048)
    let ax = badgeCenter.x
    let ay = badgeCenter.y
    arrow.move(to: NSPoint(x: ax - s * 0.07, y: ay))
    arrow.line(to: NSPoint(x: ax + s * 0.055, y: ay))
    arrow.move(to: NSPoint(x: ax + s * 0.012, y: ay + s * 0.038))
    arrow.line(to: NSPoint(x: ax + s * 0.058, y: ay))
    arrow.line(to: NSPoint(x: ax + s * 0.012, y: ay - s * 0.038))
    NSColor.white.setStroke()
    arrow.stroke()
}

func render(_ px: Int) -> NSBitmapImageRep {
    let rep = bitmap(px, px)
    withContext(rep) { drawIcon(size: CGFloat(px)) }
    return rep
}

func drawOG() -> NSBitmapImageRep {
    let rep = bitmap(1200, 630)
    withContext(rep) {
        let rect = NSRect(x: 0, y: 0, width: 1200, height: 630)
        NSGradient(colors: [
            NSColor(srgbRed: 0.90, green: 0.96, blue: 0.98, alpha: 1),
            NSColor(srgbRed: 0.82, green: 0.91, blue: 0.96, alpha: 1)
        ])!.draw(in: rect, angle: 118)

        NSGraphicsContext.current?.saveGraphicsState()
        let xform = NSAffineTransform()
        xform.translateX(by: 110, yBy: 125)
        xform.concat()
        drawIcon(size: 380)
        NSGraphicsContext.current?.restoreGraphicsState()

        let title = "FilesDesk" as NSString
        title.draw(at: NSPoint(x: 540, y: 340), withAttributes: [
            .font: NSFont.systemFont(ofSize: 84, weight: .bold),
            .foregroundColor: NSColor(srgbRed: 0.05, green: 0.26, blue: 0.40, alpha: 1)
        ])
        let sub = "Mac 智能批量重命名" as NSString
        sub.draw(at: NSPoint(x: 540, y: 260), withAttributes: [
            .font: NSFont.systemFont(ofSize: 32, weight: .medium),
            .foregroundColor: NSColor(srgbRed: 0.12, green: 0.48, blue: 0.62, alpha: 1)
        ])
    }
    return rep
}

let root = CommandLine.arguments[1]
let appIcon = root + "/FilesDesk/Assets.xcassets/AppIcon.appiconset"
let appLogo = root + "/FilesDesk/Assets.xcassets/AppLogo.imageset"
let web = root + "/docs/assets"

let sizes: [(String, Int)] = [
    ("icon_16.png", 16), ("icon_16@2x.png", 32),
    ("icon_32.png", 32), ("icon_32@2x.png", 64),
    ("icon_128.png", 128), ("icon_128@2x.png", 256),
    ("icon_256.png", 256), ("icon_256@2x.png", 512),
    ("icon_512.png", 512), ("icon_512@2x.png", 1024)
]

for (name, px) in sizes {
    writePNG(render(px), "\(appIcon)/\(name)")
}
writePNG(render(256), "\(appLogo)/AppLogo.png")
writePNG(render(512), "\(appLogo)/AppLogo@2x.png")
writePNG(render(1024), "\(web)/icon-1024.png")
writePNG(render(512), "\(web)/icon.png")
writePNG(render(32), "\(web)/favicon-32.png")
writePNG(render(180), "\(web)/apple-touch-180.png")
writePNG(drawOG(), "\(web)/og.png")
print("Logo v3 done")
