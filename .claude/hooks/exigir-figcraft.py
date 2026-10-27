#!/usr/bin/env python3
"""Hook PreToolUse: página web só depois do layout no FigCraft.

Bloqueia a criação/edição de arquivos .html dentro de projetos/<projeto>/ enquanto o projeto não tiver
um layout em brutos/FIGCRAFT/*.figcraft (ou brutos/FIGCRAFT/DISPENSADO.md, criado só quando o usuário
pede explicitamente para pular a etapa). Ver .claude/skills/craft-pagina-web/SKILL.md.
"""
import json
import re
import shlex
import sys
from pathlib import Path

HTML = re.compile(r"\.html?$", re.I)
# Destinos de escrita em comandos Bash: redirecionamento/tee, open(..., "w"), Path(...).write_text
REDIRECT = re.compile(r"(?:(?<![0-9&])>>?|\btee(?:\s+-a)?)\s*(['\"]?)([^\s'\";|&]+)\1")
PY_OPEN = re.compile(r"open\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"][wax]")
PY_WRITE = re.compile(r"Path\(\s*['\"]([^'\"]+)['\"]\s*\)\s*\.write_(?:text|bytes)")
# Comandos cujo último argumento é o destino
ULTIMO_ARG = {"cp", "mv", "install", "rsync", "ln"}


def destinos_bash(cmd):
    alvos = [m.group(2) for m in REDIRECT.finditer(cmd)]
    alvos += PY_OPEN.findall(cmd) + PY_WRITE.findall(cmd)
    for trecho in re.split(r"&&|\|\||[;|\n]", cmd):
        try:
            tokens = shlex.split(trecho)
        except ValueError:
            continue
        if not tokens:
            continue
        if tokens[0] in ULTIMO_ARG and len(tokens) > 2:
            alvos.append(tokens[-1])
        elif tokens[0] == "sed" and any(t.startswith("-i") for t in tokens[1:]):
            alvos.append(tokens[-1])
    return alvos


def projeto_do_html(caminho, cwd, raiz):
    if not HTML.search(caminho):
        return None
    p = Path(caminho)
    p = (p if p.is_absolute() else cwd / p).resolve()
    try:
        partes = p.relative_to(raiz / "projetos").parts
    except ValueError:
        return None
    if len(partes) < 2 or partes[0].startswith("_"):
        return None
    return partes[0]


def tem_layout(raiz, projeto):
    pasta = raiz / "projetos" / projeto / "brutos" / "FIGCRAFT"
    return pasta.is_dir() and (any(pasta.glob("*.figcraft")) or (pasta / "DISPENSADO.md").is_file())


def main():
    try:
        dados = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0
    cwd = Path(dados.get("cwd") or ".").resolve()
    raiz = cwd
    while raiz != raiz.parent and not (raiz / "projetos").is_dir():
        raiz = raiz.parent
    if not (raiz / "projetos").is_dir():
        return 0

    tool, entrada = dados.get("tool_name", ""), dados.get("tool_input") or {}
    if tool == "Bash":
        alvos = destinos_bash(entrada.get("command", ""))
    elif tool in ("Write", "Edit", "MultiEdit", "NotebookEdit"):
        alvos = [entrada.get("file_path") or entrada.get("notebook_path") or ""]
    else:
        return 0

    faltando = {pr for a in alvos if (pr := projeto_do_html(a, cwd, raiz)) and not tem_layout(raiz, pr)}
    if not faltando:
        return 0
    print(
        f"Bloqueado: o projeto {', '.join(sorted(faltando))} ainda não tem layout no FigCraft.\n"
        "Página web passa pelo FigCraft antes do código (skill craft-pagina-web): monte os frames Desktop e "
        "Mobile, salve em projetos/<projeto>/brutos/FIGCRAFT/layout.figcraft, mostre ao usuário e só então "
        "escreva o HTML.\nSó se o usuário pedir explicitamente para pular essa etapa, crie "
        "brutos/FIGCRAFT/DISPENSADO.md com o pedido dele e o motivo.",
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
