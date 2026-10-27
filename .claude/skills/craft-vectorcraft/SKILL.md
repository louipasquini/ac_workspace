---
name: craft-vectorcraft
description: Cria e edita ilustrações vetoriais (logos, ícones, formas, tipografia, pathfinder, efeitos) com o VectorCraft via MCP. Use para logotipos, ícones, ilustrações e artes escaláveis.
---

# VectorCraft (equivalente a Illustrator)

Servidor MCP: `vectorcraft` → ferramentas `mcp__vectorcraft__*` (headless, `vectorcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .vectorcraft (JSON); SVG, PDF, EPS, DXF.

## Ferramentas principais
`draw_shape`, `draw_path`, `add_text`, `set_paint`, `transform`, `pathfinder`, `apply_effect`, `create_graph`, `text_wrap`, `select_tool`, `inspect_document`, `render_preview`, `open_file`, `save_file`, `export`, `undo`/`redo`, `command_run`.

## Fluxo
1. Documento novo via `command_run` `file.new` (aceita `preset`) ou `open_file`. Modo headless: sem ferramentas de UI (`inspect_ui`, `type_text`, `answer_dialog`, `open_panel`).
2. Construir com `draw_shape`/`draw_path`/`add_text`; cores com `set_paint` usando a paleta das referências.
3. `inspect_document` para conferir objetos; `render_preview` para **olhar**.
4. Para entregar logo, confira com `command_list` (filter `outline`/`text`) se há comando de converter texto em contornos.

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `save_file` / `document.save` / `file.saveAs` (`.vectorcraft`) e SVG se pedido.
- **Finalizado** (skill `craft-salvar-finalizados`): `export` / `document.export`, `document.exportPdf`, `document.exportForScreens`, `document.exportForWeb`.

## Notas e limites
- Roda com `--headless` e confinamento multi-raiz (leitura: referencias/materiais/projetos/finalizados; escrita: projetos/finalizados).
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `vectorcraft/docs/mcp.md` e `vectorcraft/docs/control-protocol.md`.
