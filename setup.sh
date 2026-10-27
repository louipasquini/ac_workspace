#!/usr/bin/env bash
# setup.sh — Linux e macOS. Avalia/instala pré-requisitos, baixa, compila e registra no .mcp.json
# os Crafts escolhidos. No Windows use setup.ps1. Uso: ./setup.sh --ajuda
#
# Compatível com o bash 3.2 do macOS: sem arrays associativos, sem `set -u`, sem `sort -V`.
set -eo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_BASE="https://github.com/storytold"
RUST_MIN="1.95"
APPS=(photocraft vectorcraft filmcraft lightcraft pdfcraft figcraft effectcraft soundcraft designcraft)

case "$(uname -s)" in
  Linux) SO=linux ;;
  Darwin) SO=mac ;;
  MINGW*|MSYS*|CYGWIN*) echo "No Windows use o PowerShell: .\\setup.ps1" >&2; exit 1 ;;
  *) SO=outro ;;
esac

desc() {
  case $1 in
    photocraft) echo "Photoshop      — imagens raster" ;;
    vectorcraft) echo "Illustrator    — vetor, logos" ;;
    filmcraft) echo "Premiere       — edição de vídeo" ;;
    lightcraft) echo "Lightroom      — fotos/RAW" ;;
    pdfcraft) echo "Acrobat        — PDF" ;;
    figcraft) echo "Figma          — interfaces" ;;
    effectcraft) echo "After Effects  — motion design" ;;
    soundcraft) echo "Áudio          — trilha, mixagem" ;;
    designcraft) echo "InDesign       — diagramação" ;;
  esac
}
# Pico de disco durante a compilação (aprox.). Com a limpeza padrão sobra só o binário.
# Em décimos de GB, para dar para comparar (o bash não tem ponto flutuante).
pico_dgb() {
  case $1 in
    filmcraft) echo 140 ;; figcraft) echo 160 ;; lightcraft) echo 60 ;;
    effectcraft) echo 25 ;; soundcraft) echo 20 ;; *) echo 30 ;;
  esac
}
fmt_gb() { if (($1 % 10)); then echo "$(($1 / 10)),$(($1 % 10)) GB"; else echo "$(($1 / 10)) GB"; fi; }
pico() { fmt_gb "$(pico_dgb "$1")"; }

uso() {
  cat <<EOF
Uso: ./setup.sh [opções]          (Windows: .\\setup.ps1)

Sem opções, abre um menu para escolher os apps.

  --apps a,b,c       Apps a instalar (ex.: --apps photocraft,vectorcraft)
  --todos            Instala os 9 apps
  --listar           Mostra os apps, o que está instalado e sai
  --checar           Só avalia os pré-requisitos (não instala nada) e sai
  -y, --sim          Instala pré-requisitos ausentes sem perguntar
  --atualizar        Faz git pull nos apps já baixados antes de compilar
  --manter-build     Não apaga o cache de compilação (target/) — rebuilds mais rápidos, muito mais disco
  --sem-build        Só clona; não compila
  --so-mcp           Só regenera o .mcp.json com os apps já compilados
  --migrar           Só converte projetos da estrutura antiga de pastas (ver ESTRUTURA.md)
  -h, --ajuda        Esta ajuda

Apps: ${APPS[*]}
EOF
}

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merro:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------- menus com setas (↑/↓, espaço, enter), no estilo do `specify init` ----------
# Sem terminal interativo (pipe, CI, TERM=dumb) os chamadores caem na forma digitada.
tui_ok() { [[ -t 0 && -t 1 && ${TERM:-dumb} != dumb ]]; }
cursor() { if [[ -t 1 ]]; then printf '\033[?25%s' "$1"; fi; }  # l = esconde, h = mostra
trap 'cursor h' EXIT

# Lê uma tecla: up|down|space|enter|all|quit|key:<c>
tecla() {
  local k r
  IFS= read -rsn1 k || { echo quit; return; }
  case $k in
    $'\033')
      IFS= read -rsn2 -t 1 r || true
      case $r in '[A'|OA) echo up ;; '[B'|OB) echo down ;; *) echo quit ;; esac ;;
    '') echo enter ;;
    ' ') echo space ;;
    k|K) echo up ;;
    j|J) echo down ;;
    a|A) echo all ;;
    q|Q) echo quit ;;
    *) echo "key:$k" ;;
  esac
}

# Seleção múltipla dos apps; preenche SELECAO.
escolher_apps() {
  local n=${#APPS[@]} cur=0 i a p cont max todos linhas desenhado=0 aviso="" sel=() extra
  for ((i = 0; i < n; i++)); do sel[i]=0; done
  linhas=$((n + 4))
  cursor l
  while :; do
    if ((desenhado)); then printf '\033[%dA' "$linhas"; fi
    desenhado=1
    printf '\033[2K\033[1mQuais apps instalar?\033[0m \033[2m(↑/↓ move · espaço marca · a todos · enter confirma · q sai)\033[0m\n\033[2K\n'
    cont=0 max=0
    for ((i = 0; i < n; i++)); do
      a=${APPS[i]}
      extra=""
      if [[ -x $(bin_path "$a") ]]; then extra=" \033[2m(já instalado)\033[0m"; fi
      if ((sel[i])); then
        cont=$((cont + 1)); p=$(pico_dgb "$a"); if ((p > max)); then max=$p; fi
        mark='\033[32m◉\033[0m'
      else mark='○'; fi
      if ((i == cur)); then
        printf '\033[2K \033[36m❯\033[0m %b \033[1;36m%-12s\033[0m %-7s \033[2m%s\033[0m%b\n' "$mark" "$a" "$(pico "$a")" "$(desc "$a")" "$extra"
      else
        printf '\033[2K   %b %-12s %-7s \033[2m%s\033[0m%b\n' "$mark" "$a" "$(pico "$a")" "$(desc "$a")" "$extra"
      fi
    done
    printf '\033[2K\n'
    if [[ -n $aviso ]]; then printf '\033[2K  \033[33m%s\033[0m\n' "$aviso"
    elif ((cont)); then printf '\033[2K  %d selecionado(s) · disco livre necessário: ~%s (o maior, compilado por vez)\n' "$cont" "$(fmt_gb "$max")"
    else printf '\033[2K  \033[2mnenhum selecionado · a coluna mostra o pico de disco durante a compilação\033[0m\n'; fi
    aviso=""
    case $(tecla) in
      up) cur=$(((cur - 1 + n) % n)) ;;
      down) cur=$(((cur + 1) % n)) ;;
      space) sel[cur]=$((1 - sel[cur])) ;;
      all)
        todos=1
        for ((i = 0; i < n; i++)); do if ((!sel[i])); then todos=0; fi; done
        for ((i = 0; i < n; i++)); do sel[i]=$((1 - todos)); done ;;
      enter) if ((cont)); then break; else aviso="marque ao menos um app com espaço"; fi ;;
      quit) cursor h; echo; die "cancelado" ;;
    esac
  done
  cursor h
  SELECAO=()
  for ((i = 0; i < n; i++)); do if ((sel[i])); then SELECAO+=("${APPS[i]}"); fi; done
}

# confirmar "pergunta" ["rótulo sim" "rótulo não"]: sim/não com setas; retorna 0 para sim.
# Sem TUI, cai no [s/N] digitado.
confirmar() {
  local cur=0 i desenhado=0 resp opc
  opc=("${2:-Sim, instalar}" "${3:-Não, sair}")
  if ! tui_ok; then
    read -rp "$1 [s/N] " resp
    [[ $resp =~ ^[sSyY] ]]
    return
  fi
  cursor l
  while :; do
    if ((desenhado)); then printf '\033[3A'; fi
    desenhado=1
    printf '\033[2K\033[1m%s\033[0m \033[2m(↑/↓ e enter)\033[0m\n' "$1"
    for i in 0 1; do
      if ((i == cur)); then printf '\033[2K \033[36m❯ %s\033[0m\n' "${opc[i]}"
      else printf '\033[2K   %s\n' "${opc[i]}"; fi
    done
    case $(tecla) in
      up|down) cur=$((1 - cur)) ;;
      enter) break ;;
      key:s|key:S|key:y|key:Y) cur=0; break ;;
      key:n|key:N|quit) cur=1; break ;;
    esac
  done
  cursor h
  ((cur == 0))
}

bin_path() { echo "$ROOT/$1/target/release/$1-cli"; }
is_app()   { local a; for a in "${APPS[@]}"; do [[ $a == "$1" ]] && return 0; done; return 1; }

listar() {
  local a st
  for a in "${APPS[@]}"; do
    if [[ -x $(bin_path "$a") ]]; then st="compilado"
    elif [[ -d $ROOT/$a/.git ]]; then st="baixado (sem build)"
    else st="-"; fi
    printf '  %-12s pico ~%-7s %-22s %s\n' "$a" "$(pico "$a")" "$st" "$(desc "$a")"
  done
}

# ---------- argumentos ----------
SELECAO=() ATUALIZAR=0 MANTER=0 BUILD=1 SO_MCP=0 CHECAR=0 ASSUME_YES=0 MIGRAR=0
while (($#)); do
  case $1 in
    --apps) [[ $# -ge 2 ]] || die "--apps exige uma lista"; IFS=, read -ra SELECAO <<<"$2"; shift ;;
    --apps=*) IFS=, read -ra SELECAO <<<"${1#*=}" ;;
    --todos) SELECAO=("${APPS[@]}") ;;
    --listar) listar; exit 0 ;;
    --checar) CHECAR=1 ;;
    -y|--sim) ASSUME_YES=1 ;;
    --atualizar) ATUALIZAR=1 ;;
    --manter-build) MANTER=1 ;;
    --sem-build) BUILD=0 ;;
    --so-mcp) SO_MCP=1 ;;
    --migrar) MIGRAR=1 ;;
    -h|--ajuda|--help) uso; exit 0 ;;
    *) die "opção desconhecida: $1 (veja --ajuda)" ;;
  esac
  shift
done

# ---------- pré-requisitos ----------
# Para compilar os <app>-cli bastam git, compilador C, pkg-config (Linux) e Rust >= RUST_MIN
# (curl só para instalar o Rust). Nenhum -cli liga em bibliotecas gráficas/áudio do sistema.
export PATH="$HOME/.cargo/bin:$PATH"

gerenciador() {
  local pm
  for pm in apt-get dnf pacman zypper brew; do
    if command -v "$pm" >/dev/null; then echo "$pm"; return; fi
  done
}

# Pacote que fornece cada ferramenta, por gerenciador.
pacote() {
  case $1:$2 in
    *:git) echo git ;;
    *:curl) echo curl ;;
    apt-get:cc) echo build-essential ;;
    dnf:cc|zypper:cc) echo "gcc gcc-c++ make" ;;
    pacman:cc) echo base-devel ;;
    dnf:pkg-config) echo pkgconf-pkg-config ;;
    pacman:pkg-config) echo pkgconf ;;
    *:pkg-config) echo pkg-config ;;
  esac
}

rust_versao() { command -v rustc >/dev/null && rustc --version | awk '{print $2}'; }
# versao_ge A B: A >= B, comparando números separados por ponto.
versao_ge() {
  local IFS=. i a b
  read -ra a <<<"${1%%-*}"; read -ra b <<<"$2"
  for ((i = 0; i < ${#b[@]}; i++)); do
    ((${a[i]:-0} > ${b[i]})) && return 0
    ((${a[i]:-0} < ${b[i]})) && return 1
  done
  return 0
}
rust_ok() { local v; v=$(rust_versao) && versao_ge "$v" "$RUST_MIN"; }

# No macOS, "cc" e "git" existem como atalhos mesmo sem as Command Line Tools: checar de verdade.
tem() {
  if [[ $SO == mac && ($1 == cc || $1 == git) ]]; then xcode-select -p >/dev/null 2>&1 && command -v "$1" >/dev/null
  else command -v "$1" >/dev/null; fi
}

# Preenche FALTA (ferramentas de sistema) e RUST_ACAO (""|instalar|atualizar) e imprime o relatório.
avaliar_prereqs() {
  local t precisa
  precisa=(git)
  if ((BUILD)); then
    precisa+=(cc)
    if [[ $SO == linux ]]; then precisa+=(pkg-config); fi
  fi
  FALTA=() RUST_ACAO=""
  if ((BUILD)) && ! rust_ok; then
    if command -v rustup >/dev/null; then RUST_ACAO=atualizar; else RUST_ACAO=instalar; precisa+=(curl); fi
  fi
  log "Pré-requisitos"
  for t in "${precisa[@]}"; do
    if tem "$t"; then ok "$t"; else warn "$t: ausente"; FALTA+=("$t"); fi
  done
  ((BUILD)) || return 0
  case $RUST_ACAO in
    "") ok "Rust $(rust_versao) (mínimo $RUST_MIN)" ;;
    atualizar) warn "Rust $(rust_versao): antigo (mínimo $RUST_MIN) — será atualizado com rustup" ;;
    instalar)
      if command -v rustc >/dev/null; then warn "Rust $(rust_versao): antigo e sem rustup — será instalado via rustup"
      else warn "Rust: ausente — será instalado via rustup"; fi ;;
  esac
}

instalar_prereqs() {
  if ((${#FALTA[@]} == 0)) && [[ -z $RUST_ACAO ]]; then return 0; fi
  local pm="" pkgs=() t p sudo="" xcode=0 resp

  if ((${#FALTA[@]})); then
    if [[ $SO == mac ]]; then
      # git e cc vêm das Command Line Tools; o resto, do Homebrew.
      for t in "${FALTA[@]}"; do
        case $t in git|cc) xcode=1 ;; *) pkgs+=("$t") ;; esac
      done
      if ((${#pkgs[@]})); then
        command -v brew >/dev/null || die "instale ${pkgs[*]} (ou o Homebrew: https://brew.sh) e rode de novo"
        pm=brew
      fi
    else
      pm=$(gerenciador)
      [[ -n $pm && $pm != brew ]] || die "instale manualmente: ${FALTA[*]} (gerenciador de pacotes não reconhecido)"
      for t in "${FALTA[@]}"; do read -ra p <<<"$(pacote "$pm" "$t")"; pkgs+=("${p[@]}"); done
      if ((EUID != 0)); then
        command -v sudo >/dev/null || die "sudo não encontrado; instale como root: ${pkgs[*]}"
        sudo=sudo
      fi
    fi
  fi

  echo
  echo "O setup vai instalar:"
  if ((xcode)); then echo "  - Xcode Command Line Tools (git e compilador C) — abre uma janela do macOS"; fi
  if ((${#pkgs[@]})); then echo "  - pacotes via $pm${sudo:+ (pede a senha do sudo)}: ${pkgs[*]}"; fi
  if [[ $RUST_ACAO == instalar ]]; then echo "  - Rust (stable) via rustup em ~/.cargo e ~/.rustup, sem sudo"; fi
  if [[ $RUST_ACAO == atualizar ]]; then echo "  - atualização do Rust: rustup update stable && rustup default stable"; fi
  if ((!ASSUME_YES)); then
    [[ -t 0 ]] || die "pré-requisitos ausentes; rode de novo com --sim para instalá-los ou instale-os manualmente"
    echo
    confirmar "Instalar agora?" || die "cancelado; instale os itens acima e rode de novo"
  fi

  if ((xcode)); then
    xcode-select --install || true
    die "conclua a instalação das Command Line Tools na janela do macOS e rode ./setup.sh de novo"
  fi
  if ((${#pkgs[@]})); then
    log "Instalando ${pkgs[*]}"
    case $pm in
      apt-get) $sudo apt-get update && $sudo apt-get install -y "${pkgs[@]}" ;;
      dnf)     $sudo dnf install -y "${pkgs[@]}" ;;
      pacman)  $sudo pacman -S --needed --noconfirm "${pkgs[@]}" ;;
      zypper)  $sudo zypper install -y "${pkgs[@]}" ;;
      brew)    brew install "${pkgs[@]}" ;;
    esac
  fi
  case $RUST_ACAO in
    instalar)
      log "Instalando Rust via rustup"
      # SKIP_PATH_CHECK: convive com um Rust antigo da distro; ~/.cargo/bin vem antes no PATH.
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
        RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y --profile minimal --default-toolchain stable ;;
    atualizar)
      log "Atualizando Rust"
      rustup update stable && rustup default stable ;;
  esac

  hash -r
  avaliar_prereqs
  if ((${#FALTA[@]})) || [[ -n $RUST_ACAO ]]; then die "ainda faltam pré-requisitos (veja acima)"; fi
}

if ((CHECAR)); then
  avaliar_prereqs
  if ((${#FALTA[@]})) || [[ -n $RUST_ACAO ]]; then
    echo; warn "rode ./setup.sh para instalar o que falta"; exit 1
  fi
  exit 0
fi

# ---------- menu interativo ----------
if ((!SO_MCP && !MIGRAR)) && ((${#SELECAO[@]} == 0)); then
  [[ -t 0 ]] || die "nenhum app escolhido; use --apps a,b ou --todos"
fi
if ((!SO_MCP && !MIGRAR)) && ((${#SELECAO[@]} == 0)) && tui_ok; then
  escolher_apps
  echo
fi
if ((!SO_MCP && !MIGRAR)) && ((${#SELECAO[@]} == 0)); then
  # Forma digitada: terminal sem suporte ao menu com setas.
  echo "Apps disponíveis (pico = disco usado durante a compilação):"
  i=1
  for a in "${APPS[@]}"; do
    printf '  %d) %-12s pico ~%-7s %s\n' "$i" "$a" "$(pico "$a")" "$(desc "$a")"; i=$((i + 1))
  done
  read -rp "Números separados por espaço (ou 'todos'): " resp
  if [[ $resp == todos ]]; then SELECAO=("${APPS[@]}")
  else
    for n in $resp; do
      [[ $n =~ ^[1-9]$ ]] || die "opção inválida: $n"
      SELECAO+=("${APPS[$((n - 1))]}")
    done
  fi
  ((${#SELECAO[@]})) || die "nenhum app escolhido"
fi
for a in "${SELECAO[@]}"; do is_app "$a" || die "app desconhecido: $a"; done

# ---------- baixar / compilar ----------
instalar() {
  local a=$1 dir="$ROOT/$1" bin tmp
  bin=$(bin_path "$1")
  if [[ -d $dir/.git ]]; then
    if ((ATUALIZAR)); then log "$a: atualizando"; git -C "$dir" pull --ff-only
    else ok "$a: já baixado"; fi
  elif [[ -e $dir ]]; then
    die "$dir existe mas não é um repositório git; mova-o e rode de novo"
  else
    log "$a: clonando $REPO_BASE/$a"
    git clone --depth 1 "$REPO_BASE/$a" "$dir"
  fi

  ((BUILD)) || return 0
  log "$a: compilando $a-cli (pode levar vários minutos)"
  (cd "$dir" && cargo build --release -p "$a-cli")
  [[ -x $bin ]] || die "$a: build terminou mas $bin não existe"

  if ((!MANTER)); then
    log "$a: limpando cache de compilação (mantendo só o binário)"
    tmp=$(mktemp -d)
    mv "$bin" "$tmp/"
    (cd "$dir" && cargo clean -q)
    mkdir -p "$(dirname "$bin")"
    mv "$tmp/$a-cli" "$bin"; rmdir "$tmp"
  fi
  ok "$a: pronto ($(du -sh "$bin" | cut -f1))"
}

# ---------- .mcp.json ----------
# Raízes de confinamento: leitura e escrita só em projetos/ (cada projeto tem brutos, referencias, materiais e
# finalizados dentro dela; a separação entre subpastas é regra do CLAUDE.md). Mantenha igual ao setup.ps1.
roots_args() {
  printf ',\n        "--automation-read-root", "%s/projetos",\n        "--automation-write-root", "%s/projetos"' "$ROOT" "$ROOT"
}
mcp_args() {
  case $1 in
    vectorcraft) printf '"mcp", "--headless"'; roots_args ;;
    filmcraft)   printf '"mcp"' ;;
    lightcraft)  printf '"mcp", "--library", "%s/projetos/_bibliotecas/lightcraft"' "$ROOT" ;;
    pdfcraft)    printf '"mcp", "--compact", "--root", "%s/projetos"' "$ROOT" ;;
    *)           printf '"mcp"'; roots_args ;;
  esac
}
gerar_mcp() {
  local a sep="" out="$ROOT/.mcp.json" n=0
  {
    echo '{'
    echo '  "mcpServers": {'
    for a in "${APPS[@]}"; do
      [[ -x $(bin_path "$a") ]] || continue
      printf '%s    "%s": {\n      "command": "%s",\n      "args": [\n        %s\n      ]\n    }' \
        "$sep" "$a" "$(bin_path "$a")" "$(mcp_args "$a")"
      sep=$',\n'; n=$((n + 1))
    done
    printf '\n  }\n}\n'
  } >"$out"
  ok ".mcp.json gerado com $n servidor(es)"
}

preparar_pastas() {
  mkdir -p "$ROOT/projetos/_bibliotecas/lightcraft"
}

# ---------- migração da estrutura antiga ----------
# Antes: referencias/<p>/, materiais/<p>/, projetos/<p>/<EXT>/ e finalizados/<p>/ na raiz.
# Agora: projetos/<p>/{brutos/<EXT>,referencias,materiais,finalizados}/ (ver ESTRUTURA.md).
eh_subpasta() { case $1 in brutos|referencias|materiais|finalizados) return 0 ;; esac; return 1; }

# Imprime as mudanças pendentes, uma por linha: "origem<TAB>destino".
planejar_migracao() {
  local r d p s
  for r in referencias materiais finalizados; do
    for d in "$ROOT/$r"/*/; do
      [[ -d $d ]] || continue
      p=$(basename "$d")
      printf '%s\t%s\n' "$ROOT/$r/$p" "$ROOT/projetos/$p/$r"
    done
  done
  for d in "$ROOT"/projetos/*/; do
    [[ -d $d ]] || continue
    p=$(basename "$d")
    if [[ $p == _* ]]; then continue; fi
    for s in "$d"*/; do
      [[ -d $s ]] || continue
      s=$(basename "$s")
      if eh_subpasta "$s"; then continue; fi
      printf '%s\t%s\n' "$ROOT/projetos/$p/$s" "$ROOT/projetos/$p/brutos/$s"
    done
  done
}

# Corrige caminhos absolutos da estrutura antiga em arquivos de texto (ex.: .ecproj, scripts). Só mexe em
# brutos/ e finalizados/: referencias/ e materiais/ são do usuário. Imprime os arquivos alterados.
corrigir_caminhos() {
  local arqs=() f d
  for d in "$ROOT"/projetos/*/brutos "$ROOT"/projetos/*/finalizados; do
    [[ -d $d ]] || continue
    while IFS= read -r -d '' f; do arqs+=("$f"); done < <(
      grep -rlIF --null -e "$ROOT/referencias/" -e "$ROOT/materiais/" -e "$ROOT/finalizados/" -e "$ROOT/projetos/" "$d" 2>/dev/null || true)
  done
  ((${#arqs[@]})) || return 0
  ROOT_MIG="$ROOT" perl -e '
    my $r = quotemeta $ENV{ROOT_MIG};
    my $seg = q{[^/"\x27\n]+};
    for my $f (@ARGV) {
      open(my $h, "<", $f) or next; local $/; my $s = <$h>; close $h; my $o = $s;
      # projetos/<p>/<EXT>/ -> projetos/<p>/brutos/<EXT>/  (não mexe em _bibliotecas nem nas 4 subpastas)
      $s =~ s{($r/projetos/(?!_)$seg/)(?!(?:brutos|referencias|materiais|finalizados)/)(?=$seg/)}{${1}brutos/}g;
      # referencias|materiais|finalizados/<p>/ -> projetos/<p>/<subpasta>/
      $s =~ s{$r/(referencias|materiais|finalizados)/($seg)/}{$ENV{ROOT_MIG}/projetos/$2/$1/}g;
      next if $s eq $o;
      open($h, ">", $f) or die "$f: $!"; print $h $s; close $h; print "$f\n";
    }' "${arqs[@]}"
}

migrar() {
  local plano origem destino movidos=0 pulados=0 r d p alterados
  plano=$(planejar_migracao)
  if [[ -z $plano ]]; then
    if ((MIGRAR)); then ok "nada a migrar: já está na estrutura projetos/<projeto>/{brutos,referencias,materiais,finalizados}"; fi
    return 0
  fi
  echo
  warn "Estrutura antiga de pastas encontrada (ver ESTRUTURA.md). Vai mover:"
  while IFS=$'\t' read -r origem destino; do
    printf '      %s  →  %s\n' "${origem#"$ROOT"/}" "${destino#"$ROOT"/}"
  done <<<"$plano"
  echo "    e corrigir os caminhos absolutos gravados nos brutos de texto."
  echo "    Feche antes as sessões do Claude Code que estiverem usando esta pasta."
  if ((!ASSUME_YES)); then
    if [[ ! -t 0 ]]; then warn "migração pulada (sem terminal interativo): rode ./setup.sh --migrar --sim"; return 0; fi
    echo
    if ! confirmar "Migrar agora?" "Sim, migrar" "Não, depois"; then
      warn "migração pulada: rode ./setup.sh --migrar quando quiser"; return 0
    fi
  fi

  while IFS=$'\t' read -r origem destino; do
    if [[ -d $destino && -n $(ls -A "$destino") ]]; then
      warn "pulado (o destino já tem arquivos): ${origem#"$ROOT"/}"; pulados=$((pulados + 1)); continue
    fi
    if [[ -d $destino ]]; then rmdir "$destino"; fi
    mkdir -p "$(dirname "$destino")"
    mv "$origem" "$destino"; movidos=$((movidos + 1))
  done <<<"$plano"
  ok "$movidos pasta(s) movida(s)"

  for d in "$ROOT"/projetos/*/; do
    p=$(basename "$d")
    if [[ -d $d && $p != _* ]]; then mkdir -p "$d"{brutos,referencias,materiais,finalizados}; fi
  done
  alterados=$(corrigir_caminhos)
  if [[ -n $alterados ]]; then
    ok "caminhos corrigidos em $(printf '%s\n' "$alterados" | wc -l | tr -d ' ') arquivo(s):"
    printf '%s\n' "$alterados" | sed "s#^$ROOT/#      #"
  fi

  for r in referencias materiais finalizados; do
    [[ -d $ROOT/$r ]] || continue
    rm -f "$ROOT/$r/.gitkeep"
    if ! rmdir "$ROOT/$r" 2>/dev/null; then warn "$r/ não ficou vazia (veja os avisos acima); confira à mão"; fi
  done
  if ((pulados)); then warn "$pulados pasta(s) puladas: junte-as à mão e rode ./setup.sh --migrar de novo"; fi
}

# ---------- main ----------
if ((MIGRAR)); then
  migrar
  exit 0
fi
migrar
if ((!SO_MCP)); then
  if [[ $SO == outro ]]; then warn "sistema não testado ($(uname -s)); seguindo mesmo assim"; fi
  avaliar_prereqs
  instalar_prereqs
  log "Apps escolhidos: ${SELECAO[*]}"
  for a in "${SELECAO[@]}"; do instalar "$a"; done
fi
preparar_pastas
gerar_mcp
echo
listar
echo
log "Pronto. Abra (ou reabra) o Claude Code nesta pasta e aprove os servidores MCP do projeto."
