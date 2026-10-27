---
name: craft-pagina-web
description: Cria páginas web (landing page, LP, site, página de vendas/captura, e-mail HTML) passando obrigatoriamente pelo FigCraft antes do código - layout desktop e mobile no FigCraft, aprovação do usuário, depois HTML fiel ao layout. Use sempre que pedirem uma página, uma nova versão de página ou um redesign de site.
---

# Página web: FigCraft primeiro, código depois

Nenhuma linha de HTML/CSS é escrita antes de existir o layout no FigCraft, salvo pedido explícito do usuário para
pular essa etapa. O hook `.claude/hooks/exigir-figcraft.py` bloqueia a escrita de `.html` em um projeto sem
`brutos/FIGCRAFT/*.figcraft`.

## 1. Conteúdo e referências (antes de desenhar)
- Siga `craft-novo-projeto` e `craft-ler-referencias` normalmente.
- Se o pedido for uma nova versão de uma página existente, leia a página no navegador: textos, imagens (URLs),
  links de CTA/checkout, vídeo, cores e fontes. Se a URL não abrir ou redirecionar, avise e peça outra.
- Se houver página de referência de layout/animação, anote a estrutura das seções, a navegação, os padrões de
  movimento e a escala tipográfica. Use-a como **referência de estilo**, sem copiar marca, textos ou imagens dela.
- Anote em uma lista o que falta (link de checkout, textos novos), para perguntar junto com a aprovação do layout.

## 2. Layout no FigCraft (skill `craft-figcraft`)
- Um documento, uma página com **dois frames lado a lado**: `Desktop` (1440 px de largura) e `Mobile` (390 px).
- Um frame filho por seção, na ordem da página (Nav, Hero, …, Rodapé), com auto layout vertical, para manter a
  estrutura navegável no `inspect_document`.
- Use o **conteúdo real** (textos da página, imagens de `materiais/` ou da página original), não lorem ipsum.
- Cores, fontes, raios e espaçamentos da identidade: defina-os como estilos/variáveis no FigCraft. Eles são a fonte
  dos tokens CSS na etapa 4.
- Animações não se desenham: descreva-as num frame `Notas de movimento` ao lado (ex.: "Hero: texto entra com
  blur 10px→0 e subida de 24px, 0,9s").
- `screenshot` de cada frame e **olhe** antes de seguir. Salve com `save_file` em
  `projetos/<projeto>/brutos/FIGCRAFT/layout.figcraft` e exporte os PNGs para `brutos/PNG/layout-desktop.png` e
  `brutos/PNG/layout-mobile.png`.

## 3. Aprovação
- Mostre os dois PNGs ao usuário (SendUserFile) e pergunte se aprova, junto com as pendências da etapa 1.
- Ajustes pedidos são feitos **no FigCraft** (salvar `layout-v2.figcraft`), não direto no código.
- Só avance com aprovação explícita. Se o usuário disser para seguir sem aprovar, registre isso no resumo final.

## 4. Desenvolvimento do HTML
- Arquivo editável: `projetos/<projeto>/brutos/HTML/index.html` (um arquivo, CSS e JS inline, salvo pedido diferente).
- Leia o `.figcraft` com `inspect_document`/`get_node` para tirar medidas, cores, fontes e espaçamentos; os tokens
  CSS (`:root`) devem bater com os estilos do FigCraft.
- Estrutura de seções = frames do FigCraft, na mesma ordem. Mobile segue o frame `Mobile`.
- Implemente as animações das `Notas de movimento`, respeitando `prefers-reduced-motion`.

## 5. Conferência contra o layout
- Renderize a página (Chrome headless com `--force-prefers-reduced-motion` para captura estática, e o navegador
  embutido para ver as animações) em 1440 e 390 px.
- Compare lado a lado com `layout-desktop.png`/`layout-mobile.png`. Divergências: corrija o código, ou, se a
  mudança for melhor, atualize primeiro o FigCraft para os dois continuarem iguais.
- Confira console sem erros, sem rolagem horizontal, links (CTA, WhatsApp, checkout) e textos alternativos.

## 6. Finalizados (skill `craft-salvar-finalizados`)
- `finalizados/<nome>.html`, `finalizados/<nome>-desktop.png` e `finalizados/<nome>-mobile.png` (página inteira).
- Exporte também o layout aprovado do FigCraft: `finalizados/<nome>-layout.pdf` (ou PNGs), para quem for revisar.
- No resumo, liste o que ficou pendente (checkout, textos escritos por você e não aprovados, imagens externas).
