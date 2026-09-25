# Criterio de inconsistencia

Los cuatro tipos de hallazgo y cómo distinguirlos. La clasificación no es burocracia: cada tipo
tiene una acción distinta y una confianza distinta, y mezclarlos produce cambios que rompen
cosas.

## DESACTUALIZADO

*Era cierto, el proyecto cambió.*

Una sola fuente de contexto, y el código dice otra cosa. Es el tipo más común y el más fácil de
resolver: no hay debate sobre qué es verdad.

| Qué | Ejemplo |
|---|---|
| Comando renombrado | El doc dice `npm run start`; en `package.json` el script se llama `dev`. |
| Carpeta movida | El doc describe `src/legacy/`; ya no existe, ahora está en `src/old/`. |
| Puerto o URL cambiados | El README dice `localhost:3000`; el archivo de config dice `8080`. |
| Dependencia eliminada | El doc explica el uso de un paquete que ya no está en el manifiesto. |
| Script de verificación caído | El CONTRIBUTING dice `make test`; no existe el target. |
| Sección de estado | El doc tiene una sección "Estado: en producción" y el proyecto ya se archivó. |

**Confianza:** alta si lo leíste en el manifiesto o en el código; media si lo inferiste de un
patrón (el comando no está, pero hay uno con nombre parecido).

**Acción:** corregir el documento, no el código. Salvo que el código sea un residuo sin usar y
eso sea evidente — en ese caso es una hallazgo distinto, y conviene mencionarlo aparte.

## CONTRADICTORIO

*Dos fuentes se contradicen entre sí.*

Aparece cuando hay dos documentos, o un documento y una plataforma externa, que afirman cosas
incompatibles. Lo que hay que decidir primero es **cuál de los dos tiene autoridad**, y eso lo
decide `precedencia.md`, no el criterio de inconsistency.

| Qué | Ejemplo |
|---|---|
| Docs internos en conflicto | `AGENTS.md` dice "sin punto y coma", `CONTRIBUTING.md` dice "punto y coma obligatorio". |
| Doc vs plataforma externa | El README dice que los descuentos son para members; la página de Notion del producto dice que son para cualquiera. |
| Jerarquía mal aplicada | Un `AGENTS.md` anidado contradice al de la raíz sin ser un error, sino el diseño. |

**Confianza:** alta si tienes las dos cita textuales con su ubicación; baja si una la estás
interpretando.

**Acción:** resolver por precedencia, corregir la fuente que pierde. Si involucra una plataforma
externa, la confirmación del usuario es obligatoria, aunque el código tenga la razón.

## FALTANTE

*El proyecto tiene algo que nadie documentó.*

El hallazgo más valioso de los tres, porque no hay contradicción que delate: nadie se queja de
lo que no está escrito, simplemente se tropieza con ello.

| Qué | Ejemplo |
|---|---|
| Regla solo en la cabeza de alguien | El cálculo de descuentos tiene una regla que no está en ningún sitio. |
| Script que hay que ejecutar a mano | Un `scripts/migrate.sh` sin documentar y necesario para levantar el entorno. |
| Trampa conocida | `npm run dev` falla en Windows por un bug conocido; nadie lo escribió. |
| Requisito no obvio | El proyecto necesita una versión mínima de Node o un servicio externo para funcionar. |
| Archivo que no se debe tocar | Generado por un script; editarlo a mano se pierde. |
| Glosario | Siglas internas sin expansions. |

**Confianza:** alta si lo dedujiste del comportamiento del código; media si solo lo sugiere la
estructura.

**Acción:** generar el contenido desde las plantillas. No inventes el valor: si la regla de
negocio exacta no se puede deducir, se registra como `PREGUNTAR` y se pregunta.

## SOBRANTE

*El contexto dice algo que ya no aplica.*

El más traicionero de los cuatro, porque "no aplica" y "no debo tocarlo" se parecen mucho.

| Qué | Ejemplo |
|---|---|
| Sección obsoleta | "Migración a Postgres: pendiente" cuando la migración se completó hace un año. |
| Feature retirada | La doc describe cómo usar una opción que se eliminó del CLI. |
| Proceso caduco | "Los releases se hacen manualmente" cuando ahora hay un workflow. |
| Advertencia resuelta | "No edites `schema.sql` a mano" cuando ya es generado y no existe el archivo. |

**Confianza:** alta si confirmaste que el sujeto ya no existe; media si solo parece antiguo.

**Acción: reportar, nunca borrar.** Y la razón no es solo el límite duro de no destruir
contenido: hay una razón sustantiva. Un comando de deploy que ya no se usa es un **registro de
que existió una capacidad**, y ese registro a veces importa. Y si el juicio de "sobrante" está
equivocado, borrar es la única acción de toda la skill que no se puede deshacer con `git revert`
porque también habrías borrado el contexto que explicaba la decisión.

Propón dos cosas y deja que elija: **marcarlo como histórico** (`> Obsoleto desde <fecha> —
el comando era X`) o **eliminarlo**. No apliques ninguna sin confirmación.

## El quinto tipo que no está en la lista

A veces el hallazgo es "esto contradice a un sistema externo que no puedo leer". No lo fuerces
en uno de los cuatro: repórtalo como **no verificable** con la plataforma concreta nombrada. Es
información útil y evita que el informe dé una confianza que no se tiene.
