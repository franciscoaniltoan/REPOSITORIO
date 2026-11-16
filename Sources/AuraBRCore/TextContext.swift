import Foundation

/// Text helpers operate only on the limited context supplied by UITextDocumentProxy.
/// No text is persisted, logged or transmitted.
public enum AuraInputContext {
    public static func currentWord(in context: String) -> String {
        var reversedWord: [Character] = []
        for character in context.reversed() {
            if character.isLetter || character.isNumber || character == "'" || character == "’" {
                reversedWord.append(character)
            } else {
                break
            }
        }
        return String(reversedWord.reversed())
    }

    public static func suggestions(for context: String, maxResults: Int = 3) -> [String] {
        AuraOfflineSuggestions.suggest(prefix: currentWord(in: context), maxResults: maxResults)
    }

    public static func matchCapitalization(of suggestion: String, to prefix: String) -> String {
        guard !prefix.isEmpty else { return suggestion }
        let first = String(prefix.prefix(1))
        guard first.uppercased() == first && first.lowercased() != first else { return suggestion }
        let remaining = String(prefix.dropFirst())
        if !remaining.isEmpty && remaining.uppercased() == remaining && remaining.lowercased() != remaining {
            return suggestion.uppercased()
        }
        return String(suggestion.prefix(1)).uppercased() + suggestion.dropFirst()
    }
}
