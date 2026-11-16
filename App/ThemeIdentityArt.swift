import SwiftUI

/// Reuses the exact approved transparent fruit icons from AuraBR Android
/// v0.5.50. Other collections retain their placeholders until ported.
struct ThemeIdentityArt: View {
    let theme: AuraTheme

    var body: some View {
        Group {
            if let assetName = fruitAssetName {
                Image(assetName).resizable().scaledToFit()
            } else {
                Text(theme.emoji).font(.system(size: 31))
            }
        }
        .accessibilityLabel(Text(theme.name))
    }

    private var fruitAssetName: String? {
        switch theme.id {
        case "fruit-banana": return "aurabr_fruit_banana_color"
        case "fruit-melancia": return "aurabr_fruit_watermelon_color"
        case "fruit-morango": return "aurabr_fruit_strawberry_color"
        case "fruit-kiwi": return "aurabr_fruit_kiwi_color"
        case "fruit-uva": return "aurabr_fruit_grapes_color"
        default: return nil
        }
    }
}
