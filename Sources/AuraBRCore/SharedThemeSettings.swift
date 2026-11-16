import Foundation

/// Shared preference keys and validation used by both iOS targets.
/// The containing app writes; the restricted keyboard extension only reads.
public enum AuraSharedThemeSettings {
    public static let suiteName = "group.com.aurabr.ios"
    public static let themeKey = "aurabr.selectedThemeID"
    public static let appearanceKey = "aurabr.appearance"
    public static let defaultThemeID = "fruit-morango"

    public struct Selection: Equatable, Sendable {
        public let themeID: String
        public let appearance: AuraAppearance

        public init(themeID: String, appearance: AuraAppearance) {
            self.themeID = AuraCatalog.themes.contains { $0.id == themeID }
                ? themeID : AuraSharedThemeSettings.defaultThemeID
            self.appearance = appearance
        }
    }

    /// The extension supplies only group defaults. The containing app can
    /// provide standard defaults to migrate preferences from an older build.
    public static func read(shared: UserDefaults?, fallback: UserDefaults? = nil) -> Selection {
        let rawTheme = shared?.string(forKey: themeKey)
            ?? fallback?.string(forKey: themeKey)
            ?? defaultThemeID
        let rawAppearance = shared?.string(forKey: appearanceKey)
            ?? fallback?.string(forKey: appearanceKey)
            ?? AuraAppearance.light.rawValue
        return Selection(themeID: rawTheme,
                         appearance: AuraAppearance(rawValue: rawAppearance) ?? .light)
    }

    /// Use only in the containing app; never from the keyboard extension.
    public static func save(_ selection: Selection, shared: UserDefaults?, fallback: UserDefaults? = nil) {
        for defaults in [shared, fallback].compactMap({ $0 }) {
            defaults.set(selection.themeID, forKey: themeKey)
            defaults.set(selection.appearance.rawValue, forKey: appearanceKey)
        }
    }
}
