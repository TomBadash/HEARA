import SwiftUI
import UIKit

enum Appearance {
    static let colors = ["automatic", "forest", "blue", "purple", "orange", "rose"]
    static let fonts = ["default", "serif", "rounded", "monospaced"]
    static func color(_ name: String) -> Color {
        if name.hasPrefix("#"), name.count == 7, let value = UInt32(name.dropFirst(), radix: 16) {
            return Color(red: Double((value >> 16) & 255) / 255, green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255)
        }
        switch name {
        case "forest": return Color(red: 0.12, green: 0.40, blue: 0.27)
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return Color(red: 0.65, green: 0.30, blue: 0.05)
        case "rose": return Color(red: 0.70, green: 0.18, blue: 0.33)
        default: return .primary
        }
    }
    static func hex(_ color: Color) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return "#26734D" }
        return String(format: "#%02X%02X%02X", Int((red * 255).rounded()), Int((green * 255).rounded()), Int((blue * 255).rounded()))
    }
    static func design(_ name: String) -> Font.Design {
        switch name {
        case "serif": return .serif
        case "rounded": return .rounded
        case "monospaced": return .monospaced
        default: return .default
        }
    }
}
