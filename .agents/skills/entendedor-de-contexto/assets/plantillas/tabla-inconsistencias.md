# Tabla de inconsistencias — <PROYECTO>

> Presentar la tabla **completa** antes de tocar nada. El objetivo de la primera vista es que
> el usuario tenga el panorama entero y pueda decir "prioriza estos tres" en una frase.
>
> Después se itera: un cambio → confirmación → aplicar o descartar → siguiente.

## Secciones de esta tabla

| Sección | Rol |
|---|---|
| Resumen | Foto del estado: cuántos hallazgos de cada tipo, cuántos de alta confianza |
| Detalle | La tabla que se itera cambio por cambio |
| Evidencia | De dónde sale cada afirmación, para que el usuario no dependa de tu criterio |
| Pendientes | Lo que requiere decisión humana y no se puede deducir del código |
| Aplicados / rechazados | Qué pasó en esta ejecución, para que `estado.json` sea idempotente |

## Resumen

| Métrica | Valor |
|---|---|
| Hallazgos totales | <N> |
| Desactualizados | <n> |
| Contradictorios | <n> |
| Faltantes | <n> |
| Sobrantes | <n> |
| No verificables (plataforma externa) | <n> |
| Alta confianza | <n> |
| Cambios aplicados | <n> |
| Cambios rechazados | <n> |

## Detalle

| # | Tipo | Ubicación | Qué dice | Qué debería decir | Confianza | Acción |
|---|---|---|---|---|---|---|
| 1 | DESACTUALIZADO | `AGENTS.md:42` | `npm run start` | `npm run dev` | alta | Corregir el documento |
| 2 | DESACTUALIZADO | `README.md:18` | `localhost:3000` | `localhost:8080` | alta | Corregir el documento |
| 3 | CONTRADICTORIO | `CONTRIBUTING.md:9` vs `AGENTS.md:31` | "punto y coma obligatorio" / "sin punto y coma" | — | alta | `AGENTS.md` (cercanía + código) |
| 4 | FALTANTE | `scripts/migrate.sh` | — | Mentionar en README | media | Añadir sección |
| 5 | SOBRANTE | `docs/v2-migration.md:14` | "Migración pendiente" | Marcar histórico | media | Preguntar: marcar o quitar |
| 6 | NO VERIFICABLE | Notion: página de producto | Says "descuentos para members" | — | — | Requiere Notion conectado |
| 7 | **PREGUNTAR** | `src/Cart.jsx:31` | — | — | — | ¿El mínimo de 3 items es regla de negocio? |

**Confianza:**
- `alta` — leído directamente en código o manifiesto.
- `media` — inferido de un patrón consistente.
- `baja` — corazonada. No debería haber ninguno en la tabla final; si lo hay, márcalo como
  tal y no lo presentes junto a los de confianza alta.

## Evidencia de cada fila

Un hallazgo sin evidencia obliga al usuario a fiarse de tu criterio. Con evidencia, decide en
segundos.

| # | Evidencia |
|---|---|
| 1 | `package.json:scripts` — el script se llama `dev`, no `start` |
| 2 | `vite.config.js:server.port` — `8080` |
| 3 | `src/*.jsx` no usa punto y coma en ningún archivo |
| 4 | `scripts/migrate.sh` existe, es ejecutable y el README no lo menciona |
| 7 | `if (items.length >= 3)` en el código; ningún archivo dice si es negocio o arbitrario |

## Pendientes de confirmar

A la espera de que alguien del equipo responda. **No las resuelvas con una suposición.**

| # | Pregunta | Por qué no se puede deducir del código |
|---|---|---|
| 7 | ¿El mínimo de 3 pedidos para descuento es requisito de negocio? | El código tiene el número, no su origen. Tres cosas igual de plausibles: regla real, valor arbitrario, o resto de un experimento caducado. |

## Aplicados / rechazados

Registro de esta ejecución, para que `estado.json` sea idempotente y nadie vuelva a proponer
algo que ya se rechazó.

| # | Decisión | Motivo |
|---|---|---|
| 1 | aplicado | — |
| 5 | rechazado | El usuario prefiere conservar la sección como histórico |
