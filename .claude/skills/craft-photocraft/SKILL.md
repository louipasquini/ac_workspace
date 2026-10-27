---
name: craft-photocraft
description: Edita e compõe imagens raster em camadas (retoque, composição, máscaras, texto, filtros, artboards) com o PhotoCraft via MCP. Use para fotos, banners, mockups, thumbnails e arte raster.
---

# PhotoCraft (equivalente a Photoshop)

Servidor MCP: `photocraft` → ferramentas `mcp__photocraft__*` (headless, `photocraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .pcraft (também abre/salva PSD, TIFF em camadas, PNG, JPEG, WebP, SVG).

## Ferramentas principais
`doc_new`, `doc_open`, `doc_place`, `doc_inspect`, `command_list`/`command_run`/`command_batch`, `doc_render_preview`/`render_preview`, `doc_save`, `doc_export`, `doc_export_layers`, `doc_close`, `jobs_list`.

## Fluxo
1. `doc_new` (largura/altura/cor de fundo conforme o briefing) ou `doc_open` num arquivo de `materiais/` ou `referencias/` do projeto.
2. `doc_place` para inserir imagens/logos como camadas; ajustes e filtros via `command_run` (descubra ids com `command_list` + `filter`).
3. Use `doc_inspect` para ver a árvore de camadas e `doc_render_preview` (máx. 2048 px) para **olhar** o resultado.
4. Antes de experimentar, duplique: `command_run` `image.duplicate`; desfaça com `edit.undo`.

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `doc_save` (bruto `.pcraft`), `file.saveACopy`.
- **Finalizado** (skill `craft-salvar-finalizados`): `doc_export` (PNG/JPEG/WebP/…), `doc_export_layers`, `file.export.quickExport`, `file.export.artboardsToFiles`.

## Notas e limites
- Confinamento: uma raiz de leitura e uma de escrita, ambas `projetos/`; **você** deve escrever só em `brutos/` e `finalizados/` do projeto. Falha de lote não faz rollback.
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `photocraft/docs/mcp.md` e `photocraft/docs/control-protocol.md`.
