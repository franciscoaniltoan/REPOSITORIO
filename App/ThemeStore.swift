import SwiftUI

/// The containing app writes theme preferences. The keyboard extension only
/// reads from the shared App Group. No network or Full Access is required.
@MainActor final class AuraThemeStore: ObservableObject {
    static let suite = "group.com.aurabr.ios"
    static let keyTheme = "aurabr.selectedThemeID"
    static let keyAppearance = "aurabr.appearance"

    @Published var selectedThemeID: String {
        didSet { persist() }
    }
    @Published var appearance: AuraAppearance {
        didSet { persist() }
    }

    init() {
        let shared = UserDefaults(suiteName: Self.suite)
        let standard = UserDefaults.standard
        let themeID = shared?.string(forKey: Self.keyTheme) ?? standard.string(forKey: Self.keyTheme) ?? "fruit-morango"
        let raw = shared?.string(forKey: Self.keyAppearance) ?? standard.string(forKey: Self.keyAppearance) ?? AuraAppearance.light.rawValue
        selectedThemeID = AuraCatalog.theme(themeID).id
        appearance = AuraAppearance(rawValue: raw) ?? .light
    }

    var selectedTheme: AuraTheme { AuraCatalog.theme(selectedThemeID) }
    var selectedPalette: AuraPalette { AuraCatalog.palette(for:selectedThemeID, appearance:appearance) }

    private func persist() {
        for defaults in [UserDefaults(suiteName:Self.suite), UserDefaults.standard].compactMap({$0}) {
            defaults.set(selectedThemeID, forKey:Self.keyTheme)
            defaults.set(appearance.rawValue, forKey:Self.keyAppearance)
        }
    }
}
