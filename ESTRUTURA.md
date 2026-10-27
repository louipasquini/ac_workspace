# Estrutura de projetos

Cada trabalho tem **uma pasta só**, dentro de `projetos/`, com tudo o que pertence a ele:

```
projetos/
└YYYY-MM-DD-nome-do-projeto/
  └brutos/
    └{extensão em maiúsculas (Exemplo: PSD, ECPROJ, SVG)}/
      └arquivo{.psd}
  └referencias/
    └[Arquivos de referência, principalmente de identidade visual, para levar como base para o projeto]
    └CONTEXTO.md (briefing: objetivo, público, tom, formatos, prazos — quando necessário)
  └materiais/
    └[Arquivos que entram no projeto como estão: fotos, vídeos gravados, logos finais, trilhas licenciadas, fontes, textos aprovados]
  └finalizados/
    └todos-arquivos-finalizados-do-projeto
```

O nome da pasta segue `YYYY-MM-DD-nome-do-projeto`: data de início + nome em *kebab-case*, minúsculo, sem acentos
(ex.: `2026-10-26-vinheta-amor-em-nutrir`).

`projetos/_bibliotecas/` não é um projeto: guarda a biblioteca compartilhada do LightCraft
(`projetos/_bibliotecas/lightcraft`, um álbum por projeto).

## O que vai em cada subpasta

| Subpasta | Quem preenche | Para que serve | Exemplo |
|---|---|---|---|
| `referencias/` | usuário | Inspiração e regras: identidade visual, briefing (`CONTEXTO.md`), exemplos do estilo desejado | manual da marca, vídeo de referência, repositório do produto |
| `materiais/` | usuário | Matéria-prima que vai **dentro** da peça | fotos do produto, gravações, logo final, trilha licenciada, locução, textos aprovados |
| `brutos/` | Claude | Arquivos editáveis, uma subpasta por extensão (`brutos/PSD/`, `brutos/ECPROJ/`…) | `.pcraft`, `.vectorcraft`, `.ecproj`, `.fcproj`, SVGs e WAVs criados no projeto |
| `finalizados/` | Claude | Entregáveis exportados, todos na raiz da subpasta | PNG, SVG, PDF, MP4, WAV |

`referencias/` e `materiais/` são **somente leitura** para o Claude: ele nunca altera, move ou apaga nada nelas.
Se for preciso converter ou tratar um material, a versão tratada é salva em `brutos/<EXT>/`.
As duas são opcionais; o Claude cria as quatro subpastas ao iniciar o projeto (vazias), e o usuário pode
colocar arquivos em `referencias/` e `materiais/` antes ou depois.

## Migrando da estrutura antiga

Até outubro de 2026 o repositório usava quatro árvores separadas na raiz
(`referencias/<projeto>/`, `materiais/<projeto>/`, `projetos/<projeto>/<EXT>/`, `finalizados/<projeto>/`).
Para converter, feche as sessões do Claude Code que estiverem usando a pasta e rode:

```bash
./setup.sh --migrar
```

(Windows: `.\setup.ps1 -Migrar`.) O script move cada pasta para `projetos/<projeto>/…`, põe as subpastas de extensão
dentro de `brutos/` e corrige os caminhos absolutos gravados nos brutos de texto (ex.: `.ecproj`, scripts).
Ele não sobrescreve nada: se o destino já tiver arquivos, avisa e deixa aquela pasta onde está.
