# ArtCraft MCP — estúdio criativo operado pelo Claude

Esta pasta reúne nove aplicativos criativos escritos em Rust (os *Crafts*), cada um com um servidor
[MCP](https://modelcontextprotocol.io) próprio. Você abre o Claude Code aqui, pede um trabalho
(ex.: "faça uma vinheta animada com o logo da marca") e o Claude lê suas referências, usa os apps certos via MCP
e entrega brutos e finalizados em pastas padronizadas.

| App | Equivalente | Para quê |
|---|---|---|
| PhotoCraft | Photoshop | Imagens raster, composição, retoque |
| VectorCraft | Illustrator | Logos, ícones, ilustração vetorial |
| FilmCraft | Premiere | Edição de vídeo |
| LightCraft | Lightroom | Revelação e organização de fotos/RAW |
| PdfCraft | Acrobat | Edição e conversão de PDF |
| FigCraft | Figma | Interfaces e protótipos |
| EffectCraft | After Effects | Motion design e animação |
| SoundCraft | Editores de áudio | Trilha, locução, mixagem |
| DesignCraft | InDesign | Diagramação multipágina |

## Como usar

1. **Prepare as referências** (opcional, mas recomendado):
   ```
   referencias/2026-10-26-nome-do-projeto/
   ├── logo.svg, paleta.png, manual-da-marca.pdf, fontes…
   └── CONTEXTO.md      # briefing: objetivo, público, tom, formatos, prazos
   ```
   **Adicione os materiais** que devem entrar na peça (opcional):
   ```
   materiais/2026-10-26-nome-do-projeto/
   └── fotos, vídeos gravados, logo final, trilha licenciada, locução, textos aprovados…
   ```
2. **Abra o Claude Code nesta pasta** e aprove os servidores MCP do projeto (`.mcp.json`) na primeira vez.
3. **Peça a tarefa.** O Claude ativa o workflow (`craft-workflow`), lê as referências, conecta aos apps, desenvolve,
   salva e encerra.
4. **Retire os resultados:**
   ```
   projetos/2026-10-26-nome-do-projeto/<EXT>/arquivo.<ext>   # editáveis (brutos)
   finalizados/2026-10-26-nome-do-projeto/                   # entregáveis
   ```

A estrutura completa está em [`ESTRUTURA.md`](ESTRUTURA.md) e o fluxo detalhado em [`WORKFLOW.md`](WORKFLOW.md).

## Como funciona

- **MCP headless:** cada servidor é `<app>/target/release/<app>-cli mcp` (stdio, sem janela). O Claude Code os inicia
  ao abrir a pasta e os encerra ao sair; não há portas abertas.
- **Skills** em `.claude/skills/` (o Claude as ativa sozinho; você também pode chamar `/nome`):

  | Etapa | Skill |
  |---|---|
  | Orquestração | `craft-workflow` |
  | Novo projeto | `craft-novo-projeto` |
  | Referências | `craft-ler-referencias` |
  | Servidores | `craft-subir-servidores` |
  | Brutos | `craft-salvar-brutos` |
  | Finalizados | `craft-salvar-finalizados` |
  | Encerramento | `craft-encerrar-servidores` |
  | Apps | `craft-photocraft`, `craft-vectorcraft`, `craft-filmcraft`, `craft-lightcraft`, `craft-pdfcraft`, `craft-figcraft`, `craft-effectcraft`, `craft-soundcraft`, `craft-designcraft` |

- **Confinamento de arquivos:** leitura em `referencias/`, `materiais/`, `projetos/`, `finalizados/`; escrita em `projetos/` e
  `finalizados/`. Isso vale para VectorCraft, FigCraft, EffectCraft, SoundCraft e DesignCraft.
  **Exceções:** PhotoCraft e PdfCraft aceitam só uma raiz (usamos a pasta inteira); FilmCraft e LightCraft não têm
  confinamento. Nesses quatro, a disciplina é instrução ao Claude (ver `CLAUDE.md`).
- **LightCraft:** usa uma biblioteca persistente compartilhada em `projetos/_bibliotecas/lightcraft` (um álbum por projeto).

## Instalação / reconstrução

Os binários já foram compilados (`cargo build --release -p <app>-cli` em cada pasta). Para refazer:

```bash
export PATH="$HOME/.cargo/bin:$PATH"
for a in photocraft vectorcraft filmcraft lightcraft pdfcraft figcraft effectcraft soundcraft designcraft; do
  (cd $a && cargo build --release -p $a-cli)
done
```

Se mudar a pasta de lugar, regenere os caminhos absolutos do `.mcp.json`.

## Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| Ferramentas `mcp__<app>__*` não aparecem | `.mcp.json` só é lido ao abrir o Claude Code / servidores não aprovados | Reabra o Claude Code aqui e aprove; use `/mcp` para ver o status |
| `ENOENT` ao iniciar um servidor | `-cli` não compilado ou caminho antigo | Rebuild acima; confira o `command` no `.mcp.json` |
| "outside the automation roots" | Caminho fora das raízes (`referencias/`, `materiais/`, `projetos/`, `finalizados/`) ou relativo | Use caminho absoluto dentro das raízes |
| LightCraft: "library already open" | Biblioteca em uso por outro processo | Use só um processo por biblioteca |
| Muitas ferramentas (PdfCraft tem 179) | — | Já usamos `--compact`; o resto via `tool_search`/`tool_call` |

## Controle de versão

Este diretório é um repositório git que versiona só o workflow (docs, skills, `.mcp.json`). As pastas dos 9 apps
(repositórios próprios) e o conteúdo de `referencias/`, `materiais/`, `projetos/`, `finalizados/` ficam fora (ver `.gitignore`).

## Avisos

- Os Crafts são projetos em desenvolvimento ativo; trate resultados como rascunho até conferir visualmente.
- Cada app tem licença e regras próprias (veja `LICENSE-*` e `ATTRIBUTION.md` de cada pasta). Nada de assets de
  terceiros sem licença nos seus projetos.
