#!/usr/bin/env python3
"""Write a simple calculator app icon as PNG files (no third-party deps)."""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ICON_DIR = ROOT / "IPadCalculator" / "Assets.xcassets" / "AppIcon.appiconset"

SIZES = [20, 29, 40, 58, 76, 80, 87, 152, 167, 1024]


def png_chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def write_png(path: Path, size: int, rgba_rows: list[bytes]) -> None:
    raw = b"".join(b"\x00" + row for row in rgba_rows)
    ihdr = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n"
    png += png_chunk(b"IHDR", ihdr)
    png += png_chunk(b"IDAT", zlib.compress(raw, 9))
    png += png_chunk(b"IEND", b"")
    path.write_bytes(png)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def color_at(x: int, y: int, size: int) -> tuple[int, int, int, int]:
    nx = x / (size - 1)
    ny = y / (size - 1)
    bg = (18, 18, 22)
    orange = (242, 153, 46)

    def rect(x0: float, y0: float, x1: float, y1: float, radius: float) -> bool:
        px, py = nx, ny
        if x0 + radius <= px <= x1 - radius and y0 <= py <= y1:
            return True
        if y0 + radius <= py <= y1 - radius and x0 <= px <= x1:
            return True
        corners = [
            (x0 + radius, y0 + radius),
            (x1 - radius, y0 + radius),
            (x0 + radius, y1 - radius),
            (x1 - radius, y1 - radius),
        ]
        return any((px - cx) ** 2 + (py - cy) ** 2 <= radius ** 2 for cx, cy in corners)

    # Dark rounded square
    if not rect(0.08, 0.08, 0.92, 0.92, 0.16):
        return (0, 0, 0, 0)

    # Display band
    if rect(0.18, 0.18, 0.82, 0.38, 0.04):
        shade = int(lerp(40, 70, nx))
        return (shade, shade, shade + 8, 255)

    # Four keypad dots
    centers = [(0.32, 0.55), (0.68, 0.55), (0.32, 0.75), (0.68, 0.75)]
    for i, (cx, cy) in enumerate(centers):
        dx, dy = nx - cx, ny - cy
        if dx * dx + dy * dy <= 0.07 * 0.07:
            if i == 3:
                return (*orange, 255)
            return (70, 70, 76, 255)

    return (*bg, 255)


def main() -> None:
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    for size in SIZES:
        rows = []
        for y in range(size):
            row = bytearray()
            for x in range(size):
                row.extend(color_at(x, y, size))
            rows.append(bytes(row))
        write_png(ICON_DIR / f"icon_{size}.png", size, rows)
    print(f"Wrote {len(SIZES)} icons to {ICON_DIR}")


if __name__ == "__main__":
    main()
