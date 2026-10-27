"""Gera os passos (command_batch do FilmCraft) para montar um corte a partir de planos.json + config.

Uso:
  python -I gerar_batches.py <config.json> <planos.json> <corte> rodada1
      -> sequência, trechos, trilha, legendas, selo, gancho, barra de progresso e overlay do CTA.
  python -I gerar_batches.py <config.json> <planos.json> <corte> rodada2 <gancho> <barra> <trilha> <voz>
      -> palavra-chave do gancho na cor de destaque, pop do gancho, barra animada e fades.
     ids: <gancho> = clipe do texto do gancho, <barra> = clipe da barra de destaque, <trilha> = clipe de
     áudio da trilha, <voz> = último clipe de áudio de voz (todos vêm no resultado da rodada 1).
Imprime JSON compacto para colar em mcp__filmcraft__command_batch {steps: ...}.
Tudo que é visual vem de config["identidade"]; layout "C" = câmera cheia, "T" = tela compartilhada.
"""
import json, sys

TPS = 254016000000
cfg = json.load(open(sys.argv[1]))
pl = json.load(open(sys.argv[2]))[sys.argv[3]]
modo = sys.argv[4]
idv = cfg["identidade"]
fps = cfg.get("fps", 30)
tk = lambda s: round(s * fps) * TPS // fps
pos = idv["posicoes"]["split" if pl["layout"] == "T" else "camera"]
fim, cta = pl["fim"], round(pl["cta_inicio"] * fps) / fps
fonte = {"font": idv["fonte"], "font_style": idv["estilo_fonte"], "align": "center"}

if modo == "rodada1":
    st = [{"id": "file.newSequence", "params": {"name": sys.argv[3], "width": 1080, "height": 1920, "fps": fps,
           "sampleRate": 48000, "video": 5, "audio": 2}}]
    st += pl["steps"]
    if idv.get("trilha_item"):
        st += [{"id": "timeline.place", "params": {"item": idv["trilha_item"], "track": "A2", "frame": 0,
                "insert": False, "duration": tk(fim)}},
               {"id": "timeline.setTrack", "params": {"track": "A2", "volumeDb": idv.get("trilha_db", -9)}}]
    st += [
        {"id": "captions.import", "params": {"path": pl["srt"], "name": "Legendas"}},
        {"id": "captions.setStyle", "params": {"track": "C1", "font": f"{idv['fonte']} {idv['estilo_fonte']}",
         "size": pos["legenda_tamanho"], "color": idv["cor_texto"], "background": False, "align": "center",
         "anchor": "bottom", "margin": pos["legenda_margem"], "outline": 5, "outlineColor": "#000000"}},
        {"id": "graphics.newText", "params": {"text": idv["selo"], "position": [540, pos["selo_y"]], "size": 30,
         "seconds": fim, "track": 2, "time": 0}},
        {"id": "graphics.set", "params": {"props": {**fonte, "fill_color": idv["cor_destaque"], "tracking": 220}}},
        {"id": "graphics.newText", "params": {"text": pl["gancho"], "position": [540, pos["gancho_y"]],
         "size": pos["gancho_tamanho"], "seconds": cta, "track": 3, "time": 0}},
        {"id": "graphics.set", "params": {"props": {**fonte, "fill_color": idv["cor_texto"], "leading": -6, "shadow": True}}},
        {"id": "graphics.newRectangle", "params": {"position": [540, 1790], "size": [1000, 10], "seconds": fim, "track": 4, "time": 0}},
        {"id": "graphics.set", "params": {"props": {"fill_color": idv["cor_trilho_barra"], "corner_radius": 5}}},
        {"id": "graphics.newRectangle", "params": {"position": [540, 1790], "size": [1000, 10], "seconds": fim, "track": 5, "time": 0}},
        {"id": "graphics.set", "params": {"props": {"fill_color": idv["cor_destaque"], "corner_radius": 5}}},
    ]
    if idv.get("overlay_cta_item"):
        st.append({"id": "timeline.place", "params": {"item": idv["overlay_cta_item"], "track": "V4", "time": tk(cta),
                   "insert": False, "duration": tk(fim) - tk(cta), "audio": False}})
elif modo == "rodada2":
    gancho, barra, trilha, voz = map(int, sys.argv[5:9])
    corte = cfg["cortes"][sys.argv[3]]
    st = []
    k = corte.get("destaque")
    if k and k in pl["gancho"]:
        i = pl["gancho"].index(k)
        st.append({"id": "graphics.setCharStyle", "params": {"clip": gancho, "layer": 0, "start": i, "end": i + len(k),
                   "style": {"color": idv["cor_destaque"]}}})
    y = pos["gancho_y"] + pos["gancho_tamanho"] // 2
    st += [{"id": "effects.setParam", "params": {"clip": gancho, "effect": "motion", "param": p, "value": [540, y]}}
           for p in ("anchor", "position")]
    st += [{"id": "effects.setParam", "params": {"clip": gancho, "effect": "motion", "param": "scale", "value": v,
            "time": tk(t), "keyframe": True}} for t, v in ((0, 40), (0.2, 108), (0.33, 100))]
    st += [{"id": "effects.setParam", "params": {"clip": barra, "effect": "motion", "param": "uniform_scale", "value": False}},
           {"id": "effects.setParam", "params": {"clip": barra, "effect": "motion", "param": "anchor", "value": [40, 1790]}},
           {"id": "effects.setParam", "params": {"clip": barra, "effect": "motion", "param": "position", "value": [40, 1790]}},
           {"id": "effects.setParam", "params": {"clip": barra, "effect": "motion", "param": "scale_width", "value": 0,
            "time": 0, "keyframe": True}},
           {"id": "effects.setParam", "params": {"clip": barra, "effect": "motion", "param": "scale_width", "value": 100,
            "time": tk(fim) - 1, "keyframe": True}},
           {"id": "sequence.applyAudioTransition", "params": {"clip": trilha, "edge": "out", "frames": 45}},
           {"id": "sequence.applyAudioTransition", "params": {"clip": voz, "edge": "out", "frames": 8}}]
else:
    sys.exit("modo deve ser rodada1 ou rodada2")
print(json.dumps(st, ensure_ascii=False, separators=(",", ":")))
