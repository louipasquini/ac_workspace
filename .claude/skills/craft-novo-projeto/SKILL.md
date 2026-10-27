---
name: craft-novo-projeto
description: Define o nome padronizado YYYY-MM-DD-nome-do-projeto e cria projetos/<projeto>/ com brutos/, referencias/, materiais/ e finalizados/ conforme ESTRUTURA.md. Use no início de qualquer tarefa nova, antes de ler referências ou abrir qualquer Craft.
---

# Novo projeto

1. Listar `projetos/` (ignorando `_bibliotecas/`). Se o usuário já criou uma pasta para este trabalho (por exemplo,
   com `referencias/` ou `materiais/` preenchidas), **reutilize exatamente esse nome**.
   Se existirem várias candidatas e não for óbvio qual é, pergunte.
   Se existirem `referencias/`, `materiais/` ou `finalizados/` na raiz do repositório, é a estrutura antiga: peça ao
   usuário para rodar `./setup.sh --migrar` antes de seguir.
2. Se não existir, montar o nome: data de hoje (`date +%F`) + `-` + nome em *kebab-case*, minúsculo, sem acentos
   nem espaços (ex.: `2026-10-26-vinheta-amor-em-nutrir`). Confirmar o nome com o usuário se houver dúvida.
3. Criar (sem sobrescrever o que existir):
   ```bash
   mkdir -p projetos/<projeto>/{brutos,referencias,materiais,finalizados}
   ```
   - `referencias/` e `materiais/` nascem vazias quando o projeto é novo: é onde o usuário coloca a identidade
     visual/`CONTEXTO.md` e os arquivos que devem entrar na peça. Avise o usuário que elas existem.
   - Se `referencias/` estiver vazia, **não** invente referências: avise e pergunte se o usuário quer fornecer material.
   - As subpastas de extensão (`brutos/PSD/`, `brutos/AI/`…) são criadas pela skill `craft-salvar-brutos`.
4. Informar o caminho final: `projetos/<projeto>/`.
