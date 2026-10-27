---
name: craft-pdfcraft
description: Inspeciona, edita e converte PDFs (juntar, dividir, texto, formulários, assinatura, OCR, redação, acessibilidade, otimização) com o PdfCraft via MCP. Use para qualquer trabalho com arquivos PDF.
---

# PdfCraft (equivalente a Acrobat)

Servidor MCP: `pdfcraft` → ferramentas `mcp__pdfcraft__*` (headless, `pdfcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .pdf.

## Ferramentas principais
modo `--compact` expõe: `doc_open`, `doc_info`, `doc_save`, `doc_close`, `page_render`, `text_extract`, `text_find`, `doc_combine`, `doc_split`, `edit_undo`, `command_list`, `command_run`, `command_batch`, `doc_inspect`, `render_preview`, `tool_search`, `tool_call`. As ~179 ferramentas completas ficam acessíveis por `tool_search` + `tool_call`.

## Fluxo
1. `doc_open` com caminho absoluto. `doc_info`/`doc_inspect` para o panorama; `page_render`/`render_preview` para **olhar**.
2. Achar a ferramenta certa: `tool_search` (ex.: "watermark", "ocr", "form") e executar com `tool_call`.
3. Edição de texto/objetos: `text_edit`, `content_update`, `page_add_text`, `page_add_image`; páginas: `page_insert_file`, `page_extract`, `page_delete`.
4. Salvar com `doc_save` num caminho novo (não sobrescrever o original das referências).

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `doc_save` / `file.save_as` — o PDF editável é o bruto (`projetos/<projeto>/PDF/`).
- **Finalizado** (skill `craft-salvar-finalizados`): `doc_export_images`, `doc_export_text`, `doc_export_office` (docx/pptx), `export.html`, `doc_reduce`/`doc_optimize`, `pdfa_convert`.

## Notas e limites
- Raiz única `--root` = pasta `artcraft-mcp/` (a ferramenta confina tudo nela). Escreva apenas em `projetos/` e `finalizados/`. Nunca salve por cima do PDF de `referencias/` ou `materiais/`.
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `pdfcraft/docs/mcp.md` e `pdfcraft/docs/control-protocol.md`.
