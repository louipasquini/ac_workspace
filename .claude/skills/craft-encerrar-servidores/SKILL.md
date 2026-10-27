---
name: craft-encerrar-servidores
description: Encerra o trabalho com os Crafts - confere brutos e finalizados, fecha documentos/sessões abertos, derruba apps e processos que foram iniciados manualmente e resume a entrega. Use ao terminar qualquer projeto, inclusive quando a tarefa falhar parcialmente.
---

# Encerrar

1. **Conferir entregas**
   ```bash
   ls -laR projetos/<projeto> finalizados/<projeto>
   ```
   Brutos em `projetos/<projeto>/<EXT>/`, finalizados em `finalizados/<projeto>/`. Avise o que estiver faltando.
2. **Fechar sessões MCP**: feche/descarte os documentos abertos nos servidores (comando de fechar documento do app, via
   `command_run`) sem salvar rascunhos descartáveis. Os processos `<app>-cli mcp` do `.mcp.json` terminam sozinhos
   quando o Claude Code fecha (stdin EOF); não os mate no meio da sessão — o usuário pode querer continuar.
3. **Processos manuais**: tudo que foi iniciado fora do `.mcp.json` (apps com janela, builds, servidores de controle):
   - encerrar pelo método limpo do app (`app.quit` via canal de controle, com `force` só se não houver o que salvar);
   - depois conferir: `pgrep -a -f 'craft'` e finalizar remanescentes pelo PID.
4. Remover temporários criados por você (scratch, PNGs de preview fora do projeto).
5. **Resumo final** ao usuário: o que foi criado, caminhos dos brutos e finalizados, decisões tomadas,
   limitações dos apps encontradas e próximos passos sugeridos.
