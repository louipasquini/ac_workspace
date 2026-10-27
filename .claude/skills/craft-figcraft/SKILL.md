---
name: craft-figcraft
description: Projeta interfaces e protótipos (frames, auto layout, componentes, estilos, variáveis) com o FigCraft via MCP. Use para telas de app/site, UI kits, wireframes e protótipos.
---

# FigCraft (equivalente a Figma)

Servidor MCP: `figcraft` → ferramentas `mcp__figcraft__*` (headless, `figcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .figcraft; exporta PNG/SVG/PDF.

## Ferramentas principais
`create_node`, `set_properties`, `get_node`, `inspect_document`, `select`, `export`, `screenshot`, `open_file`, `save_file`, `undo`/`redo`, `list_commands`/`run_command`/`batch`.

## Fluxo
1. Coordenadas em unidades de página (1 un = 1 px), **y para baixo**; `x`/`y` em `create_node`/`set_properties` são relativos ao frame pai.
2. Criar frames e nós com `create_node` (frames com auto layout via `run_command`); estilizar com `set_properties` (cores da identidade).
3. `inspect_document` para a estrutura; `screenshot` para **olhar** (PNG).
4. Para renders idênticos entre máquinas, usar fontes embutidas (`--no-system-fonts`) — hoje o servidor usa as fontes do sistema.

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `save_file` (`.figcraft`).
- **Finalizado** (skill `craft-salvar-finalizados`): `export` (PNG/SVG/PDF), `figcraft-cli export doc.figcraft -o dir --format svg`.

## Notas e limites
- Multi-raiz de confinamento ativa. Comandos programáticos nunca abrem diálogos.
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `figcraft/docs/mcp.md` e `figcraft/docs/control-protocol.md`.
