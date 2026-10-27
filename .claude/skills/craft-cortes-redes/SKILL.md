---
name: craft-cortes-redes
description: Transforma vídeos longos (lives, aulas, podcasts, webinars, entrevistas) em cortes verticais 9:16 de alta retenção para Reels, TikTok e Shorts — transcrição com Whisper, revisão de termos, escolha de ganchos, jump cuts, punch-ins, legendas, trilha, CTA e exportação sem estourar a memória. Use sempre que pedirem cortes, clipes, reels ou shorts a partir de um vídeo.
---

# Cortes verticais (9:16) a partir de vídeo longo

Segue o `craft-workflow` (projeto, referências, servidores, brutos, finalizados) com FilmCraft +
SoundCraft. Scripts em `scripts/` (rode com o Python do venv da transcrição, sempre `python -I`);
modelo de configuração em `referencias/config-exemplo.json` — **todos os valores de lá são fictícios**:
identidade visual, textos e tempos vêm das `referencias/` do projeto e do usuário.

## 0. Perguntas antes de produzir
Uma rodada de AskUserQuestion, com a opção recomendada primeiro:
- **Transcrição**: instalar faster-whisper num venv isolado? Modelo `small` (bom equilíbrio; ~0,4× a
  duração do áudio em CPU de 20 threads) ou `medium` (mais preciso, 2–3× mais lento). Ou o usuário
  fornece SRT/transcrição pronta.
- **Trilha**: compor no SoundCraft (sem direitos autorais) e em qual **clima** (épico, inspirador,
  calmo, energético) / o usuário envia / sem trilha (usará áudio da plataforma).
- **CTA**: oferta, chamada exata do botão ("Link na bio", "Comente PALAVRA", "Salve este vídeo"…) e se
  pode reaproveitar falas do próprio vídeo.
- **Identidade**: cores, fontes e nome da marca, se não estiverem em `referencias/`.
- Se o vídeo citar **preço, datas, vagas ou prazos**, avise que podem estar vencidos e deixe-os fora
  do CTA, salvo pedido.

Ordem de aprovação: lista de cortes → **um corte de amostra** (design + trilha) → replicar nos demais.
Pedidos de ajuste visual ou de música na amostra são comuns; não replique antes do "aprovado".

## 1. Ambiente e transcrição
- O FilmCraft só transcreve se compilado com a feature `whisper` (`transcript.models` → `available`).
  Sem ela, use faster-whisper num venv com Python 3.12 (o Python do sistema pode não ter `ensurepip`
  nem wheels do ctranslate2):
  ```bash
  uv venv -q --python 3.12 <scratchpad>/venv
  VIRTUAL_ENV=<scratchpad>/venv uv pip install -q faster-whisper
  ```
  Peça permissão antes (baixa pacotes e o modelo do Hugging Face).
- `scripts/transcrever.py <midia> <saida.json> [modelo] [idioma]` — decodifica o áudio com PyAV e passa
  o array ao modelo (o `decode_audio` do faster-whisper quebra com PyAV ≥ 14: `metadata_errors`).
  Rode em background; o JSON é regravado a cada 20 segmentos.
- Guarde no projeto: `brutos/JSON/transcricao-<nome>.json` e `brutos/SRT/<nome>.srt`.

## 2. Revisão da transcrição (obrigatória)
`scripts/revisar_transcricao.py <transcricao.json> <pasta>` gera:
- `leitura.txt` — o vídeo inteiro, um trecho por linha `[mm:ss|seg]`, para escolher cortes;
- `palavras.json` — palavras com tempo (entrada do planejador);
- `suspeitas.txt` — baixa confiança, maiúsculas no meio da frase, palavras raras e, a mais útil,
  **termos recorrentes com confiança média baixa**: um termo que o modelo não conhece erra sempre do
  mesmo jeito (nome de marca virando palavra comum, repetido 10+ vezes com p≈0,3).

Padrões de erro a procurar e como resolver:
- **Marcas, produtos, empresas e programas** deformados e com variações de grafia entre ocorrências.
  Fonte da grafia certa: `referencias/`, `CONTEXTO.md`, textos visíveis na tela, domínio de e-mail/site.
- **Nomes de pessoas**, inclusive de quem apresenta (o modelo troca por nomes comuns parecidos).
- **Anglicismos e jargão do nicho** aportuguesados foneticamente (ex.: *leads*, *follow-up*,
  *dashboard*, siglas) e termos técnicos da área.
- **Palavras reais mas sem sentido no contexto** (homófonos, palavras quebradas no meio).
- Regra: corrija só o que o contexto ou uma fonte confirma; **na dúvida, pergunte ao usuário** — nunca
  por chute. Nomes de terceiros citados de passagem são melhores fora do corte do que escritos errados.
- As correções viram o mapa `correcoes` do config (token → token, aplicado às legendas).
- No resumo final, liste o que foi corrigido e o que ainda pede conferência.

## 3. Layout da fonte
- `scripts/mapear_layout.py <video> <saida.json>` lista as trocas de cena com tempo exato e grava uma
  série de brilho por região. Gravações costumam alternar **câmera cheia**, **tela compartilhada com a
  câmera num quadro/círculo** e **slides** — confirme cada limite com `render_frame`.
- Armadilha: `seek` + primeiro quadro decodificado devolve o **keyframe anterior** (miniaturas erradas).
  Decodifique em sequência até o tempo pedido.
- Meça na própria fonte a posição e o tamanho da câmera sobreposta (centro e diâmetro em pixels) e a
  área útil da tela compartilhada; esses números entram nas bases de layout (seção 7).

## 4. Escolha dos cortes e do CTA
- Bons ganchos: dor/pergunta do público, crença contestada, número concreto, história pessoal com
  resultado, promessa clara. 30–80 s de conteúdo com ideia completa; sem cumprimentos nem leitura de
  comentários fora de contexto.
- Apresente a lista (gancho, trecho, layout, duração estimada) antes de montar.
- **CTA curto (~10–13 s) reaproveitado em todos os cortes**, colando frases da própria pessoa:
  - deve **terminar em entonação descendente** — frase que emenda na seguinte soa brusca; troque o
    final por outra frase conclusiva do vídeo;
  - confira se cada frase escolhida está **em câmera** (encerramentos costumam ir para slide);
  - feche com ~0,5 s de imagem **sem áudio** e boca fechada (`respiro`) enquanto a trilha faz fade.

## 5. Planejamento (jump cuts + legendas)
`scripts/planejar_cortes.py <config.json> <palavras.json> <brutos/SRT> <planos.json>`:
- remove pausas ≥ `gap` (0,4 s) entre palavras, com folga `pre`/`post`; alterna base normal e
  punch-in a cada trecho; cola o CTA e o respiro; gera um SRT por corte;
- legendas em blocos de até 3 palavras / 16 caracteres, MAIÚSCULAS, quebra em `.?!`, nunca terminam em
  artigo/preposição, hífens unidos, fronteira forçada entre frases do CTA;
- trechos podem voltar no tempo (CTA): só sobreposição real é ajustada.
Leia os SRT gerados antes de montar.

## 6. Trilha (SoundCraft)
- `scripts/compor_trilha.py <saida.mid> [--clima epico|inspirador|calmo|energetico] [--bpm N]
  [--tom La] [--modo menor|maior] [--compassos N]` gera MIDI com cordas, piano, sub-grave, tema e
  percussão, crescendo até a parte cheia em ~15–20 s (cortes curtos também pegam o clímax).
- Trilha "animada/pop" costuma ser recusada para conteúdo de autoridade; épica/emocionante tende a
  funcionar melhor — confirme o clima na amostra.
- `file.import_midi` cria as faixas com instrumento (canal 10 → `drum_synth`); ajuste timbres com
  `mix.instrument` (`subtractive_synth`, `drum_synth`) e ambiência com `mix.insert`
  (`plate_reverb`, `room_reverb`, `chorus`, `mod_delay`); `bounce_mix` em `brutos/WAV/`.
- Sem saída de áudio no headless: meça a curva de energia (RMS por trecho) e diga que a escuta é do
  usuário. No vídeo: trilha em faixa própria a ~−9 dB, fade de ~1,5 s no fim.

## 7. Montagem no FilmCraft
**Sequências-base aninhadas** (`sequence.nestSequences {on:true}`), cada uma com o vídeo-fonte inteiro;
cada corte só faz `timeline.place` de trechos delas (`sourceIn`/`duration`), e o punch-in é trocar de
base (A normal / B com zoom). Isso evita repetir efeitos por trecho.
- **Câmera A/B**: fundo = a própria fonte desfocada e escurecida (ou cor da marca); vídeo num **card
  com cantos arredondados** (máscara retângulo com `cornerRadius`, em coordenadas da fonte) e moldura
  fina na cor de destaque. A ≈ escala 125, B ≈ 145 com âncora no rosto.
- **Split A/B** (tela compartilhada): câmera recortada com máscara elipse/retângulo (âncora no centro
  medido na seção 3) em cima, com aro na cor de destaque; tela num card arredondado embaixo; gancho
  entre os dois. Fundo claro desfocado fica **cinza** mesmo com brilho/opacidade baixos — use o efeito
  **Tint** (`black`/`white` com tons escuros da paleta) para casar com o fundo da câmera.
- **Overlay do CTA** como sequência própria (botão com pop + pulsos em keyframes), colocada no início
  do CTA de cada corte — evita repetir dezenas de keyframes.
- Por corte (via `scripts/gerar_batches.py`, que lê a seção `identidade` do config): selo da marca,
  gancho com palavra-chave na cor de destaque (`graphics.setCharStyle`) e animação de pop, legendas
  (`captions.import` do SRT + `captions.setStyle`), barra de progresso (`scale_width` 0→100 com âncora
  na borda esquerda e `uniform_scale:false`), trilha e overlay do CTA.
- Particularidades do FilmCraft:
  - fontes: confira `fonts.list` (estilos disponíveis variam; escolha uma família com peso Black/Heavy);
  - `graphics.set` com `time` **não** cria keyframe — use `effects.setParam {effect:"motion",
    keyframe:true, time}` no clipe, com `anchor` = `position` no ponto que deve escalar;
  - criar gráfico numa faixa ocupada falha ("Vn is not free"): adicione como camada do mesmo clipe
    (`clip: id`);
  - os comandos devolvem ids: monte cada corte em 2 batches (criação → animações com os ids);
  - efeitos aplicados com `effects.apply` agem na seleção da sequência **ativa** (`sequence.open`);
  - organize versões antigas num bin (`file.newBin` + `project.moveToBin`), salve em `brutos/FCPROJ/`
    e confira quadros-chave com `render_frame` (gancho, meio, CTA, último quadro).

## 8. Exportação e MEMÓRIA (crítico)
- O servidor MCP com o vídeo-fonte aberto ocupa vários GB, **não devolve memória** e cresce a cada
  exportação (reabrir o projeto não libera). Dois processos com a fonte carregada (MCP + CLI)
  **derrubam a sessão** em máquinas de ~16 GB.
- Regra: **uma exportação por vez, um processo por vez**. Meça antes (`free -m`) e acompanhe o RSS.
  Poucos cortes: exporte pelo MCP (`file.exportMedia … wait:true`). Vários: salve o projeto, encerre o
  servidor MCP do FilmCraft (ele volta ao reiniciar o Claude Code; avise o usuário) e rode
  `scripts/exportar_cortes.sh <proj.fcproj> <finalizados> <logs> id:nome …` (um processo por corte).
- Ao encerrar processos, **não** use `pkill -f` com um padrão que apareça na própria linha de comando
  (mata o shell que o executa, exit 144); pegue o PID com `ps -eo pid,args | grep … | grep -v grep`.
- Exportação típica: H.264, CRF 20, 1080×1920, 30 fps, AAC, `burnCaptions:true`, `loudnessLufs:-14`.
  Render ~10 fps (≈3× a duração do corte).
- Exportação interrompida deixa arquivo com o nome final e tamanho pequeno: apague e refaça.

## 9. Conferência e entrega
- `scripts/conferir_mp4.py <mp4> <grade.png>` → duração, resolução, fps, codec, RMS/pico e uma grade
  de 4 quadros para olhar com Read. Esperado: 1080×1920, 30 fps, RMS ≈ −17 dBFS, pico ≈ −1,5 dBFS.
- Entregue em `finalizados/NN-slug.mp4`; versões anteriores em `finalizados/versoes-anteriores/`.
  Brutos: `FCPROJ`, `SRT` (um por corte + o do vídeo inteiro), `JSON` (transcrição), `MID`/`WAV`/
  `SCRAFT` (trilha).
