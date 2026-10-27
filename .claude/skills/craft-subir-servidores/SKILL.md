---
name: craft-subir-servidores
description: Escolhe quais Crafts a tarefa exige, confirma que o servidor MCP de cada um está conectado e funcionando (headless, via .mcp.json) e, se faltar, orienta build ou reinício. Use depois de ler as referências e antes de desenvolver qualquer arquivo.
---

# Subir e conectar servidores MCP

Os servidores são `<app>-cli mcp` (stdio), declarados em `.mcp.json` na raiz. O Claude Code os inicia ao abrir
esta pasta (o usuário aprova na primeira vez) e os encerra ao sair. Não existe "subir" manual no modo padrão.

## Passos
1. Decida os apps necessários (tabela em `craft-workflow`). Não use mais apps do que o preciso.
2. Para cada um, confirme que há ferramentas `mcp__<app>__*` disponíveis (use ToolSearch com `+<app>` se estiverem
   adiadas) e faça uma chamada leve: `doc_inspect` (ou `command_list` com `filter`).
3. Se as ferramentas **não** existem:
   - Binário ausente? `ls <app>/target/release/<app>-cli`. Se não existir:
     ```bash
     export PATH="$HOME/.cargo/bin:$PATH"; (cd <app> && cargo build --release -p <app>-cli)
     ```
   - Binário existe, mas a sessão não vê o servidor → o `.mcp.json` só é lido na abertura: peça ao usuário para
     reiniciar o Claude Code nesta pasta e aprovar os servidores do projeto (ou usar `/mcp` para reconectar).
   - Nunca tente simular o MCP por fora sem avisar. O fallback legítimo é a CLI do app
     (`<app>-cli exec|run|render|export`), informando o usuário.
4. **Modo visível (opcional, só se o usuário pedir "quero ver ao vivo")**: subir o app com janela e a porta de controle,
   e registrar a ponte. Cada app tem uma flag própria (`--bridge`, `--connect` ou `--attach`) e **portas distintas**
   (os apps compartilham padrões como 7979). Use `run_in_background`, anote PID/porta e feche na etapa 7. Detalhes por app
   em `docs/` de cada projeto (`mcp.md`, `control-protocol.md`).
5. Reporte ao usuário quais servidores estão ativos e quais não.

## Confinamento de arquivos
O `.mcp.json` já limita leitura a `referencias/`, `materiais/`, `projetos/`, `finalizados/` e escrita a `projetos/` e `finalizados/`
(onde o app suporta). Caminhos passados às ferramentas devem ser **absolutos**, dentro dessas raízes.
