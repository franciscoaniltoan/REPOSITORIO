import Foundation
import XCTest
@testable import AuraBRCore

final class SharedThemeSettingsTests: XCTestCase {
    private func tempDefaults() -> UserDefaults {
        let id = "aurabr.tests." + UUID().uuidString
        return UserDefaults(suiteName: id)!
    }

    func testDefaultIsApprovedStrawberryAndLight() {
        let result = AuraSharedThemeSettings.read(shared: nil)
        XCTAssertEqual(result.themeID, "fruit-morango")
        XCTAssertEqual(result.appearance, .light)
    }

    func testRoundTripAcrossAllThemesAndModes() {
        let defaults = tempDefaults()
        for theme in AuraCatalog.themes {
            for mode in AuraAppearance.allCases {
                let value = AuraSharedThemeSettings.Selection(themeID: theme.id, appearance: mode)
                AuraSharedThemeSettings.save(value, shared: defaults)
                XCTAssertEqual(AuraSharedThemeSettings.read(shared: defaults), value)
            }
        }
    }

    func testRestoresOlderStandardPreferencesIntoSharedGroup() {
        let shared = tempDefaults()
        let legacy = tempDefaults()
        legacy.set("fruit-melancia", forKey: AuraSharedThemeSettings.themeKey)
        legacy.set("Glass", forKey: AuraSharedThemeSettings.appearanceKey)
        let recovered = AuraSharedThemeSettings.read(shared: shared, fallback: legacy)
        XCTAssertEqual(recovered.themeID, "fruit-melancia")
        XCTAssertEqual(recovered.appearance, .glass)
        AuraSharedThemeSettings.save(recovered, shared: shared, fallback: legacy)
        XCTAssertEqual(AuraSharedThemeSettings.read(shared: shared), recovered)
    }

    func testUnknownPreferenceValuesFallBackSafely() {
        let defaults = tempDefaults()
        defaults.set("not-real", forKey: AuraSharedThemeSettings.themeKey)
        defaults.set("invalid", forKey: AuraSharedThemeSettings.appearanceKey)
        let actual = AuraSharedThemeSettings.read(shared: defaults)
        XCTAssertEqual(actual.themeID, "fruit-morango")
        XCTAssertEqual(actual.appearance, .light)
    }

    func testNoSharedContainerStillReadsLegacyForApp() {
        let legacy = tempDefaults()
        legacy.set("limao", forKey: AuraSharedThemeSettings.themeKey)
        legacy.set("Escuro", forKey: AuraSharedThemeSettings.appearanceKey)
        let actual = AuraSharedThemeSettings.read(shared: nil, fallback: legacy)
        XCTAssertEqual(actual.themeID, "limao")
        XCTAssertEqual(actual.appearance, .dark)
    }
}
