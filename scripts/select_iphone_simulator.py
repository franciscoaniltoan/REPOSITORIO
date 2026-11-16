#!/usr/bin/env python3
"""Select an available iPhone simulator UDID from xcrun simctl JSON."""
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
matches = []
for runtime, devices in data.get("devices", {}).items():
    for item in devices:
        if item.get("isAvailable") and "iPhone" in item.get("name", ""):
            matches.append((runtime, item["udid"], item["name"]))

if not matches:
    raise SystemExit("No available iPhone simulator is installed on this runner")
matches.sort(reverse=True)
print(matches[0][1])
