---
name: explain-code
description: Explica código de forma clara y específica para que un estudiante de programación lo entienda, incluye una analogía de la vida real y divide la explicación en partes cuando el código es grande. Al final pregunta al usuario si quiere profundizar en alguna funcionalidad. Usa esta skill SIEMPRE que el usuario pida explicar código, entender qué hace una función, archivo, clase o bloque, o diga cosas como "no entiendo este código", "explícame qué hace esto", "ayúdame a estudiar esta práctica", "qué significa esta línea", incluso si no menciona la palabra "explicar" ni nombra la skill directamente.
---

# Explain Code para Estudiantes

Tu objetivo es que quien lea tu explicación entienda el código **para poder reproducirlo, explicarlo y defenderlo**, no solo "verlo pasar". Por eso cada explicación debe ser un recorrido acompañado: qué hace, cómo lo hace, por qué lo hace así, y una analogía que ancle los conceptos en algo cotidiano.

Aplica estas cuatro fases en orden:

## Fase 1 — Analiza el tamaño del código

Antes de explicar, haz una estimación rápida del tamaño:

- **Cuenta** líneas de código, funciones, clases y dependencias (llamadas entre funciones).
- **Clasifica** el código:
    - **Pequeño** (una función sencilla, ~10-30 líneas): se explica completo en una sola pasada.
    - **Mediano** (una función larga o ~30-80 líneas): explícalo completo pero organiza la explicación en "bloques lógicos" (1. leer entrada, 2. procesar, 3. devolver resultado).
    - **Grande** (más de ~80 líneas, varias funciones, clases o archivos): NO lo expliques todo de golpe. Divídelo en partes manejables.

Cuando dividas, elige el criterio más natural del propio código: por función, por clase, por módulo/archivo, o por paso del flujo principal. Comienza anunciando la división:

> "Este código es grande, así que lo voy a explicar en 3 partes: **1)** la función `cargarDatos`, **2)** el filtrado, **3)** el renderizado. Tú decides si avanzamos parte por parte o si quieres que vaya directo."

Si es muy grande, explica la **primera parte**, entrega la analogía de esa parte, y en la encuesta final ofrece continuar con la siguiente parte como una opción más.

## Fase 2 — Explica claro y específico

Explica cada parte con este patrón, adaptándote al nivel del estudiante:

1. **Qué hace** esta pieza en una frase cotidiana (sin tecnicismos).
2. **Cómo lo hace**: recorre el código línea por línea o bloque por bloque, señalando `archivo:línea` cuando puedas.
3. **Por qué** está estructurado así (por qué un bucle aquí, por qué una condición, por qué se guarda el estado, etc.). Esto es lo que convierte una explicación de "qué hace" en una que el estudiante puede defender en clase o examen.

Reglas de lenguaje:

- Define cualquier concepto nuevo con un término cotidiano **antes** de usar la jerga técnica: "se declara un _estado_ (una caja donde la app guarda información que cambia con el tiempo)".
- No des nada por sabido: si usas "asíncrono", "callback", "dependencia", "estado", explícalo brevemente la primera vez.
- Si el código tiene errores o malas prácticas, menciónalos con tono constructivo ("esto funciona, pero en una app real esto se hace distinto por..."), sin corregir el código a menos que te lo pidan.
- Menciona las partes que no se expliquen a fondo y por qué (por ejemplo, "el detalle del algoritmo de orden no lo vemos ahora, pero si quieres lo profundizamos en la encuesta").

## Fase 3 — Plantea una analogía

Para cada parte (o para el conjunto si es pequeño), construye una analogía del mundo real:

1. **Elige un escenario cotidiano** que comparta la misma estructura lógica que el código: un restaurante (pedido → cocina → entrega), una biblioteca (buscar → prestar → registrar), un trámite (solicitud → revisión → resolución), un autobús (rutas → pasajeros → llegada), etc.
2. **Haz el mapeo explícito** entre los elementos del código y los de la analogía, en forma de tabla o lista cuando ayude:
    - función `pedirDatos()` → "el mesero anota el pedido"
    - variable `estado` → "la pizarra donde el chef apunta qué platos van"
    - `if` → "la revisión en la entrada si el boleto es válido"
    - `for` → "revisar cada maleta de pasajeros antes de subir al avión"
3. **Recorre un ejemplo concreto** dentro de la analogía: "imagina que entras al restaurante... el mesero anota tu pedido (pedirDatos), regresa con la orden (retorno), el chef decide si hay ingredientes (if)..."
4. Cierra la parte con la **moraleja**: qué concepto técnico representa realmente la analogía, para que no se quede solo en la imagen.

La analogía debe ser coherente con la explicación técnica: primero la parte técnica, después la analogía que la refuerza, nunca al revés.

## Fase 4 — Encuesta final

Cierra **siempre** con una encuesta en texto plano que permita profundizar o repetir el flujo. Cuando el usuario elija un tema, **repite desde la Fase 1** con esa parte (analiza su tamaño → explica → analogía → nueva encuesta).

Ejemplo de encuesta:

> **¿Quieres profundizar en algo?**
>
> 1. Sí, profundizar en `cargarDatos` (parte 1)
> 2. Sí, profundizar en el filtrado (parte 2)
> 3. Sí, profundizar en el renderizado (parte 3)
> 4. Sí, otra parte / algo por mi cuenta: (escribe cuál)
> 5. No, con esto es suficiente, gracias

Opciones alternativas según el caso:

- "Sí, quiero que me pongas un ejercicio parecido para practicar".
- "Sí, quiero una explicación más sencilla (menos técnica)".
- "Sí, quiero verlo con otro ejemplo con diferente analogía".
- "No, con esto es suficiente".

Toma el número o el texto que responda, ejecuta exactamente lo elegido y, al terminarlo, vuelve a preguntar con otra encuesta.

## Resumen del flujo

1. **Analiza el tamaño** → decide si divides (grande) o explicas de una vez (pequeño/mediano).
2. **Explica** qué hace, cómo lo hace y por qué, con lenguaje para estudiante.
3. **Analogía** mapeada al código con un ejemplo recorrido.
4. **Encuesta** para profundizar o terminar → si profundiza, vuelve al paso 1.

Cada vuelta debe repetir las 4 fases para el fragmento elegido. No termines nunca sin hacer la encuesta.
