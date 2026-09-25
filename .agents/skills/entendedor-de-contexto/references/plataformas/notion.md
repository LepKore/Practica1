# Notion

Procedimiento para leer y para corregir contexto en Notion. Los nombres de herramienta son los
slugs reales de Composio; si en tu entorno el toolkit se llama distinto, el procedimiento se
mantiene: **leer entero → mostrar el diff → confirmar → escribir → releer**.

## Antes de tocar nada: la prueba de que puedes escribir

Un hallazgo de Notion solo es accionable si la integración puede escribir. Un bot conectado en
solo lectura produce un informe que promete correcciones que luego no puede aplicar.

1. Localiza la página objetivo.
2. Confirma que **no está archivada** (`NOTION_RETRIEVE_PAGE`). Escribir en una página
   archivada falla con error poco descriptivo.
3. Recuerda que si `NOTION_FETCH_DATA` devuelve vacío, casi siempre es que el contenido
   **no está compartido con la integración**, no que no exista. Antes de concluir "no hay
   contexto en Notion", dilo explícitamente al usuario: probablemente necesite compartir las
   páginas con el bot.

## Leer (modo A)

```
NOTION_FETCH_DATA            → inventario del workspace (páginas y bases de datos)
  ↓ filtrar por título relevante
NOTION_GET_PAGE_MARKDOWN     → contenido completo en una llamada
  ↓ si sale vacío o truncado
NOTION_FETCH_ALL_BLOCK_CONTENTS → recorrer el árbol de bloques a mano
```

`NOTION_GET_PAGE_MARKDOWN` es el atajo bueno: una llamada, sin recursión. Solo acepta **IDs de
página**, no de base de datos; para bases de datos usa `NOTION_QUERY_DATABASE` o
`NOTION_QUERY_DATA_SOURCE`.

`NOTION_SEARCH_NOTION_PAGE` busca por título, pero tiene dos limitaciones que hay que conocer
antes de concluir algo: la indexación no es inmediata (una página recién compartida puede no
aparecer) y no es exhaustiva. Si una búsqueda con términos específicos sale vacía, reintenta
con query vacía y filtra del lado del cliente.

## Corregir (modo B)

Este es el flujo exacto, y cada paso existe por un motivo:

1. **Muestra el texto actual.** `NOTION_GET_PAGE_MARKDOWN` sobre la página.
2. **Localiza el bloque exacto.** `NOTION_FETCH_BLOCK_CONTENTS` y busca el `block_id` cuyo
   `plain_text` contiene lo que vas a cambiar. Sin `block_id` no hay escritura posible.
3. **Muéstrale el cambio al usuario** y **espera confirmación explícita**. Sin excepción, ni
   siquiera si el cambio es "obvio" o si es un solo carácter.
4. **Escribe.** `NOTION_UPDATE_BLOCK` con el `block_id` y el texto nuevo completo.
5. **Relee y verifica.** `NOTION_GET_PAGE_MARKDOWN` otra vez. Si no coincide con lo que
   esperabas, dilo en el informe en lugar de intentar un segundo reintento a ciegas.

## Límites que van a morderte si no los sabes

| Límite | Consecuencia |
|---|---|
| `NOTION_UPDATE_BLOCK`: 2000 caracteres por bloque, hard limit | Textos largos fallan con `validation_error`. Divide en varios bloques. |
| No se puede cambiar el tipo de bloque | Cambiar un párrafo a lista no es update: es borrar y crear. |
| El update **sobrescribe** `rich_text` | Se pierden negritas, enlaces y anotaciones. Lee primero el `rich_text` actual y reconstruye las anotaciones en el payload. |
| Markdown renderizado literal | Si escribes `**negrita**` en un update, sale con los asteriscos. `NOTION_ADD_MULTIPLE_PAGE_CONTENT` sí parsea markdown; `NOTION_UPDATE_BLOCK` no. |
| Algunos bloques no soportan update | `table_row`, por ejemplo. Para eso: insertar y archivar. |

## Cuando el update directo no sirve

Si el bloque no soporta actualización en sitio:

```
NOTION_ADD_MULTIPLE_PAGE_CONTENT  → insertar el reemplazo (con `after` para posicionarlo)
  ↓ verificar que renderiza y quedó en el orden correcto
NOTION_DELETE_BLOCK              → archivar el original
```

El orden importa: **verifica antes de archivar**. `NOTION_DELETE_BLOCK` pone `archived: true`;
es la única acción de esta skill que no se puede deshacer, ni con historial de versión. Si
arreglas varios bloques, deja los originales sin archivar hasta que el usuario confirme que
todo se ve bien.

## Si Notion no está conectado

No es motivo para abortar. Repórtalo en el informe: qué se perdió (contexto que vive solo en
Notion y no es recuperable desde el repo), y que se puede habilitar. Un proyecto cuyo contexto
real vive en Notion y sin integración es un proyecto cuyo contexto no es verificable — y eso
es un hallazgo en sí mismo.
