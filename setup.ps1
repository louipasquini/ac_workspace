<#
.SYNOPSIS
  setup.ps1 — Windows. Avalia/instala pré-requisitos, baixa, compila e registra no .mcp.json os Crafts
  escolhidos. Equivalente ao setup.sh (Linux/macOS).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\setup.ps1
  powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Apps photocraft,vectorcraft -Sim
#>
[CmdletBinding()]
param(
  [string[]]$Apps,       # apps a instalar (ex.: -Apps photocraft,vectorcraft)
  [switch]$Todos,        # instala os 9
  [switch]$Listar,       # mostra os apps e o que está instalado
  [switch]$Checar,       # só avalia os pré-requisitos
  [switch]$Sim,          # instala pré-requisitos ausentes sem perguntar
  [switch]$Atualizar,    # git pull nos apps já baixados
  [switch]$ManterBuild,  # não apaga target/
  [switch]$SemBuild,     # só clona
  [switch]$SoMcp,        # só regenera o .mcp.json
  [switch]$Migrar,       # só converte projetos da estrutura antiga de pastas (ver ESTRUTURA.md)
  [switch]$Ajuda
)
$ErrorActionPreference = 'Stop'

$Root     = $PSScriptRoot
$RepoBase = 'https://github.com/storytold'
$RustMin  = [version]'1.95'
$AllApps  = 'photocraft','vectorcraft','filmcraft','lightcraft','pdfcraft','figcraft','effectcraft','soundcraft','designcraft'
$Desc = @{
  photocraft  = 'Photoshop      - imagens raster'
  vectorcraft = 'Illustrator    - vetor, logos'
  filmcraft   = 'Premiere       - edição de vídeo'
  lightcraft  = 'Lightroom      - fotos/RAW'
  pdfcraft    = 'Acrobat        - PDF'
  figcraft    = 'Figma          - interfaces'
  effectcraft = 'After Effects  - motion design'
  soundcraft  = 'Áudio          - trilha, mixagem'
  designcraft = 'InDesign       - diagramação'
}
# Pico de disco durante a compilação (aprox.). Com a limpeza padrão sobra só o binário.
$Pico = @{
  photocraft = '3 GB'; vectorcraft = '3 GB'; filmcraft = '14 GB'; lightcraft = '6 GB'; pdfcraft = '3 GB'
  figcraft = '16 GB'; effectcraft = '2,5 GB'; soundcraft = '2 GB'; designcraft = '3 GB'
}
$PicoGb = @{
  photocraft = 3; vectorcraft = 3; filmcraft = 14; lightcraft = 6; pdfcraft = 3
  figcraft = 16; effectcraft = 2.5; soundcraft = 2; designcraft = 3
}

function Log($m)  { Write-Host "==> $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host " ok $m" -ForegroundColor Green }
function Warn($m) { Write-Host " !! $m" -ForegroundColor Yellow }
function Die($m)  { Write-Host "erro: $m" -ForegroundColor Red; exit 1 }
# Comandos nativos não disparam exceção: conferir o código de saída.
function Run([string]$what) { if ($LASTEXITCODE -ne 0) { Die "$what falhou (código $LASTEXITCODE)" } }

function BinPath($a) { Join-Path $Root "$a\target\release\$a-cli.exe" }

# ---------- menus com setas (↑/↓, espaço, Enter), no estilo do `specify init` ----------
# Sem console interativo (entrada/saída redirecionadas) os chamadores caem na forma digitada.
# Só ASCII nos marcadores: a fonte padrão do console do Windows PowerShell 5.1 não tem ◉/❯.
function Can-Tui {
  try { return (-not [Console]::IsInputRedirected) -and (-not [Console]::IsOutputRedirected) } catch { return $false }
}

# Escreve uma linha do menu ocupando a largura toda (apaga o que havia antes).
function Menu-Line([string]$text, $color) {
  $w = [Math]::Max([Console]::WindowWidth - 1, 20)
  if ($text.Length -gt $w) { $text = $text.Substring(0, $w) }
  $text = $text.PadRight($w)
  if ($color) { Write-Host $text -ForegroundColor $color } else { Write-Host $text }
}

# Reserva $n linhas e devolve a linha do topo (o buffer pode rolar ao reservar).
function Menu-Top([int]$n) {
  for ($i = 0; $i -lt $n; $i++) { Write-Host '' }
  return [Console]::CursorTop - $n
}

function Read-MenuKey {
  $k = [Console]::ReadKey($true)
  switch ($k.Key) {
    'UpArrow'   { return 'up' }
    'K'         { return 'up' }
    'DownArrow' { return 'down' }
    'J'         { return 'down' }
    'Spacebar'  { return 'space' }
    'Enter'     { return 'enter' }
    'A'         { return 'all' }
    'Q'         { return 'quit' }
    'Escape'    { return 'quit' }
    'S'         { return 'yes' }
    'Y'         { return 'yes' }
    'N'         { return 'no' }
  }
  return 'other'
}

# Seleção múltipla dos apps; devolve os escolhidos.
function Select-Apps {
  $n = $AllApps.Count
  $sel = New-Object bool[] $n
  $cur = 0; $aviso = ''
  $top = Menu-Top ($n + 4)
  [Console]::CursorVisible = $false
  try {
    while ($true) {
      [Console]::SetCursorPosition(0, $top)
      Menu-Line 'Quais apps instalar?  (setas movem - Espaço marca - A todos - Enter confirma - Q sai)' White
      Menu-Line ''
      $cont = 0; $max = 0
      for ($i = 0; $i -lt $n; $i++) {
        $a = $AllApps[$i]
        if ($sel[$i]) { $cont++; $max = [Math]::Max($max, $PicoGb[$a]) }
        $mark = if ($sel[$i]) { '[x]' } else { '[ ]' }
        $ptr = if ($i -eq $cur) { '>' } else { ' ' }
        $extra = if (Test-Path (BinPath $a)) { ' (já instalado)' } else { '' }
        $color = if ($i -eq $cur) { 'Cyan' } elseif ($sel[$i]) { 'Green' } else { $null }
        Menu-Line (' {0} {1} {2,-12} {3,-7} {4}{5}' -f $ptr, $mark, $a, $Pico[$a], $Desc[$a], $extra) $color
      }
      Menu-Line ''
      if ($aviso) { Menu-Line "  $aviso" Yellow }
      elseif ($cont) { Menu-Line ('  {0} selecionado(s) - disco livre necessário: ~{1} GB (o maior, compilado por vez)' -f $cont, $max) }
      else { Menu-Line '  nenhum selecionado - a coluna mostra o pico de disco durante a compilação' DarkGray }
      $aviso = ''
      switch (Read-MenuKey) {
        'up'    { $cur = ($cur - 1 + $n) % $n }
        'down'  { $cur = ($cur + 1) % $n }
        'space' { $sel[$cur] = -not $sel[$cur] }
        'all'   {
          $todos = -not ($sel -contains $false)
          for ($i = 0; $i -lt $n; $i++) { $sel[$i] = -not $todos }
        }
        'enter' {
          if ($cont) { return @(for ($i = 0; $i -lt $n; $i++) { if ($sel[$i]) { $AllApps[$i] } }) }
          $aviso = 'marque ao menos um app com Espaço'
        }
        'quit'  { [Console]::CursorVisible = $true; Write-Host ''; Die 'cancelado' }
      }
    }
  } finally { [Console]::CursorVisible = $true }
}

# Pergunta sim/não com setas; sem console interativo, cai no [s/N] digitado.
function Confirm-Menu([string]$q, [string]$sim = 'Sim, instalar', [string]$nao = 'Não, sair') {
  if (-not (Can-Tui)) { $r = Read-Host "$q [s/N]"; return ($r -match '^[sSyY]') }
  $opc = $sim, $nao
  $cur = 0
  $top = Menu-Top 3
  [Console]::CursorVisible = $false
  try {
    while ($true) {
      [Console]::SetCursorPosition(0, $top)
      Menu-Line "$q  (setas e Enter)" White
      for ($i = 0; $i -lt 2; $i++) {
        if ($i -eq $cur) { Menu-Line (' > ' + $opc[$i]) Cyan } else { Menu-Line ('   ' + $opc[$i]) }
      }
      switch (Read-MenuKey) {
        'up'    { $cur = 1 - $cur }
        'down'  { $cur = 1 - $cur }
        'enter' { return ($cur -eq 0) }
        'yes'   { return $true }
        'no'    { return $false }
        'quit'  { return $false }
      }
    }
  } finally { [Console]::CursorVisible = $true }
}

function Show-List {
  foreach ($a in $AllApps) {
    $st = if (Test-Path (BinPath $a)) { 'compilado' } elseif (Test-Path (Join-Path $Root "$a\.git")) { 'baixado (sem build)' } else { '-' }
    '  {0,-12} pico ~{1,-7} {2,-22} {3}' -f $a, $Pico[$a], $st, $Desc[$a]
  }
}

if ($Ajuda) { Get-Help $PSCommandPath -Detailed; exit 0 }
if ($Listar) { Show-List; exit 0 }

# ---------- pré-requisitos ----------
# Para compilar os <app>-cli no Windows bastam git, o compilador C/C++ do Visual Studio (MSVC) e Rust >= RustMin.
# O aws-lc-sys (PhotoCraft, PdfCraft, DesignCraft) pediria NASM; usamos os objetos pré-compilados dele.

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
              [Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
              (Join-Path $env:USERPROFILE '.cargo\bin')
}

function Has($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

$Arm = $env:PROCESSOR_ARCHITECTURE -eq 'ARM64'

function Has-Msvc {
  # ProgramFiles(x86) não existe no Windows 32 bits.
  $pf = if (${env:ProgramFiles(x86)}) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles }
  if (-not $pf) { return $false }
  $vswhere = Join-Path $pf 'Microsoft Visual Studio\Installer\vswhere.exe'
  if (-not (Test-Path $vswhere)) { return $false }
  $comp = if ($Arm) { 'Microsoft.VisualStudio.Component.VC.Tools.ARM64' } else { 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64' }
  $path = & $vswhere -latest -products * -requires $comp -property installationPath
  return [bool]$path
}

function Rust-Version {
  if (-not (Has rustc)) { return $null }
  $v = (& rustc --version) -split ' ' | Select-Object -Index 1
  return [version](($v -split '-')[0])
}

function Assess {
  $script:Missing = @()
  $script:RustAction = ''
  Log 'Pré-requisitos'
  if (Has git) { Ok 'git' } else { Warn 'git: ausente'; $script:Missing += 'git' }
  if ($SemBuild) { return }
  if (Has-Msvc) { Ok 'compilador C/C++ (Visual Studio Build Tools)' }
  else { Warn 'compilador C/C++ (Visual Studio Build Tools): ausente'; $script:Missing += 'msvc' }
  $v = Rust-Version
  if ($v -and $v -ge $RustMin) { Ok "Rust $v (mínimo $RustMin)" }
  elseif (Has rustup) { Warn "Rust ${v}: antigo (mínimo $RustMin) - será atualizado com rustup"; $script:RustAction = 'atualizar' }
  else { Warn 'Rust: ausente - será instalado via rustup'; $script:RustAction = 'instalar' }
}

function Winget-Install($id, [string[]]$extra) {
  Log "Instalando $id"
  & winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements @extra
  Run "winget install $id"
}

function Install-Prereqs {
  if ($script:Missing.Count -eq 0 -and -not $script:RustAction) { return }
  if ($script:Missing.Count -gt 0 -and -not (Has winget)) {
    Die ("instale manualmente e rode de novo:`n" +
         "  - Git: https://git-scm.com/download/win`n" +
         "  - Visual Studio Build Tools com 'Desenvolvimento para desktop com C++': https://visualstudio.microsoft.com/visual-cpp-build-tools/")
  }
  Write-Host ''
  Write-Host 'O setup vai instalar:'
  if ($script:Missing -contains 'git')  { Write-Host '  - Git (winget: Git.Git)' }
  if ($script:Missing -contains 'msvc') { Write-Host '  - Visual Studio 2022 Build Tools com C++ (winget; ~5 GB, pede permissão de administrador)' }
  if ($script:RustAction -eq 'instalar')  { Write-Host '  - Rust (stable) via rustup em %USERPROFILE%\.cargo e .rustup' }
  if ($script:RustAction -eq 'atualizar') { Write-Host '  - atualização do Rust: rustup update stable; rustup default stable' }
  if (-not $Sim) {
    Write-Host ''
    if (-not (Confirm-Menu 'Instalar agora?')) { Die 'cancelado; instale os itens acima e rode de novo' }
  }

  if ($script:Missing -contains 'git') { Winget-Install 'Git.Git' }
  if ($script:Missing -contains 'msvc') {
    Winget-Install 'Microsoft.VisualStudio.2022.BuildTools' @('--override',
      '--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
  }
  switch ($script:RustAction) {
    'instalar' {
      Log 'Instalando Rust via rustup'
      $init = Join-Path $env:TEMP 'rustup-init.exe'
      $url = if ($Arm) { 'https://win.rustup.rs/aarch64' } else { 'https://win.rustup.rs/x86_64' }
      Invoke-WebRequest -Uri $url -OutFile $init -UseBasicParsing
      & $init -y --profile minimal --default-toolchain stable; Run 'rustup-init'
      Remove-Item $init -ErrorAction SilentlyContinue
    }
    'atualizar' {
      Log 'Atualizando Rust'
      & rustup update stable; Run 'rustup update'
      & rustup default stable; Run 'rustup default'
    }
  }

  Refresh-Path
  Assess
  if ($script:Missing.Count -gt 0 -or $script:RustAction) {
    Die 'ainda faltam pré-requisitos (veja acima). Se acabou de instalar algo, abra um PowerShell novo e rode de novo.'
  }
}

$env:Path = (Join-Path $env:USERPROFILE '.cargo\bin') + ';' + $env:Path

if ($Checar) {
  Assess
  if ($script:Missing.Count -gt 0 -or $script:RustAction) { Write-Host ''; Warn 'rode .\setup.ps1 para instalar o que falta'; exit 1 }
  exit 0
}

# ---------- seleção ----------
$Selecao = @()
if ($Todos) { $Selecao = $AllApps }
elseif ($Apps) { $Selecao = @($Apps | ForEach-Object { $_ -split ',' } | Where-Object { $_ } | ForEach-Object { $_.Trim() }) }
elseif (-not $SoMcp -and -not $Migrar -and (Can-Tui)) { $Selecao = @(Select-Apps); Write-Host '' }
elseif (-not $SoMcp -and -not $Migrar) {
  # Forma digitada: entrada redirecionada, sem menu com setas.
  Write-Host 'Apps disponíveis (pico = disco usado durante a compilação):'
  for ($i = 0; $i -lt $AllApps.Count; $i++) {
    $a = $AllApps[$i]
    '  {0}) {1,-12} pico ~{2,-7} {3}' -f ($i + 1), $a, $Pico[$a], $Desc[$a]
  }
  $resp = Read-Host "Números separados por espaço (ou 'todos')"
  if ($resp -eq 'todos') { $Selecao = $AllApps }
  else {
    foreach ($n in ($resp -split '\s+' | Where-Object { $_ })) {
      if ($n -notmatch '^[1-9]$') { Die "opção inválida: $n" }
      $Selecao += $AllApps[[int]$n - 1]
    }
  }
  if ($Selecao.Count -eq 0) { Die 'nenhum app escolhido' }
}
foreach ($a in $Selecao) { if ($AllApps -notcontains $a) { Die "app desconhecido: $a" } }

# ---------- baixar / compilar ----------
function Install-App($a) {
  $dir = Join-Path $Root $a
  $bin = BinPath $a
  if (Test-Path (Join-Path $dir '.git')) {
    if ($Atualizar) { Log "${a}: atualizando"; & git -C $dir pull --ff-only; Run 'git pull' }
    else { Ok "${a}: já baixado" }
  } elseif (Test-Path $dir) {
    Die "$dir existe mas não é um repositório git; mova-o e rode de novo"
  } else {
    Log "${a}: clonando $RepoBase/$a"
    # core.longpaths: os repositórios têm caminhos que passam de 260 caracteres.
    & git -c core.longpaths=true clone --depth 1 "$RepoBase/$a" $dir; Run 'git clone'
    & git -C $dir config core.longpaths true
  }

  if ($SemBuild) { return }
  Log "${a}: compilando $a-cli (pode levar vários minutos)"
  Push-Location $dir
  try { & cargo build --release -p "$a-cli"; Run "cargo build ($a)" } finally { Pop-Location }
  if (-not (Test-Path $bin)) { Die "${a}: build terminou mas $bin não existe" }

  if (-not $ManterBuild) {
    Log "${a}: limpando cache de compilação (mantendo só o binário)"
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid())
    New-Item -ItemType Directory $tmp | Out-Null
    Move-Item $bin $tmp
    Push-Location $dir
    try { & cargo clean -q; Run "cargo clean ($a)" } finally { Pop-Location }
    New-Item -ItemType Directory -Force (Split-Path $bin) | Out-Null
    Move-Item (Join-Path $tmp "$a-cli.exe") $bin
    Remove-Item $tmp
  }
  Ok ("${a}: pronto ({0:N0} MB)" -f ((Get-Item $bin).Length / 1MB))
}

# ---------- .mcp.json ----------
# Mesmos argumentos do setup.sh. Raízes: leitura e escrita só em projetos\ (a separação entre brutos,
# referencias, materiais e finalizados de cada projeto é regra do CLAUDE.md).
function Mcp-Args($a) {
  $proj = Join-Path $Root 'projetos'
  $roots = @('--automation-read-root', $proj, '--automation-write-root', $proj)
  switch ($a) {
    'vectorcraft' { return @('mcp', '--headless') + $roots }
    'filmcraft'   { return @('mcp') }
    'lightcraft'  { return @('mcp', '--library', (Join-Path $Root 'projetos\_bibliotecas\lightcraft')) }
    'pdfcraft'    { return @('mcp', '--compact', '--root', $proj) }
    default       { return @('mcp') + $roots }
  }
}

function Write-Mcp {
  $servers = [ordered]@{}
  foreach ($a in $AllApps) {
    if (Test-Path (BinPath $a)) { $servers[$a] = [ordered]@{ command = (BinPath $a); args = @(Mcp-Args $a) } }
  }
  $json = [ordered]@{ mcpServers = $servers } | ConvertTo-Json -Depth 5
  # UTF-8 sem BOM (o Out-File do Windows PowerShell 5.1 gravaria com BOM).
  [IO.File]::WriteAllText((Join-Path $Root '.mcp.json'), $json + "`n", (New-Object Text.UTF8Encoding $false))
  Ok ".mcp.json gerado com $($servers.Count) servidor(es)"
}

# ---------- migração da estrutura antiga ----------
# Antes: referencias\<p>\, materiais\<p>\, projetos\<p>\<EXT>\ e finalizados\<p>\ na raiz.
# Agora: projetos\<p>\{brutos\<EXT>,referencias,materiais,finalizados}\ (ver ESTRUTURA.md). Mesma lógica do setup.sh.
$Subpastas = 'brutos', 'referencias', 'materiais', 'finalizados'

function Rel($p) { $p.Substring($Root.Length).TrimStart('\', '/') }

function Project-Dirs {
  $proj = Join-Path $Root 'projetos'
  if (-not (Test-Path -LiteralPath $proj)) { return @() }
  return @(Get-ChildItem -LiteralPath $proj -Directory | Where-Object { $_.Name -notlike '_*' })
}

function Plan-Migration {
  $plano = @()
  foreach ($r in 'referencias', 'materiais', 'finalizados') {
    $dir = Join-Path $Root $r
    if (-not (Test-Path -LiteralPath $dir)) { continue }
    foreach ($p in Get-ChildItem -LiteralPath $dir -Directory) {
      $plano += [pscustomobject]@{ De = $p.FullName; Para = (Join-Path (Join-Path (Join-Path $Root 'projetos') $p.Name) $r) }
    }
  }
  foreach ($p in Project-Dirs) {
    foreach ($s in Get-ChildItem -LiteralPath $p.FullName -Directory | Where-Object { $Subpastas -notcontains $_.Name }) {
      $plano += [pscustomobject]@{ De = $s.FullName; Para = (Join-Path (Join-Path $p.FullName 'brutos') $s.Name) }
    }
  }
  return $plano
}

# Corrige caminhos absolutos da estrutura antiga em arquivos de texto de brutos\ e finalizados\ (referencias\ e
# materiais\ são do usuário). Aceita \ ou / como separador, inclusive \\ escapado em JSON. Devolve os alterados.
function Fix-Paths {
  $sep = '[\\/]+'
  $parts = @($Root -split '[\\/]+' | Where-Object { $_ } | ForEach-Object { [regex]::Escape($_) })
  $rootPat = $(if ($Root -match '^[\\/]') { $sep } else { '' }) + ($parts -join $sep)
  $seg = '[^\\/"''\r\n]+'
  $opts = [Text.RegularExpressions.RegexOptions]::IgnoreCase
  # projetos\<p>\<EXT>\ -> projetos\<p>\brutos\<EXT>\  (não mexe em _bibliotecas nem nas 4 subpastas)
  $re1 = New-Object regex ("(?<pre>$rootPat(?<s>[\\/]+)projetos\k<s>(?!_)$seg\k<s>)" +
    "(?!(?:brutos|referencias|materiais|finalizados)\k<s>)(?=$seg\k<s>)"), $opts
  # referencias|materiais|finalizados\<p>\ -> projetos\<p>\<subpasta>\
  $re2 = New-Object regex ("(?<base>$rootPat)(?<s>[\\/]+)(?<sub>referencias|materiais|finalizados)\k<s>(?<p>$seg)\k<s>"), $opts
  $alterados = @()
  foreach ($p in Project-Dirs) {
    foreach ($sub in 'brutos', 'finalizados') {
      $d = Join-Path $p.FullName $sub
      if (-not (Test-Path -LiteralPath $d)) { continue }
      foreach ($f in Get-ChildItem -LiteralPath $d -Recurse -File | Where-Object { $_.Length -lt 50MB }) {
        $bytes = [IO.File]::ReadAllBytes($f.FullName)
        if ([Array]::IndexOf($bytes, [byte]0, 0, [Math]::Min($bytes.Length, 8000)) -ge 0) { continue }  # binário
        $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        $txt = [Text.Encoding]::UTF8.GetString($bytes)
        if ($bom) { $txt = $txt.Substring(1) }
        $novo = $re1.Replace($txt, '${pre}brutos${s}')
        $novo = $re2.Replace($novo, '${base}${s}projetos${s}${p}${s}${sub}${s}')
        if ($novo -ceq $txt) { continue }
        [IO.File]::WriteAllText($f.FullName, $novo, (New-Object Text.UTF8Encoding $bom))
        $alterados += $f.FullName
      }
    }
  }
  return $alterados
}

function Migrate {
  $plano = @(Plan-Migration)
  if ($plano.Count -eq 0) {
    if ($Migrar) { Ok 'nada a migrar: já está na estrutura projetos\<projeto>\{brutos,referencias,materiais,finalizados}' }
    return
  }
  Write-Host ''
  Warn 'Estrutura antiga de pastas encontrada (ver ESTRUTURA.md). Vai mover:'
  foreach ($m in $plano) { Write-Host ('      {0}  ->  {1}' -f (Rel $m.De), (Rel $m.Para)) }
  Write-Host '    e corrigir os caminhos absolutos gravados nos brutos de texto.'
  Write-Host '    Feche antes as sessões do Claude Code que estiverem usando esta pasta.'
  if (-not $Sim) {
    if ([Console]::IsInputRedirected) { Warn 'migração pulada (sem console interativo): rode .\setup.ps1 -Migrar -Sim'; return }
    Write-Host ''
    if (-not (Confirm-Menu 'Migrar agora?' 'Sim, migrar' 'Não, depois')) { Warn 'migração pulada: rode .\setup.ps1 -Migrar quando quiser'; return }
  }

  $movidos = 0; $pulados = 0
  foreach ($m in $plano) {
    if ((Test-Path -LiteralPath $m.Para) -and @(Get-ChildItem -LiteralPath $m.Para -Force).Count -gt 0) {
      Warn "pulado (o destino já tem arquivos): $(Rel $m.De)"; $pulados++; continue
    }
    if (Test-Path -LiteralPath $m.Para) { Remove-Item -LiteralPath $m.Para }
    New-Item -ItemType Directory -Force (Split-Path $m.Para) | Out-Null
    Move-Item -LiteralPath $m.De -Destination $m.Para
    $movidos++
  }
  Ok "$movidos pasta(s) movida(s)"

  foreach ($p in Project-Dirs) {
    foreach ($s in $Subpastas) { New-Item -ItemType Directory -Force (Join-Path $p.FullName $s) | Out-Null }
  }
  $alterados = @(Fix-Paths)
  if ($alterados.Count) {
    Ok "caminhos corrigidos em $($alterados.Count) arquivo(s):"
    foreach ($f in $alterados) { Write-Host "      $(Rel $f)" }
  }

  foreach ($r in 'referencias', 'materiais', 'finalizados') {
    $d = Join-Path $Root $r
    if (-not (Test-Path -LiteralPath $d)) { continue }
    Remove-Item -LiteralPath (Join-Path $d '.gitkeep') -Force -ErrorAction SilentlyContinue
    if (@(Get-ChildItem -LiteralPath $d -Force).Count -eq 0) { Remove-Item -LiteralPath $d }
    else { Warn "$r\ não ficou vazia (veja os avisos acima); confira à mão" }
  }
  if ($pulados) { Warn "$pulados pasta(s) puladas: junte-as à mão e rode .\setup.ps1 -Migrar de novo" }
}

# ---------- main ----------
if ($Migrar) { Migrate; exit 0 }
Migrate
if (-not $SoMcp) {
  Assess
  Install-Prereqs
  if (-not (Has nasm)) { $env:AWS_LC_SYS_PREBUILT_NASM = '1' }
  Log "Apps escolhidos: $($Selecao -join ' ')"
  foreach ($a in $Selecao) { Install-App $a }
}
New-Item -ItemType Directory -Force (Join-Path $Root 'projetos\_bibliotecas\lightcraft') | Out-Null
Write-Mcp
Write-Host ''
Show-List
Write-Host ''
Log 'Pronto. Abra (ou reabra) o Claude Code nesta pasta e aprove os servidores MCP do projeto.'
