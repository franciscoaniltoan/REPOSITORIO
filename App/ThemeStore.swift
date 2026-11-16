import SwiftUI

/// The containing app writes theme preferences to the shared App Group.
/// The keyboard extension only reads them; no Full Access is needed.
@MainActor final class AuraThemeStore: ObservableObject {
    static let suite = AuraSharedThemeSettings.suiteName
    static let keyTheme = AuraSharedThemeSettings.themeKey
    static let keyAppearance = AuraSharedThemeSettings.appearanceKey

    @Published var selectedThemeID: String {
        didSet { persist() }
    }
    @Published var appearance: AuraAppearance {
        didSet { persist() }
    }

    init() {
        let group = Self.sharedDefaults()
        let restored = AuraSharedThemeSettings.read(shared: group, fallback: .standard)
        selectedThemeID = restored.themeID
        appearance = restored.appearance
        // The property observers do not run during init. Bootstrap the
        // read-only keyboard's group from older app-only preferences.
        AuraSharedThemeSettings.save(restored, shared: group, fallback: .standard)
    }

    var selectedTheme: AuraTheme { AuraCatalog.theme(selectedThemeID) }
    var selectedPalette: AuraPalette {
        AuraCatalog.palette(for: selectedThemeID, appearance: appearance)
    }

    private static func sharedDefaults() -> UserDefaults? {
        #if AURABR_FREE_PERSONAL
        // Free development profiles cannot reliably provision an App Group.
        return nil
        #else
        return UserDefaults(suiteName: suite)
        #endif
    }

    private func persist() {
        AuraSharedThemeSettings.save(
            .init(themeID: selectedThemeID, appearance: appearance),
            shared: Self.sharedDefaults(),
            fallback: .standard
        )
    }
}
