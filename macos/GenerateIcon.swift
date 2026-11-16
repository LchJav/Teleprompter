import Cocoa
import QuartzCore

/// Renders the Teleprompter icon across macOS resolutions and writes a valid .icns bundle directly.
guard CommandLine.arguments.count == 2 || CommandLine.arguments.count == 3 else {
    fputs("Usage: GenerateIcon <output.icns> [source-image]\n", stderr)
    exit(1)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

let scriptDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let repoRoot = scriptDir.deletingLastPathComponent()
let defaultSourceURL = repoRoot.appendingPathComponent("anexo/icono.jpg")
let sourceURL = CommandLine.arguments.count == 3
    ? URL(fileURLWithPath: CommandLine.arguments[2])
    : defaultSourceURL

let sourceCGImage: CGImage? = {
    guard FileManager.default.fileExists(atPath: sourceURL.path),
          let image = NSImage(contentsOf: sourceURL),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else {
        return nil
    }
    return cgImage
}()

let specs: [(type: String, px: Int)] = [
    ("icp4", 16),
    ("icp5", 32),
    ("icp6", 48),
    ("ic07", 128),
    ("ic08", 256),
    ("ic09", 512),
    ("ic10", 1024),
    ("ic11", 32),
    ("ic12", 64),
    ("ic13", 256),
    ("ic14", 512),
]

/// Renders the provided source artwork clipped to macOS's Big Sur+ squircle grid and drop shadow.
func renderImageIcon(px: Int, cgSource: CGImage) -> Data? {
    let size = CGFloat(px)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: px,
        pixelsHigh: px,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
        return nil
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ctx
    let cg = ctx.cgContext
    cg.interpolationQuality = .high

    // Apple HIG macOS icon grid: 824x824 squircle centered on a 1024x1024 transparent canvas
    let cardSize = size * (824.0 / 1024.0)
    let origin = (size - cardSize) / 2.0
    let cardRect = CGRect(x: origin, y: origin, width: cardSize, height: cardSize)
    let cornerRadius = cardSize * 0.225

    let container = CALayer()
    container.frame = CGRect(x: 0, y: 0, width: size, height: size)
    container.contentsScale = 1.0

    let shadowLayer = CALayer()
    shadowLayer.frame = cardRect
    shadowLayer.cornerRadius = cornerRadius
    shadowLayer.cornerCurve = .continuous
    shadowLayer.backgroundColor = NSColor.black.cgColor
    shadowLayer.shadowColor = NSColor.black.cgColor
    shadowLayer.shadowOpacity = 0.48
    shadowLayer.shadowOffset = CGSize(width: 0, height: -size * 0.012)
    shadowLayer.shadowRadius = size * 0.022
    shadowLayer.contentsScale = 1.0

    let squircleLayer = CALayer()
    squircleLayer.frame = cardRect
    squircleLayer.cornerRadius = cornerRadius
    squircleLayer.cornerCurve = .continuous
    squircleLayer.masksToBounds = true
    squircleLayer.contentsScale = 1.0

    // Slight zoom (1.015x) trims the source image's outer frame border cleanly along the squircle mask
    let cropScale: CGFloat = 1.015
    let drawSize = cardSize * cropScale
    let imageLayer = CALayer()
    imageLayer.frame = CGRect(
        x: (cardSize - drawSize) / 2.0,
        y: (cardSize - drawSize) / 2.0,
        width: drawSize,
        height: drawSize
    )
    imageLayer.contents = cgSource
    imageLayer.contentsGravity = .resizeAspectFill
    imageLayer.minificationFilter = .trilinear
    imageLayer.magnificationFilter = .trilinear
    imageLayer.contentsScale = 1.0

    squircleLayer.addSublayer(imageLayer)
    container.addSublayer(shadowLayer)
    container.addSublayer(squircleLayer)
    container.render(in: cg)

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

/// Fallback vector icon used only if the source image is unavailable.
func renderFallbackIcon(px: Int) -> Data? {
    let size = CGFloat(px)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: px,
        pixelsHigh: px,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { return nil }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    let inset = size * (100.0 / 1024.0)
    let card = bounds.insetBy(dx: inset, dy: inset)
    let radius = card.width * 0.225

    let bgPath = NSBezierPath(roundedRect: card, xRadius: radius, yRadius: radius)
    let gradient = NSGradient(
        starting: NSColor(calibratedRed: 0.086, green: 0.086, blue: 0.094, alpha: 1.0),
        ending: NSColor(calibratedRed: 0.043, green: 0.043, blue: 0.047, alpha: 1.0)
    )
    gradient?.draw(in: bgPath, angle: -90)

    NSColor(calibratedRed: 0.165, green: 0.165, blue: 0.176, alpha: 1.0).setStroke()
    bgPath.lineWidth = max(1.0, size * 0.015)
    bgPath.stroke()

    let accent = NSColor(calibratedRed: 0.247, green: 0.722, blue: 0.651, alpha: 1.0)
    let textLight = NSColor(calibratedRed: 0.957, green: 0.957, blue: 0.949, alpha: 0.92)
    let textMuted = NSColor(calibratedRed: 0.541, green: 0.541, blue: 0.561, alpha: 0.55)

    let lineLeft = card.minX + card.width * 0.24
    let lineH = max(1.5, size * 0.05)
    let lines: [(yFrac: CGFloat, wFrac: CGFloat, color: NSColor)] = [
        (0.68, 0.58, textMuted),
        (0.54, 0.62, textLight),
        (0.40, 0.48, textLight),
        (0.26, 0.54, textMuted),
    ]

    for item in lines {
        let rect = NSRect(
            x: lineLeft,
            y: card.minY + card.height * item.yFrac - lineH / 2,
            width: card.width * item.wFrac,
            height: lineH
        )
        let p = NSBezierPath(roundedRect: rect, xRadius: lineH / 2, yRadius: lineH / 2)
        item.color.setFill()
        p.fill()
    }

    let guideY = card.minY + card.height * 0.54
    let guideRect = NSRect(
        x: card.minX + card.width * 0.08,
        y: guideY - max(1.0, size * 0.011),
        width: card.width * 0.84,
        height: max(2.0, size * 0.022)
    )
    accent.withAlphaComponent(0.35).setFill()
    NSBezierPath(rect: guideRect).fill()

    let triSize = size * 0.12
    let triX = card.minX + card.width * 0.11
    let triPath = NSBezierPath()
    triPath.move(to: NSPoint(x: triX, y: guideY + triSize * 0.55))
    triPath.line(to: NSPoint(x: triX + triSize * 0.85, y: guideY))
    triPath.line(to: NSPoint(x: triX, y: guideY - triSize * 0.55))
    triPath.close()
    accent.setFill()
    triPath.fill()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

func renderIcon(px: Int) -> Data? {
    if let cgSource = sourceCGImage {
        return renderImageIcon(px: px, cgSource: cgSource)
    }
    return renderFallbackIcon(px: px)
}

func appendUInt32BE(_ data: inout Data, _ value: UInt32) {
    var big = value.bigEndian
    withUnsafeBytes(of: &big) { data.append(contentsOf: $0) }
}

var cache: [Int: Data] = [:]
var body = Data()

for spec in specs {
    let pngData: Data
    if let existing = cache[spec.px] {
        pngData = existing
    } else {
        guard let rendered = renderIcon(px: spec.px) else {
            fputs("Failed to render \(spec.px)px icon\n", stderr)
            exit(1)
        }
        cache[spec.px] = rendered
        pngData = rendered
    }
    body.append(spec.type.data(using: .ascii)!)
    appendUInt32BE(&body, UInt32(8 + pngData.count))
    body.append(pngData)
}

var icns = Data("icns".utf8)
appendUInt32BE(&icns, UInt32(8 + body.count))
icns.append(body)

try icns.write(to: outputURL)
