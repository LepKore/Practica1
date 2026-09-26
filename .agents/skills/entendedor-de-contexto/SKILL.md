---
name: entendedor-de-contexto
description: >-
  Entender el contexto de un proyecto y encontrar/actualizar documentación que quedó
  desactualizada. Úsala SIEMPRE que el usuario diga "entiende este proyecto", "onboarding",
  "¿qué convenciones usa aquí?", mencione AGENTS.md / CLAUDE.md / GEMINI.md / README /
  .cursorrules / copilot-instructions / architecture docs / el mapa del sistema, diga que la
  documentación está vieja o desfasada, o pida sincronizar Notion, ClickUp o GitHub con el
  repo — aunque no use nunca la palabra "documentación". Cubre: project context,
  documentation drift, stale docs, onboarding docs, context sync, read the codebase before
  working, refresh project memory, qué sabemos ya de este repo.
---

# Entendedor de contexto

Una sesión nueva no sabe qué está ya escrito del proyecto, dónde, ni si eso sigue siendo
cierto. Son dos huecos distintos que se confunden:

1. **No lo sé** → necesito que alguien cargue el contexto en esta sesión.
2. **Lo sé, pero está mal** → la doc dice `npm run start` y el repo ya no tiene ese script.

Son **dos modos de una misma skill**, no dos skills, porque la Fase 1 —descubrir qué hay— es
idéntica en ambos y es la que cuesta. Preguntar antes de descubrir desperdicia el trabajo;
descubrir dos veces se nota.

## Mapa de la skill

Lee lo que necesites, cuando lo necesites:

| Si vas a… | Lee |
|---|---|
| Instalar la skill, ver requisitos o un ejemplo de salida | `README.md` |
| Reconocer qué archivos cuentan como contexto | `references/rutas-contexto-conocidas.md` |
| Decidir si algo es contexto | `references/que-es-contexto.md` |
| Clasificar un hallazgo | `references/criterio-inconsistencia.md` |
| Resolver una contradicción | `references/precedencia.md` |
| Escribir en Notion / ClickUp / GitHub | `references/plataformas/<plataforma>.md` |
| Producir un archivo de salida | `assets/plantillas/*.md` |
| Barrer el repo de una pasada | `scripts/inventario.py` |
| Demostrar que la skill funciona | `evals/demo.ps1` (o `demo.sh`) |

Las fases viven aquí. Las directrices y checklists viven en `references/` porque se cargan
bajo demanda: leerlas todas de entrada gasta contexto en material que quizá no aplica a este
proyecto.

## Fase 1 — Descubrir (común a los dos modos)

### 1.1 Archivos de contexto del proyecto

Dos técnicas combinadas. **Ninguna funciona sin la otra**: las rutas conocidas las usa el 90%
de los equipos, pero las heurísticas son las que encuentran el `SETUP.md` que nadie menciona y
que sí importa.

**a) Rutas conocidas.** La tabla completa está en
`references/rutas-contexto-conocidas.md`. Los mínimos: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`,
`.cursorrules`, `.github/copilot-instructions.md`, `.context/`, `.contexto/`, `context/`,
`docs/`, `.cursor/rules/`, `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`,
`CLAUDE.local.md`, `skills-lock.json`.

**b) Heurísticas sobre el árbol.** Busca nombres tipo `CONVENTIONS`, `GUIDELINES`, `STYLE`,
`ONBOARDING`, `ARCHITECTURE`, `MAPA`, `DECISIONS`, `ADR`, `RUNBOOK`, `PLAYBOOK`, `SETUP`,
`HANDOFF`. Y si un archivo no tiene nombre obvio, **lee su primer bloque** (unas 40 líneas):
si habla de cómo se ejecuta, cómo se estructura, qué reglas hay o por qué se decidió algo,
cuenta como contexto aunque se llame `notas.txt`.

Para cada archivo entrega: ruta, tamaño, fecha del último commit, y **qué tipo de contexto
parece ser** (convenciones / comandos / mapa / decisiones / onboarding). Ese último campo es
el que permite después decir "el README es un índice, no una fuente de reglas" en vez de tratar
todo lo que hay como igualmente autoritativo.

Mecánicamente esto es un solo comando:

```bash
python <skill-dir>/scripts/inventario.py --root . --json
```

(En algunos sistemas `python3`.) Devuelve ruta, bytes, sha256, último commit y tipo
sospechado por archivo, y no se rompe si el directorio no es un repo git — devuelve
`ultimo_commit: null` y sigue. Las heurísticas por nombre y por primer bloque las completas
tú sobre su salida: el script no adivina el contenido.

Un detalle que importa: **el `.gitignore` es del repositorio, no de la documentación.** Si el
proyecto ignora `*.md` (cosa habitual para no commitear notas personales), un `CONTRIBUTING.md`
o un `docs/arquitectura.md` no trackeado desaparecen del inventario y el informe va a concluir
que no existen. Cuando sospeches eso, añade `--incluir-ignorados`: esos archivos entran marcados
con `ignorado_por_git: true`, y tú decides si cuentan. Es la diferencia entre "no hay
documentación de esto" y "no lo vi".

Un caso esperado de ese flag: si `.opencode/skills/` es una unión (junction) a
`.agents/skills/`, los mismos archivos aparecen dos veces. Son el mismo archivo; cuéntalo una
sola vez.

Un detalle que importa en la práctica: los archivos de instrucciones se aplican **por
cercanía**. Si hay un `AGENTS.md` en `src/` y otro en la raíz, al trabajar en `src/` manda el de
`src/`, y el de la raíz cubre el resto. Reporta la jerarquía si existe; asumir "gana el de la
raíz" produce reglas equivocadas justo en la carpeta donde estás trabajando.

### 1.2 Herramientas de contexto

Revisa **ambas capas**, porque no son lo mismo:

**a) Configurado en el proyecto** — `.mcp.json`, `opencode.json`/`.jsonc`, `.codex/`,
`.claude/`, manifests de plugins, scripts de skills. Esto dice lo que está **configurado**.

**b) Conectadas de verdad** — lista los servidores y recursos realmente disponibles ahora
(`list_mcp_resources`, `list_mcp_resource_templates`). Esto dice lo que está **conectado**.

Compara ambas y reporta la diferencia. **Una herramienta configurada pero no conectada no es
una capacidad, es un hueco** — y presentarla como capacidad es peor que no mencionarla, porque
el usuario la intentará y perderá el tiempo.

Clasifica cada una según si sirve para **leer** contexto (Notion, Confluence, GitHub, Drive,
codebase-memory) o para **escribirlo** (cualquier cosa con `create`/`update`/`delete`). En
modo A solo las de lectura son útiles; las de escritura se listan como disponibles para modo B
y no se tocan.

### 1.3 Estado previo

Si existe `.contexto/estado.json`, léelo. Compara los `sha256` guardados contra los actuales y
reporta **solo el delta**: qué archivos cambiaron desde la última ejecución, qué se aplicó, qué
se rechazó. Reanalizar todo desde cero cuando ya tienes el informe es tirar trabajo ajeno.

Si no existe, es la primera ejecución: dilo. El resto del flujo es idéntico.

## Modo degradado — obligatorio

Las dos degradaciones que importan, y ninguna es motivo para abortar:

**Si no hay archivos de contexto.** No pares. Sigue con el repositorio: estructura de carpetas,
manifiesto (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`…), `git log` para entender
qué se está tocando, entry points. Marca `contexto-externo: ausente` en el informe y **ofrece**
generar el contexto base como parte del entregable. Un proyecto sin `AGENTS.md` no es un
proyecto sin contexto: el código, los scripts y la historia de commits *son* contexto, solo que
nadie lo escribió todavía.

**Si no hay herramientas de contexto conectadas.** Sigue solo con el repo y anota en el informe
qué herramienta habría servido y cómo habilitarla. "No hay Notion conectado" es un dato útil,
no un bloqueo.

En ningún caso inventes contexto que no encontraste. Si no lo sabes, dilo que no lo sabes: un
hueco reportado es accionable, una convención inventada es código roto con confianza.

## Fase 2 — Preguntar al usuario

Después de la Fase 1 y **solo entonces**, pregunta exactamente una vez:

> ¿Quieres que esta sesión comprenda el contexto del proyecto, o que encuentre y mejore el
> contexto?
>
> **A — Entender.** Solo lectura. No escribe en ninguna parte salvo `.contexto/brief.md` y
> `.contexto/estado.json`.
> **B — Mejorar.** Reviso lo encontrado, detecto lo que ya no es cierto y te propongo
> corregirlo, cambio por cambio.

Pregunta *después* de descubrir, no antes: con el inventario delante la pregunta deja de ser
abstracta. El usuario ve "encontré 3 archivos de contexto, uno contradice al código" y decide
con información, en vez de decidir a ciegas y que tú lo adivines después.

**Si no hay nadie a quien preguntar** (subagente, CI, uso no interactivo): entra en **Modo A** y
dilo explícitamente en el informe, con `modo_origen: "auto"`. El motivo de esta elección es que
A es el único modo que no puede romper nada, y bloquear te deja sin nada. Si
`.contexto/estado.json` ya registra un modo elegido antes, reutiliza ese modo y no vuelvas a
preguntar.

## Fase 3 — Modo A: ENTENDER

Solo lectura. Las únicas escrituras permitidas en todo el modo son `.contexto/brief.md` y
`.contexto/estado.json`. Si empiezas a editar código durante el reconocimiento, el usuario ya no
distingue "explorar" de "implementar" — y esa es la peor forma de perder el control de lo que
pasa en su repo.

**A) `.contexto/brief.md`** — con plantilla `assets/plantillas/brief.md`. Se commitea al repo: es
contexto del equipo, con el mismo criterio que un `AGENTS.md`. Secciones obligatorias: qué es
este proyecto, cómo se ejecuta, estructura y entry points, convenciones de código, comandos de
verificación, glosario de términos propios, trampas conocidas, y **qué NO está documentado**
(esta última es la que más valor tiene y la que más se omite).

**B) Reglas de sesión** — un bloque que devuelves **en el chat**, no un archivo. Esto es lo que
hace que la sesión "entienda":

- convenciones que deben respetarse al escribir código
- archivos que no deben tocarse
- comandos de verificación obligatorios antes de dar algo por hecho
- glosario

Plantilla: `assets/plantillas/reglas-sesion.md`. Que sea en el chat y no un archivo es
deliberado: el objetivo es que el contexto esté en la sesión actual, no archivado donde nadie
lo vuelva a leer.

**C) Resumen en el chat** — máximo 15 líneas. Si el proyecto ya estaba bien documentado y todo
está al día, dilo en una línea y no expandas. Forzar un informe largo sobre un proyecto sano
entrena al usuario a ignorar tus informes.

## Fase 4 — Modo B: MEJORAR

### 4.1 Detectar inconsistencias y huecos

Para cada hallazgo, clasifícalo en uno de estos cuatro tipos. La clasificación importa porque
cada tipo tiene una acción y una confianza distintas:

- **DESACTUALIZADO** — era cierto, el proyecto cambió. Comando renombrado, carpeta movida,
  puerto distinto.
- **CONTRADICTORIO** — dos fuentes se contradicen entre sí.
- **FALTANTE** — el proyecto tiene algo que nadie documentó.
- **SOBRANTE** — el contexto dice algo que ya no aplica.

Criterio detallado con ejemplos: `references/criterio-inconsistencia.md`.

### 4.2 Resolver con precedencia — no improvises

Lee `references/precedencia.md`. La regla base: **el código ejecutable gana**, porque es lo único
que no puede mentir. Un documento puede llevar meses mintiendo sin que nadie se entere; el
código roto se nota el mismo día.

- Código vs documento del repo → se corrige el documento.
- Código vs plataforma externa (Notion, ClickUp, GitHub) → el código gana también, pero el
  cambio externo requiere confirmación explícita tuya, porque no es reversible con un Ctrl+Z.

**Excepción, y es importante:** si la contradicción no se puede resolver leyendo el código —
decisiones de negocio, intención de producto, por qué existe algo— se registra como `PREGUNTAR`
y se pregunta. Nunca adivines ahí. Un supuesto razonable sobre reglas de negocio equivocado se
propaga a cada decisión posterior y es caro deshacerlo después.

### 4.3 Presentar la tabla de inconsistencies

Plantilla: `assets/plantillas/tabla-inconsistencias.md`. Una fila por hallazgo:

| # | Tipo | Ubicación | Qué dice | Qué debería decir | Confianza | Acción |

`Confianza` es **alta** cuando lo leíste directamente en código o manifiesto, **media** cuando lo
inferiste de un patrón, **baja** cuando es una corazonada. Declarar la confianza te permite
aceptar los hallazgos de alta rápido y frenar a discutir los de baja.

### 4.4 Confirmar cambio por cambio

Presenta la tabla **completa** primero, para que tengas el panorama entero. Después itera:

**MUESTRA un cambio → ESPERA respuesta → aplica o descarta → SIGUIENTE.**

Nunca apliques un lote sin haber mostrado cada uno. El motivo no es desconfianza: es que el
juicio de precedencia puede fallar, y si aplicaste cinco cambios de golpe, un error tuyo se
convierte en cinco archivos modificados que alguien tiene que revertir a mano.

Un rechazo es una **decisión, no un error**. Anótalo en `estado.json` y no lo vuelvas a proponer
en la misma ejecución. Si el usuario rechazó "cambiar el comando de build", seguir insistiendo
con "¿qué tal si lo cambiamos igual?" desperdicia su tiempo y tu credibilidad.

### 4.5 Aplicar según destino

- **Archivos del repo** → editar directamente, ya confirmado.
- **Plataformas externas** → seguir la checklist de `references/plataformas/<plataforma>.md`.
- **Contexto faltante** → generar desde las plantillas. No inventes formato libre: un
  `.contexto/brief.md` con la forma estándar es comparable entre proyectos; uno con forma propia
  obliga a reaprenderlo cada vez.
- **Contexto sobrante** → **nunca borrar**. Se reporta como sugerencia y queda a decisión tuya.
  Puede que la sección "vaya a producción" que ya no aplica te sirva como registro de que hubo
  un comando de deploy; la información de que algo *estuvo* ahí tiene valor. Y si yo me equivoqué
  al juzgar que está sobrante, al borrar te quedas sin la evidencia de por qué se decidió algo.

Si los hallazgos **no caben en una sesión** —muchos, o de varios destinos con riesgo distinto— no
improvises una tabla gigante: agrúpalos en `assets/plantillas/plan-accion.md`, que separa los
cambios por **dónde se aplican** (repo = reversible con git, Notion = requiere confirmación,
ClickUp = alguien más puede estar escribiendo). Para tres correcciones puntuales, la tabla de
inconsistencias con su iteración cambio por cambio es suficiente y ese archivo sobra.

### 4.6 Verificar y cerrar

Reescanea tras aplicar. Reporta qué se aplicó, qué se rechazó y qué sigue pendiente. Actualiza
`.contexto/estado.json` para que la próxima ejecución sepa dónde quedó todo.

## Límites duros

- **Nunca borrar ni archivar contenido.** En ningún sistema, ni en un repo, ni en Notion, ni en
  ClickUp. Se propone; quien decide borra.
- **Nunca escribir en plataformas externas sin confirmación explícita de ese cambio.** El
  repositorio es reversible con git; una página de Notion compartida con el equipo no lo es.
- **Nunca inventar contexto ausente.** Se reporta como hueco.
- **Nunca aplicar más de un cambio sin haberlo mostrado.**

## Persistencia

`.contexto/` se commitea al repo. Contiene:

- `brief.md` — el entendimiento del proyecto
- `estado.json` — fecha, modo elegido, hallazgos, cambios aplicados, rechazos. Es lo que hace
  idempotente la reejecución.

```json
{
  "version": 1,
  "ultima_ejecucion": "2026-09-25T21:38:01Z",
  "modo": "A",
  "modo_origen": "usuario",
  "contexto_externo": "presente",
  "herramientas": {
    "configuradas": [],
    "conectadas": [],
    "huecos": []
  },
  "inventario": [
    { "ruta": "AGENTS.md", "sha256": "...", "ultimo_commit": "...", "tipo": "convenciones" }
  ],
  "hallazgos": [],
  "cambios_aplicados": [],
  "rechazos": [],
  "pendientes": []
}
```

`hallazgos[]`: `{ "tipo": "DESACTUALIZADO", "ubicacion": "AGENTS.md:12", "dice": "npm run start",
"deberia": "npm run dev", "confianza": "alta", "estado": "aplicado|rechazado|pendiente" }`.

Regenerar `inventario` entero en cada ejecución es correcto y barato: son hashes. Lo que consume
es el trabajo de *interpretar* el delta, y para eso está `hallazgos[]`.
