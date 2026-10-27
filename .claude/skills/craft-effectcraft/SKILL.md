---
name: craft-effectcraft
description: Cria motion design e animações com composições, camadas, keyframes, expressões, efeitos e render com o EffectCraft via MCP. Use para vinhetas, animações de logo, lower thirds, vídeos animados e Lottie.
---

# EffectCraft (equivalente a After Effects)

Servidor MCP: `effectcraft` → ferramentas `mcp__effectcraft__*` (headless, `effectcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .ecproj (JSON versionado); exporta MP4 (H.264/HEVC/AV1), ProRes, WebM, GIF, PNG/EXR, Lottie.

## Ferramentas principais
`command_run`/`command_batch`/`command_list`, `list_commands`/`describe_command`, `doc_inspect`, `get_project`/`get_comp`/`get_layer`/`get_property`, `set_property`, `add_keyframe`, `add_effect`, `list_effects`, `list_fonts`, `render_frame`/`render_preview`, `save_project`, `open_project`, `run_script` (JS no modelo de objetos do AE), `undo`/`redo`.

## Fluxo
1. `command_run` `comp.new` (largura, altura, duração, fps do briefing). Importar mídia/logo com `file.import` (`{paths: [...]}`, caminhos absolutos).
2. Criar camadas (sólidos, formas, texto) por comandos; animar com `add_keyframe`/`set_property`; efeitos com `add_effect`.
3. Ver o resultado com `render_preview` em vários tempos (`time`), **olhando** composição e timing.
4. Renderizar: `renderQueue.add` (`comp`, `format`: h264|hevc|av1|prores|…) e depois `renderQueue.render`; progresso via `_meta.progressToken`. Só uma renderização por vez.

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `save_project` / `file.save` / `file.saveAs` (`.ecproj`).
- **Finalizado** (skill `craft-salvar-finalizados`): `renderQueue.render` (vídeo/sequência), `comp.saveFrameAs` (PNG), `file.exportLottie`, `comp.saveFrameAsPsd`/`Exr`.

## Notas e limites
- Confinamento multi-raiz: scripts (`run_script`) e as ferramentas `ui_*` são **recusados** enquanto confinado. Áudio: inclua `--audio` no render ou mixe no SoundCraft e junte no FilmCraft.
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `effectcraft/docs/mcp.md` e `effectcraft/docs/control-protocol.md`.
