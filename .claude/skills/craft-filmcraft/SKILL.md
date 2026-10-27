---
name: craft-filmcraft
description: Monta e edita vídeo (timeline, cortes, transições, efeitos, legendas, cor, áudio) com o FilmCraft via MCP. Use para edição de vídeo, montagem final de motion e exportação de mídia.
---

# FilmCraft (equivalente a Premiere)

Servidor MCP: `filmcraft` → ferramentas `mcp__filmcraft__*` (headless, `filmcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .fcproj; exporta MP4/H.264/HEVC/ProRes etc., EDL/OTIO/FCPXML.

## Ferramentas principais
`media_import`, `project_inspect`, `sequence_inspect`, `command_list`/`command_run`/`command_batch`, `render_frame`, `render_preview`, `doc_inspect`.

## Fluxo
1. `command_list` com `filter` para achar comandos (sequências, clipes, efeitos). `media_import` com caminhos **absolutos** de `materiais/`, `referencias/` ou `finalizados/` do projeto.
2. Montar a sequência por `command_run`/`command_batch` (cada passo é uma edição desfazível).
3. `sequence_inspect` para conferir a timeline; `render_frame`/`render_preview` em tempos-chave para **olhar**.
4. Exportar com `file.exportMedia` (parâmetro `wait=true` bloqueia até terminar).

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `file.save` / `file.saveAs` / `file.saveCopy` (`.fcproj`).
- **Finalizado** (skill `craft-salvar-finalizados`): `file.exportMedia`, `file.exportOtio`, `file.exportEdl`, `file.exportFcpxml`; presets: `export.presets.list`.

## Notas e limites
- O MCP do FilmCraft **não tem flags de confinamento** — ele lê/escreve onde o usuário puder. Disciplina própria: só escrever em `brutos/` e `finalizados/` do projeto. Transcrição por Whisper só se compilado com a feature `whisper` (não é o caso por padrão).
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `filmcraft/docs/mcp.md` e `filmcraft/docs/control-protocol.md`.
