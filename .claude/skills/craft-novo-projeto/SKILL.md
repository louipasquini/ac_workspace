---
name: craft-novo-projeto
description: Define o nome padronizado YYYY-MM-DD-nome-do-projeto e cria as pastas materiais/, projetos/ e finalizados/ conforme ESTRUTURA.md. Use no início de qualquer tarefa nova, antes de ler referências ou abrir qualquer Craft.
---

# Novo projeto

1. Listar `referencias/` e `materiais/`. Se o usuário já criou uma pasta para este trabalho em qualquer uma delas, **reutilize exatamente esse nome**.
   Se existirem várias candidatas e não for óbvio qual é, pergunte.
2. Se não existir, montar o nome: data de hoje (`date +%F`) + `-` + nome em *kebab-case*, minúsculo, sem acentos
   nem espaços (ex.: `2026-10-26-vinheta-amor-em-nutrir`). Confirmar o nome com o usuário se houver dúvida.
3. Criar (sem sobrescrever o que existir):
   ```bash
   mkdir -p materiais/<projeto> projetos/<projeto> finalizados/<projeto>
   ```
   `materiais/<projeto>/` nasce vazia: é onde o usuário coloca os arquivos que devem entrar na peça
   (fotos, gravações, logo final, trilha, textos). Avise o usuário que ela existe.
   As subpastas de extensão (`PSD/`, `AI/`…) são criadas pela skill `craft-salvar-brutos`.
   Se `referencias/<projeto>/` não existir, **não** a invente: avise o usuário e pergunte se quer fornecer material.
4. Informar o nome final, que será usado nas quatro árvores.
