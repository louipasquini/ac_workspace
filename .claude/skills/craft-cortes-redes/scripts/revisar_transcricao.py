"""Gera material de revisão de uma transcrição do transcrever.py.

Uso: python -I revisar_transcricao.py <transcricao.json> <pasta_saida>
Grava em <pasta_saida>:
  leitura.txt   - um segmento por linha "[mm:ss|seg] texto", para ler a live inteira e escolher cortes
  palavras.json - lista plana de palavras {w, s, e, p} (entrada do planejar_cortes.py)
  suspeitas.txt - palavras para revisar: baixa confiança, maiúsculas no meio da frase (nomes,
                  marcas), palavras raras e termos recorrentes com confiança média baixa (o modelo
                  erra um termo desconhecido sempre do mesmo jeito, às vezes com grafias variadas)
Nada é corrigido automaticamente: as correções vão no "correcoes" do config do planejar_cortes.py,
depois de confirmadas pelo contexto (e, na dúvida, perguntadas ao usuário).
"""
import collections, json, os, re, sys, unicodedata

d = json.load(open(sys.argv[1]))
out = sys.argv[2]
os.makedirs(out, exist_ok=True)
W = [w for s in d for w in s["words"]]
json.dump(W, open(f"{out}/palavras.json", "w"), ensure_ascii=False)
with open(f"{out}/leitura.txt", "w") as f:
    for s in d:
        f.write(f"[{int(s['start']) // 60:02}:{int(s['start']) % 60:02}|{s['start']:.0f}] {s['text']}\n")

def norm(t):
    t = unicodedata.normalize("NFD", t.lower())
    return re.sub(r"[^a-z0-9]", "", "".join(ch for ch in t if unicodedata.category(ch) != "Mn"))

def ctx(i, n=5):
    return " ".join(x["w"].strip() for x in W[max(0, i - n):i + n + 1])

freq = collections.Counter(norm(w["w"]) for w in W)
linhas = ["# BAIXA CONFIANÇA (p < 0.45, palavras pouco frequentes): confira o sentido pelo contexto"]
for i, w in enumerate(W):
    if w["p"] < 0.45 and len(norm(w["w"])) > 3 and freq[norm(w["w"])] <= 3:
        linhas.append(f"{w['s']:8.1f}  p={w['p']:.2f}  {w['w'].strip():<18} … {ctx(i)}")

linhas.append("\n# MAIÚSCULAS NO MEIO DA FRASE (nomes, marcas, produtos): confira a grafia oficial")
vistos = collections.defaultdict(list)
for i, w in enumerate(W[1:], 1):
    t = w["w"].strip()
    if t[:1].isupper() and not re.search(r"[.?!]$", W[i - 1]["w"].strip()):
        vistos[norm(t)].append(i)
for k, idx in sorted(vistos.items(), key=lambda kv: -len(kv[1])):
    i = idx[0]
    linhas.append(f"{len(idx):3}x  {W[i]['w'].strip():<18} ex.: {W[i]['s']:.1f}s … {ctx(i)}")

linhas.append("\n# PALAVRAS RARAS (1 ocorrência, 5+ letras): erros de reconhecimento costumam aparecer aqui")
for i, w in enumerate(W):
    n = norm(w["w"])
    if freq[n] == 1 and len(n) >= 5 and w["p"] < 0.8:
        linhas.append(f"{w['s']:8.1f}  p={w['p']:.2f}  {w['w'].strip():<18} … {ctx(i)}")

linhas.append("\n# RECORRENTES COM CONFIANÇA MÉDIA BAIXA (termo que o modelo não conhece e erra sempre igual)")
probs = collections.defaultdict(list)
for i, w in enumerate(W):
    probs[norm(w["w"])].append((w["p"], i))
for k, v in sorted(probs.items(), key=lambda kv: sum(p for p, _ in kv[1]) / len(kv[1])):
    media = sum(p for p, _ in v) / len(v)
    if len(v) >= 2 and len(k) >= 4 and media < 0.6:
        i = v[0][1]
        linhas.append(f"{len(v):3}x  média p={media:.2f}  {W[i]['w'].strip():<16} ex.: {W[i]['s']:.1f}s … {ctx(i)}")

open(f"{out}/suspeitas.txt", "w").write("\n".join(linhas) + "\n")
print(f"{len(W)} palavras · revisar {out}/suspeitas.txt · ler {out}/leitura.txt")
