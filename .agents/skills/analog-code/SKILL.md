---
name: analog-code
description: Diseña analogías de la vida real para explicar conceptos de programación, algoritmos, estructuras de datos y patrones de diseño del proyecto. La analogía debe ser clara, específica y fácil de entender para un estudiante de programación. Divide la explicación en partes cuando el concepto es grande y al final pregunta al usuario si quiere profundizar y repetir el flujo. Usa esta skill SIEMPRE que el usuario pida una analogía para entender un concepto, función, archivo, clase o bloque de código, incluso si no menciona la palabra "analogía" ni nombra la skill directamente.
---

# Analog-Code para Estudiantes

Tu objetivo es traducir el funcionamiento de un concepto, una función, una clase o un algoritmo del proyecto a una escena cotidiana que un estudiante pueda recordar y volver a contar en clase o en el examen. Una buena analogía no es un cuento bonito: es un mapa de correspondencias entre los elementos del código y los elementos de la escena, recorrido con un ejemplo concreto.

Aplica estas cuatro fases en orden:

## Fase 1 — Analiza el concepto y su tamaño

Antes de crear la analogía:

1. Identifica el concepto, función, clase o algoritmo que se pide explicar y dónde vive en el proyecto (archivo) si aplica.
2. Detecta sus elementos principales y la relación entre ellos: qué entra, qué se transforma, qué sale, condiciones, bucles, estados.
3. Estima el tamaño:
   - **Pequeño o mediano** (una función o un concepto simple): la analogía se construye completa en una sola pasada.
   - **Grande** (un flujo completo, una clase extensa, un algoritmo complejo o varias funciones): divide el concepto en partes lógicas y crea una analogía por parte (o una analogía general más una por cada tramo del recorrido). Anuncia la división al estudiante:
     > "Este concepto es grande, así que lo divido en 3 partes con su analogía cada una: 1) el pedido, 2) la preparación, 3) la entrega."

## Fase 2 — Pregunta el nivel de detalle

Pregunta al usuario qué tipo de analogía quiere antes de construirla:

- **General** (explica la idea sin nombres del código) o **específica** (incluye y mapea los nombres reales de funciones, variables y clases del proyecto).
- Escenario **familiar** concreto (cocina, biblioteca, oficina, transporte, trámite) o si prefiere que elijas uno tú.
- Analogía para un **elemento puntual** (una función) o para el **flujo completo**.

Adapta estas preguntas al caso y continúa; no todas aplican siempre, así que haz solo las que aporten.

## Fase 3 — Construye la analogía

Con las respuestas de la fase anterior, construye la analogía así:

1. **Elige un escenario cotidiano** que tenga la misma estructura lógica que el código: si el código recibe algo, lo transforma y lo devuelve, elige una escena que haga exactamente eso.
2. **Mapea cada elemento** de forma explícita (tabla o lista) para que la correspondencia no quede implícita:
   - `pedirDatos()` → "el mesero anota el pedido"
   - variable `estado` → "la pizarra donde el chef apunta qué platos van"
   - `if` → "el guardia de la entrada que revisa si el boleto es válido"
   - `for` → "revisar cada maleta de pasajeros antes de subir al avión"
3. **Recorre un ejemplo concreto** dentro de la escena: entra con el usuario y muéstralo pasar por cada elemento de la analogía en el mismo orden en que el código se ejecuta.
4. Cierra con la **moraleja**: qué concepto o estructura técnica representa la analogía, para que el estudiante pueda traducirla de vuelta a código cuando la necesite.

Reglas:

- Primero deja clara la idea técnica y después la analogía que la refuerza; la analogía nunca sustituye a la explicación.
- Si pediste nivel específico, usa los nombres reales del proyecto; si es general, omítelos.
- Si la analogía no cubre algún detalle del código, dilo a propósito: "esto no lo representa la analogía, porque en el código pasa X". Ese aviso evita que el estudiante se lleve una idea falsa.

## Fase 4 — Encuesta final

Cierra siempre preguntando si el usuario quiere profundizar o repetir el flujo. Ejemplo:

> **¿Quieres que te ayude con algo más?**
> 1. Sí, quiero la misma analogía pero más específica (con nombres del proyecto)
> 2. Sí, quiero otra analogía con un escenario diferente
> 3. Sí, quiero la siguiente parte (parte 2)
> 4. Sí, otra cosa: (escribe qué)
> 5. No, gracias, con esto entiendo

Si elige una opción, vuelve a la fase que corresponda y repite el flujo. No termines la interacción sin haber hecho la encuesta.

## Resumen del flujo

1. **Analiza** el concepto, sus elementos y su tamaño → decide si divides.
2. **Pregunta** el nivel de detalle (general/específico y escenario).
3. **Construye** la analogía: escenario → mapeo → ejemplo recorrido → moraleja.
4. **Encuesta** para profundizar o terminar → si elige, repites desde la fase adecuada.