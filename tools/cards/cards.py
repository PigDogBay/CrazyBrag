#!/usr/bin/env python3
"""Draws the western playing cards as SVG.
Writes one HTML sheet per suit plus one for the card back; build.sh renders them with
headless Chrome and cuts the sheets into the individual card images."""
import math, sys

W, H = 691, 1056
INK = '#1c1a17'
RED = '#a8201a'
NAVY = '#27406b'
GOLD = '#d9a520'
STOCK = '#fbf4e1'
PANEL = '#f1e2bd'
SKIN = '#e8b98f'
ST = f'stroke="{INK}" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"'
FONT = "font-family=\"Rockwell\" font-weight=\"bold\""

SUITS = {
    'H': dict(ink=RED, p=RED, s=GOLD, hat='#c9a66b', hair='#5a3418', lady='#8a3b12', eye='#3f6b3a'),
    'D': dict(ink=RED, p=RED, s=NAVY, hat='#e6d6ae', hair='#3a2a1d', lady='#d9b24c', eye='#2f5f8f'),
    'S': dict(ink=INK, p='#2a2d35', s=GOLD, hat='#4a3626', hair='#9a9a96', lady='#1c1a17', eye='#5a3a1c'),
    'C': dict(ink=INK, p=NAVY, s=RED, hat='#8a8172', hair='#1c1a17', lady='#6b3d1e', eye='#3f6b3a'),
}
PIPS = {
    'H': '<path d="M50 90C20 64 5 46 5 29 5 13 18 5 30 5c10 0 17 6 20 14 3-8 10-14 20-14 12 0 25 8 25 24 0 17-15 35-45 61z"/>',
    'D': '<path d="M50 2Q70 28 90 50 70 72 50 98 30 72 10 50 30 28 50 2z"/>',
    'S': '<path d="M50 4C62 22 95 40 95 62c0 14-10 22-22 22-9 0-16-4-20-11 1 11 5 19 13 24H34c8-5 12-13 13-24-4 7-11 11-20 11C15 84 5 76 5 62 5 40 38 22 50 4z"/>',
    'C': '<g><circle cx="50" cy="27" r="22"/><circle cx="26" cy="60" r="22"/><circle cx="74" cy="60" r="22"/><circle cx="50" cy="52" r="14"/><path d="M50 55c1 20 6 35 16 42H34c10-7 15-22 16-42z"/></g>',
}

def pip(suit, cx, cy, size, rot=False, color=None):
    r = ' rotate(180)' if rot else ''
    return f'<g transform="translate({cx:.1f},{cy:.1f}){r} scale({size / 100:.3f}) translate(-50,-50)" fill="{color or SUITS[suit]["ink"]}">{PIPS[suit]}</g>'

def star(cx, cy, r, fill=GOLD, inner=.45, n=5, extra=''):
    p = []
    for i in range(n * 2):
        a = -math.pi / 2 + i * math.pi / n
        rr = r if i % 2 == 0 else r * inner
        p.append(f'{cx + rr * math.cos(a):.1f},{cy + rr * math.sin(a):.1f}')
    return f'<polygon points="{" ".join(p)}" fill="{fill}" {extra}/>'

def bez(p0, p1, p2, p3, t):
    u = 1 - t
    return tuple(u ** 3 * a + 3 * u * u * t * b + 3 * u * t * t * c + t ** 3 * d for a, b, c, d in zip(p0, p1, p2, p3))

def index(suit, rank):
    c = SUITS[suit]['ink']
    tl = ' textLength="78" lengthAdjust="spacingAndGlyphs"' if rank == '10' else ''
    one = (f'<text x="56" y="112" text-anchor="middle" {FONT} font-size="112" fill="{c}"{tl}>{rank}</text>' + pip(suit, 56, 166, 62))
    return one + f'<g transform="rotate(180 {W / 2} {H / 2})">{one}</g>'

def blank():
    return (f'<rect x="3" y="3" width="{W - 6}" height="{H - 6}" rx="44" fill="{STOCK}" stroke="#8a7a5a" stroke-width="3"/>')

# ---------------------------------------------------------------- number cards
COLS = (212, W / 2, W - 212)
TOP, BOT = 196, H - 196
def ys(*f):
    return [TOP + (BOT - TOP) * x for x in f]
LAYOUT = {
    2: [(1, 0), (1, 1)],
    3: [(1, 0), (1, .5), (1, 1)],
    4: [(0, 0), (2, 0), (0, 1), (2, 1)],
    5: [(0, 0), (2, 0), (1, .5), (0, 1), (2, 1)],
    6: [(0, 0), (2, 0), (0, .5), (2, .5), (0, 1), (2, 1)],
    7: [(0, 0), (2, 0), (1, .25), (0, .5), (2, .5), (0, 1), (2, 1)],
    8: [(0, 0), (2, 0), (1, .25), (0, .5), (2, .5), (1, .75), (0, 1), (2, 1)],
    9: [(0, 0), (2, 0), (0, 1 / 3), (2, 1 / 3), (1, .5), (0, 2 / 3), (2, 2 / 3), (0, 1), (2, 1)],
    10: [(0, 0), (2, 0), (1, 1 / 6), (0, 1 / 3), (2, 1 / 3), (0, 2 / 3), (2, 2 / 3), (1, 5 / 6), (0, 1), (2, 1)],
}

def number_card(suit, n):
    o = [blank(), index(suit, str(n))]
    for col, f in LAYOUT[n]:
        o.append(pip(suit, COLS[col], TOP + (BOT - TOP) * f, 150 if n < 9 else 128, rot=f > .5))
    return ''.join(o)

# ---------------------------------------------------------------- ace: a bullet
def ace(suit):
    s = SUITS[suit]
    o = [blank(), index(suit, 'A')]
    cx, cy = W / 2, H / 2
    rays = ''.join(f'<line x1="{cx + 150 * math.cos(a):.1f}" y1="{cy + 150 * math.sin(a):.1f}" x2="{cx + (285 if i % 2 else 250) * math.cos(a):.1f}" y2="{cy + (285 if i % 2 else 250) * math.sin(a):.1f}"/>'
                   for i, a in enumerate(k * math.pi / 18 for k in range(36)))
    o.append(f'<g stroke="#cdb57a" stroke-width="6" stroke-linecap="round">{rays}</g>')
    o.append('<defs><linearGradient id="brass"><stop offset="0" stop-color="#8f6b1e"/><stop offset=".38" stop-color="#ecd078"/><stop offset=".7" stop-color="#c39a34"/><stop offset="1" stop-color="#7d5c18"/></linearGradient>'
             '<linearGradient id="lead"><stop offset="0" stop-color="#6d7178"/><stop offset=".38" stop-color="#d9dce0"/><stop offset=".7" stop-color="#9da1a8"/><stop offset="1" stop-color="#5e6168"/></linearGradient></defs>')
    # cartridge, 170 wide and 520 tall, standing on its rim
    o.append(f'<g transform="translate({cx - 85},{cy - 262})" {ST}>'
             '<path d="M10 200V160C10 78 55 14 85 0c30 14 75 78 75 160v40z" fill="url(#lead)"/>'
             '<rect x="0" y="198" width="170" height="296" rx="6" fill="url(#brass)"/>'
             '<path d="M0 224h170M0 470h170" fill="none"/>'
             '<rect x="-10" y="492" width="190" height="30" rx="8" fill="url(#brass)"/>'
             f'<circle cx="85" cy="346" r="72" fill="{STOCK}"/></g>')
    o.append(pip(suit, cx, cy + 86, 96))
    return ''.join(o)

# ---------------------------------------------------------------- court figures (drawn in a 500 x 420 box)
def head(s, jaw=250):
    return (f'<ellipse cx="188" cy="178" rx="10" ry="17" fill="{SKIN}" {ST}/><ellipse cx="312" cy="178" rx="10" ry="17" fill="{SKIN}" {ST}/>'
            f'<path d="M190 150C190 215 216 {jaw + 6} 250 {jaw + 6}s60-{jaw - 209} 60-{jaw - 144}c0-42-120-42-120 0z" fill="{SKIN}" {ST}/>')

def hat(colour, band, crown):
    return (f'<path d="M84 126C118 152 382 152 416 126 404 104 352 98 250 98S96 104 84 126z" fill="{colour}" {ST}/>'
            f'<path d="{crown}" fill="{colour}" {ST}/>'
            f'<path d="M168 113C200 124 300 124 332 113L334 92C300 103 200 103 166 92z" fill="{band}" {ST}/>')

def sheriff(suit):
    s = SUITS[suit]
    o = []
    o.append(f'<path d="M92 425L104 332C110 300 150 286 205 275H295C350 286 390 300 396 332L408 425z" fill="#f4ecd8" {ST}/>')
    o.append(f'<path d="M250 292V425" {ST} fill="none"/>' + ''.join(f'<circle cx="250" cy="{y}" r="5" fill="{INK}"/>' for y in (345, 380, 412)))
    o.append(f'<path d="M104 425L111 336C117 311 150 296 196 283L236 425z" fill="{s["p"]}" {ST}/><path d="M396 425L389 336C383 311 350 296 304 283L264 425z" fill="{s["p"]}" {ST}/>')
    o.append(f'<rect x="222" y="225" width="56" height="62" fill="{SKIN}" {ST}/>')
    o.append(f'<path d="M200 274C225 266 275 266 300 274L262 318 276 372 250 356 224 372 238 318z" fill="{s["s"]}" {ST}/>')
    o.append(star(330, 362, 36, GOLD, .5, 5, ST) + f'<circle cx="330" cy="362" r="9" fill="#f6e08a" {ST}/>')
    o.append(head(s))
    o.append(f'<path d="M190 128h12l-3 58-9-10zM310 128h-12l3 58 9-10z" fill="{s["hair"]}" {ST}/>')
    o.append(hat(s['hat'], s['s'], 'M166 113C162 58 184 32 216 37 236 40 242 50 250 50S264 40 284 37C316 32 338 58 334 113z'))
    for x in (225, 275):
        o.append(f'<ellipse cx="{x}" cy="174" rx="12" ry="8" fill="white" {ST}/><circle cx="{x}" cy="174" r="5" fill="{INK}"/>')
    o.append(f'<path d="M207 158L240 154M293 158L260 154" stroke="{s["hair"]}" stroke-width="9" stroke-linecap="round"/>')
    o.append(f'<path d="M250 176L243 206 256 208" {ST} fill="none"/>')
    o.append(f'<path d="M250 214C236 203 210 207 199 222 191 233 181 227 179 215 176 238 196 249 215 240 232 233 244 227 250 225 256 227 268 233 285 240 304 249 324 238 321 215 319 227 309 233 301 222 290 207 264 203 250 214z" fill="{s["hair"]}" {ST}/>')
    o.append(f'<path d="M238 240Q250 246 262 240" {ST} fill="none"/>')
    return ''.join(o)

def lady(suit):
    s = SUITS[suit]
    hair = s['lady']
    o = []
    o.append(f'<path d="M146 196C126 112 168 40 250 36 332 40 374 112 354 196 349 222 334 242 320 252H180C166 242 151 222 146 196z" fill="{hair}" {ST}/>')
    for cx, cy, r in ((156, 222, 24), (344, 222, 24), (166, 262, 18), (334, 262, 18)):
        o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{hair}" {ST}/>')
    o.append(f'<path d="M98 425L110 346C118 316 160 301 215 289H285C340 301 382 316 390 346L402 425z" fill="{SKIN}" {ST}/>')
    o.append(f'<rect x="225" y="228" width="50" height="68" fill="{SKIN}" {ST}/>')
    left = ((126, 374), (150, 350), (215, 345), (250, 388))
    right = ((250, 388), (285, 345), (350, 350), (374, 374))
    o.append(f'<path d="M116 425L126 374C150 350 215 345 250 388 285 345 350 350 374 374L384 425z" fill="{s["p"]}" {ST}/>')
    o.append(f'<path d="M250 392V425" stroke="{s["s"]}" stroke-width="6"/>')
    for cx in (116, 384):
        o.append(f'<ellipse cx="{cx}" cy="376" rx="30" ry="27" fill="#fbf6ea" {ST}/>')
    for curve in (left, right):
        for k in range(8):
            x, y = bez(*curve, (k + .5) / 8)
            o.append(f'<circle cx="{x:.1f}" cy="{y - 4:.1f}" r="13" fill="#fbf6ea" {ST}/>')
    o.append(f'<rect x="225" y="262" width="50" height="15" fill="{INK}"/><ellipse cx="250" cy="270" rx="10" ry="12" fill="{s["s"]}" {ST}/>')
    o.append(f'<path d="M194 150C194 212 221 254 250 254s56-42 56-104c0-44-112-44-112 0z" fill="{SKIN}" {ST}/>')
    o.append(f'<path d="M192 156C196 108 238 98 262 112 286 100 308 126 308 156 292 134 272 128 258 130 234 124 210 134 192 156z" fill="{hair}" {ST}/>')
    o.append(f'<ellipse cx="250" cy="50" rx="56" ry="36" fill="{hair}" {ST}/><path d="M214 52Q250 30 286 52" {ST} fill="none"/>')
    o.append(f'<path d="M288 64C318 2 392-6 424 30 392 30 352 56 304 92z" fill="{s["p"]}" {ST}/><path d="M298 78C330 44 370 30 410 30" {ST} fill="none"/>')
    o.append(f'<circle cx="296" cy="76" r="13" fill="{s["s"]}" {ST}/>')
    for x in (226, 274):
        o.append(f'<ellipse cx="{x}" cy="176" rx="13" ry="8" fill="white" {ST}/><circle cx="{x}" cy="176" r="5.5" fill="{s["eye"]}"/><circle cx="{x}" cy="176" r="2.5" fill="{INK}"/>')
    o.append(f'<path d="M210 174Q226 160 242 174M258 174Q274 160 290 174M210 174l-8-6M290 174l8-6" stroke="{INK}" stroke-width="6" fill="none" stroke-linecap="round"/>')
    o.append(f'<path d="M212 156Q226 148 240 154M260 154Q274 148 288 156" stroke="{hair}" stroke-width="5" fill="none" stroke-linecap="round"/>')
    o.append(f'<path d="M250 182L246 205 254 206" {ST} fill="none"/>')
    o.append('<circle cx="212" cy="208" r="13" fill="#e2777a" opacity=".55"/><circle cx="288" cy="208" r="13" fill="#e2777a" opacity=".55"/>')
    o.append(f'<path d="M234 225Q243 217 250 222 257 217 266 225 250 241 234 225z" fill="#c0281f" {ST}/>')
    o.append(f'<circle cx="274" cy="216" r="3.5" fill="{INK}"/>')
    for x in (192, 308):
        o.append(f'<path d="M{x} 196v10" {ST}/><circle cx="{x}" cy="214" r="8" fill="{GOLD}" {ST}/>')
    return ''.join(o)

def outlaw(suit):
    s = SUITS[suit]
    coat = '#4b382a' if suit in 'HD' else '#33363d'
    o = []
    o.append(f'<path d="M82 425L98 334C106 300 150 286 205 272H295C350 286 394 300 402 334L418 425z" fill="{coat}" {ST}/>')
    o.append(f'<path d="M212 278H288L250 404z" fill="{s["s"]}" {ST}/>')
    o.append(f'<path d="M205 272L164 246 184 336zM295 272L336 246 316 336z" fill="{coat}" {ST}/>')
    o.append(f'<path d="M120 318L152 300 352 425H296z" fill="#8a5a2e" {ST}/>')
    for k in range(5):
        x, y = 150 + k * 37, 322 + k * 23
        o.append(f'<rect x="{x}" y="{y}" width="13" height="30" rx="5" fill="{GOLD}" {ST} transform="rotate(-58 {x + 6} {y + 15})"/>')
    o.append(head(s))
    o.append(f'<path d="M188 126h14l-2 74-12-14zM312 126h-14l2 74 12-14z" fill="{s["hair"]}" {ST}/>')
    o.append(f'<path d="M184 192C210 182 290 182 316 192 318 228 302 252 292 264L250 336 208 264C198 252 182 228 184 192z" fill="{s["p"]}" {ST}/>')
    o.append(f'<path d="M210 262Q250 282 290 262M222 286Q250 298 278 286" {ST} fill="none"/>')
    dot = '#fbf4e1'
    for x, y in ((214, 208), (250, 204), (286, 208), (232, 232), (268, 232), (250, 256), (228, 262), (272, 262), (250, 296)):
        o.append(f'<circle cx="{x}" cy="{y}" r="5" fill="{dot}"/>')
    o.append(hat('#2b2622', s['s'], 'M172 113L182 50C214 40 286 40 318 50L328 113z'))
    for x in (224, 276):
        o.append(f'<ellipse cx="{x}" cy="172" rx="12" ry="6" fill="white" {ST}/><circle cx="{x}" cy="172" r="4.5" fill="{INK}"/>')
    o.append(f'<path d="M204 152L242 163M296 152L258 163" stroke="{INK}" stroke-width="10" stroke-linecap="round"/>')
    o.append(f'<path d="M286 140L270 186" stroke="#9c4a3c" stroke-width="4" stroke-linecap="round"/>')
    return ''.join(o)

FIGURES = {'K': sheriff, 'Q': lady, 'J': outlaw}

def court_card(suit, rank):
    s = SUITS[suit]
    fx, fy, fw, fh = 126, 92, W - 252, H - 184
    half = FIGURES[rank](suit)
    sx, sy = fw / 500, (fh / 2) / 420
    cid = f'h{suit}{rank}'
    one = f'<g clip-path="url(#{cid})"><g transform="translate({fx},{fy}) scale({sx:.4f},{sy:.4f})">{half}</g></g>' + pip(suit, fx + 52, fy + 56, 70)
    o = [blank(), index(suit, rank)]
    o.append(f'<defs><clipPath id="{cid}"><rect x="{fx}" y="{fy}" width="{fw}" height="{fh / 2}"/></clipPath></defs>')
    o.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="{PANEL}"/>')
    o.append(one + f'<g transform="rotate(180 {W / 2} {H / 2})">{one}</g>')
    o.append(f'<rect x="{fx}" y="{H / 2 - 17}" width="{fw}" height="34" fill="{s["s"]}" {ST}/>')
    o.append(''.join(star(fx + fw * k / 8, H / 2, 10, STOCK if s['s'] != GOLD else INK) for k in range(1, 8)))
    o.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="none" stroke="{s["ink"]}" stroke-width="6"/>')
    return ''.join(o)

# ---------------------------------------------------------------- jokers (Looky Looky)
def mini_card(rank, suit, angle):
    """a small black-suited card in a fan pivoting at (0, 0)"""
    return (f'<g transform="rotate({angle})"><rect x="-27" y="-150" width="54" height="150" rx="6" fill="{STOCK}" {ST} stroke-width="4"/>'
            f'<text x="-19" y="-118" {FONT} font-size="30" fill="{INK}">{rank}</text>'
            f'<g transform="translate(-9,-100) scale(.2) translate(-50,-50)" fill="{INK}">{PIPS[suit]}</g></g>')

def wild_bill():
    """The good joker: Wild Bill Hickok, in buckskins, holding aces and eights."""
    hair, buck, shade, felt = '#8a5425', '#c99b5c', '#a67c43', '#e6d6ae'
    o = []
    # hair down the back, buckskin jacket, shirt and neckerchief
    o.append(f'<path d="M184 116C150 160 160 222 140 258 126 284 136 310 160 322L250 300 340 322C364 310 374 284 360 258 340 222 350 160 316 116z" fill="{hair}" {ST}/>')
    o.append(f'<path d="M82 425L98 334C106 300 150 286 205 272H295C350 286 394 300 402 334L418 425z" fill="{buck}" {ST}/>')
    o.append(f'<path d="M212 278H288L250 404z" fill="#f4ecd8" {ST}/>')
    o.append(f'<path d="M205 272L170 250 190 340 250 404zM295 272L330 250 310 340 250 404z" fill="{shade}" {ST}/>')
    o.append(f'<rect x="222" y="225" width="56" height="62" fill="{SKIN}" {ST}/>')
    o.append(f'<path d="M206 276C230 268 270 268 294 276L266 312 280 350 250 336 220 350 234 312z" fill="{RED}" {ST}/>')
    # fringed yoke
    for curve in (((100, 328), (130, 356), (165, 362), (196, 346)), ((400, 328), (370, 356), (335, 362), (304, 346))):
        (x0, y0), c1, c2, (x3, y3) = curve
        o.append(f'<path d="M{x0} {y0}C{c1[0]} {c1[1]} {c2[0]} {c2[1]} {x3} {y3}" {ST} fill="none"/>')
        for k in range(9):
            x, y = bez(*curve, (k + .5) / 9)
            o.append(f'<path d="M{x:.1f} {y:.1f}v26" {ST} stroke-width="4"/>')
    # marshal's badge
    o.append(star(344, 379, 24, GOLD, .5, 5, ST) + f'<circle cx="344" cy="379" r="6" fill="#f6e08a" {ST}/>')
    # the dead man's hand: black aces and eights
    o.append(f'<g transform="translate(140,452)">' + ''.join(mini_card(r, s, a) for r, s, a in (('A', 'S', -33), ('A', 'C', -11), ('8', 'S', 11), ('8', 'C', 33))) + '</g>')
    o.append(f'<path d="M96 425C92 392 112 376 140 380 172 376 190 396 186 425z" fill="{SKIN}" {ST}/><path d="M118 392v22M140 388v26M162 392v22" {ST} fill="none" stroke-width="4"/>')
    o.append(head(None))
    # locks falling over the ears to the shoulders
    o.append(f'<path d="M190 124h13C200 160 204 196 196 226 190 250 178 268 160 282 170 250 170 222 176 196 180 170 182 148 190 124z" fill="{hair}" {ST}/>')
    o.append(f'<path d="M310 124h-13C300 160 296 196 304 226 310 250 322 268 340 282 330 250 330 222 324 196 320 170 318 148 310 124z" fill="{hair}" {ST}/>')
    # wide flat-brimmed hat with a low crown
    o.append(f'<path d="M56 122C98 150 402 150 444 122 428 102 352 96 250 96S72 102 56 122z" fill="{felt}" {ST}/>')
    o.append(f'<path d="M168 112C162 66 196 44 250 44S338 66 332 112z" fill="{felt}" {ST}/>')
    o.append(f'<path d="M168 113C200 124 300 124 332 113L333 94C300 105 200 105 167 94z" fill="{NAVY}" {ST}/>')
    for x in (225, 275):
        o.append(f'<ellipse cx="{x}" cy="174" rx="12" ry="8" fill="white" {ST}/><circle cx="{x}" cy="174" r="5.5" fill="#4f7fa8"/><circle cx="{x}" cy="174" r="2.5" fill="{INK}"/>')
    o.append(f'<path d="M208 156Q224 148 240 155M292 156Q276 148 260 155" stroke="{hair}" stroke-width="8" stroke-linecap="round" fill="none"/>')
    o.append(f'<path d="M250 176L243 206 256 208" {ST} fill="none"/>')
    # long drooping moustache
    o.append(f'<path d="M250 213C238 204 216 207 207 222 201 234 201 252 192 268 207 262 218 250 224 238 233 231 244 227 250 226 256 227 267 231 276 238 282 250 293 262 308 268 299 252 299 234 293 222 284 207 262 204 250 213z" fill="{hair}" {ST}/>')
    o.append(f'<path d="M240 243Q250 249 260 243" {ST} fill="none"/>')
    return ''.join(o)

def calamity_jane():
    """The bad joker: Calamity Jane in a coonskin cap and furs, passed out with an empty whiskey bottle."""
    hair, buck, fur, dark, glass = '#3a2a1d', '#9a6b3a', '#8c7a66', '#3b302a', '#cfe3d2'
    o = []
    o.append(f'<path d="M82 425L98 334C106 300 150 286 205 272H295C350 286 394 300 402 334L418 425z" fill="{buck}" {ST}/>')
    o.append(f'<path d="M250 330V425" {ST} fill="none"/>')
    o.append(f'<rect x="222" y="225" width="56" height="62" fill="{SKIN}" {ST}/>')
    # fur collar
    collar = 'M128 318C160 268 222 282 250 338 278 282 340 268 372 318'
    o.append(f'<path d="{collar}" fill="none" stroke="{INK}" stroke-width="56" stroke-linecap="round" stroke-linejoin="round"/>')
    o.append(f'<path d="{collar}" fill="none" stroke="{fur}" stroke-width="46" stroke-linecap="round" stroke-linejoin="round"/>')
    o.append(f'<path d="M140 300l8 14M172 284l4 16M206 290l-2 16M232 312l-8 12M360 300l-8 14M328 284l-4 16M294 290l2 16M268 312l8 12" stroke="{dark}" stroke-width="4" stroke-linecap="round"/>')
    # the empty bottle, upended, and the hand that still has hold of it
    o.append(f'<g transform="translate(196,376) rotate(-100) scale(.8) translate(-40,0)" {ST} stroke-width="7">'
             f'<path d="M30 0h20v60c14 8 28 18 28 40v146c0 8-6 12-12 12H14c-6 0-12-4-12-12V100c0-22 14-32 28-40z" fill="{glass}"/>'
             f'<rect x="2" y="124" width="76" height="76" fill="{RED}"/><text x="40" y="176" text-anchor="middle" {FONT} font-size="36" fill="{STOCK}" stroke="none">XXX</text>'
             f'<path d="M16 100v-4c0-10 6-16 12-20" fill="none" stroke="white" stroke-width="6"/></g>')
    o.append(f'<path d="M186 384q-7 12 0 16 7-4 0-16z" fill="#c98a2b" stroke="{INK}" stroke-width="3"/>')
    o.append(f'<path d="M362 314C382 298 412 310 416 334 418 356 402 372 382 370 360 368 348 334 362 314z" fill="{SKIN}" {ST}/><path d="M372 322l20 28M386 314l18 26" {ST} fill="none" stroke-width="4"/>')
    # head lolling to one side
    h = []
    h.append(f'<path d="M188 128C160 160 158 214 150 250 148 268 166 276 190 270L310 270C334 276 352 268 350 250 342 214 340 160 312 128z" fill="{hair}" {ST}/>')
    h.append(head(None))
    # coonskin cap and its ringed tail
    tail = 'M192 104C150 130 150 190 138 250'
    h.append(f'<path d="{tail}" fill="none" stroke="{INK}" stroke-width="50" stroke-linecap="round"/>')
    h.append(f'<path d="{tail}" fill="none" stroke="{fur}" stroke-width="40" stroke-linecap="round"/>')
    h.append(f'<path d="{tail}" fill="none" stroke="{dark}" stroke-width="40" stroke-dasharray="16 22" stroke-dashoffset="-26"/>')
    h.append(f'<path d="M178 152C164 84 198 42 250 42S336 84 322 152C306 132 290 142 276 130 262 142 238 142 224 130 210 142 194 132 178 152z" fill="{fur}" {ST}/>')
    h.append(f'<path d="M206 84l5 16M232 68l3 16M266 68l-3 16M294 84l-5 16M250 96v16M218 112l4 12M282 112l-4 12" stroke="{dark}" stroke-width="4" stroke-linecap="round"/>')
    h.append(f'<path d="M194 148C192 170 196 186 190 204M306 148C308 170 304 186 310 204" stroke="{hair}" stroke-width="9" stroke-linecap="round" fill="none"/>')
    # eyes shut, flushed, mouth hanging open
    h.append(f'<path d="M212 172Q225 182 238 172M262 172Q275 182 288 172M214 176l-5 6M225 179v7M286 176l5 6M275 179v7" stroke="{INK}" stroke-width="5" fill="none" stroke-linecap="round"/>')
    h.append(f'<path d="M210 154Q224 146 240 152M260 152Q276 146 290 154" stroke="{hair}" stroke-width="6" fill="none" stroke-linecap="round"/>')
    h.append('<circle cx="212" cy="206" r="15" fill="#d9534f" opacity=".5"/><circle cx="288" cy="206" r="15" fill="#d9534f" opacity=".5"/>')
    h.append(f'<path d="M250 180L244 204" {ST} fill="none"/><circle cx="248" cy="206" r="9" fill="#d9534f" {ST} stroke-width="4"/>')
    h.append(f'<ellipse cx="250" cy="233" rx="13" ry="9" fill="#5a1f1a" {ST}/><path d="M260 240q5 14 0 20" stroke="#8fb7d6" stroke-width="5" fill="none" stroke-linecap="round"/>')
    o.append(f'<g transform="rotate(-11 250 262)">{"".join(h)}</g>')
    for x, y, size in ((370, 176, 36), (402, 132, 48), (438, 84, 62)):
        o.append(f'<text x="{x}" y="{y}" text-anchor="middle" {FONT} font-size="{size}" fill="{RED}" stroke="{INK}" stroke-width="2">Z</text>')
    return ''.join(o)

# name: (figure, ink colour, band colour); the image is called Joker<name>
JOKERS = {'Good': (wild_bill, NAVY, GOLD), 'Bad': (calamity_jane, INK, RED)}

def joker_index(ink, band):
    letters = ''.join(f'<text x="56" y="{92 + k * 54}" text-anchor="middle" {FONT} font-size="60" fill="{ink}">{c}</text>' for k, c in enumerate('JOKER'))
    one = letters + star(56, 352, 30, band, .45, 5, f'stroke="{ink}" stroke-width="4" stroke-linejoin="round"')
    return one + f'<g transform="rotate(180 {W / 2} {H / 2})">{one}</g>'

def joker(name):
    figure, ink, band = JOKERS[name]
    fx, fy, fw, fh = 126, 92, W - 252, H - 184
    sx, sy = fw / 500, (fh / 2) / 420
    cid = f'j{name}'
    one = f'<g clip-path="url(#{cid})"><g transform="translate({fx},{fy}) scale({sx:.4f},{sy:.4f})">{figure()}</g></g>'
    o = [blank(), joker_index(ink, band)]
    o.append(f'<defs><clipPath id="{cid}"><rect x="{fx}" y="{fy}" width="{fw}" height="{fh / 2}"/></clipPath></defs>')
    o.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="{PANEL}"/>')
    o.append(one + f'<g transform="rotate(180 {W / 2} {H / 2})">{one}</g>')
    o.append(f'<rect x="{fx}" y="{H / 2 - 17}" width="{fw}" height="34" fill="{band}" {ST}/>')
    o.append(''.join(star(fx + fw * k / 8, H / 2, 10, STOCK if band != GOLD else INK) for k in range(1, 8)))
    o.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="none" stroke="{ink}" stroke-width="6"/>')
    return ''.join(o)

# ---------------------------------------------------------------- card back
def revolver():
    return ('<g><path d="M6 30h8l4-9h8l2 9h124v24H6z"/><rect x="34" y="57" width="118" height="10" rx="4"/>'
            '<rect x="150" y="20" width="68" height="54" rx="9"/>'
            '<path d="M216 28L238 30 252 4 264 9 254 36C266 44 270 56 274 72L298 138C302 151 288 159 264 155L247 152C241 122 236 98 222 82L216 74z"/>'
            '<path d="M168 74C166 108 214 108 222 82" fill="none" stroke-width="7"/><path d="M196 76l4 16" fill="none" stroke-width="6"/></g>')

# Howie's deck: every card has its own back, marked so that a sharp-eyed player can read it.
#   Suit  - colour of the left-hand poker chip: hearts red, diamonds gold, spades black, clubs green
#   Rank  - how full the whiskey glasses are, plus one blemish:
#             glass empty 2-5, half full 6-9, full 10-K, and no glass at all for an ace
#             within each group of four: clean, a dot (left edge, above the chips),
#             a scratch (left edge, below the chips), a dog-eared top-left corner
#   Jokers - a purple left-hand chip; the good joker's glass is full, the bad joker's is empty
# All the marks are in the left half of the card, which stays visible when a hand is fanned.
MARK_CHIP = {'H': RED, 'D': GOLD, 'S': '#23252b', 'C': '#2e7046', 'Joker': '#6d3f86'}
MARK_GROUPS = (('2', '3', '4', '5'), ('6', '7', '8', '9'), ('10', 'J', 'Q', 'K'))
EAR = 82

def marks(rank):
    """(glass, blemish): glass is None, 'empty', 'half' or 'full', blemish is 0-3"""
    if rank in JOKERS:
        return ('full' if rank == 'Good' else 'empty'), 0
    for level, group in zip(('empty', 'half', 'full'), MARK_GROUPS):
        if rank in group:
            return level, group.index(rank)
    return None, 0

def back(suit=None, rank=None):
    cream, navy, red = '#f3e6c4', '#22334f', '#a8201a'
    glass, blemish = marks(rank) if rank else ('half', 0)
    left_chip = MARK_CHIP[suit] if suit else GOLD
    o = [f'<rect x="3" y="3" width="{W - 6}" height="{H - 6}" rx="44" fill="{cream}" stroke="#8a7a5a" stroke-width="3"/>']
    o.append(f'<defs><pattern id="lat" width="46" height="46" patternUnits="userSpaceOnUse" patternTransform="rotate(45)"><rect width="46" height="46" fill="{navy}"/><path d="M0 0H46M0 0V46" stroke="#3a5078" stroke-width="5"/><circle cx="23" cy="23" r="4" fill="#3a5078"/></pattern>'
             f'<clipPath id="bk"><rect x="34" y="34" width="{W - 68}" height="{H - 68}" rx="24"/></clipPath></defs>')
    o.append(f'<rect x="34" y="34" width="{W - 68}" height="{H - 68}" rx="24" fill="url(#lat)"/>')
    o.append(f'<rect x="56" y="56" width="{W - 112}" height="{H - 112}" rx="12" fill="none" stroke="{GOLD}" stroke-width="5"/>')
    o.append(f'<rect x="70" y="70" width="{W - 140}" height="{H - 140}" rx="6" fill="none" stroke="{cream}" stroke-width="3"/>')
    for x, y in ((96, 96), (W - 96, 96), (96, H - 96), (W - 96, H - 96)):
        o.append(star(x, y, 20, GOLD, .45, 5, f'stroke="{navy}" stroke-width="3"'))
    cx, cy = W / 2, H / 2
    # oval plaque for each half so the drawings read against the lattice
    half = []
    half.append(f'<ellipse cx="{cx}" cy="292" rx="232" ry="172" fill="{navy}" stroke="{GOLD}" stroke-width="5"/>')
    half.append(f'<ellipse cx="{cx}" cy="292" rx="216" ry="156" fill="none" stroke="{cream}" stroke-width="2.5"/>')
    whiskey = {'empty': '', 'half': '<path d="M5 36h48l-4 34H9z" fill="#c98a2b" stroke="none"/>', 'full': '<path d="M3 8h52l-6 62H9z" fill="#c98a2b" stroke="none"/>', None: ''}[glass]
    # revolver on the left pointing right, shot glass under the barrel, whiskey bottle on the right
    half.append(f'<g transform="translate({cx + 62},232) scale(-.84,.84)" fill="{cream}" stroke="{cream}">{revolver()}</g>')
    half.append(f'<g transform="translate({cx - 6},322)" fill="{cream}" stroke="{navy}" stroke-width="4" stroke-linejoin="round"><path d="M0 0h58l-8 72H8z"/>{whiskey}</g>' if glass else '')
    half.append(f'<g transform="translate({cx + 92},186) scale(.86)" fill="{cream}" stroke="{navy}" stroke-width="4" stroke-linejoin="round">'
                '<rect x="28" y="0" width="24" height="16" rx="3" fill="#c9a66b"/><path d="M30 16h20v44c14 8 28 18 28 40v146c0 8-6 12-12 12H14c-6 0-12-4-12-12V100c0-22 14-32 28-40z"/>'
                f'<rect x="2" y="124" width="76" height="76" fill="{red}"/><text x="40" y="176" text-anchor="middle" {FONT} font-size="36" fill="{cream}" stroke="none">XXX</text></g>')
    o.append(''.join(half) + f'<g transform="rotate(180 {cx} {cy})">{"".join(half)}</g>')
    # poker chips in the middle
    def chip(x, y, c):
        return (f'<g transform="translate({x},{y})"><circle r="66" fill="{c}" stroke="{navy}" stroke-width="5"/>'
                f'<circle r="56" fill="none" stroke="{cream}" stroke-width="18" stroke-dasharray="22 21.98"/>'
                f'<circle r="40" fill="{cream}" stroke="{navy}" stroke-width="4"/>{star(0, 0, 26, c)}</g>')
    o.append(chip(cx - 92, cy + 14, left_chip) + chip(cx + 92, cy - 14, GOLD) + chip(cx, cy, red))
    if blemish == 1:    # dot
        o.append(f'<circle cx="122" cy="404" r="11" fill="{cream}"/>')
    elif blemish == 2:  # scratch
        o.append(f'<path d="M100 612l22 20 14 20 26 22 30 34" fill="none" stroke="#d8ccab" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>')
    elif blemish == 3:  # dog-eared corner: cut the corner off and fold it over
        o = [f'<defs><clipPath id="ear"><path d="M{EAR} 0H{W}V{H}H0V{EAR}z"/></clipPath></defs><g clip-path="url(#ear)">'] + o + ['</g>']
        o.append(f'<path d="M{EAR} 0L{EAR} {EAR - 12}Q{EAR} {EAR} {EAR - 12} {EAR}L0 {EAR}z" fill="#e9dcb8" stroke="#8a7a5a" stroke-width="3" stroke-linejoin="round"/>')
        o.append(f'<path d="M{EAR} 0L0 {EAR}" stroke="#8a7a5a" stroke-width="3"/>')
    return ''.join(o)

# ---------------------------------------------------------------- sheets
RANKS = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']

def card(suit, rank):
    if rank == 'A':
        return ace(suit)
    if rank in FIGURES:
        return court_card(suit, rank)
    return number_card(suit, int(rank))

def sheet(cards, cols):
    o = ['<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;background:transparent}svg{position:absolute}</style></head><body>']
    for i, c in enumerate(cards):
        o.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" style="left:{(i % cols) * W}px;top:{(i // cols) * H}px">{c}</svg>')
    o.append('</body></html>')
    return ''.join(o)

out = sys.argv[1]
for suit in SUITS:
    open(f'{out}/sheet_{suit}.html', 'w').write(sheet([card(suit, r) for r in RANKS], 7))
    open(f'{out}/sheet_back_{suit}.html', 'w').write(sheet([back(suit, r) for r in RANKS], 7))
open(f'{out}/sheet_back.html', 'w').write(sheet([back()], 1))
open(f'{out}/sheet_joker.html', 'w').write(sheet([joker(name) for name in JOKERS] + [back('Joker', name) for name in JOKERS], len(JOKERS)))
