# Builds theme/colored/state-*.svg: Bamboe logo with the upstream status glyph as a corner badge.
# Usage: python3 gen_state_icons.py <dir with upstream state-*.svg> <logo.png> theme/colored
import base64, io, re, sys, os
from PIL import Image
src_dir, logo_png, out_dir = sys.argv[1:4]
im = Image.open(logo_png).convert("RGBA")
l, t, r, b = im.getbbox()
side = max(r - l, b - t)
sq = Image.new("RGBA", (side, side), (0, 0, 0, 0))
sq.paste(im.crop((l, t, r, b)), ((side - (r - l)) // 2, (side - (b - t)) // 2))
sq = sq.resize((128, 128), Image.LANCZOS)
buf = io.BytesIO(); sq.save(buf, "PNG", optimize=True)
logo = base64.b64encode(buf.getvalue()).decode()

D = 8.4            # badge glyph diameter
C = 11.6           # badge centre
for name in ["ok", "sync", "error", "pause", "offline", "warning"]:
    svg = open(os.path.join(src_dir, f"state-{name}.svg")).read()
    vb = [float(x) for x in re.search(r'viewBox="([^"]+)"', svg).group(1).split()]
    inner = re.search(r"<svg[^>]*>(.*)</svg>", svg, re.S).group(1)
    s = D / 13.87
    tx = C - (vb[2] / 2) * s
    ty = C - (vb[3] / 2) * s
    out = (
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="16" height="16" viewBox="0 0 16 16">'
        f'<image x="0" y="0" width="13.6" height="13.6" xlink:href="data:image/png;base64,{logo}"/>'
        f'<circle cx="{C}" cy="{C}" r="{D/2 + 0.55:.2f}" fill="#FFF"/>'
        f'<g transform="translate({tx:.3f} {ty:.3f}) scale({s:.4f})">{inner}</g>'
        "</svg>\n"
    )
    open(os.path.join(out_dir, f"state-{name}.svg"), "w").write(out)
    print(name, len(out))
