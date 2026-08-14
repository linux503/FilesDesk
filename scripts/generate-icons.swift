import AppKit
import Foundation

struct Palette {
    static let bgTop = NSColor(calibratedRed: 0.11, green: 0.42, blue: 0.58, alpha: 1)
    static let bgBottom = NSColor(calibratedRed: 0.06, green: 0.24, blue: 0.38, alpha: 1)
    static let glow = NSColor(calibratedRed: 0.35, green: 0.78, blue: 0.95, alpha: 0.35)
    static let paper = NSColor(calibratedRed: 0.98, green: 0.99, blue: 1.0, alpha: 1)
    static let paperShadow = NSColor(calibratedRed: 0.82, green: 0.88, blue: 0.94, alpha: 1)
    static let ink = NSColor(calibratedRed: 0.14, green: 0.22, blue: 0.30, alpha: 0.35)
    static let accent = NSColor(calibratedRed: 0.98, green: 0.72, blue: 0.28, alpha: 1)
    static let accentDeep = NSColor(calibratedRed: 0.92, green: 0.55, blue: 0.12, alpha: 1)
    static let line = NSColor(calibratedRed: 0.20, green: 0.55, blue: 0.72, alpha: 0.55)
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

func drawIcon(size: CGFloat) {
    let s = size
    let pad = s * 0.055
    let board = NSRect(x: pad, y: pad, width: s - pad * 2, height: s - pad * 2)
    let radius = s * 0.225

    // Background squircle
    let bg = squircle(board, radius: radius)
    let grad = NSGradient(colors: [Palette.bgTop, Palette.bgBottom])!
    grad.draw(in: bg, angle: 270)

    // Top glow
    let glowRect = NSRect(x: board.minX + s * 0.08, y: board.midY, width: board.width * 0.84, height: board.height * 0.52)
    let glowPath = squircle(glowRect, radius: radius * 0.7)
    Palette.glow.setFill()
    glowPath.fill()

    // Back card
    let back = NSRect(x: s * 0.22, y: s * 0.28, width: s * 0.44, height: s * 0.50)
    let backPath = squircle(back, radius: s * 0.045)
    Palette.paperShadow.setFill()
    backPath.fill()

    // Middle card
    let mid = NSRect(x: s * 0.18, y: s * 0.22, width: s * 0.46, height: s * 0.52)
    let midPath = squircle(mid, radius: s * 0.048)
    NSColor(calibratedWhite: 0.94, alpha: 0.92).setFill()
    midPath.fill()

    // Front card
    let front = NSRect(x: s * 0.14, y: s * 0.16, width: s * 0.50, height: s * 0.54)
    let frontPath = squircle(front, radius: s * 0.05)
    Palette.paper.setFill()
    frontPath.fill()

    // Card border
    Palette.line.setStroke()
    frontPath.lineWidth = max(1, s * 0.012)
    frontPath.stroke()

    // Text lines on card
    if s >= 24 {
        Palette.ink.setStroke()
        for i in 0..<3 {
            let y = front.minY + s * (0.12 + CGFloat(i) * 0.075)
            let line = NSBezierPath()
            line.lineWidth = max(0.8, s * 0.014)
            line.lineCapStyle = .round
            let w = s * (0.28 - CGFloat(i) * 0.04)
            line.move(to: NSPoint(x: front.minX + s * 0.07, y: y))
            line.line(to: NSPoint(x: front.minX + s * 0.07 + w, y: y))
            line.stroke()
        }
    }

    // Rename arrow badge
    let badgeR = s * 0.17
    let badgeCenter = NSPoint(x: s * 0.72, y: s * 0.68)
    let badge = NSBezierPath(ovalIn: NSRect(
        x: badgeCenter.x - badgeR,
        y: badgeCenter.y - badgeR,
        width: badgeR * 2,
        height: badgeR * 2
    ))
    let badgeGrad = NSGradient(colors: [Palette.accent, Palette.accentDeep])!
    badgeGrad.draw(in: badge, angle: 135)

    // Arrow inside badge
    let arrow = NSBezierPath()
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    arrow.lineWidth = max(1.8, s * 0.042)
    let ax = badgeCenter.x - s * 0.055
    let ay = badgeCenter.y
    arrow.move(to: NSPoint(x: ax - s * 0.04, y: ay))
    arrow.line(to: NSPoint(x: ax + s * 0.05, y: ay))
    arrow.move(to: NSPoint(x: ax + s * 0.015, y: ay + s * 0.028))
    arrow.line(to: NSPoint(x: ax + s * 0.05, y: ay))
    arrow.line(to: NSPoint(x: ax + s * 0.015, y: ay - s * 0.028))
    NSColor(calibratedWhite: 1, alpha: 0.95).setStroke()
    arrow.stroke()

    // Subtle bottom shadow on board
    let shadow = squircle(board.insetBy(dx: 0, dy: -s * 0.01), radius: radius)
    NSColor.black.withAlphaComponent(0.08).setStroke()
    shadow.lineWidth = max(1, s * 0.008)
    shadow.stroke()
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
            NSColor(calibratedRed: 0.92, green: 0.96, blue: 0.99, alpha: 1),
            NSColor(calibratedRed: 0.86, green: 0.93, blue: 0.97, alpha: 1)
        ])!.draw(in: rect, angle: 110)

        NSGraphicsContext.current?.saveGraphicsState()
        let xform = NSAffineTransform()
        xform.translateX(by: 120, yBy: 120)
        xform.concat()
        drawIcon(size: 280)
        NSGraphicsContext.current?.restoreGraphicsState()

        let title = "FilesDesk" as NSString
        title.draw(at: NSPoint(x: 460, y: 340), withAttributes: [
            .font: NSFont.systemFont(ofSize: 88, weight: .bold),
            .foregroundColor: NSColor(calibratedRed: 0.06, green: 0.24, blue: 0.38, alpha: 1)
        ])
        let sub = "Mac 智能批量重命名" as NSString
        sub.draw(at: NSPoint(x: 460, y: 260), withAttributes: [
            .font: NSFont.systemFont(ofSize: 34, weight: .regular),
            .foregroundColor: NSColor(calibratedRed: 0.11, green: 0.42, blue: 0.58, alpha: 1)
        ])
    }
    return rep
}

let root = CommandLine.arguments[1]
let appIcon = root + "/FilesDesk/Assets.xcassets/AppIcon.appiconset"
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
writePNG(render(1024), "\(web)/icon-1024.png")
writePNG(render(512), "\(web)/icon.png")
writePNG(render(32), "\(web)/favicon-32.png")
writePNG(render(180), "\(web)/apple-touch-180.png")
writePNG(drawOG(), "\(web)/og.png")
print("Logo v2 done")
