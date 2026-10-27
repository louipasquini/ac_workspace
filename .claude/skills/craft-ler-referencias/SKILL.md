---
name: craft-ler-referencias
description: Lê e resume os arquivos de referencias/<projeto>/ (identidade visual, logos, paletas, fontes, imagens, PDFs), o CONTEXTO.md e os materiais de materiais/<projeto>/ antes de qualquer produção. Use logo após definir o projeto e sempre que o usuário mencionar referências, materiais, identidade visual ou briefing.
---

# Ler referências

1. `ls -la referencias/<projeto>/` — liste tudo, incluindo subpastas.
2. Ler `CONTEXTO.md` primeiro (briefing, público, tom, formatos, prazos, restrições).
3. Examinar cada arquivo:
   - **Imagens** (png/jpg/webp/svg): abrir com a ferramenta de leitura de imagens; anotar cores dominantes, estilo, composição.
   - **PDFs** (manual de marca, brief): ler com a skill/ferramenta de PDF; extrair paleta, tipografia, regras de uso de logo.
   - **Fontes** (ttf/otf): registrar nomes e pesos; confirmar licença quando houver dúvida.
   - **Áudio/vídeo**: anotar duração, formato, uso previsto.
4. Produzir um **resumo de identidade** para o usuário e para uso nas etapas seguintes:
   paleta (hex), tipografia, tom/estilo, formatos e resoluções, o que deve/não deve aparecer.
5. Listar `materiais/<projeto>/` (se existir). Materiais são arquivos que entram na peça como estão
   (fotos, gravações, logo final, trilha, locução, textos aprovados). Para cada um, anotar formato, resolução/duração
   e onde será usado. Use-os antes de criar substitutos; se faltar algo que a peça exige, pergunte se o usuário
   tem o material antes de gerar um. Inclua a lista no resumo.
6. Se houver contradição, informação faltando ou referência ilegível, **pergunte** antes de seguir.
7. Referências e materiais são somente leitura: nunca alterar nem mover arquivos em `referencias/` ou `materiais/`.
   Versões tratadas (recorte, conversão, limpeza de áudio) vão para `projetos/<projeto>/<EXT>/`.
