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

## Error 6 — Se podían agregar más unidades que el stock disponible

- **Ubicación:** `src/App.jsx:31` y `src/App.jsx:45`
- **Descripción:** `addToCart` sumaba siempre 1 a la cantidad aunque se hubiera alcanzado el stock, y `changeQty` permitía superar el stock con el botón "+". Tampoco se impedía agregar un producto con stock 0.
- **Solución aplicada:** en `addToCart` se devuelve el carrito sin cambios si el producto ya está al máximo de stock (o si `stock <= 0`). En `changeQty`, el botón "+" no supera `item.stock`; si se intenta, la cantidad queda igual.

## Error 6 — El carrito cubría los filtros y su botón de cierre

- **Ubicación:** `src/App.css:101`
- **Descripción:** el panel fijo del carrito comenzaba en la parte superior de la ventana y cubría los botones de filtro y el botón `Carrito`, impidiendo cerrar la sección desde ese botón.
- **Solución aplicada:** el panel ahora comienza debajo del encabezado (`top: 80px`) y limita su altura al espacio restante, manteniendo accesibles los filtros y el botón para mostrar u ocultar el carrito.

## Error 7 — La compra no reducía el stock

- **Ubicación:** `src/App.jsx` y `src/ProductCard.jsx`
- **Descripción:** al finalizar una compra se vaciaba el carrito, pero el stock de los productos no se modificaba.
- **Solución aplicada:** al comprar se descuenta del estado de productos la cantidad adquirida, se limita la cantidad del carrito al stock disponible y se deshabilita el botón cuando un producto queda agotado.

## Error 8 — Algunos precios del carrito aparecían negativos

- **Ubicación:** `src/App.jsx` y `src/Cart.jsx`
- **Descripción:** el descuento porcentual se restaba directamente al precio como si fuera una cantidad fija, por ejemplo `precio - descuentoPercentage`.
- **Solución aplicada:** el precio final ahora se calcula como `precio * (1 - descuentoPercentage / 100)`, tanto en el total como en el detalle de cada producto.

## Error 9 — El precio del carrito no coincidía con el precio del producto

- **Ubicación:** `src/Cart.jsx:13`
- **Descripción:** la pantalla principal mostraba el precio base, pero el carrito mostraba el precio con descuento aplicado, generando una diferencia visual.
- **Solución aplicada:** el detalle del carrito ahora muestra el mismo precio base que la pantalla principal; el descuento se mantiene únicamente en el cálculo del total.

## Error 10 — El total del carrito no coincidía con el costo mostrado en inventario

- **Ubicación:** `src/App.jsx:79`
- **Descripción:** el total aplicaba `precio * (1 - descuentoPercentage / 100)` y el redondeo dejaba diferencias de centavos: productos como "Green Chili Pepper" (US$0.99) se sumaban como US$0.98. El inventario muestra el precio base, por lo que el total del carrito no coincidía.
- **Solución aplicada:** el total ahora se calcula como `precio * cantidad` (`sum + item.price * item.quantity`), igualando exactamente el costo mostrado en el inventario.

## Error 11 — El filtro "Todas" no mostraba todos los productos

- **Ubicación:** `src/App.jsx:21`
- **Descripción:** la carga inicial solicitaba únicamente 30 productos (`limit=30`), aunque el filtro "Todas" debía mostrar todo el catálogo.
- **Solución aplicada:** la consulta general ahora usa `limit=0` para solicitar todos los productos disponibles.

## Error 12 — Eliminación por categoría en lugar de producto

- **Ubicación:** `src/App.jsx`, función `removeFromCart`.
- **Descripción:** eliminar un producto comparando la categoría podía quitar también otros productos de la misma categoría.
- **Solución aplicada:** la eliminación compara el identificador único `id` del producto seleccionado.

## Error 13 — El carrito no se abría al agregar un producto

- **Ubicación:** `src/App.jsx:31`
- **Descripción:** si el carrito estaba cerrado, al presionar "Agregar" el producto entraba al carrito pero la vista del carrito permanecía oculta, obligando al usuario a abrirla manualmente.
- **Solución aplicada:** `addToCart` ahora llama `setShowCart(true)`, de modo que al agregar un producto el carrito se abre automáticamente.

## Error 14 — El botón "x" bajaba de línea con cantidades de dos dígitos

- **Ubicación:** `src/App.css:140` y `src/App.css:109`
- **Descripción:** `.cart-item` usaba `flex-wrap: wrap` con un ancho fijo del carrito de 400px. Al alcanzar una cantidad de dos dígitos (por ejemplo 10), la fila dejaba de caber y el botón "x" de eliminar saltaba a la línea siguiente, perdiendo la alineación y ocultándose del lado derecho del producto.
- **Solución aplicada:** se quitó `flex-wrap` de `.cart-item` para que todos los elementos permanezcan en una sola fila (el título se encoge con `flex: 1` según el espacio) y se amplió el ancho del carrito a `min(440px, 100%)` para que la ventana se adapte al contenido.
