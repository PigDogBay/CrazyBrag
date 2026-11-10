#!/usr/bin/env python3
"""Generates town.html: a one-point-perspective western street, drawn in greys.
Rendered with headless Chrome, then toned to sepia with ImageMagick (see build.sh)."""
import math, sys

W, H = 2048, 1536
CX, HY, F, EYE = 1024, 952, 1500, 1.7   # vanishing point, focal length (px), eye height (m)
WALL, WALK = 5.6, 3.9                   # building line and boardwalk edge, metres from street centre
FONT = sys.argv[1]
FOG = 238

def P(X, Y, Z):
    return (CX + F * X / Z, HY - F * (Y - EYE) / Z)

def fogA(z):
    return max(0.0, min(0.62, (z - 11) / 105.0))

def g(v, z=None):
    if z is not None:
        a = fogA(z)
        v = v * (1 - a) + FOG * a
    v = int(max(0, min(255, v)))
    return f'rgb({v},{v},{v})'

def pts(ps):
    return ' '.join(f'{x:.1f},{y:.1f}' for x, y in ps)

def solve(A, b):
    n = len(b)
    M = [row[:] + [b[i]] for i, row in enumerate(A)]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(M[r][c]))
        M[c], M[p] = M[p], M[c]
        for r in range(n):
            if r != c:
                k = M[r][c] / M[c][c]
                M[r] = [x - k * y for x, y in zip(M[r], M[c])]
    return [M[i][n] / M[i][i] for i in range(n)]

def matrix3d(w, h, quad):
    """CSS matrix3d mapping the rect (0,0,w,h) onto quad = TL,TR,BR,BL"""
    src = [(0, 0), (w, 0), (w, h), (0, h)]
    A, b = [], []
    for (x, y), (u, v) in zip(src, quad):
        A.append([x, y, 1, 0, 0, 0, -x * u, -y * u]); b.append(u)
        A.append([0, 0, 0, x, y, 1, -x * v, -y * v]); b.append(v)
    a, bb, c, d, e, f, gg, hh = solve(A, b)
    return f'matrix3d({a},{d},0,{gg},{bb},{e},0,{hh},0,0,1,0,{c},{f},0,1)'

class B:
    def __init__(self, z0, z1, name, H, style, tone, storeys=1, hang=None, door='door', extra=None):
        self.z0, self.z1, self.name, self.H, self.style = z0, z1, name, H, style
        self.tone, self.storeys, self.hang, self.door, self.extra = tone, storeys, hang, door, extra
    def min_top(self):
        return self.H - {'flat': 0, 'step': .8, 'peak': 1.2, 'arch': .9}[self.style]

LEFT = [B(7.5, 19.5, 'HARDWARE', 5.2, 'step', 112, hang='TOOLS'),
        B(20.7, 31, 'SALOON', 7.6, 'flat', 150, 2, hang='WHISKEY', door='batwing'),
        B(32, 40, 'BANK', 5.6, 'peak', 128),
        B(41, 49, 'LIVERY', 5.0, 'flat', 104, door='barn'),
        B(50, 60, 'HOTEL', 7.2, 'flat', 140, 2)]
RIGHT = [B(8, 18.5, 'UNDERTAKER', 5.2, 'arch', 100, hang='COFFINS', extra='coffin'),
         B(19.7, 30, 'GENERAL STORE', 5.6, 'step', 152, hang='DRY GOODS'),
         B(31, 39, 'SHERIFF', 4.8, 'flat', 122, hang='JAIL'),
         B(40, 50, 'BARBER', 7.0, 'flat', 142, 2),
         B(51, 60, 'ASSAY', 5.0, 'peak', 116)]

S = 100  # px per metre in the flat facade drawings
uid = 0

def facade(b, side):
    """Flat elevation of a building front, later warped into perspective"""
    global uid
    uid += 1
    i = uid
    L = b.z1 - b.z0
    w, h = L * S, b.H * S
    X = lambda u: u * S
    Y = lambda y: (b.H - y) * S
    Hh, mt = b.H, b.min_top()
    if b.style == 'flat':
        top = [(0, Hh), (L, Hh)]
    elif b.style == 'step':
        top = [(0, mt), (L * .2, mt), (L * .2, Hh), (L * .8, Hh), (L * .8, mt), (L, mt)]
    elif b.style == 'peak':
        top = [(0, mt), (L / 2, Hh), (L, mt)]
    else:
        top = [(0, mt), (L * .22, mt)] + [(L / 2 - L * .28 * math.cos(t * math.pi / 16), mt + .9 * math.sin(t * math.pi / 16)) for t in range(17)] + [(L * .78, mt), (L, mt)]
    outline = [(X(u), Y(y)) for u, y in top]
    poly = [(0, h)] + outline + [(w, h)]
    t = b.tone
    o = []
    o.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs>')
    o.append(f'<clipPath id="c{i}"><polygon points="{pts(poly)}"/></clipPath>')
    o.append(f'<pattern id="p{i}" width="40" height="21" patternUnits="userSpaceOnUse"><rect width="40" height="21" fill="none"/><rect y="18" width="40" height="3" fill="black" opacity=".33"/><rect y="0" width="40" height="2" fill="white" opacity=".12"/></pattern>')
    o.append(f'<filter id="n{i}" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="0.012 0.35" numOctaves="3" seed="{i * 7}"/><feColorMatrix type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0.9 0 0 0 -0.22"/></filter>')
    za, zb = (b.z0, b.z1) if side < 0 else (b.z1, b.z0)
    o.append(f'<linearGradient id="f{i}"><stop offset="0" stop-color="{g(FOG)}" stop-opacity="{fogA(za):.3f}"/><stop offset="1" stop-color="{g(FOG)}" stop-opacity="{fogA(zb):.3f}"/></linearGradient>')
    o.append(f'<linearGradient id="w{i}" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{g(70)}"/><stop offset="1" stop-color="{g(28)}"/></linearGradient>')
    o.append('</defs>')
    o.append(f'<g clip-path="url(#c{i})">')
    o.append(f'<rect width="{w}" height="{h}" fill="{g(t)}"/>')
    o.append(f'<rect width="{w}" height="{h}" fill="url(#p{i})"/>')
    o.append(f'<rect width="{w}" height="{h}" filter="url(#n{i})"/>')
    # cornice along the top of the false front
    o.append(f'<polyline points="{pts(outline)}" fill="none" stroke="{g(t + 60)}" stroke-width="26"/>')
    o.append(f'<polyline points="{pts([(x, y + 22) for x, y in outline])}" fill="none" stroke="{g(t - 50)}" stroke-width="7"/>')
    # sign board
    st = mt - .22
    sb = max(6.25 if b.storeys == 2 else 3.6, st - 1.0)
    bx0, bx1 = L * .07, L * .93
    o.append(f'<rect x="{X(bx0)}" y="{Y(st)}" width="{X(bx1 - bx0)}" height="{(st - sb) * S}" fill="{g(190)}" stroke="{g(45)}" stroke-width="7"/>')
    fs = (st - sb) * S * .74
    tl = min(len(b.name) * fs * .78, X(bx1 - bx0) * .88)
    o.append(f'<text x="{w / 2}" y="{Y(sb) - (st - sb) * S * .2}" text-anchor="middle" font-family="Q" font-size="{fs:.0f}" textLength="{tl:.0f}" lengthAdjust="spacingAndGlyphs" fill="{g(35)}">{b.name}</text>')

    def window(uc, sill, ww, wh):
        x, y = X(uc - ww / 2), Y(sill + wh)
        o.append(f'<rect x="{x - 9}" y="{y - 9}" width="{ww * S + 18}" height="{wh * S + 18}" fill="{g(t + 55)}"/>')
        o.append(f'<rect x="{x}" y="{y}" width="{ww * S}" height="{wh * S}" fill="url(#w{i})"/>')
        o.append(f'<path d="M{x + ww * S / 2} {y}v{wh * S}M{x} {y + wh * S / 2}h{ww * S}" stroke="{g(t + 55)}" stroke-width="6"/>')
        o.append(f'<rect x="{x - 16}" y="{y + wh * S + 9}" width="{ww * S + 32}" height="10" fill="{g(t + 70)}"/>')
    # ground floor
    dc = L / 2
    if b.door == 'barn':
        dw, dh = 3.0, 2.9
        o.append(f'<rect x="{X(dc - dw / 2)}" y="{Y(dh)}" width="{dw * S}" height="{dh * S}" fill="{g(30)}" stroke="{g(t + 50)}" stroke-width="10"/>')
    else:
        dw, dh = (1.7, 2.4) if b.door == 'batwing' else (1.2, 2.35)
        o.append(f'<rect x="{X(dc - dw / 2) - 10}" y="{Y(dh) - 10}" width="{dw * S + 20}" height="{dh * S + 10}" fill="{g(t + 55)}"/>')
        o.append(f'<rect x="{X(dc - dw / 2)}" y="{Y(dh)}" width="{dw * S}" height="{dh * S}" fill="{g(26 if b.door == "batwing" else 50)}"/>')
        if b.door == 'batwing':
            for k in (0, 1):
                x = X(dc - dw / 2) + k * dw * S / 2 + 3
                o.append(f'<path d="M{x} {Y(1.75)} q{dw * S / 4 - 3} -34 {dw * S / 2 - 6} 0 v{1.0 * S} q-{dw * S / 4 - 3} 30 -{dw * S / 2 - 6} 0z" fill="{g(t + 25)}" stroke="{g(40)}" stroke-width="4"/>')
        else:
            o.append(f'<rect x="{X(dc - dw / 2) + 14}" y="{Y(dh) + 14}" width="{dw * S - 28}" height="{dh * S * .42}" fill="url(#w{i})"/>')
        for uc in (L * .2, L * .8):
            window(uc, .95, min(1.9, L * .2), 1.55)
    if b.storeys == 2:
        for uc in (L * .17, L * .5, L * .83):
            window(uc, 4.3, 1.05, 1.6)
    if b.extra == 'coffin':
        u = dc + dw / 2 + .78
        c = [(u - .2, .3), (u - .36, 1.62), (u - .2, 2.15), (u + .2, 2.15), (u + .36, 1.62), (u + .2, .3)]
        o.append(f'<polygon points="{pts([(X(a), Y(bb)) for a, bb in c])}" fill="{g(196)}" stroke="{g(40)}" stroke-width="7"/>')
        o.append(f'<path d="M{X(u)} {Y(1.95)}V{Y(1.25)}M{X(u - .17)} {Y(1.7)}H{X(u + .17)}" stroke="{g(60)}" stroke-width="8"/>')
    # shade under the porch roof, then distance haze
    o.append(f'<rect x="0" y="{Y(3.4)}" width="{w}" height="{3.4 * S}" fill="black" opacity=".3"/>')
    o.append(f'<rect width="{w}" height="{h}" fill="url(#f{i})"/>')
    o.append('</g></svg>')
    if side < 0:
        quad = [P(-WALL, b.H, b.z0), P(-WALL, b.H, b.z1), P(-WALL, 0, b.z1), P(-WALL, 0, b.z0)]
    else:
        quad = [P(WALL, b.H, b.z1), P(WALL, b.H, b.z0), P(WALL, 0, b.z0), P(WALL, 0, b.z1)]
    return f'<div class="q" style="width:{w}px;height:{h}px;transform:{matrix3d(w, h, quad)}">{"".join(o)}</div>'

def layer(inner):
    return f'<svg class="l" xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">{inner}</svg>'

def building(b, s):
    out = []
    o = []
    zm = (b.z0 + b.z1) / 2
    # wall facing the camera, seen through the alley and above lower neighbours
    (x0, y0), (x1, y1) = P(s * WALL, b.H - .7, b.z0), P(s * 19, 0, b.z0)
    xa, xb = min(x0, x1), max(x0, x1)
    o.append(f'<rect x="{xa:.1f}" y="{y0:.1f}" width="{xb - xa:.1f}" height="{y1 - y0:.1f}" fill="{g(b.tone - 42, b.z0)}"/>')
    step = .24 * F / b.z0
    n = int((y1 - y0) / step)
    o.append(f'<path d="{"".join(f"M{xa:.1f} {y0 + k * step:.1f}H{xb:.1f}" for k in range(1, n))}" stroke="black" stroke-opacity="{.22 * (1 - fogA(b.z0)):.2f}" stroke-width="{max(1, step * .12):.1f}"/>')
    out.append(layer(''.join(o)))
    out.append(facade(b, s))
    o = []
    top = 3.3
    edge = 3.3 if b.storeys == 2 else 2.95
    # boardwalk
    o.append(f'<polygon points="{pts([P(s * WALL, .3, b.z0), P(s * WALL, .3, b.z1), P(s * WALK, .3, b.z1), P(s * WALK, .3, b.z0)])}" fill="{g(150, zm)}"/>')
    o.append(f'<polygon points="{pts([P(s * WALK, .3, b.z0), P(s * WALK, .3, b.z1), P(s * WALK, 0, b.z1), P(s * WALK, 0, b.z0)])}" fill="{g(62, zm)}"/>')
    # porch roof underside and fascia board
    o.append(f'<polygon points="{pts([P(s * WALL, top, b.z0), P(s * WALL, top, b.z1), P(s * WALK, edge, b.z1), P(s * WALK, edge, b.z0)])}" fill="{g(48, zm)}"/>')
    o.append(f'<polygon points="{pts([P(s * WALK, edge + .08, b.z0), P(s * WALK, edge + .08, b.z1), P(s * WALK, edge - .2, b.z1), P(s * WALK, edge - .2, b.z0)])}" fill="{g(178, zm)}"/>')
    if b.storeys == 2:  # balcony rail
        z = b.z1
        while z >= b.z0 - .01:
            (xa, ya), (xb, yb) = P(s * WALK, 3.38, z), P(s * WALK, 4.25, z)
            o.append(f'<line x1="{xa:.1f}" y1="{ya:.1f}" x2="{xb:.1f}" y2="{yb:.1f}" stroke="{g(165, z)}" stroke-width="{.07 * F / z:.1f}"/>')
            z -= .42
        (xa, ya), (xb, yb) = P(s * WALK, 4.25, b.z0), P(s * WALK, 4.25, b.z1)
        o.append(f'<line x1="{xa:.1f}" y1="{ya:.1f}" x2="{xb:.1f}" y2="{yb:.1f}" stroke="{g(185, zm)}" stroke-width="{.12 * F / zm:.1f}"/>')
    # posts, far to near
    nposts = max(2, round((b.z1 - b.z0) / 2.6) + 1)
    for k in range(nposts - 1, -1, -1):
        z = b.z0 + .15 + (b.z1 - b.z0 - .3) * k / (nposts - 1)
        (xa, ya), (xb, yb) = P(s * WALK, .3, z), P(s * WALK, edge, z)
        o.append(f'<line x1="{xa:.1f}" y1="{ya:.1f}" x2="{xb:.1f}" y2="{yb:.1f}" stroke="{g(74, z)}" stroke-width="{.17 * F / z:.1f}"/>')
    if b.hang:
        z = b.z0 + .15
        (xa, ya), (xb, yb) = P(s * (WALK - .12), 2.72, z), P(s * (WALK - 1.75), 2.15, z)
        xl, xr = min(xa, xb), max(xa, xb)
        yarm = P(0, 2.86, z)[1]
        o.append(f'<line x1="{xa:.1f}" y1="{yarm:.1f}" x2="{xb:.1f}" y2="{yarm:.1f}" stroke="{g(60, z)}" stroke-width="{.07 * F / z:.1f}"/>')
        for xx in (xl + (xr - xl) * .12, xr - (xr - xl) * .12):
            o.append(f'<line x1="{xx:.1f}" y1="{ya:.1f}" x2="{xx:.1f}" y2="{yarm:.1f}" stroke="{g(50, z)}" stroke-width="{max(1.5, .03 * F / z):.1f}"/>')
        o.append(f'<rect x="{xl:.1f}" y="{ya:.1f}" width="{xr - xl:.1f}" height="{yb - ya:.1f}" fill="{g(208, z)}" stroke="{g(45, z)}" stroke-width="{.05 * F / z:.1f}"/>')
        fs = (yb - ya) * .66
        tl = min(len(b.hang) * fs * .78, (xr - xl) * .86)
        o.append(f'<text x="{(xl + xr) / 2:.1f}" y="{yb - (yb - ya) * .24:.1f}" text-anchor="middle" font-family="Q" font-size="{fs:.1f}" textLength="{tl:.1f}" lengthAdjust="spacingAndGlyphs" fill="{g(35, z)}">{b.hang}</text>')
    out.append(layer(''.join(o)))
    return ''.join(out)

def barrel(X, Z):
    sc = F / Z
    x, y = P(X, .3, Z)
    w, h = .62 * sc, .92 * sc
    return (f'<g><rect x="{x - w / 2:.1f}" y="{y - h:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{w * .16:.1f}" fill="{g(92, Z)}"/>'
            f'<ellipse cx="{x:.1f}" cy="{y - h:.1f}" rx="{w / 2:.1f}" ry="{w * .1:.1f}" fill="{g(130, Z)}"/>'
            f'<path d="M{x - w / 2:.1f} {y - h * .72:.1f}h{w:.1f}M{x - w / 2:.1f} {y - h * .25:.1f}h{w:.1f}" stroke="{g(40, Z)}" stroke-width="{max(1.5, h * .05):.1f}"/></g>')

def hitching(s, za, zb):
    o = []
    for z in (zb, za):
        (xa, ya), (xb, yb) = P(s * 3.3, 0, z), P(s * 3.3, 1.05, z)
        o.append(f'<line x1="{xa:.1f}" y1="{ya:.1f}" x2="{xb:.1f}" y2="{yb:.1f}" stroke="{g(80, z)}" stroke-width="{.11 * F / z:.1f}"/>')
    (xa, ya), (xb, yb) = P(s * 3.3, 1.0, za), P(s * 3.3, 1.0, zb)
    w0, w1 = .08 * F / za, .08 * F / zb
    o.append(f'<polygon points="{xa:.1f},{ya - w0 / 2:.1f} {xb:.1f},{yb - w1 / 2:.1f} {xb:.1f},{yb + w1 / 2:.1f} {xa:.1f},{ya + w0 / 2:.1f}" fill="{g(84, (za + zb) / 2)}"/>')
    return ''.join(o)

def figure():
    half = [(4, 29), (20, 36), (24, 42), (37, 68), (36, 98), (32, 103), (29, 96), (30, 70), (21, 50), (17, 78),
            (22, 96), (23, 108), (19, 110), (27, 150), (12, 152), (20, 190), (27, 197), (27, 200), (8, 200), (7, 160), (0, 120)]
    body = half + [(-x, y) for x, y in reversed(half[:-1])]
    d = (f'<polygon points="{pts(body)}"/><ellipse cx="0" cy="21" rx="7.5" ry="9.5"/>'
         f'<ellipse cx="0" cy="14.5" rx="26" ry="3.6"/><polygon points="-10.5,14 -9.5,3 -5,0 0,2.2 5,0 9.5,3 10.5,14"/>')
    Z = 15.0
    x, y = P(0, 0, Z)
    sc = 1.86 * F / Z / 200
    shadow = f'<g transform="translate({x:.1f},{y:.1f}) skewX(-8) scale({sc * 1.25:.3f},{-sc * 2.3:.3f}) translate(0,-200)" fill="black" opacity=".34" filter="url(#soft)">{d}</g>'
    man = f'<g transform="translate({x:.1f},{y:.1f}) scale({sc:.3f}) translate(0,-200)" fill="{g(30, Z)}">{d}</g>'
    return shadow + man

def base():
    o = ['<defs>']
    o.append(f'<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{g(138)}"/><stop offset=".62" stop-color="{g(232)}"/></linearGradient>')
    o.append(f'<radialGradient id="sun" cx="{CX}" cy="{HY - 250}" r="900" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="white" stop-opacity=".6"/><stop offset="1" stop-color="white" stop-opacity="0"/></radialGradient>')
    o.append(f'<linearGradient id="dirt" x1="0" y1="{HY}" x2="0" y2="{H}" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="{g(232)}"/><stop offset=".25" stop-color="{g(205)}"/><stop offset="1" stop-color="{g(158)}"/></linearGradient>')
    o.append('<filter id="soft"><feGaussianBlur stdDeviation="2.5"/></filter><filter id="cloud"><feGaussianBlur stdDeviation="22"/></filter>')
    o.append('<filter id="gn" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="0.006 0.09" numOctaves="4" seed="5"/><feColorMatrix type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  1.1 0 0 0 -0.36"/></filter>')
    o.append('</defs>')
    o.append(f'<rect width="{W}" height="{H}" fill="url(#sky)"/>')
    for cx, cy, rx, ry, op in ((380, 250, 420, 46, .5), (1500, 160, 520, 40, .45), (1150, 420, 380, 30, .4), (250, 520, 300, 26, .35), (1800, 480, 330, 28, .35)):
        o.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="white" opacity="{op}" filter="url(#cloud)"/>')
    o.append(f'<rect width="{W}" height="{H}" fill="url(#sun)"/>')
    # mesas on the horizon
    o.append(f'<polygon points="{pts([(560, HY), (640, HY - 34), (700, HY - 40), (760, HY - 96), (905, HY - 100), (940, HY - 52), (1010, HY - 44), (1060, HY)])}" fill="{g(158)}"/>')
    o.append(f'<polygon points="{pts([(1010, HY), (1080, HY - 30), (1130, HY - 70), (1235, HY - 74), (1262, HY - 40), (1330, HY - 30), (1400, HY)])}" fill="{g(170)}"/>')
    o.append(f'<polygon points="{pts([(830, HY), (900, HY - 16), (1180, HY - 20), (1260, HY)])}" fill="{g(184)}"/>')
    # ground
    o.append(f'<rect y="{HY}" width="{W}" height="{H - HY}" fill="url(#dirt)"/>')
    o.append(f'<rect y="{HY}" width="{W}" height="{H - HY}" filter="url(#gn)"/>')
    for xb, op, sw in ((-1.6, .2, 24), (-1.2, .14, 14), (1.3, .2, 24), (1.75, .13, 14), (-3.1, .08, 30), (3.3, .08, 30)):
        (xa, ya), (xc, yc) = P(xb, 0, 4.4), P(xb, 0, 60)
        o.append(f'<polygon points="{xc:.1f},{yc:.1f} {xa - sw:.1f},{ya:.1f} {xa + sw:.1f},{ya:.1f}" fill="black" opacity="{op}"/>')
    # far end of town: water tower and windmill
    z = 68
    x, y = P(12.5, 0, z); sc = F / z
    o.append(f'<g fill="{g(120, z)}" stroke="{g(120, z)}"><rect x="{x - 2 * sc:.1f}" y="{y - 9 * sc:.1f}" width="{4 * sc:.1f}" height="{3.4 * sc:.1f}"/><polygon points="{x - 2.3 * sc:.1f},{y - 9 * sc:.1f} {x:.1f},{y - 10.4 * sc:.1f} {x + 2.3 * sc:.1f},{y - 9 * sc:.1f}"/>'
             f'<path d="M{x - 1.8 * sc:.1f} {y - 5.6 * sc:.1f}L{x - 2.4 * sc:.1f} {y:.1f}M{x + 1.8 * sc:.1f} {y - 5.6 * sc:.1f}L{x + 2.4 * sc:.1f} {y:.1f}M{x - 2.2 * sc:.1f} {y - 2 * sc:.1f}L{x + 2 * sc:.1f} {y - 5 * sc:.1f}M{x + 2.2 * sc:.1f} {y - 2 * sc:.1f}L{x - 2 * sc:.1f} {y - 5 * sc:.1f}" stroke-width="{.3 * sc:.1f}" fill="none"/></g>')
    z = 74
    x, y = P(-13, 0, z); sc = F / z
    blades = ''.join(f'<line x1="{x:.1f}" y1="{y - 10 * sc:.1f}" x2="{x + 2 * sc * math.cos(a * math.pi / 6):.1f}" y2="{y - 10 * sc + 2 * sc * math.sin(a * math.pi / 6):.1f}" stroke-width="{.35 * sc:.1f}"/>' for a in range(12))
    o.append(f'<g stroke="{g(120, z)}" fill="none"><path d="M{x:.1f} {y - 10 * sc:.1f}L{x - 1.6 * sc:.1f} {y:.1f}M{x:.1f} {y - 10 * sc:.1f}L{x + 1.6 * sc:.1f} {y:.1f}M{x - 1 * sc:.1f} {y - 4 * sc:.1f}h{2 * sc:.1f}" stroke-width="{.25 * sc:.1f}"/>{blades}</g>')
    return layer(''.join(o))

html = [f'''<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{{font-family:Q;src:url("file://{FONT}")}}
html,body{{margin:0;background:#888}}
#s{{position:relative;width:{W}px;height:{H}px;overflow:hidden}}
.l{{position:absolute;left:0;top:0}}
.q{{position:absolute;left:0;top:0;transform-origin:0 0}}
.q svg{{display:block}}
</style></head><body><div id="s">''']
html.append(base())
for side, row in ((-1, LEFT), (1, RIGHT)):
    for b in reversed(row):
        html.append(building(b, side))
        props = ''
        if b.name == 'SALOON':
            props += barrel(-4.4, 22.2) + barrel(-5.0, 22.9) + hitching(-1, 24, 28)
        if b.name == 'HARDWARE':
            props += barrel(-4.4, 18.4) + barrel(-5.0, 12.2)
        if b.name == 'GENERAL STORE':
            props += barrel(4.4, 21) + barrel(5.0, 21.6) + barrel(4.4, 28.5) + hitching(1, 23, 27)
        if b.name == 'UNDERTAKER':
            props += barrel(4.5, 17.6)
        if props:
            html.append(layer(props))
html.append(layer('<defs><filter id="soft"><feGaussianBlur stdDeviation="2.5"/></filter></defs>' + figure()))
html.append('</div></body></html>')
open(sys.argv[2], 'w').write(''.join(html))
