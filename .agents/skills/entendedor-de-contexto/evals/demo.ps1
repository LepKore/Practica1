# Demo de la skill entendedor-de-contexto.
#
# Qué demuestra: la parte determinista del flujo (Fase 1, descubrimiento) y los hechos
# del repo que un agente sin la skill no encuentra. Es reproducible, sin agentes ni
# Task tool, para poder ejecutarla en vivo durante la presentacion.
#
# Uso:  powershell -ExecutionPolicy Bypass -File .\evals\demo.ps1
# Sale con 0 si todas las aserciones pasan, con 1 si alguna falla.

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$SkillDir   = Split-Path -Parent $PSScriptRoot
$Inventario = Join-Path $SkillDir 'scripts\inventario.py'
$Fixtures   = Join-Path $PSScriptRoot 'fixtures'

$script:Pasadas = 0
$script:Fallidas = 0

function Write-Titulo([string]$Texto) {
    Write-Host ''
    Write-Host "=== $Texto ===" -ForegroundColor Cyan
}

function Afirmar([string]$Descripcion, [bool]$Condicion, [string]$Detalle = '') {
    if ($Condicion) {
        $script:Pasadas++
        Write-Host "  [PASS] $Descripcion" -ForegroundColor Green
    } else {
        $script:Fallidas++
        Write-Host "  [FAIL] $Descripcion" -ForegroundColor Red
        if ($Detalle) { Write-Host "         $Detalle" -ForegroundColor Red }
    }
}

function Get-Inventario([string]$Fixture) {
    $raiz = Join-Path $Fixtures $Fixture
    $json = & python $Inventario --root $raiz --json
    if ($LASTEXITCODE -ne 0) { throw "inventario.py fallo en $Fixture" }
    return ($json -join "`n") | ConvertFrom-Json
}

# --------------------------------------------------------------------------------------
Write-Titulo '0. Requisitos'
# --------------------------------------------------------------------------------------
$py = & python -V 2>&1
Afirmar "python disponible ($py)" ($LASTEXITCODE -eq 0) 'instala Python 3.9+'
Afirmar 'inventario.py existe' (Test-Path $Inventario) "se esperaba en $Inventario"

# --------------------------------------------------------------------------------------
Write-Titulo '1. Inventario: 3 fixtures, salida en JSON'
# --------------------------------------------------------------------------------------
$stale = Get-Inventario 'stale-agents-md'
$novctx = Get-Inventario 'no-context'
$cvdoc  = Get-Inventario 'code-vs-doc'

foreach ($par in @(@{n='stale-agents-md'; d=$stale}, @{n='no-context'; d=$novctx}, @{n='code-vs-doc'; d=$cvdoc})) {
    Write-Host "  $($par.n): $($par.d.total) archivos, es_repo_git=$($par.d.es_repo_git)"
    foreach ($a in $par.d.archivos) {
        $fecha = if ($a.ultimo_commit) { $a.ultimo_commit } else { 'sin git' }
        $tipo  = if ($a.tipo_sospechado) { $a.tipo_sospechado } else { '?' }
        Write-Host ("     {0,-14} {1,5} B  {2}  {3}" -f $a.ruta, $a.bytes, $fecha, $tipo)
    }
}

Afirmar 'stale-agents-md: AGENTS.md clasificado como convenciones' (
    ($stale.archivos | Where-Object { $_.ruta -eq 'AGENTS.md' }).tipo_sospechado -eq 'convenciones')
Afirmar 'stale-agents-md: README.md clasificado como onboarding' (
    ($stale.archivos | Where-Object { $_.ruta -eq 'README.md' }).tipo_sospechado -eq 'onboarding')
Afirmar 'el inventario trae sha256 por archivo' (
    $stale.archivos[0].sha256 -match '^[0-9a-f]{64}$')

# --------------------------------------------------------------------------------------
Write-Titulo '2. Hechos que el inventario NO ve y la skill si (hallazgos del modo B)'
# --------------------------------------------------------------------------------------

# Hecho 1: el script `start` invoca un archivo que no existe. Ningun inventario lo detecta
# porque los dos archivos (package.json y la ausencia de server.js) estan en archivos distintos.
$pkgStale = Get-Content (Join-Path $Fixtures 'stale-agents-md\package.json') -Raw | ConvertFrom-Json
$serverJs = Test-Path (Join-Path $Fixtures "stale-agents-md\$($pkgStale.scripts.start -replace '^node\s+','')")
Afirmar 'stale-agents-md: `start` invoca un archivo inexistente (DESACTUALIZADO)' `
    (-not $serverJs) "start = $($pkgStale.scripts.start); server.js presente = $serverJs"

# Hecho 2: `vite` no esta declarado, asi que `npm run dev` no resuelve en instalacion limpia.
$declaraVite = $null -ne $pkgStale.dependencies -and $null -ne $pkgStale.dependencies.vite
Afirmar 'stale-agents-md: `vite` no esta en dependencies (FALTANTE)' `
    (-not $declaraVite) 'el doc lo lista como comando pero el manifiesto no lo instala'

# Hecho 3: el proyecto sin documentacion no tiene NINGUN archivo de contexto.
$conContexto = @($novctx.archivos | Where-Object { $null -ne $_.tipo_sospechado })
Afirmar 'no-context: cero archivos de contexto (modo degradado)' `
    ($conContexto.Count -eq 0) "encontrados: $($conContexto.ruta -join ', ')"
Afirmar 'no-context: se ofrece generar el contexto base, no se aborta' `
    ($novctx.total -ge 1) 'el script sigue y devuelve inventario vacio de contexto'

# Hecho 4: drift real entre codigo y documento. Gana el codigo (references/precedencia.md).
$readmeCvdoc = Get-Content (Join-Path $Fixtures 'code-vs-doc\README.md') -Raw
$srcCvdoc    = Get-Content (Join-Path $Fixtures 'code-vs-doc\src') -Raw
Afirmar 'code-vs-doc: README dice /api/v2 y el codigo /api/v1 (CONTRADICTORIO)' `
    (($readmeCvdoc -match '/api/v2') -and ($srcCvdoc -match '/api/v1')) `
    "README: $($readmeCvdoc.Trim()); src: $($srcCvdoc.Trim() -replace "`r?`n", ' ')"
Afirmar 'code-vs-doc: el inventario NO lista `src` (sin extension), por eso hace falta leerlo' `
    ($null -eq ($cvdoc.archivos | Where-Object { $_.ruta -eq 'src' }))

# --------------------------------------------------------------------------------------
Write-Titulo '3. Modo degradado sin git'
# --------------------------------------------------------------------------------------
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('entendedor-demo-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    Set-Content -Path (Join-Path $tmp 'README.md') -Value "puerto 3000" -Encoding UTF8
    $json = & python $Inventario --root $tmp --json
    $sinGit = ($json -join "`n") | ConvertFrom-Json
    Afirmar 'sin repo git: no falla, devuelve ultimo_commit null' `
        ($sinGit.es_repo_git -eq $false -and $null -eq $sinGit.archivos[0].ultimo_commit)
} finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force
}

# --------------------------------------------------------------------------------------
Write-Titulo '4. Regresion: --incluir-ignorados'
# --------------------------------------------------------------------------------------
# El caso que motiva el flag: un repo que ignora *.md esconde su propia documentacion.
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('entendedor-demo-git-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    & git init -q $tmp
    Set-Content -Path (Join-Path $tmp '.gitignore') -Value "*.md" -Encoding UTF8
    Set-Content -Path (Join-Path $tmp 'README.md')      -Value "# Guia del equipo" -Encoding UTF8
    Set-Content -Path (Join-Path $tmp 'CONVENTIONS.md') -Value "sin punto y coma"  -Encoding UTF8
    Set-Content -Path (Join-Path $tmp 'package.json')   -Value '{"name":"demo"}'   -Encoding UTF8

    $json = & python $Inventario --root $tmp --json
    $sinFlag = ($json -join "`n") | ConvertFrom-Json
    $json = & python $Inventario --root $tmp --json --incluir-ignorados
    $conFlag = ($json -join "`n") | ConvertFrom-Json

    Afirmar 'repo con *.md ignorado: el inventario por defecto NO ve la documentacion' `
        ($null -eq ($sinFlag.archivos | Where-Object { $_.ruta -eq 'README.md' })) `
        "sin flag: $($sinFlag.total) archivos"
    $rutasConFlag = @($conFlag.archivos | ForEach-Object { $_.ruta })
    Afirmar '--incluir-ignorados si ve README.md y CONVENTIONS.md' `
        (($rutasConFlag -contains 'README.md') -and ($rutasConFlag -contains 'CONVENTIONS.md')) `
        "con flag: $($rutasConFlag -join ', ')"
    Afirmar 'y los marca con ignorado_por_git' `
        ($null -ne ($conFlag.archivos | Where-Object { $_.ignorado_por_git -eq $true } | Select-Object -First 1))
} finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force
}

# --------------------------------------------------------------------------------------
Write-Host ''
$color = if ($script:Fallidas -eq 0) { 'Green' } else { 'Red' }
Write-Host "=== Resultado: $script:Pasadas pasaron, $script:Fallidas fallaron ===" -ForegroundColor $color

$codigo = 0
if ($script:Fallidas -gt 0) { $codigo = 1 }
exit $codigo
