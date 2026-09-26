#!/usr/bin/env bash
# Demo de la skill entendedor-de-contexto (equivalente a demo.ps1).
#
# Qué demuestra: la parte determinista del flujo (Fase 1, descubrimiento) y los hechos
# del repo que un agente sin la skill no encuentra. Es reproducible, sin agentes ni
# Task tool, para poder ejecutarla en vivo durante la presentacion.
#
# Uso:  bash ./evals/demo.sh
# Sale con 0 si todas las aserciones pasan, con 1 si alguna falla.
#
# Nota de verificacion: este script es el equivalente linea por linea de demo.ps1, que si
# se ejecuto y se verifico en Windows (PowerShell 5.1). El .sh se reviso por lectura: el
# entorno de desarrollo no tiene bash instalado.

set -u

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INVENTARIO="$SKILL_DIR/scripts/inventario.py"
FIXTURES="$(cd "$(dirname "$0")/fixtures" && pwd)"

PY=python3
command -v python3 >/dev/null 2>&1 || PY=python

PASADAS=0
FALLIDAS=0

titulo() { printf '\n=== %s ===\n' "$1"; }

afirmar() {
  # afirmar <descripcion> <0|1_exito> [detalle]
  if [ "$2" = "1" ]; then
    PASADAS=$((PASADAS + 1))
    printf '  [PASS] %s\n' "$1"
  else
    FALLIDAS=$((FALLIDAS + 1))
    printf '  [FAIL] %s\n' "$1"
    [ -n "${3:-}" ] && printf '         %s\n' "$3"
  fi
  return 0
}

inventario() { "$PY" "$INVENTARIO" --root "$1" --json; }

# --------------------------------------------------------------------------------------
titulo '0. Requisitos'
# --------------------------------------------------------------------------------------
VERSION=$("$PY" -V 2>&1)
afirmar "python disponible ($VERSION)" "$([ $? -eq 0 ] && echo 1 || echo 0)"
afirmar 'inventario.py existe' "$([ -f "$INVENTARIO" ] && echo 1 || echo 0)" "se esperaba en $INVENTARIO"

# --------------------------------------------------------------------------------------
titulo '1. Inventario: 3 fixtures, salida en JSON'
# --------------------------------------------------------------------------------------
for f in stale-agents-md no-context code-vs-doc; do
  json=$(inventario "$FIXTURES/$f") || { echo "inventario.py fallo en $f"; exit 1; }
  total=$(printf '%s' "$json" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["total"])')
  echo "  $f: $total archivos"
  printf '%s' "$json" | "$PY" -c '
import json, sys
for a in json.load(sys.stdin)["archivos"]:
    print("     %-14s %5d B  %s  %s" % (a["ruta"], a["bytes"],
          a["ultimo_commit"] or "sin git", a["tipo_sospechado"] or "?"))'
done

tipo_de() { inventario "$FIXTURES/$1" | "$PY" -c 'import json,sys; d=json.load(sys.stdin); print(next((a["tipo_sospechado"] or "") for a in d["archivos"] if a["ruta"]==sys.argv[1]), "")' "$2"; }
sha_de()  { inventario "$FIXTURES/$1" | "$PY" -c 'import json,sys; d=json.load(sys.stdin); print(next((a["sha256"] for a in d["archivos"]), ""))'; }
total_de(){ inventario "$FIXTURES/$1" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["total"])'; }
con_contexto() { inventario "$FIXTURES/$1" | "$PY" -c 'import json,sys; print(sum(1 for a in json.load(sys.stdin)["archivos"] if a["tipo_sospechado"]))'; }

afirmar 'stale-agents-md: AGENTS.md clasificado como convenciones' \
  "$([ "$(tipo_de stale-agents-md AGENTS.md)" = 'convenciones' ] && echo 1 || echo 0)" \
  "tipo=$(tipo_de stale-agents-md AGENTS.md)"
afirmar 'stale-agents-md: README.md clasificado como onboarding' \
  "$([ "$(tipo_de stale-agents-md README.md)" = 'onboarding' ] && echo 1 || echo 0)"
afirmar 'el inventario trae sha256 por archivo' \
  "$(printf '%s' "$(sha_de stale-agents-md)" | grep -Eq '^[0-9a-f]{64}$' && echo 1 || echo 0)"

# --------------------------------------------------------------------------------------
titulo '2. Hechos que el inventario NO ve y la skill si (hallazgos del modo B)'
# --------------------------------------------------------------------------------------
# Hecho 1: el script `start` invoca un archivo que no existe.
START_CMD=$("$PY" -c 'import json,sys; print(json.load(open(sys.argv[1]))["scripts"]["start"])' "$FIXTURES/stale-agents-md/package.json")
START_FILE=${START_CMD#node }
afirmar 'stale-agents-md: `start` invoca un archivo inexistente (DESACTUALIZADO)' \
  "$([ ! -f "$FIXTURES/stale-agents-md/$START_FILE" ] && echo 1 || echo 0)" \
  "start = $START_CMD; $START_FILE presente = $([ -f "$FIXTURES/stale-agents-md/$START_FILE" ] && echo si || echo no)"

# Hecho 2: `vite` no esta declarado, asi que `npm run dev` no resuelve en instalacion limpia.
DECLARA_VITE=$("$PY" -c 'import json,sys; d=json.load(open(sys.argv[1])); print("si" if "vite" in d.get("dependencies",{}) else "no")' "$FIXTURES/stale-agents-md/package.json")
afirmar 'stale-agents-md: `vite` no esta en dependencies (FALTANTE)' \
  "$([ "$DECLARA_VITE" = 'no' ] && echo 1 || echo 0)" \
  'el doc lo lista como comando pero el manifiesto no lo instala'

# Hecho 3: el proyecto sin documentacion no tiene NINGUN archivo de contexto.
N_CTX=$(con_contexto no-context)
afirmar 'no-context: cero archivos de contexto (modo degradado)' \
  "$([ "$N_CTX" = '0' ] && echo 1 || echo 0)" "encontrados: $N_CTX"
afirmar 'no-context: se ofrece generar el contexto base, no se aborta' \
  "$([ "$(total_de no-context)" -ge 1 ] && echo 1 || echo 0)" 'el script sigue y devuelve inventario vacio de contexto'

# Hecho 4: drift real entre codigo y documento. Gana el codigo (references/precedencia.md).
afirmar 'code-vs-doc: README dice /api/v2 y el codigo /api/v1 (CONTRADICTORIO)' \
  "$(grep -q '/api/v2' "$FIXTURES/code-vs-doc/README.md" && grep -q '/api/v1' "$FIXTURES/code-vs-doc/src" && echo 1 || echo 0)" \
  "README=$(tr '\n' ' ' < "$FIXTURES/code-vs-doc/README.md")"
afirmar 'code-vs-doc: el inventario NO lista `src` (sin extension), por eso hace falta leerlo' \
  "$(inventario "$FIXTURES/code-vs-doc" | grep -q '"ruta": "src"' && echo 0 || echo 1)"

# --------------------------------------------------------------------------------------
titulo '3. Modo degradado sin git'
# --------------------------------------------------------------------------------------
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
printf 'puerto 3000\n' > "$TMP/README.md"
"$PY" "$INVENTARIO" --root "$TMP" --json > "$TMP/salida.json"
SIN_GIT=$("$PY" -c 'import json,sys; d=json.load(open(sys.argv[1])); print("1" if d["es_repo_git"] is False and d["archivos"][0]["ultimo_commit"] is None else "0")' "$TMP/salida.json")
afirmar 'sin repo git: no falla, devuelve ultimo_commit null' "$SIN_GIT"

# --------------------------------------------------------------------------------------
titulo '4. Regresion: --incluir-ignorados'
# --------------------------------------------------------------------------------------
# El caso que motiva el flag: un repo que ignora *.md esconde su propia documentacion.
REPO=$(mktemp -d)
git init -q "$REPO"
printf '*.md\n' > "$REPO/.gitignore"
printf '# Guia del equipo\n' > "$REPO/README.md"
printf 'sin punto y coma\n' > "$REPO/CONVENTIONS.md"
printf '{"name":"demo"}' > "$REPO/package.json"

SIN_FLAG=$("$PY" "$INVENTARIO" --root "$REPO" --json)
CON_FLAG=$("$PY" "$INVENTARIO" --root "$REPO" --json --incluir-ignorados)

VEE_SIN_FLAG=$(printf '%s' "$SIN_FLAG" | grep -c '"ruta": "README.md"' || true)
VEE_CON_FLAG=$(printf '%s' "$CON_FLAG" | grep -c '"ruta": "README.md"\|"ruta": "CONVENTIONS.md"' || true)
MARCA=$(printf '%s' "$CON_FLAG" | grep -c '"ignorado_por_git": true' || true)

afirmar 'repo con *.md ignorado: el inventario por defecto NO ve la documentacion' \
  "$([ "$VEE_SIN_FLAG" = '0' ] && echo 1 || echo 0)"
afirmar '--incluir-ignorados si ve README.md y CONVENTIONS.md' \
  "$([ "$VEE_CON_FLAG" = '2' ] && echo 1 || echo 0)" "encontradas: $VEE_CON_FLAG de 2"
afirmar 'y los marca con ignorado_por_git' \
  "$([ "$MARCA" -ge 1 ] && echo 1 || echo 0)"
rm -rf "$REPO"

# --------------------------------------------------------------------------------------
printf '\n=== Resultado: %s pasaron, %s fallaron ===\n' "$PASADAS" "$FALLIDAS"
[ "$FALLIDAS" -gt 0 ] && exit 1
exit 0
