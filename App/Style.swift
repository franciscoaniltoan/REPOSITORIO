import SwiftUI

extension Color {
    init(rgb: RGBColor) {
        self.init(.sRGB, red:Double(rgb.r)/255, green:Double(rgb.g)/255, blue:Double(rgb.b)/255, opacity:1)
    }
}

enum AuraStyle {
    static let background = Color(red:246/255, green:247/255, blue:250/255)
    static let text = Color(red:31/255, green:34/255, blue:42/255)
    static let secondary = Color(red:119/255, green:121/255, blue:130/255)
    static let accent = Color(red:0, green:143/255, blue:130/255)
    static let selectedBorder = Color(red:129/255, green:148/255, blue:176/255)
}
