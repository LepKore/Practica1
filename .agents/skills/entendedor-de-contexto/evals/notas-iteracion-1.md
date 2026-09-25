# Notas de la iteración 1 — qué midió el benchmark y qué no

Fecha: 2026-09-25. 3 evals × 2 configuraciones, n=1 por celda.

## El titular y por qué engaña

La primera pasada dio **17/17 con skill vs 5/17 sin skill (100% vs 29%)**. Ese número no
significa lo que parece. Al auditarlo salió que:

- **3 de 17 aserciones no discriminaban**: las que pedían encontrar el drift de la API,
  reconocer que las premisas del usuario no tienen respaldo, y aplicar precedencia. El
  baseline las pasaba igual. Un baseline competente ya cumple eso.
- **Varias aserciones comprobaban vocabulario de la skill** (`DESACTUALIZADO`, `PREGUNTAR`,
  `modo_origen`, `Confianza`). Un baseline no puede pasarlas aunque analice mejor, porque no
  tiene por qué usar esas palabras.

Medición de marcadores de terminología de la skill en los informes:

| Run | Tokens de skill |
|---|---|
| eval-1 con skill | 10 |
| eval-1 sin skill | 0 |
| eval-2 con skill | 14 |
| eval-2 sin skill | 0 |
| eval-3 con skill | 13 |
| eval-3 sin skill | 0 |

Separación perfecta de vocabulario. Cualquier aserción que exija uno de esos tokens va a
discriminar **por construcción**, no por meritencia.

## El error que cometí al corregir

Error intenté arreglarlo endureciendo las regex para exigir conducta explícita (citar la regla de
precedencia *por nombre*, proponer texto con ubicación y evidencia, declarar `modo_origen`). El
resultado fue **18/18 vs 0/18 — un 100/0 perfecto**. Eso es *peor* que el problema original:
el 5/17 original al menos reconocía que el baseline acertaba en 3 cosas, y el 0/18 afirma que un
baseline no puede hacer nada bien. Endurecer regex hasta que separen dos grupos es
sobreajustar el benchmark, no medirlo.

## La evaluación correcta: tres cubetas separadas

Separar según **qué mide** cada aserción, y reportar por separado. Un único agregado aplana
capacidad contra formato y exagera la diferencia.

| Cubeta | Qué mide | Con skill | Sin skill | Delta |
|---|---|---|---|---|
| **A · Capacidad** | ¿el run encuentra los hechos reales del repo? | 10/10 (100%) | 6/10 (60%) | **+40%** |
| **B · Proceso** | ¿sigue el método que la skill exige? | 9/9 (100%) | 0/9 (0%) | +100% |
| **C · Seguridad** | ¿declara cero escrituras y no toca nada externo? | 4/4 (100%) | 0/4 (0%) | +100% |
| *Agregado* | *todo mezclado* | *23/23* | *6/23* | *+74% ← el número engañoso* |

### Lo que dice cada cubeta

**A · Capacidad (+40%) es el número que importa.** De 10 hechos-verdad comprobados contra los
fixtures, el baseline encontró 6 y la skill los 10. Los 4 que la skill-exclusive encontró:

1. El script `start` invoca `server.js`, que no existe en el repo.
2. No hay ninguna convención documentada (el `AGENTS.md` solo lista scripts).
3. En `no-context`, no existe **ningún** archivo de contexto.
4. `vite` no está declarado en `dependencies`, así que `npm run dev` no resuelve en instalación
   limpia.

El 4º es el más valioso: exige leer el manifiesto con cuidado y una inferencia de una línea
que no está escrita. Ese es análisis genuinamente superior, no formato.

Y lo inverso también es cierto: **el baseline acertó 6 de 10 hechos, incluidos los tres más
difíciles del eval 3** (refutar las dos premisas falsas del usuario y detectar el drift real de
la API). La skill no lo hace más listo. Lo hace más completo en la cobertura y más explícito
en el método.

**B · Proceso (+100%) es measurement artefact.** No aporta evidencia sobre calidad de análisis.
Lo que sí confirma es que la skill **se carga y se aplica** en 3 de 3 casos sin excepción. Eso
tiene valor operativo (el `description` dispara, el `SKILL.md` se lee, el flujo se sigue) pero
no debe venderse como "la skill razona mejor".

**C · Seguridad (+100%) es la justificación más fuerte de la skill.** Ningún run sin skill
declaró alguna vez que no hubiera escrito, ni mencionó no tocar plataformas externas. La skill
lo hace en 3 de 3. Para una skill cuyo riesgo principal es editar el repo equivocado o escribir
en Notion sin permiso, esa es la diferencia que justifica existir.

## Conclusión honesta

La skill **no** hace que el agente analyse mejor: hace que analice algo más completo, siga un
método visible, y sobre todo **no toque nada sin decirlo**. La justificación real es C, con A
como complemento y B como evidencia de que la skill se aplica.

Si alguien presentara solo el `+74%` agregado, estaría vendiendo formato como inteligencia.

## Lo que faltó y sesga el resultado

- **n=1 por celda.** Sin varianza ni test de hipótesis. El `stddev` que reporta el agregador es
  0 por construcción, no porque los runs sean equivalentes.
- **Sin timing ni tokens.** El Task tool de este entorno devuelve solo texto, sin `total_tokens`
  ni `duration_ms`. Los campos quedan en 0 por ausencia de dato. Único tiempo real medido:
  139 s de pared para 4 runs en paralelo (19:20:06Z–19:22:25Z), que es agregado, no por run.
- **Fixtures mínimos.** Con 2-4 archivos, el trabajo de reconocer el proyecto es trivial. En un
  repo real la skillaportaría más de la fase de descubrimiento, que aquí está subestimada.
- **Fallo de arnés, no de la skill.** En la primera ronda un run con skill escribió su salida
  *dentro* del fixture analizado. La ronda 2 lo detectó solo, lo verificó por sha256 y lo
  reportó como SOBRANTE sin borrarlo. El fixture se restauró.
