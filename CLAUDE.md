# ArtCraft MCP — instruções para o Claude

Esta pasta é um estúdio criativo operado por MCP. Nove apps Rust (os "Crafts") ficam em subpastas; o usuário pede
um trabalho e você o executa de ponta a ponta, salvando brutos e finalizados na estrutura padronizada.
Idioma: responda e documente em **português (BR)**.

| Pasta | Equivalente | Servidor MCP |
|---|---|---|
| `photocraft/` | Photoshop | `photocraft` |
| `vectorcraft/` | Illustrator | `vectorcraft` |
| `filmcraft/` | Premiere | `filmcraft` |
| `lightcraft/` | Lightroom | `lightcraft` |
| `pdfcraft/` | Acrobat | `pdfcraft` |
| `figcraft/` | Figma | `figcraft` |
| `effectcraft/` | After Effects | `effectcraft` |
| `soundcraft/` | Editores de áudio | `soundcraft` |
| `designcraft/` | InDesign | `designcraft` |

Os servidores estão em `.mcp.json` (`<app>-cli mcp`, stdio, headless). As ferramentas aparecem como `mcp__<app>__*`.

## Workflow obrigatório
Ao receber qualquer tarefa criativa, ative a skill **`craft-workflow`** e siga `WORKFLOW.md`:

1. `craft-novo-projeto` — nome `YYYY-MM-DD-nome-do-projeto`, criar `materiais/`, `projetos/` e `finalizados/`.
2. `craft-ler-referencias` — ler `referencias/<projeto>/`, `CONTEXTO.md` e `materiais/<projeto>/` **antes** de produzir.
3. `craft-subir-servidores` — escolher os apps e confirmar que o MCP responde.
4. Desenvolver com a skill do app (`craft-photocraft`, `craft-vectorcraft`, `craft-filmcraft`, `craft-lightcraft`,
   `craft-pdfcraft`, `craft-figcraft`, `craft-effectcraft`, `craft-soundcraft`, `craft-designcraft`).
5. `craft-salvar-brutos` — editáveis em `projetos/<projeto>/<EXT>/`.
6. `craft-salvar-finalizados` — entregáveis em `finalizados/<projeto>/`.
7. `craft-encerrar-servidores` — fechar sessões/processos e resumir.

## Estrutura de pastas (ver `ESTRUTURA.md`)
```
referencias/YYYY-MM-DD-nome-do-projeto/   # entrada do usuário (somente leitura) + CONTEXTO.md
materiais/YYYY-MM-DD-nome-do-projeto/     # arquivos a usar na peça (somente leitura)
projetos/YYYY-MM-DD-nome-do-projeto/<EXT>/arquivo.<ext>   # brutos editáveis
finalizados/YYYY-MM-DD-nome-do-projeto/   # entregáveis
```

## Regras
- **Pergunte, não assuma** quando faltar informação criativa/técnica ou a referência for ambígua.
- Nunca escreva fora de `projetos/` e `finalizados/`; nunca altere `referencias/` nem `materiais/`.
- `referencias/` é inspiração e regra; `materiais/` é matéria-prima que entra na peça. Use os materiais fornecidos
  antes de criar substitutos.
- Use caminhos **absolutos** nas ferramentas MCP (as raízes de confinamento exigem).
- Olhe o resultado (`render_preview`/screenshot) antes de salvar como finalizado. Não sobrescreva entregas: use `-v2`.
- Os Crafts são software em desenvolvimento: se um comando falhar, leia o erro, tente alternativa (CLI do app:
  `<app>/target/release/<app>-cli`) e informe o usuário.
- Não edite o código-fonte dos Crafts (`<app>/crates`, `apps`) salvo pedido explícito. Cada subpasta tem seu
  próprio `CLAUDE.md`/`AGENTS.md` voltado a *desenvolver* o app — **não se aplica** ao uso por MCP.
- Binários: `cd <app> && cargo build --release -p <app>-cli` (PATH com `~/.cargo/bin`).
- Se as ferramentas `mcp__<app>__*` não existirem: o `.mcp.json` só é lido ao abrir o Claude Code; peça reinício e aprovação.
