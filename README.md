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

## Instalação

Este repositório versiona só o workflow (docs, skills e os scripts de setup). Os apps são repositórios próprios
([github.com/storytold](https://github.com/storytold)) e **não vêm no clone**. O script de setup cuida de tudo:
confere e instala os pré-requisitos, baixa e compila os apps que você escolher e gera o `.mcp.json`.
Não é preciso instalar os nove: escolha só os que vai usar.

| Sistema | Script |
|---|---|
| Linux (Debian/Ubuntu, Fedora, Arch, openSUSE) | [`setup.sh`](setup.sh) |
| macOS | [`setup.sh`](setup.sh) (funciona com o bash 3.2 que já vem no sistema) |
| Windows 10/11 | [`setup.ps1`](setup.ps1) (PowerShell) |

Os dois scripts têm as mesmas opções e geram o mesmo `.mcp.json`.

### 1. Clonar este repositório

Só é preciso ter o `git` para clonar. Sem ele, baixe o ZIP pelo GitHub (botão **Code → Download ZIP**) e
descompacte; o setup instala o git em seguida.

```bash
git clone https://github.com/louipasquini/ac_workspace.git artcraft-mcp
```

### 2. Rodar o setup

**Linux e macOS**, no terminal, dentro da pasta:

```bash
./setup.sh
```

**Windows**, no PowerShell, dentro da pasta (o `-ExecutionPolicy Bypass` libera a execução só deste script, sem
mudar a configuração do sistema):

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Sem argumentos, o script:

1. **confere os pré-requisitos** e mostra o que está ok e o que falta;
2. se faltar algo, **mostra o que vai instalar e pede confirmação** (`s` para seguir);
3. mostra um **menu numerado** dos apps: digite os números (ex.: `1 2 7`) ou `todos`;
4. para cada app: clona `github.com/storytold/<app>` em `<app>/` (clone raso, só o último commit), compila só o
   servidor MCP (`cargo build --release -p <app>-cli`), apaga o cache de compilação (`target/`) e mantém só o
   binário em `<app>/target/release/<app>-cli` (`.exe` no Windows);
5. cria `referencias/`, `materiais/`, `projetos/`, `finalizados/` e a biblioteca do LightCraft;
6. gera o `.mcp.json` com os caminhos absolutos desta pasta, **só com os apps que estão compilados**.

Depois, abra o Claude Code na pasta e aprove os servidores MCP do projeto.

### Pré-requisitos (instalados pelo setup)

Os servidores MCP (`<app>-cli`) não usam bibliotecas gráficas nem de áudio do sistema. Para compilá-los basta:

| Precisa | Linux | macOS | Windows |
|---|---|---|---|
| git | pacote `git` | Xcode Command Line Tools | `winget install Git.Git` |
| Compilador C | `build-essential` (apt), `gcc gcc-c++ make` (dnf/zypper), `base-devel` (pacman) | Xcode Command Line Tools | Visual Studio 2022 Build Tools com C++ (~5 GB) |
| pkg-config | `pkg-config` / `pkgconf` | — | — |
| Rust **1.95+** | rustup | rustup | rustup |

Como o setup instala cada um:

- **Linux:** usa o gerenciador da distribuição (`apt-get`, `dnf`, `pacman` ou `zypper`) com `sudo`, então
  pede a sua senha.
- **macOS:** abre o instalador das *Command Line Tools* (`xcode-select --install`). Termine a instalação na
  janela e rode `./setup.sh` de novo.
- **Windows:** usa o `winget`, que já vem no Windows 10/11 atualizado. O instalador do Visual Studio pede
  permissão de administrador. Se a sessão não enxergar algo recém-instalado, abra um PowerShell novo e rode de
  novo.
- **Rust (todos):** é instalado pelo [rustup](https://rustup.rs) na pasta do usuário, sem sudo. Se o Rust já
  existir mas for antigo, o setup roda `rustup update stable`. Um Rust antigo instalado pela distribuição pode
  continuar lá: o do rustup tem prioridade.

Para só conferir, sem instalar nada: `./setup.sh --checar` (ou `.\setup.ps1 -Checar`). Para instalar sem
perguntar (ex.: em CI): `--sim` (ou `-Sim`). Se preferir instalar tudo à mão, use a tabela acima; o setup
apenas vai confirmar que está ok.

### Espaço em disco

Quase todo o espaço vem do cache de compilação, não dos apps. Com a limpeza padrão, o que fica é pequeno.
Os apps são compilados um de cada vez, então você precisa de espaço livre para o maior da sua seleção.

| App | Pico durante a compilação | Fica depois (repo + binário) |
|---|---|---|
| PhotoCraft | ~3 GB | ~150 MB |
| VectorCraft | ~3 GB | ~150 MB |
| FilmCraft | ~14 GB | ~80 MB |
| LightCraft | ~6 GB | ~400 MB |
| PdfCraft | ~3 GB | ~110 MB |
| FigCraft | ~16 GB | ~70 MB |
| EffectCraft | ~2,5 GB | ~130 MB |
| SoundCraft | ~2 GB | ~20 MB |
| DesignCraft | ~3 GB | ~100 MB |

Os 9 juntos com `--manter-build` passam de 50 GB; sem ele, ficam em torno de 1,2 GB. A compilação também leva
tempo: de alguns minutos a mais de meia hora por app, dependendo da máquina.

### Opções

| Linux/macOS | Windows | Faz |
|---|---|---|
| `./setup.sh` | `.\setup.ps1` | Pré-requisitos + menu interativo |
| `./setup.sh --apps photocraft,vectorcraft` | `.\setup.ps1 -Apps photocraft,vectorcraft` | Instala só esses (sem menu) |
| `./setup.sh --todos` | `.\setup.ps1 -Todos` | Instala os 9 |
| `./setup.sh --listar` | `.\setup.ps1 -Listar` | Mostra cada app: baixado, compilado ou ausente |
| `./setup.sh --checar` | `.\setup.ps1 -Checar` | Só confere os pré-requisitos |
| `./setup.sh --sim` | `.\setup.ps1 -Sim` | Instala pré-requisitos sem perguntar |
| `./setup.sh --apps figcraft --atualizar` | `.\setup.ps1 -Apps figcraft -Atualizar` | `git pull` no app e recompila |
| `./setup.sh --manter-build` | `.\setup.ps1 -ManterBuild` | Mantém `target/`: recompilar fica mais rápido, mas ocupa muito mais disco |
| `./setup.sh --sem-build` | `.\setup.ps1 -SemBuild` | Só clona |
| `./setup.sh --so-mcp` | `.\setup.ps1 -SoMcp` | Só regenera o `.mcp.json` (ex.: depois de mover a pasta de lugar) |

No Windows, o PowerShell precisa do prefixo `powershell -ExecutionPolicy Bypass -File` quando a política de
execução bloqueia scripts (o padrão).

Para **adicionar um app depois**, rode `./setup.sh --apps <app>`: os apps já instalados são mantidos e
continuam no `.mcp.json`. Para **remover** um, apague a pasta do app e rode `./setup.sh --so-mcp` (ou `.\setup.ps1 -SoMcp`).
Sempre reabra o Claude Code depois de mudar o `.mcp.json`.

> O `.mcp.json` não é versionado (está no `.gitignore`), porque contém os caminhos absolutos da sua máquina e
> só os apps que você instalou.

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
2. **Abra o Claude Code nesta pasta** (depois do [setup](#instalação)) e aprove os servidores MCP do projeto (`.mcp.json`) na primeira vez.
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

## Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| Ferramentas `mcp__<app>__*` não aparecem | `.mcp.json` só é lido ao abrir o Claude Code / servidores não aprovados | Reabra o Claude Code aqui e aprove; use `/mcp` para ver o status |
| `ENOENT` ao iniciar um servidor | `-cli` não compilado ou pasta movida | `./setup.sh --listar`; instale o app ou rode `./setup.sh --so-mcp` |
| Setup: "ainda faltam pré-requisitos" | Instalação não concluída, ou o terminal não vê o que acabou de ser instalado | Abra um terminal novo e rode o setup de novo; veja `--checar` |
| Windows: "a execução de scripts foi desabilitada" | Política de execução do PowerShell | `powershell -ExecutionPolicy Bypass -File .\setup.ps1` |
| Windows: `link.exe not found` ao compilar | Faltam as ferramentas C++ do Visual Studio | Rode o setup de novo ou instale o Build Tools com "Desenvolvimento para desktop com C++" |
| Windows: erro de caminho longo no clone | Limite de 260 caracteres | O setup já usa `core.longpaths`; mova a pasta para um caminho curto (ex.: `C:\artcraft`) |
| Setup: "No space left on device" | Disco cheio durante a compilação | Libere espaço para o maior app da seleção (tabela acima) e rode de novo |
| "outside the automation roots" | Caminho fora das raízes (`referencias/`, `materiais/`, `projetos/`, `finalizados/`) ou relativo | Use caminho absoluto dentro das raízes |
| LightCraft: "library already open" | Biblioteca em uso por outro processo (ex.: outra sessão do Claude Code aberta) | Feche a outra sessão; use só um processo por biblioteca |
| Muitas ferramentas (PdfCraft tem 179) | — | Já usamos `--compact`; o resto via `tool_search`/`tool_call` |

## Controle de versão

Este diretório é um repositório git que versiona só o workflow (docs, skills, `setup.sh`/`setup.ps1`). As pastas dos 9 apps
(repositórios próprios), o `.mcp.json` gerado e o conteúdo de `referencias/`, `materiais/`, `projetos/`, `finalizados/` ficam fora (ver `.gitignore`).

## Avisos

- Os Crafts são projetos em desenvolvimento ativo; trate resultados como rascunho até conferir visualmente.
- Cada app tem licença e regras próprias (veja `LICENSE-*` e `ATTRIBUTION.md` de cada pasta). Nada de assets de
  terceiros sem licença nos seus projetos.
