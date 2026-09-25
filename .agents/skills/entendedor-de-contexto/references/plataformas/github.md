# GitHub y el repositorio

GitHub es el caso fácil y también el peligroso, porque escribir en un repo **parece** reversible
y no siempre lo es. La diferencia entre lo local y lo remoto es la que decide el procedimiento.

## Archivos del repo → local, y con confirmación

Un cambio en un archivo del repo se hace **en el working tree**, nunca con la API de GitHub.
Motivo: el working tree es reversible con `git diff` y `git checkout`; un commit publicado es
visible para todos y deshacerlo crea ruido en el historial.

1. Verifica que el cambio propuesto está en la tabla de inconsistencias.
2. Muéstralo al usuario con ubicación, texto actual y texto propuesto.
3. **Espera confirmación.**
4. Aplica con `Edit`.
5. **No hagas commit ni push** salvo que el usuario lo pida explícitamente. Editar el archivo y
   commitear son dos decisiones distintas: la primera es tuya si la aprobaron, la segunda es
   del usuario.

Cuando el cambio aplique a varios archivos, cada archivo es un cambio distinto y se confirma
por separado, salvo que el usuario diga explícitamente "aplica el lote".

## Issues y pull requests → solo si lo piden

Un hallazgo que **no aplica al repo** (contradice con un sistema externo, o un hueco que nadie
puede cerrar) puede convertirse en un issue. Pero crear issues sin que lo pidan ensucia el
tracker del equipo, y un issue que se abre con una descripción de media línea obliga a alguien
a volver a buscar el contexto.

Si el usuario pide documentar los hallazgos como issues:

- **Un issue por hallazgo**, no uno con todo mezclado. La granularidad importa: un issue con
  seis problemas se cierra entero cuando resuelven uno.
- Título imperativo y específico: `Actualizar comando de build en AGENTS.md:42`.
- Cuerpo con ubicación, texto actual, texto propuesto, evidencia y confianza. El mismo formato
  de la tabla, para que quien lo lea no tenga que fiarse de tu juicio.
- Etiqueta solo si el repo ya usa etiquetas y hay una que encaje. Inventar un sistema de
  etiquetas es peor que no etiquetar.

## Ramas y comparación

Si el usuario pide trabajar en una rama, créala. Si pide comparar, `git diff` local es más
barato y más claro que una PR.

Si hay commits sin pushear, **no los borres ni los resetees**. Un commit local no publicado es
información: puede contener el trabajo de otra persona o el tuyo de una sesión anterior. Se
reporta, no se toca.

## Lo que nunca se hace

- **`git push --force`** a una rama compartida, ni con `--force-with-lease`. Elimina historia
  de todos los demás. Si el usuario lo pide explícitamente, avisa una vez de lo que implica y
  luego hazlo — pero solo si insiste.
- **Borrar ramas remotas** o tags.
- **Cerrar issues** como "efecto secundario" de un arreglo. El cierre es del equipo.
- **Hacer `git checkout .` o `git reset --hard`** para "limpiar" antes de trabajar. Eso destruye
  cambios sin commitear de quien sea, y son irrecuperables.
- **Editar `.gitignore` para que algo deje de aparecer en el inventario.** Si un archivo de
  contexto está ignorado, eso es un hallazgo (nadie lo commitea, luego se pierde), no algo que
  se resuelva silenciosamente.

## La relación con `estado.json`

`.contexto/` es contexto del equipo, así que va commiteado como cualquier otra cosa — con la
salvedad de que este proyecto tiene `*.md` en `.gitignore`. Si ese es el caso, `.contexto/`
queda fuera del repo sin que nadie lo note.

**Este es un hallazgo real y hay que reportarlo**, no resolverlo por tu cuenta: significa que
la promesa "el brief se commitea" es falsa. Preséntalo al usuario con la excepción exacta de
`.gitignore` que haría falta:

```
!/.contexto/
!/.contexto/brief.md
```

que se aplica a `CLAUDE.md` y `AGENTS.md`. Corregir el `.gitignore` es un cambio en el repo, así
que pasa por la misma confirmación que cualquier otro.
