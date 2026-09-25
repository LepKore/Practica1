# ClickUp

Procedimiento para leer contexto desde ClickUp y para corregirlo. ClickUp es peor fuente de
contexto de lo que parece: el contexto de negocio cambia más rápido que el código y nadie
actualiza la descripción de una tarea. Úsalo sobre todo para leer decisiones, no para escribir
técnica.

## Leer (modo A)

La jerarquía es team → space → folder → list → task, y hay que recorrerla entera; no existe un
"buscar en todo ClickUp" que sea fiable.

```
CLICKUP_GET_AUTHORIZED_TEAMS_WORKSPACES  → workspaces accesibles
  ↓
CLICKUP_GET_SPACES          → spaces del team
  ↓
CLICKUP_GET_FOLDERS         → folders del space
  ↓
CLICKUP_GET_LISTS           → lists del folder
  ↓   (o CLICKUP_GET_FOLDERLESS_LISTS si la list cuelga directo del space)
CLICKUP_GET_LIST            → tasks de la list
```

Dos trampas de navegación que cuestan tiempo:

- `CLICKUP_GET_FOLDERLESS_LISTS` **solo** devuelve lists sin folder. Una list dentro de un
  folder nunca aparece ahí. Si buscas en los dos sitios y no aparece en ninguno, probablemente
  el scope de team está mal.
- `CLICKUP_GET_AUTHORIZED_TEAMS_WORKSPACES` falla a veces con HTTP 500. Usa
  `CLICKUP_AUTHORIZATION_GET_WORK_SPACE_LIST` como fuente alterna del workspace. Si tampoco
  funciona, no insistas: repórtalo como no verificable.

Si el recorrido no devuelve nada por temas de visibilidad,
`CLICKUP_GET_SHARED_HIERARCHY` recupera lo que se ha compartido contigo, aunque luego algunos
IDs no se puedan leer con `CLICKUP_GET_LIST` o `CLICKUP_GET_FOLDER`.

## Corregir (modo B)

El riesgo real aquí no es escribir mal: es **sobrescribir el trabajo de otra persona**. La
descripción de una tarea la escribieron y la mantienen personas, no el código.

1. `CLICKUP_GET_TASK` — **siempre primero**. Necesitas el texto actual para no perderlo.
2. Compara con lo que propone el código.
3. Muestra el antes/después al usuario y **espera confirmación explícita**.
4. `CLICKUP_UPDATE_TASK` con `task_id` y el `description` **completo en una sola escritura**.
5. `CLICKUP_GET_TASK` otra vez para verificar.

## Detalles que evitan corrupción

| Detalle | Por qué importa |
|---|---|
| El `description` se envía **completo**, nunca por fragmentos | Escribir solo el párrafo nuevo borra el resto. |
| Un espacio `" "` (no cadena vacía) es lo que limpia el campo | `""` no lo limpia. |
| Varios campos de descripción conviven: renderizado y fuente markdown | Escribir en el equivocado corrompe el formato. Compara ambos antes y después. |
| La respuesta puede venir con markup escapado con backslashes | Normaliza antes de reescribir o los artefactos persisten. |
| `GET_TASK` devuelve 401 si falta scope | Resuelve permisos **antes** de intentar escribir. |
| Previews truncados | `GET_TASK` puede recortar textos largos. Verifica con un re-fetch comparando campos de texto. |

## La alternativa no destructiva

Cuando el texto nuevo es una **aportación** y no una corrección — un dato que encontraste y el
equipo no tenía — el comentario es mejor que sobrescribir la descripción:

```
CLICKUP_CREATE_TASK_COMMENT
```

`task_id`, `comment_text`, más `assignee` y `notify_all` si quieres que alguien lo vea. Deja
intacta la descripción de la tarea. Cuando la duda es "esto ya se arregló en el código, pero la
descripción no lo sabe", el comentario registra el hallazgo sin riesgo de pisar a nadie.

## Qué buscar en ClickUp y qué no

**Útil:** decisiones de negocio y su porqué, criterios de aceptación, contexto de por qué un
módulo existe.

**No útil:** estado de tareas, responsables, fechas. Eso cambia cada día, no es contexto
estable, y un informe de documentación no debería incluirlo.
