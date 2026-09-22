# Registro de errores

## Error 1 — Texto invisible en el botón "Agregar"

- **Ubicación:** `src/App.css:89`
- **Descripción:** el botón `.add-btn` tenía `background: #4a90d9` (azul) y `color: #5a9ae0` (azul muy similar). El texto "Agregar" resultaba ilegible por falta de contraste.
- **Solución aplicada:** el color del texto se cambió a blanco (`color: #fff`), contrastando correctamente con el fondo azul.