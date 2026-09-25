# Reglas de sesión — <PROYECTO>

> Esto se devuelve **en el chat**, no se escribe en ningún archivo. El objetivo es que el
> contexto esté en esta sesión y no archivado donde nadie lo vuelva a leer. Si el usuario
> quiere que persista, ya se guardó en `.contexto/brief.md`.

## Cómo trabajo en este proyecto

- Stack: <lo que sea, en una línea>.
- Entry point: `<ruta>`. El flujo entra por `<ruta>`.
- El estado de la aplicación vive en `<ruta>`. Las props viajan hacia abajo, los callbacks hacia
  arriba. No introduzcas un patrón de gestión de estado nuevo sin decirlo.

## Convenciones que se respetan al escribir código

- <estilo: comillas, punto y coma, indentación, idioma de los strings>
- <nombres: PascalCase para componentes, camelCase para funciones>
- <lo que siempre se hace y lo que nunca se hace>
- Formato de commits: `<idioma, imperativo, corto>`.

## Archivos que no toco

| Archivo / carpeta | Por qué |
|---|---|
| `<dist/>` | Generado por el build. |
| `<package-lock.json>` | Se regenera, no se edita a mano. |
| `<archivo concreto>` | <generado por script / propiedad de otro equipo / migración> |

> No uses `.gitignore` como atajo para saber esto: un archivo ignorado puede ser código real
> que alguien necesita. Esta tabla es la que vale.

## Verificación obligatoria

Antes de decir que algo funciona:

```bash
<el comando que de verdad detecta errores en este proyecto>
```

- <prueba concreta> — <qué cubre>.
- <otro comando> — <qué cubre>.

> Ejecuta estos comandos, no "los de siempre". Si un comando de la lista está roto, dilo en el
> informe en lugar de saltártelo en silencio: un comando que no funciona y no se reporta es
> peor que no tenerlo.

## Glosario

| Término | Significa |
|---|---|
| `<término>` | <significado en este dominio> |

## Lo que no está documentado

- `<hueco que descubrí>` — <por qué importa>.
- Pregunta abierta: <lo que solo alguien del equipo puede responder>.

> No hay que resolver estos huecos para trabajar. Se listan para que sepamos qué no sabemos, y
> eso ya es progreso.
