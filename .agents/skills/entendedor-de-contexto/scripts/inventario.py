#!/usr/bin/env python3
"""Inventario de contexto de un repositorio en una sola pasada.

Para cada archivo que parece documentación de proyecto devuelve: ruta, bytes, sha256,
fecha del último commit y el tipo de contexto que parece ser.

El script NO decide qué es contexto ni lo interpreta: eso lo hace quien lo invoque,
leyendo los archivos. Aquí solo está la parte mecánica (encontrar, medir, fechar), que
de otro modo son decenas de llamadas a git por ejecución.

Uso:
    python inventario.py --root . --json
    python inventario.py --root . --muestra 15
    python inventario.py --root . --json > inventario.json

No requiere dependencias externas. Si el directorio no es un repo git, no falla:
devuelve "ultimo_commit": null y sigue con el resto del inventario.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

# Directorios que nunca contienen contexto de proyecto y solo ralentizan el escaneo.
IGNORAR_DIRS = {
    ".git", "node_modules", "dist", "build", "out", ".output", ".next", ".nuxt",
    "vendor", "target", "coverage", "__pycache__", ".venv", "venv", "env",
    ".cache", ".svelte-kit", ".turbo", ".parcel-cache", ".pytest_cache", ".mypy_cache",
    "bower_components", "Pods", "DerivedData", ".gradle", ".terraform",
}

# Rutas que el equipo declara explícitamente como contexto.
RUTAS_CONOCIDAS = {
    "AGENTS.md": "convenciones",
    "CLAUDE.md": "convenciones",
    "CLAUDE.local.md": "convenciones",
    "GEMINI.md": "convenciones",
    ".cursorrules": "convenciones",
    ".github/copilot-instructions.md": "convenciones",
    "README.md": "onboarding",
    "CONTRIBUTING.md": "onboarding",
    "ARCHITECTURE.md": "mapa",
    "CODEOWNERS": "organizacion",
    "ROADMAP.md": "decisiones",
    "CHANGELOG.md": "decisiones",
    "skills-lock.json": "configuracion",
    "opencode.json": "configuracion",
    "opencode.jsonc": "configuracion",
    ".mcp.json": "configuracion",
}

# Carpetas que son contexto en bloque aunque su contenido varíe.
DIRECTORIOS_CONOCIDOS = {
    ".context": "contexto",
    ".contexto": "contexto",
    "context": "contexto",
    "docs": "mapa",
    "doc": "mapa",
    ".cursor/rules": "convenciones",
    "docs/adr": "decisiones",
    "docs/decisions": "decisiones",
    "docs/architecture": "mapa",
    "docs/runbooks": "comandos",
    ".github/workflows": "comandos",
    ".codex": "configuracion",
    ".claude": "configuracion",
    ".codex/skills": "configuracion",
    ".claude/skills": "configuracion",
}

# Nombres que delatan contexto aunque estén enterrados en cualquier carpeta.
PATRONES_NOMBRE = {
    "CONVENTIONS": "convenciones", "GUIDELINES": "convenciones", "STYLEGUIDE": "convenciones",
    "STYLE_GUIDE": "convenciones", "CODING_STANDARDS": "convenciones", "HANDSHAKING": "convenciones",
    "ONBOARDING": "onboarding", "GETTING_STARTED": "onboarding", "SETUP": "comandos",
    "INSTALL": "comandos", "RUNBOOK": "comandos", "PLAYBOOK": "comandos", "CHEATSHEET": "comandos",
    "ARCHITECTURE": "mapa", "MAPA": "mapa", "STRUCTURE": "mapa", "SYSTEM_OVERVIEW": "mapa",
    "DESIGN": "mapa", "DECISIONS": "decisiones", "ADR": "decisiones", "RFC": "decisiones",
    "HANDOFF": "decisiones", "NOTES": "decisiones", "GLOSSARY": "glosario",
}

# Solothese extensiones, para no arrastrar binarios ni assets al informe.
EXTENSIONES = {".md", ".mdx", ".rst", ".txt", ".adoc", ".json", ".yaml", ".yml", ".toml", ".cfg", ".ini"}

LIMITE_COMMITS = 1000  # corta el log para no comerse un monorepo con historia infinita.


def es_ignorable(nombre: str) -> bool:
    return nombre in IGNORAR_DIRS or nombre.endswith((".dll", ".so", ".dylib"))


def sha256_de(ruta: Path) -> str:
    h = hashlib.sha256()
    with ruta.open("rb") as fh:
        for trozo in iter(lambda: fh.read(65536), b""):
            h.update(trozo)
    return h.hexdigest()


def tipo_sospechado(rel: str, nombre: str) -> str:
    """Mejor tipo adivinado a partir de la ruta, sin leer el contenido."""
    posix = rel.replace("\\", "/")
    ruta = posix.lower()

    for clave, tipo in RUTAS_CONOCIDAS.items():
        if ruta == clave.lower() or ruta.endswith("/" + clave.lower()):
            return tipo

    for clave, tipo in DIRECTORIOS_CONOCIDOS.items():
        prefijo = clave.lower()
        if ruta == prefijo or ruta.startswith(prefijo + "/") or f"/{prefijo}/" in f"/{ruta}":
            return tipo

    mayus = nombre.upper().replace("-", "_")
    for clave, tipo in PATRONES_NOMBRE.items():
        if clave in mayus:
            return tipo

    return None


def recorrer_arbol(raiz: Path, respeta_gitignore: bool) -> list[Path]:
    """Recorre el árbol y devuelve los archivos que podrían ser contexto."""
    ignorados: set[str] = set()
    if respeta_gitignore:
        try:
            salida = subprocess.run(
                ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
                cwd=raiz, capture_output=True, text=True, timeout=30,
            )
            if salida.returncode == 0:
                ignorados = {l.strip().replace("\\", "/") for l in salida.stdout.splitlines() if l.strip()}
        except (OSError, subprocess.SubprocessError):
            ignorados = set()

    candidatos: list[Path] = []
    for ruta in raiz.rglob("*"):
        try:
            rel = ruta.relative_to(raiz)
        except ValueError:
            continue
        if any(es_ignorable(p) for p in rel.parts):
            continue
        if not ruta.is_file() or ruta.is_symlink():
            continue

        posix = rel.as_posix()
        # Si git está disponible, su lista de archivos ya viene libre de ignorados.
        if respeta_gitignore and ignorados and posix not in ignorados:
            continue

        nombre = ruta.name
        extension = ruta.suffix.lower()
        if extension not in EXTENSIONES and nombre not in {
            "AGENTS", "CLAUDE", "GEMINI", "Makefile", "Dockerfile", ".cursorrules"
        }:
            continue
        candidatos.append(ruta)

    return sorted(candidatos)


def fechas_de_commit(raiz: Path, rutas: list[Path]) -> dict[str, str]:
    """Fecha ISO del último commit por archivo, en una sola pasada por el log."""
    fechas: dict[str, str] = {}
    if not rutas:
        return fechas

    posix = [r.relative_to(raiz).as_posix() for r in rutas]
    try:
        salida = subprocess.run(
            ["git", "log", f"-n{LIMITE_COMMITS}", "--format=%x01%cI", "--name-only", "--", *posix],
            cwd=raiz, capture_output=True, text=True, timeout=60, errors="replace",
        )
    except (OSError, subprocess.SubprocessError):
        return fechas

    if salida.returncode != 0:
        return fechas

    fecha_actual = None
    for linea in salida.stdout.splitlines():
        if linea.startswith("\x01"):
            fecha_actual = linea[1:].strip()
            continue
        nombre = linea.strip()
        if nombre and fecha_actual and nombre not in fechas:
            fechas[nombre] = fecha_actual

    # Archivos sin commit en la ventana reciente: consulta dirigida, son pocos.
    faltantes = [p for p in posix if p not in fechas]
    for nombre in faltantes:
        try:
            uno = subprocess.run(
                ["git", "log", "-1", "--format=%cI", "--", nombre],
                cwd=raiz, capture_output=True, text=True, timeout=20, errors="replace",
            )
        except (OSError, subprocess.SubprocessError):
            continue
        if uno.returncode == 0 and uno.stdout.strip():
            fechas[nombre] = uno.stdout.strip()

    return fechas


def es_repo_git(raiz: Path) -> bool:
    try:
        return subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=raiz, capture_output=True, text=True, timeout=15,
        ).returncode == 0
    except (OSError, subprocess.SubprocessError):
        return False


def construir_inventario(raiz: Path, muestra: int) -> list[dict]:
    en_git = es_repo_git(raiz)
    candidatos = recorrer_arbol(raiz, respeta_gitignore=en_git)
    fechas = fechas_de_commit(raiz, candidatos) if en_git else {}

    inventario = []
    for ruta in candidatos:
        rel = ruta.relative_to(raiz).as_posix()
        tipo = tipo_sospechado(rel, ruta.name)
        entrada = {
            "ruta": rel,
            "bytes": ruta.stat().st_size,
            "sha256": sha256_de(ruta),
            "ultimo_commit": fechas.get(rel),
            "tipo_sospechado": tipo,
        }
        if muestra and not tipo:
            # utf-8-sig descarta el BOM: si no, el primer título sale con un carácter basura.
            lineas = ruta.read_text(encoding="utf-8-sig", errors="replace").splitlines()[:muestra]
            entrada["primera_linea"] = "\n".join(l.strip() for l in lineas if l.strip())
        inventario.append(entrada)

    return inventario


def main() -> int:
    ap = argparse.ArgumentParser(description="Inventario de contexto de un repositorio.")
    ap.add_argument("--root", default=".", help="Raíz del repositorio (por defecto, el directorio actual)")
    ap.add_argument("--json", action="store_true", help="Salida en JSON")
    ap.add_argument("--muestra", type=int, default=0, metavar="N",
                    help="Incluye las primeras N líneas de los archivos sin tipo reconocido, "
                         "para decidir si son contexto (0 = no incluir)")
    args = ap.parse_args()

    # La consola de Windows suele ser cp1252 y el contenido de los repos sí trae acentos,
    # emojis o alfabetos no latinos. Sin esto, imprimir un nombre con tilde aborta el script.
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    raiz = Path(args.root).resolve()
    if not raiz.is_dir():
        print(f"error: {raiz} no es un directorio", file=sys.stderr)
        return 1

    inventario = construir_inventario(raiz, args.muestra)
    en_git = es_repo_git(raiz)

    if args.json:
        print(json.dumps({
            "raiz": str(raiz),
            "es_repo_git": en_git,
            "total": len(inventario),
            "archivos": inventario,
        }, indent=2, ensure_ascii=False))
        return 0

    if not inventario:
        print("Sin archivos de contexto encontrados. ¿Es el directorio correcto?")
        return 0

    ancho = max(len(a["ruta"]) for a in inventario)
    for a in inventario:
        fecha = (a["ultimo_commit"] or "sin git")[:10]
        tipo = a["tipo_sospechado"] or "?"
        kb = a["bytes"] / 1024
        print(f"{a['ruta']:<{ancho}}  {kb:>7.1f}KB  {fecha:<10}  {tipo}")
        if "primera_linea" in a:
            for linea in a["primera_linea"].splitlines():
                print(f"{'':<{ancho}}  | {linea}")
    print(f"\n{len(inventario)} archivos. " + ("" if en_git else "(no es repo git: sin fechas)"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
