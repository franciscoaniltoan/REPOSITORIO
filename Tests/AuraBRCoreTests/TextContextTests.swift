import XCTest
@testable import AuraBRCore

final class TextContextTests: XCTestCase {
    func testUnicodeWordExtraction() {
        XCTAssertEqual(AuraInputContext.currentWord(in: "Oi, você"), "você")
        XCTAssertEqual(AuraInputContext.currentWord(in: "Atenção: não"), "não")
        XCTAssertEqual(AuraInputContext.currentWord(in: "d'água"), "d'água")
        XCTAssertEqual(AuraInputContext.currentWord(in: "🍓 na"), "na")
        XCTAssertEqual(AuraInputContext.currentWord(in: "bom dia!"), "")
        XCTAssertEqual(AuraInputContext.currentWord(in: "Olá "), "")
        XCTAssertEqual(AuraInputContext.currentWord(in: ""), "")
    }

    func testAccentInsensitiveOfflineSuggestions() {
        XCTAssertTrue(AuraInputContext.suggestions(for: "Eu na").contains("não"))
        XCTAssertTrue(AuraInputContext.suggestions(for: "Oi, vo").contains("você"))
        XCTAssertEqual(AuraInputContext.suggestions(for: "Oi!"), [])
        XCTAssertEqual(AuraInputContext.suggestions(for: "abc123xyz"), [])
        XCTAssertEqual(AuraInputContext.suggestions(for: "Eu na", maxResults: 0), [])
    }

    func testCapitalizationPreservesPortugueseAccents() {
        XCTAssertEqual(AuraInputContext.matchCapitalization(of: "não", to: "Na"), "Não")
        XCTAssertEqual(AuraInputContext.matchCapitalization(of: "não", to: "NA"), "NÃO")
        XCTAssertEqual(AuraInputContext.matchCapitalization(of: "você", to: "vo"), "você")
        XCTAssertEqual(AuraInputContext.matchCapitalization(of: "olá", to: "Ol"), "Olá")
    }
}
