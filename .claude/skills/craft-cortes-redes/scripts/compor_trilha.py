"""Compõe uma trilha de fundo em MIDI (tipo 1) para importar no SoundCraft (file.import_midi).

Uso: python -I compor_trilha.py <saida.mid> [--clima epico|inspirador|calmo|energetico] [--bpm N]
                                [--tom La] [--modo menor|maior] [--compassos N]
Faixas: Cordas (pad), Piano (arpejo em colcheias), Sub (grave), Tema (melodia), Percussão (canal 10).
Estrutura: intro (2 compassos) → crescendo (4) → cheio → respiro (4) → cheio → acorde final com cauda,
para que cortes curtos já alcancem a parte cheia em ~15–20 s.
"""
import argparse, struct

CLIMAS = {  # bpm, modo, percussão (0 nenhuma, 1 leve, 2 cheia), progressão em graus da escala
    "epico":      (80, "menor", 2, [0, 5, 2, 6]),   # i-VI-III-VII  (Am-F-C-G em Lá menor)
    "inspirador": (96, "maior", 1, [0, 4, 5, 3]),   # I-V-vi-IV
    "calmo":      (70, "maior", 0, [0, 5, 3, 4]),   # I-vi-IV-V
    "energetico": (120, "maior", 2, [0, 4, 5, 3]),
}
TONS = {"Do": 48, "Re": 50, "Mi": 52, "Fa": 53, "Sol": 55, "La": 57, "Si": 59}
ESCALA = {"maior": [0, 2, 4, 5, 7, 9, 11], "menor": [0, 2, 3, 5, 7, 8, 10]}

ap = argparse.ArgumentParser()
ap.add_argument("saida")
ap.add_argument("--clima", default="epico", choices=CLIMAS)
ap.add_argument("--bpm", type=int)
ap.add_argument("--tom", default="La", choices=TONS)
ap.add_argument("--modo", choices=ESCALA)
ap.add_argument("--compassos", type=int, default=34)
a = ap.parse_args()
bpm, modo, perc_nivel, prog = CLIMAS[a.clima]
bpm, modo = a.bpm or bpm, a.modo or modo
esc, raiz = ESCALA[modo], TONS[a.tom]

def grau(g, oit=0):
    return raiz + esc[g % 7] + 12 * (g // 7 + oit)

def triade(g):
    return [grau(g), grau(g + 2), grau(g + 4)]

Q, BAR, E = 960, 3840, 480
BARS = a.compassos

def secao(b):
    if b < 2: return "intro"
    if b < 6: return "build"
    if b < BARS // 2: return "cheio"
    if b < BARS // 2 + 4: return "respiro"
    if b < BARS - 2: return "cheio"
    return "fim"

def vlq(n):
    out = [n & 0x7F]; n >>= 7
    while n:
        out.insert(0, (n & 0x7F) | 0x80); n >>= 7
    return bytes(out)

def faixa(nome, notas, ch):
    ev = []
    for p, st, ln, v in notas:
        ev += [(st, 1, bytes([0x90 | ch, p, v])), (st + ln, 0, bytes([0x80 | ch, p, 0]))]
    ev.sort(key=lambda e: (e[0], e[1]))
    d, t = b"\x00\xff\x03" + vlq(len(nome)) + nome.encode(), 0
    for at, _, msg in ev:
        d += vlq(at - t) + msg; t = at
    d += b"\x00\xff\x2f\x00"
    return b"MTrk" + struct.pack(">I", len(d)) + d

# tema de 4 compassos em graus da escala (nota, início e duração em colcheias)
TEMA = [(9, 0, 3), (8, 3, 1), (7, 4, 4), (10, 8, 3), (9, 11, 1), (7, 12, 4),
        (11, 16, 3), (10, 19, 1), (9, 20, 4), (8, 24, 6), (6, 30, 2)]
cordas, piano, sub, tema, perc = [], [], [], [], []
inicio_cheio = [b for b in range(BARS) if secao(b) == "cheio" and secao(b - 1) != "cheio"]
for b in range(BARS):
    s, t0, g = secao(b), b * BAR, prog[b % len(prog)]
    if s == "fim":
        if b == BARS - 2:
            cordas += [(n, t0, 2 * BAR, 90) for n in triade(0) + [grau(0, 1)]]
            sub.append((grau(0, -2), t0, 2 * BAR, 110))
            if perc_nivel: perc += [(36, t0, 400, 127), (49, t0, 3000, 120)]
        continue
    vel = {"intro": 58, "build": 72, "cheio": 92, "respiro": 64}[s]
    up = 12 if s == "cheio" and b > BARS // 2 else 0
    cordas += [(n + up, t0, BAR - 30, vel) for n in triade(g)] + [(grau(g, -1), t0, BAR - 30, vel - 6)]
    arp = triade(g) + [grau(g, 1)]
    for i in range(8):
        piano.append((arp[[0, 1, 2, 3, 2, 1, 2, 3][i]] + 12, t0 + i * E, E + 200, vel - 4 + (8 if i % 4 == 0 else 0)))
    if s != "intro":
        sub.append((grau(g, -2), t0, BAR - 30, 100 if s == "cheio" else 80))
    if s == "cheio" and any((b - c) % 4 == 0 and b >= c for c in inicio_cheio):
        tema += [(grau(n, 1) + up, t0 + st * E, ln * E - 40, 96) for n, st, ln in TEMA]
    if perc_nivel and s == "build":
        perc += [(36, t0, 300, 90 + 6 * (b - 2)), (45, t0 + 2 * Q, 300, 70 + 6 * (b - 2))]
        if b == 5:
            perc += [(38, t0 + i * (Q // 4), 80, 40 + i * 5) for i in range(16)]
    if perc_nivel and s == "cheio":
        perc += [(36, t0, 300, 120), (36, t0 + 2 * Q + E, 300, 105)]
        if perc_nivel == 2:
            perc += [(41, t0 + Q, 300, 100), (43, t0 + 3 * Q, 300, 105), (45, t0 + 3 * Q + E, 300, 110),
                     (39, t0 + 2 * Q, 200, 95)]
        if b in inicio_cheio or (b - inicio_cheio[0]) % 8 == 0:
            perc.append((49, t0, 3000, 118))
    if perc_nivel and s == "respiro" and secao(b + 1) == "cheio":
        perc += [(38, t0 + i * (Q // 4), 80, 35 + i * 5) for i in range(16)]

us = int(60_000_000 / bpm)
cond = b"\x00\xff\x51\x03" + us.to_bytes(3, "big") + b"\x00\xff\x58\x04\x04\x02\x18\x08\x00\xff\x2f\x00"
open(a.saida, "wb").write(b"MThd" + struct.pack(">IHHH", 6, 1, 6, Q) + b"MTrk" + struct.pack(">I", len(cond)) + cond
                          + faixa("Cordas", cordas, 0) + faixa("Piano", piano, 1) + faixa("Sub", sub, 2)
                          + faixa("Tema", tema, 3) + faixa("Percussao", perc, 9))
print(f"ok: {a.clima}, {bpm} BPM, {a.tom} {modo}, {BARS} compassos = {BARS * 4 * 60 / bpm:.0f} s")
