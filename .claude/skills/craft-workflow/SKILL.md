---
name: craft-workflow
description: Orquestra o fluxo completo de qualquer tarefa criativa nesta pasta (motion design, imagem, vetor, vídeo, áudio, PDF, UI, diagramação) usando os Crafts via MCP, das referências aos finalizados. Use sempre que o usuário pedir para criar, editar ou exportar um material visual, sonoro ou de documento.
---

# Orquestrador do workflow Craft

Conduza a tarefa nesta ordem, ativando cada skill na sequência. Detalhes em `WORKFLOW.md`.

1. **`craft-novo-projeto`** — definir `YYYY-MM-DD-nome-do-projeto` e criar `projetos/<projeto>/` com `brutos/`,
   `referencias/`, `materiais/` e `finalizados/`.
2. **`craft-ler-referencias`** — ler `referencias/` (com o `CONTEXTO.md`) e `materiais/` do projeto; resumir ao usuário
   o que entendeu e quais materiais serão usados.
3. **`craft-subir-servidores`** — decidir quais Crafts a tarefa exige e confirmar que o MCP de cada um responde.
4. **Desenvolver** com a skill do app: `craft-photocraft`, `craft-vectorcraft`, `craft-filmcraft`,
   `craft-lightcraft`, `craft-pdfcraft`, `craft-figcraft`, `craft-effectcraft`, `craft-soundcraft`, `craft-designcraft`.
5. **`craft-salvar-brutos`** — salvar os editáveis em `projetos/<projeto>/brutos/<EXT>/`.
6. **`craft-salvar-finalizados`** — exportar os entregáveis em `projetos/<projeto>/finalizados/`.
7. **`craft-encerrar-servidores`** — fechar sessões, verificar processos, resumir a entrega.

## Mapa tarefa → apps
| Tarefa | Apps |
|---|---|
| Motion design / animação | EffectCraft (+ VectorCraft para formas, SoundCraft para trilha, FilmCraft para montagem final) |
| Edição de vídeo | FilmCraft (+ SoundCraft, EffectCraft) |
| Retoque / composição de imagem | PhotoCraft |
| Revelação de fotos / RAW | LightCraft |
| Logo, ilustração, ícones | VectorCraft |
| Interface, protótipo | FigCraft |
| Livro, revista, folheto, multipágina | DesignCraft (+ VectorCraft, PhotoCraft) |
| PDF (editar, juntar, formulários) | PdfCraft |
| Áudio, trilha, locução | SoundCraft |

## Regras
- Se faltar informação criativa (formato, duração, público, tom) ou a referência for ambígua, **pergunte antes** de produzir.
- Se a tarefa pedir um app cujas ferramentas MCP não estão disponíveis na sessão, diga ao usuário (o `.mcp.json`
  só é lido ao abrir o Claude Code) em vez de improvisar.
- Sempre olhar o resultado (`render_preview`/screenshot) antes de salvar como finalizado.
- Ao final, sempre executar a etapa 7 mesmo se a tarefa falhar parcialmente.
