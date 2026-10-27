"""Transcreve um vídeo/áudio com faster-whisper e grava palavras com tempo.

Uso: python -I transcrever.py <midia> <saida.json> [modelo=small] [idioma=pt]
Saída: lista de segmentos {start, end, text, words:[{w, s, e, p}]} (p = probabilidade da palavra).
O JSON é regravado a cada 20 segmentos, então dá para acompanhar/reaproveitar se o processo cair.

O áudio é decodificado aqui com PyAV (16 kHz mono) e passado como array: o decode_audio do
faster-whisper quebra com PyAV >= 14 ("unexpected keyword argument 'metadata_errors'").
"""
import json, sys, time

import av
import numpy as np
from faster_whisper import WhisperModel

src, out = sys.argv[1], sys.argv[2]
model_name = sys.argv[3] if len(sys.argv) > 3 else "small"
lang = sys.argv[4] if len(sys.argv) > 4 else "pt"

c = av.open(src)
r = av.AudioResampler(format="s16", layout="mono", rate=16000)
buf = []
for fr in c.decode(audio=0):
    for o in r.resample(fr):
        buf.append(o.to_ndarray().reshape(-1))
for o in r.resample(None):
    buf.append(o.to_ndarray().reshape(-1))
audio = np.concatenate(buf).astype(np.float32) / 32768.0
print("audio", round(len(audio) / 16000, 1), "s", flush=True)

model = WhisperModel(model_name, device="cpu", compute_type="int8")
segs, info = model.transcribe(audio, language=lang, word_timestamps=True, vad_filter=True, beam_size=5)
res, t0 = [], time.time()
for s in segs:
    res.append({"start": s.start, "end": s.end, "text": s.text.strip(),
                "words": [{"w": w.word, "s": w.start, "e": w.end, "p": w.probability} for w in s.words]})
    print(f"[{s.start:7.1f}] {s.text.strip()}", flush=True)
    if len(res) % 20 == 0:
        json.dump(res, open(out, "w"), ensure_ascii=False)
json.dump(res, open(out, "w"), ensure_ascii=False)
print("DONE", round(info.duration, 1), "s de mídia em", round(time.time() - t0), "s", flush=True)
