import XCTest
@testable import AuraBRCore

final class ThemeTests: XCTestCase {
    func testCatalogMatchesAndroidThemeIDs() {
        XCTAssertEqual(AuraCatalog.themes.count, 23)
        XCTAssertEqual(AuraCatalog.themes.filter { $0.category == .fruits }.map(\.name),
                       ["Banana", "Melancia", "Morango", "Kiwi", "Uva"])
        XCTAssertEqual(AuraCatalog.themes.filter { $0.category == .gemstones }.count, 6)
    }

    func testApprovedFruitPalettesRemainDistinct() {
        let water = AuraCatalog.palette(for: "fruit-melancia", appearance: .glass)
        let berry = AuraCatalog.palette(for: "fruit-morango", appearance: .glass)
        XCTAssertEqual(water.background.hex, "#F3ECE6")
        XCTAssertEqual(water.action.hex, "#84A76E")
        XCTAssertEqual(berry.background.hex, "#F7E7EC")
        XCTAssertEqual(berry.key.hex, "#F0B9C9")
        XCTAssertEqual(berry.action.hex, "#B69288")
        XCTAssertNotEqual(water.action, berry.action)
    }

    func testLimeGlassMatchesApprovedAndroidReference() {
        let leaf = AuraCatalog.palette(for: "limao", appearance: .glass)
        XCTAssertEqual(leaf.background.hex, "#E1F5D6")
        XCTAssertEqual(leaf.backgroundStart.hex, "#E5F6D2")
        XCTAssertEqual(leaf.backgroundEnd.hex, "#DCF4D9")
        XCTAssertEqual(leaf.key.hex, "#F3FAF0")
        XCTAssertEqual(leaf.action.hex, "#BCEE84")
        XCTAssertEqual(leaf.ink.hex, "#252D20")
    }

    func testEveryThemeCanResolveAllAppearances() {
        for theme in AuraCatalog.themes {
            for appearance in AuraAppearance.allCases {
                let palette = AuraCatalog.palette(for:theme.id, appearance:appearance)
                XCTAssertTrue(palette.background.hex.hasPrefix("#"))
                XCTAssertEqual(palette.background.hex.count,7)
            }
        }
    }

    func testOfflineSuggestionsAccentInsensitive() {
        XCTAssertTrue(AuraOfflineSuggestions.suggest(prefix: "na").contains("não"))
        XCTAssertEqual(AuraOfflineSuggestions.suggest(prefix: "xyz"), [])
        XCTAssertTrue(AuraOfflineSuggestions.suggest(prefix: "vi", maxResults: 0).isEmpty)
    }
}
