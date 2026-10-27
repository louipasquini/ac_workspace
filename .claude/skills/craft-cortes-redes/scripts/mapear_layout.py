"""Mapeia trocas de layout de um vídeo (câmera cheia x tela compartilhada x slide) e cortes de cena.

Uso: python -I mapear_layout.py <video> <saida.json> [passo_s=2] [x0 y0 x1 y1 da região-teste em fração]
- Decodifica em sequência (NÃO usar seek + primeiro frame: o seek cai no keyframe anterior e devolve
  o quadro errado — já gerou miniaturas enganosas).
- Mede, a cada passo, brilho médio e desvio da região-teste (padrão: faixa esquerda 0-20% da largura,
  que fica clara/lisa em tela compartilhada e texturizada em câmera) e o brilho do quadro inteiro.
- Imprime as trocas (salto de brilho > 8) com o tempo exato, e grava a série em JSON.
Sempre confirme olhando quadros (render_frame) nos limites: a heurística erra em telas escuras/slides.
"""
import json, sys

import av

src, out = sys.argv[1], sys.argv[2]
step = float(sys.argv[3]) if len(sys.argv) > 3 else 2.0
x0, y0, x1, y1 = map(float, sys.argv[4:8]) if len(sys.argv) > 7 else (0, 0, 0.2, 1)

c = av.open(src)
v = c.streams.video[0]
v.thread_type = "AUTO"
serie, nxt, prev = [], 0.0, None
for f in c.decode(v):
    t = float(f.pts * v.time_base)
    g = f.to_ndarray(format="gray")
    m = float(g[::16, ::16].mean())
    if prev is not None and abs(m - prev) > 8:
        print(f"troca em {t:8.2f}s  brilho {prev:.0f} -> {m:.0f}", flush=True)
    prev = m
    if t < nxt:
        continue
    nxt = t + step
    h, w = g.shape
    reg = g[int(y0 * h):int(y1 * h):8, int(x0 * w):int(x1 * w):8]
    serie.append({"t": round(t, 2), "geral": round(m, 1), "reg_media": round(float(reg.mean()), 1),
                  "reg_desvio": round(float(reg.std()), 1)})
json.dump(serie, open(out, "w"))
print("ok", len(serie), "amostras")
