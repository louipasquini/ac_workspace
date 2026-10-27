---
name: craft-lightcraft
description: Importa, avalia, revela (RAW, exposição, cor, máscaras, presets) e exporta fotos com o LightCraft via MCP. Use para tratamento de fotografias e lotes de fotos.
---

# LightCraft (equivalente a Lightroom)

Servidor MCP: `lightcraft` → ferramentas `mcp__lightcraft__*` (headless, `lightcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: biblioteca/catálogo (sessão headless em memória por padrão); edições exportadas como JPEG/TIFF.

## Ferramentas principais
`import`, `query_photos`, `select_photos`, `list_controls`, `get_develop`, `set_develop`, `apply_preset`, `crop`, `render_photo`, `export`, `command_list`/`command_run`/`command_batch`, `doc_inspect`, `render_preview`.

## Fluxo
1. `import` com pasta/arquivos absolutos (de `materiais/` ou `referencias/`). `query_photos` / `select_photos` para localizar.
2. `list_controls` mostra os controles de revelação; ajustar com `set_develop`/`apply_preset`/`crop`.
3. `render_photo` ou `render_preview` para **olhar**; repetir até aprovar.
4. Exportar com `export` (formato/qualidade/tamanho conforme o briefing).

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): as edições ficam na biblioteca persistente compartilhada `projetos/_bibliotecas/lightcraft` (passada em `--library` no `.mcp.json`; uma só biblioteca para todos os projetos). Importe as fotos do projeto num álbum com o nome do projeto. Metadados também podem ir para XMP (`photo.saveMetadataToFile`).
- **Finalizado** (skill `craft-salvar-finalizados`): `export`, `render_photo`, `export.contactSheet`, `print.exportPdf`.

## Notas e limites
- O MCP do LightCraft **não tem flags de confinamento**. Só escrever em `projetos/` e `finalizados/`. A biblioteca só pode ser aberta por um processo por vez (`catalog.lock`); não abra o app desktop sobre ela enquanto o MCP estiver ativo. Importar copia originais para `Originals/` da biblioteca por padrão; para não duplicar, use o modo de importação por referência (add).
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `lightcraft/docs/mcp.md` e `lightcraft/docs/control-protocol.md`.
