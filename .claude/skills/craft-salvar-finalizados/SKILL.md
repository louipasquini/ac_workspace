---
name: craft-salvar-finalizados
description: Exporta e salva os entregáveis finais (PNG, SVG, PDF, MP4, WAV etc.) em finalizados/YYYY-MM-DD-nome-do-projeto/ conforme ESTRUTURA.md e verifica os arquivos. Use quando o resultado estiver aprovado visualmente ou quando o usuário pedir a entrega.
---

# Salvar finalizados

1. Confirme que o resultado foi **visto** (preview/screenshot) e bate com `CONTEXTO.md` e a identidade visual.
2. Exporte para `finalizados/<projeto>/` usando caminhos absolutos. Nomes claros e sem espaços:
   `<projeto>-<descricao>[-vN].<ext>` (ex.: `2026-10-26-vinheta-logo-1080p.mp4`).
3. Formatos usuais: imagem → PNG/JPG/WebP; vetor → SVG/PDF; vídeo → MP4/MOV; animação → MP4/GIF/Lottie/sequência PNG;
   áudio → WAV/FLAC/MP3; documento → PDF; UI → PNG/SVG/PDF. Se o formato não foi especificado, use o **padrão abaixo** e informe a escolha ao usuário (pergunte só se o uso final mudar o formato, ex.: impressão profissional ou broadcast):

   | Tipo | Padrão |
   |---|---|
   | Vídeo / animação | MP4 H.264 + AAC, na resolução e fps do briefing (padrão 1920×1080, 30 fps) |
   | Áudio | WAV 48 kHz 24 bits (+ MP3 192 kbps se for para web) |
   | Imagem raster | PNG (JPEG qualidade 90 para fotos) |
   | Vetor | SVG + PDF |
   | Documento diagramado | PDF |
   | UI / protótipo | PNG @2x + SVG |
   | Animação leve | Lottie (JSON) + MP4 de fallback |
4. Nunca sobrescreva um finalizado existente: se já existe, use `-v2`, `-v3`.
5. Verifique:
   ```bash
   ls -la finalizados/<projeto>/ && file finalizados/<projeto>/*
   ```
   Tamanho > 0 e tipo coerente. Se possível, abra/inspecione o arquivo exportado (ex.: PNG com a ferramenta de imagem).
6. Liste ao usuário os caminhos entregues. Não coloque brutos aqui e não copie referências para cá.
