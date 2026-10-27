---
name: craft-salvar-brutos
description: Salva os arquivos brutos/editáveis (projetos nativos dos Crafts, PSD, SVG, sessões, etc.) em projetos/YYYY-MM-DD-nome-do-projeto/brutos/<EXTENSÃO>/ conforme ESTRUTURA.md. Use durante o desenvolvimento (salvamentos frequentes) e antes de exportar finalizados.
---

# Salvar brutos

Estrutura obrigatória (de `ESTRUTURA.md`):
```
projetos/YYYY-MM-DD-nome-do-projeto/brutos/<EXT>/arquivo.<ext>
```
`<EXT>` = extensão em **maiúsculas**, uma subpasta por extensão. Padrão: o formato nativo do app; se o usuário pedir ou o fluxo exigir um formato conhecido (PSD, AI/SVG, IDML), salve também nele na pasta correspondente.

## Passos
1. `mkdir -p projetos/<projeto>/brutos/<EXT>` (caminho absoluto ao passar para o MCP).
2. Salve com o comando do app (`doc_save`/`session.save`/`file.save`… veja `command_list` com `filter: "save"`),
   usando **caminho absoluto** dentro de `projetos/<projeto>/brutos/`. Escrever fora de `projetos/` é recusado pelo servidor.
3. Nome: `<descricao>[-vN].<ext>` (o nome do projeto já está na pasta). Não sobrescreva versão anterior aprovada; use `-v2`.
4. Confirme: `ls -la projetos/<projeto>/brutos/<EXT>/`.
5. Salve a cada marco relevante (estrutura pronta, antes de exportar, ao final).

## Extensões por app
| App | Bruto editável | Pasta (em `brutos/`) |
|---|---|---|
| PhotoCraft | `.pcraft` (nativo; PSD/TIFF em camadas também são possíveis se pedido) | `PCRAFT/` (ou `PSD/`) |
| VectorCraft | `.vectorcraft` (ou `.svg`) | `VECTORCRAFT/` (ou `SVG/`) |
| FilmCraft | `.fcproj` | `FCPROJ/` |
| LightCraft | biblioteca compartilhada em `projetos/_bibliotecas/lightcraft` (álbum com o nome do projeto); XMP opcional | `LIGHTCRAFT/` só para XMP exportado |
| PdfCraft | `.pdf` editável | `PDF/` |
| FigCraft | `.figcraft` | `FIGCRAFT/` |
| EffectCraft | `.ecproj` | `ECPROJ/` |
| SoundCraft | `.scraft` | `SCRAFT/` |
| DesignCraft | `.designcraft` (IDML se pedido) | `DESIGNCRAFT/` (ou `IDML/`) |
| Página web (código) | `.html` (só depois do `.figcraft` aprovado) | `HTML/` |

Mídia criada durante o projeto (áudio, vídeo, imagens geradas ou tratadas) vai na pasta da sua extensão dentro de
`brutos/` (ex.: `brutos/WAV/`, `brutos/PNG/`). Arquivos de `referencias/` e `materiais/` **não** são copiados: os brutos
apontam para eles no lugar onde estão.
Se um app salvar mídia embutida ao lado do bruto (ex.: `Audio Files/`), mantenha-a junto do arquivo.
