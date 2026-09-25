# Qué cuenta como contexto

Antes de decidir si algo está desactualizado, hay que decidir si es contexto. No todo lo que
un equipo escribe es contexto del proyecto, y meter en el informe los changelogs y los
licenses infla el trabajo y esconde lo que importa.

## La prueba de tres preguntas

Un archivo es contexto si cumple **al menos dos** de estas tres:

1. **Alguien nuevo lo necesita** para hacer su primer cambio sin atascarse.
2. **Cambia con el proyecto**, no con el calendario.
3. **Describirlo aquí cuesta más que deducirlo del código.**

La tercera es la que más descarta. Si la información se lee en dos minutos mirando el repo,
documentarla es mantenimiento puro: alguien tiene que actualizarla cada vez que cambie, y es una
fuente más de contradicciones. La jerarquía de instrucciones de un framework, el árbol de
dependencias, la configuración de un linter que se deduce del archivo de config: todo eso es
ruido.

## Sí es contexto

- **Convenciones** — cómo se escribe código aquí. Nombres, imports, estilo, idioma de los
  mensajes de error.
- **Comandos de verificación** — cómo se comprueba que algo funciona. Tests, lint, typecheck.
  Especialmente si no son los obvios del framework.
- **Arquitectura** — qué hace cada módulo y por qué están separados así.
- **Decisiones con su porqué** — sobre todo lo contraintuitivo. "Usamos polling y no WebSocket
  porque el servidor es single-threaded y no queríamos otro proceso."
- **Glosario** — qué significa `Pedido`, `Reserva`, `Draft` en *este* negocio. Nadie más puede
  deducirlo.
- **Trampas conocidas** — lo que parece un bug pero es intencional.
- **Onboarding** — el camino de la primera vez.

## No es contexto

| Qué | Por qué no |
|---|---|
| `CHANGELOG.md` | Documenta el pasado, no el presente. Se desactualiza solo y no se consulta para cambiar código. |
| Historial de git | Ya está en `git log`, con más detalle y con autoría. Re-documentarlo es trabajo sin valor. |
| Licencias, guías de contribución, plantillas de PR | Boilerplate. No cambia con el proyecto. |
| Documentación de la librería que usas | Ya está upstream y se actualiza sola. Copiarla al repo la convierte en una copia desactualizada. |
| Diagramas sin fuente | Un `.png` de arquitectura sin el archivo que lo genera no se puede mantener; la primera actualización lo vuelve falso. |
| El código mismo | Es contexto de facto, pero no es *documentación*. No se corrige ni se "actualiza": es la fuente de verdad. |
| Conversaciones de Slack/Notion sin export | Existen pero no son contexto del repositorio: no se versionan y no sobreviven a quien las escribió. Señalarlas como FALTANTE es legítimo. |

## El criterio difícil: intención sin evidencia

A veces lo que hay que documentar no está en ningún archivo: está en la cabeza del equipo.

> El código dice `if (user.role === 'admin')`. Nadie escribió *por qué* existe un rol `admin`
> además del sistema de permisos, ni cuándo se puede eliminar.

Eso es un hueco FALTANTE real. Pero el hallazgo honesto dice "no encontré respaldo documental
para X", no "la intención probablemente era Y". La diferencia importa: la primera frase
pregunta algo que alguien del equipo sabe; la segunda mete una suposición en el repo y la
convierte en deuda.

## Un archivo que cuenta como contexto, no como regla

El `README.md` suele ser una **puerta**, no una fuente de reglas. Apunta a otros documentos en
lugar de dictar convenciones. La diferencia importa al detectar contradicciones: si el README
y el `AGENTS.md` discrepan, probablemente el README es una descripción general desactualizada y
el `AGENTS.md` manda, no al revés. Clasifica el rol de cada archivo (`onboarding`, `convenciones`,
`mapa`, `decisiones`) en el inventario, y deja que la precedencia use ese rol.
