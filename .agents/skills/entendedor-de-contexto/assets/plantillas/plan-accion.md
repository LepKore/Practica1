# Plan de acción — <PROYECTO>

> Se genera cuando el número de hallazgos de la tabla de inconsistencias justifica más de un
> intercambio, o cuando el trabajo se extiende a varias sesiones. Para tres correcciones
> puntuales, la tabla de inconsistencias con su iteración cambio por cambio es suficiente y
> este archivo sobra.

## Contexto

| | |
|---|---|
| Alcance | <qué repos / qué documentos> |
| Generado | `<fecha>` |
| Modo | `<A \| B>` |
| Contexto externo | `<presente \| ausente>` |

## Hallazgos por destino

Los cambios se agrupan por **dónde se aplican**, porque el procedimiento y el riesgo son
distintos en cada caso. Un archivo del repo se edita en local y es reversible con git; Notion
es de solo lectura hasta que haya confirmación; ClickUp puede tener a otra persona
escribiendo a la vez.

| Destino | Hallazgos | Riesgo | Procedimiento |
|---|---|---|---|
| Archivos del repo | 1, 2, 3 | Bajo — reversible con git | `plataformas/github.md` |
| Notion | 6 | Alto — compartido, sin Ctrl+Z | `plataformas/notion.md` |
| ClickUp | — | Medio — otro autor | `plataformas/clickup.md` |
| Contexto faltante | 4, 7 | Nulo — se crea nuevo | `assets/plantillas/` |

## Secuencia propuesta

El orden no es arbitrario. Lo más barato y reversible primero, para que cuando llegues a lo
caro y no reversible ya hayas validado los hallazgos de verdad.

### 1. Archivos del repo (riesgo bajo)

- [ ] **#1** `AGENTS.md:42` — `npm run start` → `npm run dev`
  Evidencia: `package.json:scripts`. Confianza alta. A la espera de confirmación.
- [ ] **#2** `README.md:18` — puerto 3000 → 8080
  Evidencia: `vite.config.js:server.port`. Confianza alta.
- [ ] **#3** contradicción entre `CONTRIBUTING.md` y `AGENTS.md`
  Propuesta: alinear `CONTRIBUTING.md` con lo que hace el código.

### 2. Contexto faltante (riesgo nulo)

- [ ] **#4** Documentar `scripts/migrate.sh` en el README
  Generar desde `assets/plantillas/brief.md`, sección de comandos. No inventes el propósito
  del script: léelo y descríbelo.

### 3. Notion (riesgo alto, requiere confirmación explícita)

- [ ] **#6** Actualizar la página de producto
  Solo tras confirmación del texto exacto, bloque por bloque. Verificar antes de archivar
  cualquier bloque original.

## Bloqueantes

Nada puede avanzar sin esto.

| # | Pregunta | Quién puede responder |
|---|---|---|
| 7 | ¿El mínimo de 3 pedidos para el descuento es regla de negocio? | Alguien de producto/negocio |
| — | Notion no está conectado. ¿Se conecta o se deja el hallazgo como no verificable? | El usuario |

## Fuera de alcance

Cosas que se detectaron y **no** se van a tocar en esta pasada, con el motivo. Sin esta
sección, la próxima ejecución vuelve a proponer lo mismo.

| Hallazgo | Motivo |
|---|---|
| #5 sección obsoleta en `docs/v2-migration.md` | El usuario prefiere conservarla como registro histórico |
| Documentación de la librería en `docs/vendor/` | Se actualiza sola upstream; copiarla aquí solo crea desfase |

## Cierre

Al terminar, reescanear y reportar:

| | |
|---|---|
| Aplicados | <n> |
| Rechazados | <n> |
| Pendientes | <n> |
| Bloqueantes resueltos | <n> |

Y actualizar `.contexto/estado.json` con el resultado, para que la próxima ejecución sepa
qué queda sin tocar y no vuelva a proponer lo ya rechazado.
