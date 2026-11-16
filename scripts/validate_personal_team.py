#!/usr/bin/env python3
"""Static guards for the free Apple Personal Team development configuration."""
from pathlib import Path
import plistlib

root = Path(__file__).resolve().parents[1]
spec = (root / "project-free.yml").read_text(encoding="utf-8")
normal = (root / "project.yml").read_text(encoding="utf-8")
app = (root / "App/ThemeStore.swift").read_text(encoding="utf-8")
keyboard = (root / "KeyboardExtension/AuraKeyboardViewController.swift").read_text(encoding="utf-8")
settings = (root / "App/ContentView.swift").read_text(encoding="utf-8")
keyboard_info = plistlib.loads((root / "KeyboardExtension/Info.plist").read_bytes())

assert "name: AuraBRiOSFree" in spec
assert "PRODUCT_BUNDLE_IDENTIFIER: com.aurabr.ios.free" in spec
assert "PRODUCT_BUNDLE_IDENTIFIER: com.aurabr.ios.free.keyboard" in spec
assert spec.count("AURABR_FREE_PERSONAL") == 2
assert "CODE_SIGN_ENTITLEMENTS" not in spec, "Free profiles must not include App Group entitlements"
assert "App/AuraBR.entitlements" in normal and "KeyboardExtension/AuraKeyboard.entitlements" in normal, "Keep paid/full configuration unchanged"
assert "AURABR_FREE_PERSONAL" in app and "return nil" in app
assert "AURABR_FREE_PERSONAL" in keyboard
for marker in ("nextFreeTheme", "nextFreeAppearance", "freeThemeID", "freeAppearance", 'setTitle("🎨"', 'setTitle("◐"'):
    assert marker in keyboard, marker
assert "AURABR_FREE_PERSONAL" in settings
attributes = keyboard_info["NSExtension"]["NSExtensionAttributes"]
assert attributes["RequestsOpenAccess"] is False
assert keyboard_info["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.keyboard-service"
print("Modo gratuito validado: sem App Groups no profile, modo local no teclado e rede desativada.")
