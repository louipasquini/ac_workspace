---
name: craft-designcraft
description: Diagrama documentos multipágina (livros, revistas, folhetos, relatórios) com molduras, texto encadeado, estilos e páginas-mestras no DesignCraft via MCP. Use para materiais impressos e PDFs diagramados.
---

# DesignCraft (equivalente a InDesign)

Servidor MCP: `designcraft` → ferramentas `mcp__designcraft__*` (headless, `designcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .designcraft; IDML, INDD (import); exporta PDF, EPUB, HTML, PPTX.

## Ferramentas principais
`new_document`, `open_document`, `save_document`, `inspect_document`, `get_story`/`set_story_text`, `place_image`, `render_page`, `export_png`, `list_commands`/`execute`/`batch`, `select_tool`, `pointer`.

## Fluxo
1. `new_document` (formato, páginas, margens, sangria conforme o briefing).
2. Molduras e estilos via `execute`; texto com `set_story_text`; imagens com `place_image` (caminhos absolutos).
3. `render_page` / `export_png` por página para **olhar**; `inspect_document` para a estrutura.
4. Exportar PDF com `file.exportPdf` (ou `book.exportPdf`).

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `save_document` / `file.saveAs` (`.designcraft`); `file.exportIdml` se pedido.
- **Finalizado** (skill `craft-salvar-finalizados`): `file.exportPdf`, `export_png`, `file.exportEpub`, `file.exportHtml`.

## Notas e limites
- Multi-raiz de confinamento. Sem fontes de `craft-fonts`, texto CJK pode faltar glifos; use as fontes das referências.
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `designcraft/docs/mcp.md` e `designcraft/docs/control-protocol.md`.
