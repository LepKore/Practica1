# entendedor-de-contexto

Skill de agentes que responde a dos preguntas distintas sobre un repositorio:

- **¿Qué sabemos ya de este proyecto?** → modo **A · Entender**
- **¿Qué de eso ya no es cierto?** → modo **B · Mejorar**

La distinción importa porque son dos huecos que se confunden: *no lo sé* (falta cargar
contexto en la sesión) y *lo sé, pero está mal* (el doc dice `npm run start` y el repo ya no
tiene ese script). Se mantiene como una sola skill, y no como dos, porque la fase de
descubrimiento es idéntica en ambos y es la que cuesta: preguntar antes de descubrir
desperdicia el trabajo, descubrir dos veces se nota.

El flujo completo, los criterios de clasificación y las reglas de precedencia están en
[`SKILL.md`](SKILL.md). Este archivo es solo instalación, requisitos y ejemplo.

## Cuándo se activa

El `description` del frontmatter dispara con frases como *"entiende este proyecto"*,
*"onboarding"*, *"¿qué convenciones usa aquí?"*, *"la documentación está vieja"*, *"sincroniza
Notion / ClickUp / GitHub con el repo"*, o cuando el usuario menciona `AGENTS.md`, `CLAUDE.md`,
`README` o `.cursorrules` — incluso si nunca dice la palabra "documentación".

## Requisitos

| Requisito | Versión | Notas |
|---|---|---|
| Python | 3.9 o superior | Sin dependencias externas: solo biblioteca estándar. |
| git | opcional | Sin git **no falla**: devuelve `ultimo_commit: null` y sigue. |
| Bash o PowerShell | opcional | Solo para `evals/demo.sh` / `evals/demo.ps1`, no para la skill. |

Verificado con Python 3.14.4 y git 2.54.0 en Windows. El `3.9+` no es arbitrario: el script usa
`list[Path]` en las anotaciones de tipo, que sin `from __future__ import annotations` no
funciona en 3.8.

## Instalación

1. Copia la carpeta completa a `<proyecto>/.agents/skills/entendedor-de-contexto/`.

2. Si tu agente descubre las skills en `.opencode/skills/`, crea un enlace para no duplicar
   el contenido:

   ```powershell
   New-Item -ItemType Junction -Path .opencode\skills\entendedor-de-contexto `
            -Target .agents\skills\entendedor-de-contexto
   ```

   En Linux/macOS: `ln -s ../../.agents/skills/entendedor-de-contexto .opencode/skills/`.

   El enlace es opcional. Si tu agente ya lee `.agents/skills/`, no lo hagas.

3. Reinicia el agente. La skill aparece en la lista de disponibles junto a su `name`.

> Si la copias a un proyecto que usa `skills-lock.json`, revisa si ese archivo es la fuente de
> verdad de las skills instaladas: entonces el paso 1 debe ser a través de su gestor, no a mano.

## Ejemplo de entrada y salida

La fase de descubrimiento es mecánica y este es el comando que la ejecuta:

```bash
python scripts/inventario.py --root evals/fixtures/stale-agents-md --json
```

Salida real (verificada):

```json
{
  "raiz": ".../evals/fixtures/stale-agents-md",
  "es_repo_git": true,
  "total": 3,
  "archivos": [
    {
      "ruta": "AGENTS.md",
      "bytes": 46,
      "sha256": "adb7bd60a8524a0884a22fcfd2b6dd7ac9bdd6cf518526b1c5ba64a2366cd3e0",
      "ultimo_commit": "2026-09-25T20:39:47-04:00",
      "tipo_sospechado": "convenciones"
    },
    {
      "ruta": "package.json",
      "bytes": 105,
      "sha256": "41bdc0112b11d7f2bc354a76ed65299f2204bc2670577270c950d29516459064",
      "ultimo_commit": "2026-09-25T20:39:47-04:00",
      "tipo_sospechado": null
    },
    {
      "ruta": "README.md",
      "bytes": 28,
      "sha256": "66b10591207d55233cc9ae71965cccaff088e0103e882febf54c5372c02a6300",
      "ultimo_commit": "2026-09-25T20:39:47-04:00",
      "tipo_sospechado": "onboarding"
    }
  ]
}
```

**Qué observar:**

- `tipo_sospechado` es una *hipótesis por ruta y nombre*, no una verdad. `package.json` sale
  `null` a propósito: el script no adivina el contenido, eso lo hace quien lo invoque leyéndolo.
- Los `sha256` son lo que hace idempotente la reejecución: permiten comparar contra
  `.contexto/estado.json` y reportar **solo el delta**, sin reanalizar todo.
- Esto **no** encuentra el hallazgo interesante de este fixture. `AGENTS.md` promete
  `npm run start`, y el manifiesto dice `"start": "node server.js"`, pero `server.js` no existe
  en el repo. Eso exige cruzar dos archivos, y es trabajo de la fase 4, no del inventario.
- `ultimo_commit` refleja el commit del *repositorio que contiene* el fixture, no del fixture
  como repo propio: los fixtures ya no llevan su `.git` para poder versionarse como archivos
  normales.

Un flag que importa en la práctica:

```bash
python scripts/inventario.py --root . --json --incluir-ignorados
```

Sin él, el script respeta `.gitignore`, y un repo que ignora `*.md` esconde su propia
documentación: el informe concluye que no existe. Con él, esos archivos entran marcados con
`ignorado_por_git: true`. La diferencia entre "no hay documentación de esto" y "no lo vi".

## Demostración

```powershell
powershell -ExecutionPolicy Bypass -File .\evals\demo.ps1   # Windows
bash ./evals/demo.sh                                       # Linux/macOS
```

15 aserciones, salida PASS/FAIL y código de salida ≠ 0 si algo falla. No necesita agentes ni
Task tool: es determinista, así que se puede ejecutar en vivo. Cubre el inventario sobre los
3 fixtures, los 4 hechos que el inventario no ve pero la skill sí, el modo degradado sin git y
una regresión del flag `--incluir-ignorados`.

> **Verificación:** `demo.ps1` se ejecutó y pasó 15/15, y se comprobó que devuelve código de
> salida 1 al fallar una aserción. `demo.sh` es su equivalente línea por línea y **no se pudo
> ejecutar**: el entorno de desarrollo no tiene bash. Si vas a presentarlo en Linux, pruébalo
> una vez antes.

Lo anterior es la parte automatizable y reproducible. La comparación **con skill vs. sin skill**
que sí se corrió (3 evals × 2 configuraciones) no es un script: requiere lanzar un agente por
celda y calificar su informe, así que se hizo a mano. El registro está en
[`evals/notas-iteracion-1.md`](evals/notas-iteracion-1.md), con los prompts y expectations en
[`evals/evals.json`](evals/evals.json). El artefacto crudo de esa corrida no se versiona: se
regenera, y versionarlo daría la falsa impresión de que es reproducible con un comando.

Y una advertencia sobre esas notas, porque es el tipo de error que se repite en un benchmark:
el titular "+74%" mezcla capacidad con formato y engaña. Lo que sostiene la skill es la cubeta
de seguridad (0/4 runs sin skill declararon no haber escrito nada) y la de capacidad (+40% en
hechos reales del repo). El 100% en la cubeta de proceso es artefacto de medición.

## Estructura

| Ruta | Qué es |
|---|---|
| `SKILL.md` | El flujo completo. Esto es lo que lee el agente. |
| `scripts/inventario.py` | La parte mecánica: encontrar, medir, fechar, hashear. |
| `references/` | Criterios y reglas, cargados bajo demanda. |
| `assets/plantillas/` | Formato de los archivos de salida. |
| `evals/` | Fixtures, evals con sus expectations, demo y notas del benchmark. |
