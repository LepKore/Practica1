# Registro de errores

## Error 1 — Texto invisible en el botón "Agregar"

- **Ubicación:** `src/App.css:89`
- **Descripción:** el botón `.add-btn` tenía `background: #4a90d9` (azul) y `color: #5a9ae0` (azul muy similar). El texto "Agregar" resultaba ilegible por falta de contraste.
- **Solución aplicada:** el color del texto se cambió a blanco (`color: #fff`), contrastando correctamente con el fondo azul.

## Error 2 — Búsqueda sensible a mayúsculas/minúsculas

- **Ubicación:** `src/App.jsx:59`
- **Descripción:** el filtro cliente `.filter((p) => p.title.includes(search))` distinguía mayúsculas de minúsculas: buscar "IPHONE" no encontraba "iPhone". Eso se suma a que la consulta server-side (dummyjson) sí es insensible a mayúsculas, por lo que el doble filtrado podía descartar resultados válidos.
- **Solución aplicada:** se normalizan ambas cadenas con `toLowerCase()` antes de comparar: `.filter((p) => p.title.toLowerCase().includes(search.toLowerCase()))`. Ahora la búsqueda no distingue entre mayúsculas y minúsculas, tanto en el texto de entrada como en los títulos.

## Error 3 — Sección "Tu carrito" detrás o encima de los productos

- **Ubicación:** `src/App.jsx` y `src/App.css`
- **Descripción:** la sección `.cart` tenía un orden de apilamiento incorrecto y, al corregirlo, podía superponerse a las tarjetas de productos.
- **Solución aplicada:** se estableció un orden de apilamiento visible, se reservó espacio lateral para el carrito en escritorio y se colocó debajo de los productos en pantallas pequeñas. El botón permite mostrarlo y ocultarlo.

## Error 4 — No se podía acceder al desplazamiento y a los controles del carrito

- **Ubicación:** `src/Cart.jsx` y `src/App.css`
- **Descripción:** el contenido y los controles del carrito no eran cómodos de alcanzar cuando había muchos artículos o el ancho era reducido.
- **Solución aplicada:** se mantuvo el desplazamiento vertical del panel, se permitió el ajuste de cada artículo y se dieron dimensiones visibles a los botones de aumentar y reducir.

## Error 5 — El carrito no se actualizaba al agregar productos

- **Ubicación:** `src/App.jsx:31`
- **Descripción:** `addToCart` mutaba directamente el estado existente y volvía a guardar la misma referencia, por lo que React no siempre renderizaba el cambio.
- **Solución aplicada:** se actualiza el carrito de forma inmutable y se incrementa la cantidad si el producto ya estaba agregado.
