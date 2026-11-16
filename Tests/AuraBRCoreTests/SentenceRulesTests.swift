import XCTest
@testable import AuraBRCore

final class SentenceRulesTests: XCTestCase {
    func testStartAndAfterPunctuation() {
        for text in ["", " ", "\n", "Olá. ", "Tudo bem? ", "Bom!", "Uau…", "Olá!\" "] {
            XCTAssertTrue(AuraSentenceRules.shouldCapitalize(after: text), text)
        }
    }

    func testDoesNotForceCapitalMidSentence() {
        for text in ["Oi", "Olá, ", "Tudo bem", "foi: ", "e aí", "123 "] {
            XCTAssertFalse(AuraSentenceRules.shouldCapitalize(after: text), text)
        }
    }
}
