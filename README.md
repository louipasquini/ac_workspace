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

1. abre um **menu para escolher os apps**, no estilo do `specify init` do spec-kit:

   ```
   Quais apps instalar? (↑/↓ move · espaço marca · a todos · enter confirma · q sai)

      ○ photocraft   3 GB    Photoshop      — imagens raster
      ◉ vectorcraft  3 GB    Illustrator    — vetor, logos
    ❯ ◉ figcraft     16 GB   Figma          — interfaces
      ○ soundcraft   2 GB    Áudio          — trilha, mixagem (já instalado)
      …

     2 selecionado(s) · disco livre necessário: ~16 GB (o maior, compilado por vez)
   ```

   | Tecla | Faz |
   |---|---|
   | ↑ / ↓ (ou `k` / `j`) | move |
   | espaço | marca/desmarca o app |
   | `a` | marca todos (de novo: desmarca todos) |
   | enter | confirma |
   | `q` / Esc | sai sem instalar nada |

   No Windows o menu é o mesmo, com `[x]` e `>` no lugar dos símbolos (a fonte padrão do console não tem ◉/❯).
   Sem terminal interativo (saída redirecionada, CI), o script volta à lista numerada em que se digitam os
   números; para automatizar, use `--apps`;
2. pergunta se você quer **também os apps com janela** (*Sim, com atalho / Não, só o MCP*; ver
   [Apps com janela](#apps-com-janela-opcional));
3. **confere os pré-requisitos** e mostra o que está ok e o que falta;
4. se faltar algo, **mostra o que vai instalar e pergunta** com um menu *Sim, instalar / Não, sair*
   (setas + enter, ou `s`/`n`);
5. para cada app: clona `github.com/storytold/<app>` em `<app>/` (clone raso, só o último commit), compila só o
   servidor MCP (`cargo build --release -p <app>-cli`), apaga o cache de compilação (`target/`) e mantém só o
   binário em `<app>/target/release/<app>-cli` (`.exe` no Windows);
6. se você pediu, instala o **app com janela** de cada um, com atalho na área de trabalho;
7. cria `projetos/` e a biblioteca do LightCraft; se encontrar a estrutura antiga de pastas, oferece a
   [migração](ESTRUTURA.md#migrando-da-estrutura-antiga);
8. gera o `.mcp.json` com os caminhos absolutos desta pasta, **só com os apps que estão compilados**.

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

### Apps com janela (opcional)

O Claude não precisa deles: ele usa os servidores MCP (`<app>-cli`), que rodam sem janela. Os apps com janela servem
para **você** abrir os brutos (`.pcraft`, `.ecproj`, `.designcraft`…) e ajustar à mão. O setup instala o app pelo
**instalador oficial** da release mais recente de cada um no GitHub, confere o SHA-256 que o GitHub publica para o
arquivo (se não bater, descarta) e cria o atalho:

| Sistema | Instalador | Onde fica | Atalho |
|---|---|---|---|
| Debian/Ubuntu | `.deb` via `apt-get` (pede a senha do sudo) | menu de aplicativos | área de trabalho (marcado como confiável no GNOME) |
| Fedora / openSUSE | `.rpm` via `dnf` / `zypper` | menu de aplicativos | área de trabalho |
| Arch | `.pkg.tar.zst` via `pacman` | menu de aplicativos | área de trabalho |
| Outras distros | AppImage em `~/Applications/` + lançador em `~/.local/share/applications/` | menu de aplicativos | área de trabalho |
| macOS | `.dmg` (universal) copiado para `/Applications` (ou `~/Applications` sem permissão) | Launchpad | atalho na Mesa |
| Windows | `.msi` via `msiexec` (o Windows pede permissão de administrador) | Menu Iniciar | área de trabalho |

Para instalar ou atualizar só os apps com janela depois, sem recompilar o MCP:
`./setup.sh --apps <app> --desktop --sem-build` (Windows: `.\setup.ps1 -Apps <app> -Desktop -SemBuild`).
Para desinstalar, use o caminho normal do sistema (gerenciador de pacotes, Lixo no macOS, "Aplicativos instalados"
no Windows).

> **LightCraft:** o app com janela e o servidor MCP não podem abrir a biblioteca `projetos/_bibliotecas/lightcraft`
> ao mesmo tempo. Para usá-la no app, feche antes o Claude Code (ou abra outra biblioteca no app).

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
| `./setup.sh --migrar` | `.\setup.ps1 -Migrar` | Só converte projetos da [estrutura antiga](ESTRUTURA.md#migrando-da-estrutura-antiga) de pastas |
| `./setup.sh --desktop` | `.\setup.ps1 -Desktop` | Instala também os [apps com janela](#apps-com-janela-opcional), sem perguntar |
| `./setup.sh --sem-desktop` | `.\setup.ps1 -SemDesktop` | Não pergunta sobre os apps com janela |

No Windows, o PowerShell precisa do prefixo `powershell -ExecutionPolicy Bypass -File` quando a política de
execução bloqueia scripts (o padrão).

Para **adicionar um app depois**, rode `./setup.sh --apps <app>`: os apps já instalados são mantidos e
continuam no `.mcp.json`. Para **remover** um, apague a pasta do app e rode `./setup.sh --so-mcp` (ou `.\setup.ps1 -SoMcp`).
Sempre reabra o Claude Code depois de mudar o `.mcp.json`.

> O `.mcp.json` não é versionado (está no `.gitignore`), porque contém os caminhos absolutos da sua máquina e
> só os apps que você instalou.

## Como usar

1. **Crie a pasta do projeto e coloque referências e materiais** (opcional, mas recomendado). Cada trabalho fica
   numa pasta só, dentro de `projetos/`:
   ```
   projetos/2026-10-26-nome-do-projeto/
   ├── referencias/   # você: logo.svg, paleta.png, manual-da-marca.pdf, fontes…
   │   └── CONTEXTO.md  # briefing: objetivo, público, tom, formatos, prazos
   ├── materiais/     # você: fotos, vídeos gravados, logo final, trilha licenciada, locução, textos aprovados…
   ├── brutos/        # Claude: editáveis
   └── finalizados/   # Claude: entregáveis
   ```
   Se você não criar a pasta, o Claude cria ao começar o trabalho e avisa onde colocar os arquivos.
2. **Abra o Claude Code nesta pasta** (depois do [setup](#instalação)) e aprove os servidores MCP do projeto (`.mcp.json`) na primeira vez.
3. **Peça a tarefa.** O Claude ativa o workflow (`craft-workflow`), lê as referências, conecta aos apps, desenvolve,
   salva e encerra.
4. **Retire os resultados:**
   ```
   projetos/2026-10-26-nome-do-projeto/brutos/<EXT>/arquivo.<ext>   # editáveis
   projetos/2026-10-26-nome-do-projeto/finalizados/                 # entregáveis
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

- **Confinamento de arquivos:** os servidores só leem e escrevem dentro de `projetos/`. Isso vale para PhotoCraft,
  VectorCraft, PdfCraft, FigCraft, EffectCraft, SoundCraft e DesignCraft; FilmCraft e LightCraft não têm confinamento.
  Dentro de `projetos/`, a regra de escrever só em `brutos/` e `finalizados/` e nunca mexer em `referencias/` e
  `materiais/` é instrução ao Claude (ver `CLAUDE.md`), porque os apps não restringem subpastas por projeto.
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
| "outside the automation roots" | Caminho fora de `projetos/` ou relativo | Use caminho absoluto dentro de `projetos/` |
| Pastas `referencias/`, `materiais/` ou `finalizados/` na raiz | Estrutura antiga de pastas | Feche as sessões do Claude Code e rode `./setup.sh --migrar` (Windows: `.\setup.ps1 -Migrar`) |
| LightCraft: "library already open" | Biblioteca em uso por outro processo (outra sessão do Claude Code, ou o LightCraft com janela aberto nela) | Feche o outro processo; use só um por biblioteca |
| Setup: "SHA-256 não confere" (app com janela) | Download corrompido ou interceptado | Rode de novo; se repetir, baixe pela página de releases do app e confira |
| Muitas ferramentas (PdfCraft tem 179) | — | Já usamos `--compact`; o resto via `tool_search`/`tool_call` |

## Controle de versão

Este diretório é um repositório git que versiona só o workflow (docs, skills, `setup.sh`/`setup.ps1`). As pastas dos 9 apps
(repositórios próprios), o `.mcp.json` gerado e o conteúdo de `projetos/` ficam fora (ver `.gitignore`).

## Avisos

- Os Crafts são projetos em desenvolvimento ativo; trate resultados como rascunho até conferir visualmente.
- Cada app tem licença e regras próprias (veja `LICENSE-*` e `ATTRIBUTION.md` de cada pasta). Nada de assets de
  terceiros sem licença nos seus projetos.
