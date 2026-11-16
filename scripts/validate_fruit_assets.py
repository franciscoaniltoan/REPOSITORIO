"""Check that AuraBR iOS reuses the approved Android PNGs without edits."""
from pathlib import Path
import hashlib
import json
import struct

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "App" / "Assets.xcassets"
VIEW = (ROOT / "App" / "ThemeIdentityArt.swift").read_text(encoding="utf-8")
ASSETS = {
    "banana": ("aurabr_fruit_banana_color", "f9853bf2c22543343c1f962788921f06878c4bea"),
    "melancia": ("aurabr_fruit_watermelon_color", "72cf72be4db299b9ee333e28b5662fd741b14607"),
    "morango": ("aurabr_fruit_strawberry_color", "84d5ba3b64e861bb907bed12c0248900d7acd4c9"),
    "kiwi": ("aurabr_fruit_kiwi_color", "c0fbacb93c68bd6a40756a263407af0824706bbe"),
    "uva": ("aurabr_fruit_grapes_color", "d78129d635fc8e9d37581138014cc8bd23f27211"),
}

for fruit, (asset, sha) in ASSETS.items():
    folder = ART / (asset + ".imageset")
    png = folder / (asset + ".png")
    payload = png.read_bytes()
    assert payload[:8] == b"\x89PNG\r\n\x1a\n", f"Not PNG: {png}"
    width, height = struct.unpack(">II", payload[16:24])
    assert (width, height) == (128, 128), f"Unexpected dimensions: {fruit} {(width,height)}"
    blob = hashlib.sha1(f"blob {len(payload)}\0".encode("ascii") + payload).hexdigest()
    assert blob == sha, f"Approved artwork modified: {fruit}"
    manifest = json.loads((folder / "Contents.json").read_text(encoding="utf-8"))
    assert any(image.get("filename") == png.name for image in manifest["images"])
    assert f'case "fruit-{fruit}": return "{asset}"' in VIEW
assert "ThemeIdentityArt(theme: theme)" in (ROOT / "App" / "ThemeGalleryView.swift").read_text()
assert "ThemeIdentityArt(theme: store.selectedTheme)" in (ROOT / "App" / "ContentView.swift").read_text()
print("5 artes originais, metadados iOS e uso no app validados")
