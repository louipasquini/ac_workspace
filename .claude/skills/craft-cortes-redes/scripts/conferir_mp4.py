"""Confere um MP4 exportado: duração, resolução, fps, codec de áudio, nível (RMS/pico) e grade de 4 quadros.

Uso: python -I conferir_mp4.py <video.mp4> <grade.png>
A grade (1 s, 40%, 70%, fim-2 s) serve para olhar gancho, meio, legenda e CTA com a ferramenta Read.
Decodifica a partir do seek até alcançar o tempo pedido (o seek sozinho cai no keyframe anterior).
"""
import struct, sys, zlib

import av
import numpy as np

p, out = sys.argv[1], sys.argv[2]
c = av.open(p)
v, a = c.streams.video[0], c.streams.audio[0]
dur = float(c.duration / 1e6)
print("dur %.2fs  %dx%d  %s fps  audio %s %dHz" % (dur, v.width, v.height, v.average_rate, a.codec_context.name, a.rate))
imgs = []
for t in (1.0, dur * 0.4, dur * 0.7, dur - 2):
    c.seek(int(t * 1e6), any_frame=False, backward=True)
    for f in c.decode(video=0):
        if f.time >= t - 0.05:
            imgs.append(f.to_ndarray(format="rgb24")[::4, ::4]); break
g = np.concatenate(imgs, axis=1)
raw = b"".join(b"\x00" + g[y].tobytes() for y in range(g.shape[0]))
ch = lambda t, d: struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
open(out, "wb").write(b"\x89PNG\r\n\x1a\n" + ch(b"IHDR", struct.pack(">IIBBBBB", g.shape[1], g.shape[0], 8, 2, 0, 0, 0))
                      + ch(b"IDAT", zlib.compress(raw)) + ch(b"IEND", b""))
s = np.concatenate([f.to_ndarray().reshape(-1) for f in av.open(p).decode(audio=0)]).astype(float)
print("áudio rms %.1f dBFS  pico %.1f dBFS" % (20 * np.log10(np.sqrt((s ** 2).mean()) + 1e-9),
                                               20 * np.log10(np.abs(s).max() + 1e-9)))
