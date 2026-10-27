---
name: craft-soundcraft
description: Grava, edita, mixa e masteriza áudio (trilhas, clipes, efeitos, MIDI, bounce) com o SoundCraft via MCP. Use para trilha sonora, locução, efeitos sonoros e masterização.
---

# SoundCraft (equivalente a editores de áudio (DAW))

Servidor MCP: `soundcraft` → ferramentas `mcp__soundcraft__*` (headless, `soundcraft-cli mcp`, definido em `.mcp.json`).
Formato nativo: .scraft (sessão); exporta WAV/FLAC/MP3, MIDI.

## Ferramentas principais
`new_session`, `open_session`, `save_session`, `import_audio`, `inspect_session`, `bounce_mix`, `list_commands`, `execute`, `batch`, `parity`, `screenshot`.

## Fluxo
1. `new_session` (taxa de amostragem conforme o projeto); `import_audio` com caminhos absolutos.
2. Edição/mixagem por `execute` (descubra ids com `list_commands`); `batch` para sequências.
3. `inspect_session` para conferir faixas, níveis e duração; confirmar sincronia com o vídeo.
4. `bounce_mix` para o arquivo final.

## Salvar
- **Bruto** (skill `craft-salvar-brutos`): `save_session` / `session.save_as` (`.scraft`). Áudio da sessão fica em `Audio Files/` ao lado — mantenha junto.
- **Finalizado** (skill `craft-salvar-finalizados`): `bounce_mix`, `file.bounce_stems`, `file.export_midi`.

## Notas e limites
- Confinamento em `projetos/` (leitura e escrita); escreva só em `brutos/` e `finalizados/` do projeto. Sem dispositivo de áudio no headless: não dá para *ouvir*; verifique níveis/duração com `inspect_session` e informe ao usuário que a escuta é dele.
- Descoberta de comandos: `command_list`/`list_commands` com `filter`; `describe_command` quando existir.
- Sempre caminhos **absolutos**. Sempre **olhar** um preview antes de exportar.
- Se uma ferramenta falhar, leia a mensagem de erro: parâmetros desconhecidos são rejeitados com a lista aceita.
- Documentação detalhada do app: `soundcraft/docs/mcp.md` e `soundcraft/docs/control-protocol.md`.
