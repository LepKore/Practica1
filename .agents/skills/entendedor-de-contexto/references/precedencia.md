# Precedencia

Quién tiene la razón cuando dos fuentes se contradicen. Esta es la parte de la skill donde
equivocarse cuesta caro, así que la regla se apoya en una única pregunta: **¿qué fuente puede
mentir sin que nadie se entere?**

## La regla

**El código ejecutable gana.** Es lo único que no puede mentir en silencio.

Un documento puede afirmar durante seis meses que el puerto es 3000 mientras el servidor
arranca en 8080, y no pasa nada: nadie ejecuta el puerto, o si lo hacen asumen que el README
está viejo. El código equivocado, en cambio, revienta de inmediato el primer `npm run dev`.

Esa asimetría es toda la justificación. No es que el código sea "más oficial": es que **el
error en él es ruidoso y el error en la documentación es silencioso**, y por eso el
mantenimiento se acumula siempre en la documentación.

## Aplicación

### Código vs documento del repo → corrige el documento

El documento es el que se rompió. Se corrige el documento, con confirmación del usuario.

Excepción: si el código parece un residuo muerto (un script que nadie llama, una carpeta
abandonada) y el documento describe algo que aún debería existir, entonces el problema es
**otro**: falta una decisión sobre si se restaura o se documenta la deprecación. Eso es un
ADR pendiente, no una corrección de doc. Pregunta.

### Código vs plataforma externa → el código gana, con confirmación

Igual que arriba, pero el cambio ocurre fuera del repo y por eso necesita confirmación
explícita, siempre. No porque el código tenga menos razón, sino porque **el costo de revertir
es distinto**: `git revert` es un comando, deshacer una edición en una página compartida con
el equipo es un rato de tu tiempo y una explicación incómoda.

Presenta el cambio propuesto con la URL exacta, el bloque exacto y el texto exacto antes de
tocarlo. Ver `plataformas/<plataforma>.md` para el procedimiento.

### Jerarquía de instrucciones → la más cercana gana

Dos `AGENTS.md` en directorios distintos no son una contradicción: es anidación. Se reporta
la jerarquía completa para que sea visible, y se corrige el archivo que aplica a la zona
equivocada, no "el que está mal".

## La excepción que no admite atajos

**Si la contradicción no se puede resolver leyendo el código, se pregunta. No se decide.**

El código te dice *qué hace* el sistema. No te dice *por qué*. Y hay contradictorias donde
"qué" está clarísimo y "por qué" es la pregunta entera:

- El doc dice que los descuentos solo aplican a clientes con 3+ pedidos. El código tiene un
  `if (order.items.length >= 3)`. El código no dice si el 3 es un requisito de negocio, un
  valor arbitrario que alguien puso, o el resultado de un experimento que ya caducó. **Las tres
  son igual de plausibles y el código no las distingue.**
- El doc dice "el endpoint v1 se mantiene por compatibilidad". El código tiene ambos. Nadie
  escribió por qué, ni hasta cuándo.
- Un flag `experimental: true` en un módulo que lleva dos años en producción.

En estos casos: registra `PREGUNTAR` con la pregunta concreta, y sigue con los demás
hallazgos mientras espera respuesta. No bloquees el informe completo por un PREGUNTAR.

El motivo por el que aquí no se improvisa: un supuesto razonable sobre reglas de negocio es
**silenciosamente correcto hasta que no lo es**. Un supuesto sobre un nombre de carpeta cuesta
30 segundos de deshacer. Un supuesto sobre cuándo aplica un descuento se propaga a cada
decisión posterior, llega a producción, y deshacerlo significa revisar todo lo que se decidió
en medio. La asimetría de costos es brutal.

## Mal menor: cómo presentar una corrección propuesta

Incluso cuando el código gana y la respuesta es obvia, el cambio se propone con esto:

1. **Ubicación exacta** — archivo y línea. `AGENTS.md:42`.
2. **Texto actual** — cita literal, no parafrasis.
3. **Propuesta** — el texto nuevo, escrito ya, listo para aplicar.
4. **Evidencia** — de dónde sale: `package.json:scripts.dev`, `vite.config.js:server.port`.
5. **Confianza** — alta / media / baja.

Con los cinco, el usuario aprueba o corrige en segundos. Sin la evidencia, tiene que fiarse de
tu juicio, y no tiene por qué.

Y entonces **esperas**. Un cambio a la vez. La razón no es desconfianza: es que si aplicas
cinco cambios de golpe y uno estaba equivocado, el usuario tiene cinco archivos modificados
que revertir a mano en lugar de uno.
