from PIL import Image, ImageDraw, ImageFont
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def make_icon(size: int, path: str, scale: float = 0.31) -> None:
    img = Image.new("RGB", (size, size), (5, 5, 8))
    draw = ImageDraw.Draw(img)
    center = size // 2
    radius = int(size * scale)
    box = [center - radius, center - radius, center + radius, center + radius]

    draw.ellipse(box, fill=(20, 20, 22))
    draw.ellipse(box, outline=(10, 132, 255), width=max(2, int(size * 0.022)))
    draw.arc(box, start=270, end=370, fill=(10, 132, 255), width=max(3, int(size * 0.04)))

    try:
        font = ImageFont.truetype("arialbd.ttf", int(size * (scale * 0.85)))
    except OSError:
        font = ImageFont.load_default()

    draw.text(
        (center, center - int(size * 0.015)),
        "J",
        fill="white",
        anchor="mm",
        font=font,
    )

    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)


def main() -> None:
    for size in (192, 512):
        make_icon(size, os.path.join(ROOT, f"web/icons/Icon-{size}.png"), 0.31)
        make_icon(
            size,
            os.path.join(ROOT, f"web/icons/Icon-maskable-{size}.png"),
            0.24,
        )

    make_icon(192, os.path.join(ROOT, "web/favicon.png"), 0.31)
    make_icon(512, os.path.join(ROOT, "assets/images/logo.png"), 0.31)
    print("Square icons generated.")


if __name__ == "__main__":
    main()
    sys.exit(0)
