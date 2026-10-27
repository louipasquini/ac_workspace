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

Os servidores estão em `.mcp.json` (`<app>-cli mcp`, stdio, headless), gerado pelo `setup.sh`/`setup.ps1` só com os
apps instalados. As ferramentas aparecem como `mcp__<app>__*`.

## Workflow obrigatório
Ao receber qualquer tarefa criativa, ative a skill **`craft-workflow`** e siga `WORKFLOW.md`:

1. `craft-novo-projeto` — nome `YYYY-MM-DD-nome-do-projeto`; criar `projetos/<projeto>/` com `brutos/`, `referencias/`,
   `materiais/` e `finalizados/`.
2. `craft-ler-referencias` — ler `referencias/` (com o `CONTEXTO.md`) e `materiais/` do projeto **antes** de produzir.
3. `craft-subir-servidores` — escolher os apps e confirmar que o MCP responde.
4. Desenvolver com a skill do app (`craft-photocraft`, `craft-vectorcraft`, `craft-filmcraft`, `craft-lightcraft`,
   `craft-pdfcraft`, `craft-figcraft`, `craft-effectcraft`, `craft-soundcraft`, `craft-designcraft`).
5. `craft-salvar-brutos` — editáveis em `projetos/<projeto>/brutos/<EXT>/`.
6. `craft-salvar-finalizados` — entregáveis em `projetos/<projeto>/finalizados/`.
7. `craft-encerrar-servidores` — fechar sessões/processos e resumir.

## Estrutura de pastas (ver `ESTRUTURA.md`)
```
projetos/YYYY-MM-DD-nome-do-projeto/
├── brutos/<EXT>/arquivo.<ext>   # editáveis (Claude)
├── referencias/                 # identidade visual + CONTEXTO.md (usuário, somente leitura)
├── materiais/                   # arquivos que entram na peça (usuário, somente leitura)
└── finalizados/                 # entregáveis (Claude)
```
`projetos/_bibliotecas/lightcraft` é a biblioteca compartilhada do LightCraft, não um projeto.

## Regras
- **Pergunte, não assuma** quando faltar informação criativa/técnica ou a referência for ambígua.
- Escreva só em `projetos/<projeto>/brutos/` e `projetos/<projeto>/finalizados/` (e na biblioteca do LightCraft).
  Nunca altere `referencias/` nem `materiais/` de um projeto, nem pastas de outros projetos.
- `referencias/` é inspiração e regra; `materiais/` é matéria-prima que entra na peça. Use os materiais fornecidos
  antes de criar substitutos.
- O confinamento dos servidores MCP cobre `projetos/` inteira (leitura e escrita); a separação entre
  subpastas e entre projetos é disciplina sua.
- Use caminhos **absolutos** nas ferramentas MCP (as raízes de confinamento exigem).
- Olhe o resultado (`render_preview`/screenshot) antes de salvar como finalizado. Não sobrescreva entregas: use `-v2`.
- Os Crafts são software em desenvolvimento: se um comando falhar, leia o erro, tente alternativa (CLI do app:
  `<app>/target/release/<app>-cli`) e informe o usuário.
- Não edite o código-fonte dos Crafts (`<app>/crates`, `apps`) salvo pedido explícito. Cada subpasta tem seu
  próprio `CLAUDE.md`/`AGENTS.md` voltado a *desenvolver* o app — **não se aplica** ao uso por MCP.
- App não instalado: `./setup.sh --apps <app>` (Windows: `.\setup.ps1 -Apps <app>`), depois de perguntar ao usuário.
- Se as ferramentas `mcp__<app>__*` não existirem: o `.mcp.json` só é lido ao abrir o Claude Code; peça reinício e aprovação.
- Se encontrar pastas na estrutura antiga (`referencias/`, `materiais/` ou `finalizados/` na raiz), não trabalhe nelas:
  peça ao usuário para rodar `./setup.sh --migrar` (ver `ESTRUTURA.md`).
