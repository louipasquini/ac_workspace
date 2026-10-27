"""Planeja os cortes: jump cuts (remove pausas), punch-in alternado, CTA comum e SRT de legendas.

Uso: python -I planejar_cortes.py <config.json> <palavras.json> <pasta_srt> <planos.json>
config.json (ver referencias/config-exemplo.json):
  fps, gap (pausa removida, s), pre/post (folga antes/depois da fala, s)
  bases: {"C": [id_normal, id_punchin], "T": [...]}   ids das sequências-base no FilmCraft
  layouts: [[ini, fim, "C"|"T"], ...]                  qual base usar por trecho da fonte
  correcoes: {"errado": "certo"}                       só termos confirmados (ver suspeitas.txt)
  cta: [[ini, fim], ...]  cta_limite_fim: s            frases do CTA (terminar em entonação descendente)
  respiro: [ini, fim]                                  vídeo sem áudio após o CTA (boca fechada)
  cortes: {"nome": {"gancho": "TEXTO\\nEM 2 LINHAS", "trechos": [[ini, fim], ...]}}
Saída planos.json: por corte {gancho, layout, steps (timeline.place), cta_inicio, fim, srt}.
Os steps usam frame/ticks inteiros (1 s = 254016000000 ticks) e alternam as bases A/B a cada trecho.
"""
import json, re, sys

cfg = json.load(open(sys.argv[1]))
W = json.load(open(sys.argv[2]))
SRT_DIR, OUT = sys.argv[3], sys.argv[4]
TPS = 254016000000
FPS = cfg.get("fps", 30)
GAP, PRE, POST = cfg.get("gap", 0.40), cfg.get("pre", 0.06), cfg.get("post", 0.10)
BASES, FIX = cfg["bases"], cfg.get("correcoes", {})
STOP = {"no", "na", "nos", "nas", "de", "do", "da", "dos", "das", "a", "o", "as", "os", "com", "pra", "para",
        "que", "e", "em", "um", "uma", "se", "eu", "ela", "ele", "seu", "sua", "meu", "minha", "mais", "por"}

def layout(t):
    for a, b, k in cfg["layouts"]:
        if a <= t < b:
            return k
    return cfg["layouts"][-1][2]

def frames(t):
    return round(t * FPS)

def pieces(ranges):
    grupos = []
    for a, b in ranges:
        ws = [w for w in W if a - 0.03 <= w["s"] < b]
        if not ws:
            sys.exit(f"nenhuma palavra em {a}-{b}")
        cur = [ws[0]]
        for w in ws[1:]:
            if w["s"] - cur[-1]["e"] >= GAP:
                grupos.append(cur); cur = [w]
            else:
                cur.append(w)
        grupos.append(cur)
    res = []
    for g in grupos:
        i, o = g[0]["s"] - PRE, g[-1]["e"] + POST
        if res and res[-1]["in"] < i < res[-1]["out"]:   # só ajusta sobreposição real (trechos podem voltar no tempo)
            i = res[-1]["out"]
        res.append({"in": i, "out": o, "words": g})
    return res

def clean(tok):
    t = tok.strip()
    core = t.rstrip(",.?!")
    return FIX[t] if t in FIX else (FIX[core] + t[len(core):] if core in FIX else t)

def chunks(timed):
    """[(texto, ini, fim)] -> legendas de até 3 palavras / 16 caracteres, sem terminar em artigo/preposição."""
    res, cur = [], []
    for tok, s, e in timed:
        if tok == "|":                                   # fronteira forçada (início/troca de frase do CTA)
            if cur: res.append(cur)
            cur = []; continue
        if tok.startswith("-") and cur:                  # check-up, limpa-mesa
            t, cs, _ = cur[-1]; cur[-1] = (t + tok, cs, e); continue
        if cur and (len(cur) >= 3 or len(" ".join(c[0] for c in cur) + tok) > 16):
            carry = []
            while len(cur) > 1 and cur[-1][0].lower() in STOP:
                carry.insert(0, cur.pop())
            res.append(cur); cur = carry
        cur.append((tok, s, e))
        if re.search(r"[.?!]$", tok) or (tok.endswith(",") and len(cur) >= 2):
            res.append(cur); cur = []
    if cur:
        res.append(cur)
    out = []
    for c in res:
        txt = re.sub(r"[.,]+(?=\s|$)", "", " ".join(t for t, _, _ in c)).upper()
        out.append([txt, c[0][1], c[-1][2]])
    for a, b in zip(out, out[1:]):
        a[2] = b[1]
    out[-1][2] += 0.3
    return out

def srt_time(t):
    ms = int(round(t * 1000)); h, ms = divmod(ms, 3600000); m, ms = divmod(ms, 60000); s, ms = divmod(ms, 1000)
    return f"{h:02}:{m:02}:{s:02},{ms:03}"

def place(item, t, a, dur, audio=True):
    p = {"item": item, "track": "V1", "frame": round(t * FPS), "insert": False,
         "sourceIn": frames(a) * TPS // FPS, "duration": dur * TPS // FPS}
    if audio:
        p["audioTrack"] = "A1"
    else:
        p["audio"] = False
    return {"id": "timeline.place", "params": p}

planos = {}
for nome, c in cfg["cortes"].items():
    cta = pieces(cfg["cta"])
    if "cta_limite_fim" in cfg:
        cta[-1]["out"] = min(cta[-1]["out"], cfg["cta_limite_fim"])
    t, steps, timed, k = 0.0, [], [], 0
    for parte, lst in (("main", pieces(c["trechos"])), ("cta", cta)):
        if parte == "cta":
            cta_inicio = t
            timed.append(("|", t, t))
        prev = None
        for p in lst:
            if parte == "cta" and prev is not None and abs(p["in"] - prev) > 2:
                timed.append(("|", t, t))
            prev = p["out"]
            base = BASES[layout(p["in"])]
            dur = frames(p["out"]) - frames(p["in"])
            steps.append(place(base[k % 2], t, p["in"], dur))
            t0 = round(t * FPS) / FPS - frames(p["in"]) / FPS
            timed += [(clean(w["w"]), t0 + w["s"], t0 + w["e"]) for w in p["words"]]
            t = (round(t * FPS) + dur) / FPS
            k += 1
    if "respiro" in cfg:
        a, b = cfg["respiro"]
        dur = frames(b) - frames(a)
        steps.append(place(BASES[layout(a)][k % 2], t, a, dur, audio=False))
        t = (round(t * FPS) + dur) / FPS
    caps = chunks(timed)
    caminho = f"{SRT_DIR}/{nome}.srt"
    open(caminho, "w").write("\n".join(f"{i + 1}\n{srt_time(s)} --> {srt_time(e)}\n{txt}\n"
                                       for i, (txt, s, e) in enumerate(caps)))
    planos[nome] = {"gancho": c["gancho"], "layout": layout(c["trechos"][0][0]), "steps": steps,
                    "cta_inicio": cta_inicio, "fim": t, "srt": caminho}
    print(f"{nome}: {len(steps)} trechos, conteúdo {cta_inicio:.1f}s + CTA {t - cta_inicio:.1f}s = {t:.1f}s")
json.dump(planos, open(OUT, "w"), ensure_ascii=False, indent=1)
