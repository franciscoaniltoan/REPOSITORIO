import UIKit

/// Native iOS custom keyboard (UITextDocumentProxy), independent of the
/// Android InputMethodService. No logging, network access, or clipboard reads.
final class AuraKeyboardViewController: UIInputViewController {
    private enum Page { case letters, numbers, symbols, emoji }
    private var page: Page = .letters
    private var shifted = true
    private var keyboardHeight: NSLayoutConstraint?
    private let gradient = CAGradientLayer()
    private let stack = UIStackView()
    private let suggestions = UIStackView()
    private var palette = AuraCatalog.palette(for: "fruit-morango", appearance: .light)
    private var lastRenderedTheme = ""
    private var lastRenderedAppearance = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        view.layer.insertSublayer(gradient, at: 0)
        keyboardHeight = view.heightAnchor.constraint(equalToConstant: 278)
        keyboardHeight?.priority = UILayoutPriority(999)
        keyboardHeight?.isActive = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -7)
        ])
        loadTheme()
        renderKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTheme()
        renderKeyboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        let compact = view.bounds.width > view.bounds.height * 2.1
        let target: CGFloat = compact ? 224 : 278
        if abs((keyboardHeight?.constant ?? 0) - target) > 0.5 {
            keyboardHeight?.constant = target
        }
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        let previous = (lastRenderedTheme,lastRenderedAppearance)
        loadTheme()
        if previous.0 != lastRenderedTheme || previous.1 != lastRenderedAppearance {
            renderKeyboard()
        } else {
            updateSuggestions()
        }
    }

    private func loadTheme() {
        // Shared configuration is read-only; if iOS denies access in a
        // restricted keyboard sandbox, a safe bundled palette remains usable.
        let defaults = UserDefaults(suiteName: "group.com.aurabr.ios")
        let id = defaults?.string(forKey: "aurabr.selectedThemeID") ?? "fruit-morango"
        let raw = defaults?.string(forKey: "aurabr.appearance") ?? "Claro"
        palette = AuraCatalog.palette(for: id, appearance: AuraAppearance(rawValue: raw) ?? .light)
        lastRenderedTheme = id
        lastRenderedAppearance = raw
        gradient.colors = [UIColor(rgb: palette.backgroundStart).cgColor,
                           UIColor(rgb: palette.backgroundEnd).cgColor]
    }

    private func renderKeyboard() {
        stack.arrangedSubviews.forEach { v in stack.removeArrangedSubview(v); v.removeFromSuperview() }
        addSuggestionStrip()
        switch page {
        case .letters:
            addRow("qwertyuiop".map(String.init))
            addRow("asdfghjkl".map(String.init), inset: 11)
            addRow(["⇧"] + "zxcvbnm".map(String.init) + ["⌫"])
            addRow(["123", "☺", "globe", "espaço", "↵"], bottom: true)
        case .numbers:
            addRow("1234567890".map(String.init))
            addRow(["@", "#", "$", "%", "&", "-", "+", "(", ")"])
            addRow(["=\\<", "*", "\"", "'", ":", ";", "!", "?", "⌫"])
            addRow(["ABC", "#+=", "globe", "espaço", "↵"], bottom: true)
        case .symbols:
            addRow(["[", "]", "{", "}", "<", ">", "^", "~", "|"])
            addRow(["\\", "/", "_", "€", "£", "¥", "•", "…"])
            addRow(["123", "§", "±", "÷", "×", "≠", "≈", "⌫"])
            addRow(["ABC", "123", "globe", "espaço", "↵"], bottom: true)
        case .emoji:
            let emojis = ["😀","😂","🥰","😍","😊","😭","❤️","🔥",
                          "👍","🙏","🎉","🍓","🍉","🍌","🍃","💚",
                          "😎","😉","😴","🤔","👏","💜","✨","✅"]
            for start in stride(from: 0, to: emojis.count, by: 8) {
                addRow(Array(emojis[start ..< min(start+8,emojis.count)]))
            }
            addRow(["ABC", "123", "globe", "espaço", "⌫"], bottom: true)
        }
    }

    private func addSuggestionStrip() {
        suggestions.arrangedSubviews.forEach { v in suggestions.removeArrangedSubview(v); v.removeFromSuperview() }
        suggestions.axis = .horizontal
        suggestions.spacing = 3
        suggestions.distribution = .fillEqually
        stack.addArrangedSubview(suggestions)
        suggestions.heightAnchor.constraint(equalToConstant: 33).isActive = true
        updateSuggestions()
    }

    private func updateSuggestions() {
        let current = textDocumentProxy.documentContextBeforeInput ?? ""
        let prefix = String(current.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).last ?? "")
        let completions = AuraOfflineSuggestions.suggest(prefix: prefix)
        suggestions.arrangedSubviews.forEach { v in suggestions.removeArrangedSubview(v); v.removeFromSuperview() }
        for (index,text) in (0..<3).map({ completions.indices.contains($0) ? completions[$0] : "" }).enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.setTitleColor(UIColor(rgb: palette.ink), for: .normal)
            button.accessibilityLabel = text.isEmpty ? "Sem sugestão" : "Sugestão: \(text)"
            button.isEnabled = !text.isEmpty
            button.tag = index
            button.addTarget(self, action: #selector(selectSuggestion(_:)), for: .touchUpInside)
            suggestions.addArrangedSubview(button)
        }
    }

    private func addRow(_ tokens: [String], inset: CGFloat = 0, bottom: Bool = false) {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fill
        row.spacing = 4
        stack.addArrangedSubview(row)
        row.heightAnchor.constraint(equalToConstant: 43).isActive = true
        if inset > 0 { row.layoutMargins = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset); row.isLayoutMarginsRelativeArrangement = true }
        for token in tokens {
            let button = makeKey(token)
            row.addArrangedSubview(button)
            let weight: CGFloat = token == "espaço" ? 4.3 : (bottom ? (token == "globe" ? 0.9 : 1.3) : (token == "⇧" || token == "⌫" ? 1.28 : 1))
            // A single proportional constraint per pair keeps rows responsive.
            if let reference = row.arrangedSubviews.first, reference !== button {
                let referenceToken = (reference as? UIButton)?.accessibilityIdentifier ?? ""
                let referenceWeight: CGFloat = referenceToken == "espaço" ? 4.3 : (bottom ? (referenceToken == "globe" ? 0.9 : 1.3) : (referenceToken == "⇧" || referenceToken == "⌫" ? 1.28 : 1))
                button.widthAnchor.constraint(equalTo: reference.widthAnchor, multiplier: weight / referenceWeight).isActive = true
            }
        }
    }

    private func makeKey(_ token: String) -> UIButton {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = token
        button.accessibilityLabel = token == "globe" ? "Próximo teclado" : (token == "espaço" ? "Espaço" : token)
        let title = token == "globe" ? "🌐" : (token == "espaço" ? "PT BR" : (page == .letters && token.count == 1 && shifted ? token.uppercased() : token))
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: token == "espaço" ? 12 : 20, weight: .medium)
        let actionKey = ["⇧","⌫","123","ABC","☺","#+=","=\\<","↵","globe"].contains(token)
        button.backgroundColor = UIColor(rgb: actionKey ? palette.action : palette.key).withAlphaComponent(palette.glass ? (actionKey ? 0.86 : 0.83) : 1)
        button.setTitleColor(UIColor(rgb: actionKey ? palette.actionInk : palette.keyInk), for: .normal)
        button.layer.cornerRadius = 9
        button.layer.borderWidth = 0.65
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        button.layer.shadowColor = UIColor(rgb: palette.ink).withAlphaComponent(0.12).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.45
        button.addTarget(self, action: #selector(pressKey(_:)), for: .touchUpInside)
        return button
    }

    @objc private func pressKey(_ sender: UIButton) {
        let token = sender.accessibilityIdentifier ?? ""
        switch token {
        case "globe": advanceToNextInputMode(); return
        case "⇧": shifted.toggle(); renderKeyboard(); return
        case "⌫": textDocumentProxy.deleteBackward()
        case "↵": textDocumentProxy.insertText("\n")
        case "espaço": textDocumentProxy.insertText(" ")
        case "123": page = .numbers; renderKeyboard(); return
        case "ABC": page = .letters; renderKeyboard(); return
        case "#+=", "=\\<": page = page == .symbols ? .numbers : .symbols; renderKeyboard(); return
        case "☺": page = .emoji; renderKeyboard(); return
        default:
            textDocumentProxy.insertText(page == .letters && !shifted ? token : (page == .letters ? token.uppercased() : token))
            if page == .letters && shifted { shifted = false; renderKeyboard() }
        }
        updateSuggestions()
    }

    @objc private func selectSuggestion(_ sender: UIButton) {
        guard let choice = sender.title(for: .normal), !choice.isEmpty else { return }
        let current = textDocumentProxy.documentContextBeforeInput ?? ""
        let last = String(current.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).last ?? "")
        for _ in last { textDocumentProxy.deleteBackward() }
        textDocumentProxy.insertText(choice + " ")
        updateSuggestions()
    }
}

private extension UIColor {
    convenience init(rgb: RGBColor) {
        self.init(red: CGFloat(rgb.r)/255, green: CGFloat(rgb.g)/255, blue: CGFloat(rgb.b)/255, alpha: 1)
    }
}
