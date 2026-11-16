import Foundation

/// Sentence-start capitalization for an offline keyboard. Input is only the
/// short context exposed by the current text field, never stored or logged.
public enum AuraSentenceRules {
    public static func shouldCapitalize(after text: String) -> Bool {
        var remaining = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if remaining.isEmpty { return true }
        // Ignore closing punctuation after the terminator: Olá!" → capital.
        while let last = remaining.last,
              ["\u{0022}", "'", "’", "”", ")", "]", "}"].contains(String(last)) {
            remaining.removeLast()
        }
        guard let last = remaining.last else { return true }
        return last == "." || last == "!" || last == "?" || last == "…" || last == "\n"
    }
}
