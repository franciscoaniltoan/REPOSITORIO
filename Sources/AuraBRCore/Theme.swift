import Foundation

/// Portable AuraBR design tokens, based on Android 0.5.50 (not a port of Android UI code).
public struct RGBColor: Equatable, Hashable, Sendable, CustomStringConvertible {
    public let r: Int
    public let g: Int
    public let b: Int

    public init(hex: UInt32) {
        r = Int((hex >> 16) & 0xff)
        g = Int((hex >> 8) & 0xff)
        b = Int(hex & 0xff)
    }

    public init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        precondition(value.count == 6 && UInt32(value, radix: 16) != nil, "Invalid 6-digit RGB color")
        self.init(hex: UInt32(value, radix: 16)!)
    }

    public var hex: String { String(format: "#%02X%02X%02X", r, g, b) }
    public var description: String { hex }

    public func mixed(with other: RGBColor, weight: Double) -> RGBColor {
        let t = min(1, max(0, weight))
        func channel(_ a: Int, _ b: Int) -> Int {
            Int((Double(a) * (1 - t) + Double(b) * t).rounded())
        }
        return RGBColor(hex: UInt32((channel(r,other.r) << 16) |
                                     (channel(g,other.g) << 8) |
                                      channel(b,other.b)))
    }

    public var isDark: Bool { Double(r) * 0.21 + Double(g) * 0.72 + Double(b) * 0.07 < 140 }
}

public enum AuraAppearance: String, CaseIterable, Codable, Sendable {
    case light = "Claro"
    case glass = "Glass"
    case dark = "Escuro"
}

public enum AuraCategory: String, CaseIterable, Sendable {
    case pastels = "Clássicos e pastéis"
    case gemstones = "Pedras preciosas"
    case fruits = "Frutas"
}

public struct AuraPalette: Equatable, Sendable {
    public let background: RGBColor
    public let key: RGBColor
    public let action: RGBColor
    public let ink: RGBColor
    public let accent: RGBColor
    public let keyInk: RGBColor
    public let actionInk: RGBColor
    public let backgroundStart: RGBColor
    public let backgroundEnd: RGBColor
    public let glass: Bool

    public init(background: UInt32, key: UInt32, action: UInt32, ink: UInt32, accent: UInt32,
                keyInk: UInt32? = nil, actionInk: UInt32? = nil,
                backgroundStart: UInt32? = nil, backgroundEnd: UInt32? = nil, glass: Bool = false) {
        self.background = RGBColor(hex: background)
        self.key = RGBColor(hex: key)
        self.action = RGBColor(hex: action)
        self.ink = RGBColor(hex: ink)
        self.accent = RGBColor(hex: accent)
        self.keyInk = RGBColor(hex: keyInk ?? ink)
        self.actionInk = RGBColor(hex: actionInk ?? ink)
        self.backgroundStart = RGBColor(hex: backgroundStart ?? background)
        self.backgroundEnd = RGBColor(hex: backgroundEnd ?? background)
        self.glass = glass
    }
}

public struct AuraTheme: Equatable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let category: AuraCategory
    public let emoji: String
    public init(_ id: String, _ name: String, _ category: AuraCategory, _ emoji: String) {
        self.id = id
        self.name = name
        self.category = category
        self.emoji = emoji
    }
}

public enum AuraCatalog {
    /// Matches Android ThemePalette.OPTIONS, GEMSTONE_OPTIONS and FRUIT_OPTIONS IDs/order.
    public static let themes: [AuraTheme] = [
        .init("iphone-claro", "Clássico", .pastels, "⌨️"),
        .init("rosa", "Bebê", .pastels, "🌸"),
        .init("coral", "Coral", .pastels, "🐚"),
        .init("pessego", "Pêssego", .pastels, "🍑"),
        .init("amarelo", "Baunilha", .pastels, "🌼"),
        .init("limao", "Limão", .pastels, "🍃"),
        .init("verde", "Menta", .pastels, "🌿"),
        .init("azul", "Céu", .pastels, "☁️"),
        .init("azul-aqua", "Aqua", .pastels, "💧"),
        .init("lavanda", "Lavanda", .pastels, "🪻"),
        .init("lilas", "Lilás", .pastels, "💠"),
        .init("rosa-orquidea", "Orquídea", .pastels, "🌺"),
        .init("gem-rubi", "Rubi", .gemstones, "💎"),
        .init("gem-esmeralda", "Esmeralda", .gemstones, "💚"),
        .init("gem-safira", "Safira", .gemstones, "🔷"),
        .init("gem-obsidiana", "Obsidiana", .gemstones, "🖤"),
        .init("gem-quartzo-rosa", "Quartzo rosa", .gemstones, "🩷"),
        .init("gem-ametista", "Ametista", .gemstones, "🔮"),
        .init("fruit-banana", "Banana", .fruits, "🍌"),
        .init("fruit-melancia", "Melancia", .fruits, "🍉"),
        .init("fruit-morango", "Morango", .fruits, "🍓"),
        .init("fruit-kiwi", "Kiwi", .fruits, "🥝"),
        .init("fruit-uva", "Uva", .fruits, "🍇")
    ]

    public static func theme(_ id: String) -> AuraTheme {
        themes.first(where: { $0.id == id }) ?? themes[0]
    }

    public static func palette(for id: String, appearance: AuraAppearance) -> AuraPalette {
        let classic = lightPalette(id)
        switch appearance {
        case .light: return classic
        case .dark: return darkPalette(classic)
        case .glass: return glassPalette(id, original: classic)
        }
    }

    private static func lightPalette(_ id: String) -> AuraPalette {
        // Colors follow Android v0.5.50. For gem/fruit themes, key/action ink
        // may differ from the general text color to maintain contrast.
        switch id {
        case "iphone-claro": return .init(background: 0xD6D7DC,key:0xFFFFFF,action:0xB4BAC4,ink:0x1D1F25,accent:0x5E8EA2)
        case "rosa": return .init(background: 0xF9E9F1,key:0xFFFFFF,action:0xEBD0DB,ink:0x27222B,accent:0xBA7E9C)
        case "coral": return .init(background: 0xFFE8E4,key:0xFFFFFF,action:0xF3C2BA,ink:0x2A2427,accent:0xD67E77)
        case "pessego": return .init(background: 0xFFF0E6,key:0xFFFFFF,action:0xF4D3C2,ink:0x33282A,accent:0xD9A489)
        case "amarelo": return .init(background: 0xFFF8D9,key:0xFFFFFF,action:0xF2E6AE,ink:0x363125,accent:0xC7AA53)
        case "limao": return .init(background: 0xF6F9E2,key:0xFFFFFF,action:0xE2ECB7,ink:0x343828,accent:0xA3B976)
        case "verde": return .init(background: 0xE8F7ED,key:0xFFFFFF,action:0xC5E7D1,ink:0x233A2E,accent:0x73AE8B)
        case "azul": return .init(background: 0xE5F2FF,key:0xFFFFFF,action:0xC7E0F7,ink:0x263342,accent:0x7BABD2)
        case "azul-aqua": return .init(background: 0xE4F8F7,key:0xFFFFFF,action:0xBCE7E8,ink:0x21363A,accent:0x65BEC2)
        case "lavanda": return .init(background: 0xF2E5FA,key:0xFFFFFF,action:0xD9B9EF,ink:0x473054,accent:0xA47BC5)
        case "lilas": return .init(background: 0xEAF0FF,key:0xFFFFFF,action:0xC8D5F8,ink:0x2D3E60,accent:0x8198D1)
        case "rosa-orquidea": return .init(background: 0xFBE9F5,key:0xFFFFFF,action:0xF0CEE5,ink:0x402A3B,accent:0xC882AD)
        case "gem-rubi": return .init(background:0x820020,key:0xC86D83,action:0xAA0F3C,ink:0xFFECF2,accent:0xEFB2C2,keyInk:0x3E1021,actionInk:0xFFFFFF)
        case "gem-esmeralda": return .init(background:0x073E31,key:0x24B594,action:0x09634B,ink:0xE5FFF4,accent:0x68E7C4,keyInk:0x093B2C,actionInk:0xFFFFFF)
        case "gem-safira": return .init(background:0x08265B,key:0x347FD7,action:0x092F7B,ink:0xE9F2FF,accent:0x83BCFF,keyInk:0x041120,actionInk:0xFFFFFF)
        case "gem-obsidiana": return .init(background:0x191B20,key:0x535861,action:0x25272C,ink:0xF2F4F6,accent:0x90969E,keyInk:0xF5F6F9,actionInk:0xFFFFFF)
        case "gem-quartzo-rosa": return .init(background:0xFFE9E9,key:0xF4C8CF,action:0xE7A0A8,ink:0x56343D,accent:0xFFE9E6,keyInk:0x56343D,actionInk:0x59303B)
        case "gem-ametista": return .init(background:0xEDE3FB,key:0xFAF8FF,action:0x7B3FB6,ink:0x2D2542,accent:0xFFFFFF,keyInk:0x2D2542,actionInk:0xFFFFFF)
        case "fruit-banana": return .init(background:0xFFDE1B,key:0xFFF4C5,action:0xE1A614,ink:0x513219,accent:0xFFFFEA,keyInk:0x593A20,actionInk:0x563314)
        case "fruit-melancia": return .init(background:0xF3ECE6,key:0xE991A5,action:0x567C39,ink:0x32432C,accent:0xF7C4CD,keyInk:0x4F2932,actionInk:0xFFFFFF)
        case "fruit-morango": return .init(background:0xF7E7EC,key:0xE6AAB9,action:0x865D59,ink:0x4D3037,accent:0xF8CCD5,keyInk:0x492A35,actionInk:0xFFFFFF)
        case "fruit-kiwi": return .init(background:0xF4FAE8,key:0x91CD4B,action:0x815C3B,ink:0x34452B,accent:0xC2E977,keyInk:0x27431A,actionInk:0xFFFFFF)
        case "fruit-uva": return .init(background:0xF5E7FA,key:0x84279C,action:0x5A7C3C,ink:0x47394D,accent:0xAD50C3,keyInk:0xFFFFFF,actionInk:0xFFFFFF)
        default: return lightPalette("iphone-claro")
        }
    }

    private static func glassPalette(_ id: String, original: AuraPalette) -> AuraPalette {
        switch id {
        case "rosa": return .init(background:0xF5CFE0,key:0xFFF8FB,action:0xF2A6CB,ink:0x76314D,accent:0xD6679D,glass:true)
        case "coral": return .init(background:0xF1A695,key:0xFFF9F5,action:0xF07E6D,ink:0x592118,accent:0xE36955,glass:true)
        case "pessego": return .init(background:0xF6D3C0,key:0xFFFAF6,action:0xF0B091,ink:0x713A25,accent:0xDF9275,glass:true)
        case "amarelo": return .init(background:0xF8EBC1,key:0xFFFDF4,action:0xF6D576,ink:0x785617,accent:0xDAAC43,glass:true)
        case "limao": return .init(background:0xE1F5D6,key:0xF3FAF0,action:0xBCEE84,ink:0x252D20,accent:0x95CF43,
                                  backgroundStart:0xE5F6D2,backgroundEnd:0xDCF4D9,glass:true)
        case "verde": return .init(background:0xC6F4DB,key:0xF6FFFA,action:0x78DFB6,ink:0x215B47,accent:0x45B990,glass:true)
        case "azul-aqua": return .init(background:0xB6F3EF,key:0xF4FFFF,action:0x4FE1DB,ink:0x185867,accent:0x28BFC3,glass:true)
        case "lavanda": return .init(background:0xEAD4F5,key:0xFFF9FF,action:0xD2A3EA,ink:0x673881,accent:0xAB72CF,glass:true)
        case "lilas": return .init(background:0xDDE6FC,key:0xFAFCFF,action:0xA7BDF3,ink:0x344E82,accent:0x708EDA,glass:true)
        case "fruit-melancia": return .init(background:0xF3ECE6,key:0xF1A3B3,action:0x84A76E,ink:0x2B362A,accent:0xEE7786,glass:true)
        case "fruit-morango": return .init(background:0xF7E7EC,key:0xF0B9C9,action:0xB69288,ink:0x342027,accent:0xED829A,glass:true)
        default:
            // Same fallback as Android 0.5.50: source, background, normal,
            // special and ink blended from the original, preserving identity.
            let source = original.background.isDark ? original.background.mixed(with: original.key,weight:0.67) : original.background
            let background = source.mixed(with: original.accent,weight:0.19)
            let normal = original.key.mixed(with: RGBColor(hex:0xFFFFFF),weight:0.66)
            let action = original.action.mixed(with: original.accent,weight:0.32)
            let ink = original.background.isDark
                ? original.accent.mixed(with: RGBColor(hex:0x20232B),weight:0.63)
                : original.ink.mixed(with: original.accent,weight:0.18)
            return .init(background:background.rgb,key:normal.rgb,action:action.rgb,ink:ink.rgb,accent:original.accent.rgb,glass:true)
        }
    }

    private static func darkPalette(_ original: AuraPalette) -> AuraPalette {
        if original.background.isDark { return original }
        var hue = original.accent
        let spread = max(hue.r,max(hue.g,hue.b)) - min(hue.r,min(hue.g,hue.b))
        if spread < 37 && original.keyInk != original.ink { hue = original.action }
        let luminance = (hue.r * 21 + hue.g * 72 + hue.b * 7) / 100
        let normal = RGBColor(hex:0x343C47).mixed(with:hue,weight:luminance > 190 ? 0.26 : 0.36)
        let action = RGBColor(hex:0x242C37).mixed(with:hue,weight:0.30)
        let bg = RGBColor(hex:0x171D26).mixed(with:hue,weight:0.31)
        let accent = hue.mixed(with:RGBColor(hex:0xFFFFFF),weight:0.20)
        return .init(background:bg.rgb,key:normal.rgb,action:action.rgb,ink:0xF5F7FA,accent:accent.rgb,
                     keyInk:0xFFFFFF,actionInk:0xFFFFFF)
    }
}

public extension RGBColor {
    var rgb: UInt32 { UInt32((r << 16) | (g << 8) | b) }
}

/// Minimal offline suggestion engine scaffold; NOT equivalent to AuraBR Android
/// contextual autocorrection. Replace later with licensed PT-BR resources.
public enum AuraOfflineSuggestions {
    public static let words: [String] = [
        "a","agora","ainda","amor","amigo","até","aura","aqui","assim",
        "boa","bom","boa noite","brasil","casa","cidade","como","com","conversa",
        "de","dia","do","dizer","ela","ele","em","então","está","estar",
        "eu","faz","fazer","feliz","hoje","isso","já","legal","mais","muito",
        "não","nós","obrigado","oi","olá","para","por","porque","pode",
        "qual","quando","que","quer","sim","se","sem","sua","seu",
        "teclado","tema","tudo","uma","você","vocês","vamos","verde"
    ]

    public static func suggest(prefix: String, maxResults: Int = 3) -> [String] {
        let query = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier:"pt_BR"))
        if query.isEmpty { return [] }
        return words.filter { word in
            word.folding(options:[.caseInsensitive,.diacriticInsensitive], locale:Locale(identifier:"pt_BR"))
                .hasPrefix(query)
        }.prefix(max(0,maxResults)).map { $0 }
    }
}
