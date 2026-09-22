# Registro de errores

## Error 1 — Texto invisible en el botón "Agregar"

- **Ubicación:** `src/App.css:89`
- **Descripción:** el botón `.add-btn` tenía `background: #4a90d9` (azul) y `color: #5a9ae0` (azul muy similar). El texto "Agregar" resultaba ilegible por falta de contraste.
- **Solución aplicada:** el color del texto se cambió a blanco (`color: #fff`), contrastando correctamente con el fondo azul.

## Error 2 — Búsqueda sensible a mayúsculas/minúsculas

- **Ubicación:** `src/App.jsx:59`
- **Descripción:** el filtro cliente `.filter((p) => p.title.includes(search))` distinguía mayúsculas de minúsculas: buscar "IPHONE" no encontraba "iPhone". Eso se suma a que la consulta server-side (dummyjson) sí es insensible a mayúsculas, por lo que el doble filtrado podía descartar resultados válidos.
- **Solución aplicada:** se normalizan ambas cadenas con `toLowerCase()` antes de comparar: `.filter((p) => p.title.toLowerCase().includes(search.toLowerCase()))`. Ahora la búsqueda no distingue entre mayúsculas y minúsculas, tanto en el texto de entrada como en los títulos.