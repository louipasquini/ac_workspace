# Workflow completo — da solicitação ao arquivo finalizado

Este documento é a fonte de verdade do fluxo de trabalho. O `CLAUDE.md` resume e aponta para cá;
cada etapa tem uma skill em `.claude/skills/` que o Claude ativa sozinho (ou você chama com `/nome`).

## Visão geral

```
 1 Solicitação ──► 2 Pasta do projeto ──► 3 Referências ──► 4 Servidores ──► 5 Conexão MCP
                                                                                   │
 9 Encerrar ◄── 8 Finalizados ◄── 7 Brutos ◄── 6 Desenvolvimento ◄────────────────┘
```

| # | Etapa | Skill | O que acontece |
|---|-------|-------|----------------|
| 0 | Orquestração | `craft-workflow` | Conduz as etapas 1–9 na ordem certa |
| 1 | Novo projeto | `craft-novo-projeto` | Define `YYYY-MM-DD-nome-do-projeto` e cria `projetos/<projeto>/` com as 4 subpastas |
| 2 | Referências | `craft-ler-referencias` | Lê `referencias/` (com o `CONTEXTO.md`) e `materiais/` do projeto |
| 3 | Servidores | `craft-subir-servidores` | Escolhe os Crafts necessários e confirma que o MCP responde |
| 4 | Desenvolvimento | `craft-<app>` | Opera o app específico via MCP |
| 5 | Brutos | `craft-salvar-brutos` | Salva o arquivo editável em `projetos/<projeto>/brutos/<EXT>/` |
| 6 | Finalizados | `craft-salvar-finalizados` | Exporta o entregável em `projetos/<projeto>/finalizados/` |
| 7 | Encerramento | `craft-encerrar-servidores` | Fecha sessões, confere pendências, resume a entrega |

## Etapa a etapa

### 1. Novo projeto
- Nome: `YYYY-MM-DD-nome-do-projeto` — data de hoje, nome em *kebab-case* sem acentos.
- Se o usuário já criou a pasta do trabalho em `projetos/` (por exemplo, para deixar referências), **usa-se esse nome**.
- Cria `projetos/<projeto>/` com `brutos/`, `referencias/`, `materiais/` e `finalizados/` (sem sobrescrever o que
  existir). As subpastas de extensão dentro de `brutos/` nascem sob demanda.

### 2. Referências
- Listar `projetos/<projeto>/referencias/` por inteiro. Ler `CONTEXTO.md` primeiro, depois as imagens,
  PDFs, paletas, fontes e logos de identidade visual.
- Extrair e anotar: paleta (hex), tipografia, tom, formatos/resoluções pedidos, restrições.
- Se não houver referências ou o `CONTEXTO.md` for ambíguo, **perguntar** antes de produzir.
- Nunca copiar material de referência para `finalizados/`; ele só entra se for parte do entregável.
- Listar `projetos/<projeto>/materiais/`: são os arquivos que entram na peça (fotos, gravações, logo final, trilha,
  textos). Anotar formato, resolução e duração de cada um e usá-los antes de criar substitutos. Se precisar tratar um
  material, salvar a versão tratada em `brutos/<EXT>/`, nunca por cima do original.

### 3. Servidores
- Os servidores MCP são `<app>-cli mcp` (stdio), registrados em `.mcp.json` e iniciados pelo
  Claude Code ao abrir esta pasta; cada um fecha quando a sessão termina.
- Escolher só os apps necessários (ex.: motion design → EffectCraft + SoundCraft + VectorCraft).
- Confirmar com uma chamada leve (`doc_inspect` ou equivalente). Se a ferramenta não existir,
  o servidor não subiu: ver "Solução de problemas" no `README.md`.

### 4. Desenvolvimento
- Seguir a skill do app (`craft-photocraft`, `craft-vectorcraft`, …) para convenções e ferramentas.
- Fluxo padrão: `command_list` → `command_run`/`command_batch` → `render_preview` (olhar o resultado)
  → ajustar. Sempre conferir visualmente antes de exportar.
- Salvar com frequência (etapa 5) para não perder trabalho.

### 5. Brutos (editáveis)
```
projetos/YYYY-MM-DD-nome-do-projeto/brutos/<EXT>/arquivo.<ext>
```
`EXT` é a extensão em maiúsculas (`PSD`, `AI`, `FCPROJ`, `FIGCRAFT`…). Ver tabela de extensões em
`.claude/skills/craft-salvar-brutos/SKILL.md`.

### 6. Finalizados (entregáveis)
```
projetos/YYYY-MM-DD-nome-do-projeto/finalizados/<arquivos exportados>
```
Todos os entregáveis do projeto ficam na raiz de `finalizados/` (PNG, SVG, PDF, MP4, WAV…), com nomes claros.

### 7. Encerramento
- Confirmar que brutos e finalizados existem e abrem (`ls -la`, tamanho > 0).
- Liberar sessões abertas (fechar/descartar documentos sem salvar o que não importa).
- Os processos MCP terminam com a sessão do Claude Code; processos avulsos (apps com janela,
  builds) devem ser encerrados explicitamente e verificados com `pgrep`.
- Entregar ao usuário um resumo: o que foi feito, caminhos, o que ficou pendente.

## Regras transversais
1. **Perguntar, não assumir** quando faltar informação criativa ou técnica.
2. **Confinamento de arquivos**: os servidores MCP leem e escrevem só dentro de `projetos/` (ver `.mcp.json`).
   Dentro dela, escrever apenas em `brutos/` e `finalizados/` do projeto atual; `referencias/` e `materiais/` são
   somente leitura.
3. **Nunca sobrescrever** um entregável existente sem avisar; versionar com `-v2`, `-v3`.
4. **Nunca usar assets de terceiros** (ícones, fontes, imagens) sem licença; usar o que está em `materiais/` e `referencias/` do projeto.
5. **Os Crafts são projetos Rust em desenvolvimento**: se um comando falhar, registrar o erro,
   tentar caminho alternativo e informar o usuário em vez de insistir em silêncio.
