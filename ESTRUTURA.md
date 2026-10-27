# Estrutura de projetos

Todos os projetos desenvolvidos aqui iremos salvar na pasta projetos e os arquivos finalizados na pasta finalizados seguindo a seguinte estrutura:

```
referencias/
└YYYY-MM-DD-nome-do-projeto/
  └[Lista de arquivos de referência, principalmente de identidade visual para você levar como base para o projeto em questão]
  └CONTEXTO.md (arquivo markdown de contexto para os documentos caso seja necessário)  

materiais/
└YYYY-MM-DD-nome-do-projeto/
  └[Arquivos que entram no projeto como estão: fotos, vídeos gravados, logos finais, trilhas licenciadas, fontes, textos aprovados]

projetos/
└YYYY-MM-DD-nome-do-projeto/
  └{extensão (Exemplo: PSD, MOV, AI)}
    └arquivo{.psd}

finalizados
└YYYY-MM-DD-nome-do-projeto/
  └todos-arquivos-finalizados-do-projeto
```

## Referências × materiais

| Pasta | Para que serve | Exemplo |
|---|---|---|
| `referencias/` | Inspiração e regras: identidade visual, briefing (`CONTEXTO.md`), exemplos do estilo desejado | manual da marca, vídeo de referência, repositório do produto |
| `materiais/` | Matéria-prima que vai **dentro** da peça | fotos do produto, gravações, logo final, trilha licenciada, locução, textos aprovados |

As duas pastas são preenchidas pelo usuário e são **somente leitura**: o Claude nunca altera, move ou apaga nada nelas.
Se for preciso converter ou tratar um material, a versão tratada é salva em `projetos/<projeto>/<EXT>/`.
Ambas são opcionais e usam o mesmo nome `YYYY-MM-DD-nome-do-projeto` das outras pastas.

