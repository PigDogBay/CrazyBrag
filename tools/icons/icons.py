#!/usr/bin/env python3
"""Draws the Looky Looky action buttons as SVG: one HTML sheet with the three icons side by side.
build.sh renders it with headless Chrome and cuts it into the individual images."""
import sys

S = 256
INK = '#1c1a17'
RED = '#a8201a'
NAVY = '#27406b'
GOLD = '#d9a520'
STOCK = '#fbf4e1'
ST = f'stroke="{INK}" stroke-width="8" stroke-linejoin="round" stroke-linecap="round"'

def badge():
    """a poker chip style disc that the icon sits on"""
    return (f'<circle cx="128" cy="128" r="120" fill="{STOCK}" stroke="{INK}" stroke-width="8"/>'
            f'<circle cx="128" cy="128" r="106" fill="none" stroke="{GOLD}" stroke-width="5"/>')

def card(x, y, angle=0, fill=STOCK):
    return f'<rect x="{x}" y="{y}" width="72" height="104" rx="9" fill="{fill}" {ST} transform="rotate({angle} {x + 36} {y + 104})"/>'

def looky():
    """Looky Looky: an eye"""
    return (badge() +
            f'<path d="M36 128C70 76 186 76 220 128 186 180 70 180 36 128z" fill="white" {ST}/>'
            f'<circle cx="128" cy="128" r="34" fill="{NAVY}" {ST}/><circle cx="128" cy="128" r="14" fill="{INK}"/>'
            f'<circle cx="140" cy="116" r="7" fill="white"/>'
            f'<path d="M72 86L60 68M104 72L98 52M152 72L158 52M184 86L196 68" {ST} fill="none"/>')

def stash():
    """Stash hand: a circular arrow over three cards"""
    arc = 'M166 140A38 38 0 1 1 147 107'
    return (badge() +
            card(92, 62, -32, NAVY) + card(92, 62, 0, NAVY) + card(92, 62, 32, NAVY) +
            f'<path d="{arc}" fill="none" stroke="{STOCK}" stroke-width="24" stroke-linecap="round"/>'
            f'<path d="{arc}" fill="none" stroke="{RED}" stroke-width="13" stroke-linecap="round"/>'
            f'<path d="M136 88L172 100 146 126z" fill="{RED}" stroke="{STOCK}" stroke-width="5" stroke-linejoin="round"/>')

def change():
    """Change a middle card: a card with a cross on it"""
    return (badge() +
            f'<rect x="80" y="52" width="96" height="152" rx="12" fill="{NAVY}" {ST}/>'
            f'<rect x="94" y="66" width="68" height="124" rx="5" fill="none" stroke="{GOLD}" stroke-width="4"/>'
            f'<path d="M98 98L158 158M158 98L98 158" fill="none" stroke="{STOCK}" stroke-width="30" stroke-linecap="round"/>'
            f'<path d="M98 98L158 158M158 98L98 158" fill="none" stroke="{RED}" stroke-width="18" stroke-linecap="round"/>')

# image name: drawing
ICONS = {'ActionLooky': looky, 'ActionStash': stash, 'ActionChange': change}

out = sys.argv[1]
html = ['<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;background:transparent}svg{position:absolute;top:0}</style></head><body>']
for i, draw in enumerate(ICONS.values()):
    html.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{S}" height="{S}" viewBox="0 0 {S} {S}" style="left:{i * S}px">{draw()}</svg>')
html.append('</body></html>')
open(f'{out}/sheet.html', 'w').write(''.join(html))
print(' '.join(ICONS))
