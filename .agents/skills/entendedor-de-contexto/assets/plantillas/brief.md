# Brief de contexto — <NOMBRE_DEL_PROYECTO>

> Generado por la skill `entendedor-de-contexto`. Contexto del equipo: se commitea al repo.
> Última revisión: `<fecha>`. Modo de generación: `<usuario | auto>`.
>
> Todas las afirmaciones de aquí son verificables contra el código. Cuando una afirmación
> venga de un documento del repo y no se haya podido confirmar en el código, está marcada
> como `[no verificado]`. Esa marca es deliberada: mejor una duda visible que una certeza
> falsa.

## Qué es este proyecto

<Dos o tres frases. Qué resuelve, para quién, y qué tipo de software es. Si el README lo dice
en una línea y es cierto, esa línea es la respuesta. Si el README no lo dice o miente, escribe
lo que se deduce del código y marca `[no verificado]` lo que no se pudo confirmar.>

## Cómo se ejecuta

```bash
<comando de desarrollo>
<comando de build>
<comando de preview / producción>
<comando de test>
<comando de lint / typecheck>
```

| Acción | Comando | Notas |
|---|---|---|
| Instalar | `<npm i>` | <requiere Node X, o lo que aplique> |
| Desarrollo | `<npm run dev>` | <puerto, URL> |
| Build | `<npm run build>` | <genera dist/, no se commitea> |
| Verificar | `<npm run build>` | <el comando que de verdad detecta errores aquí> |

> Si la tabla tiene una sola fila en "Notas", casi con seguridad el comando no tiene nota
> especial. Y si falta la fila de "Verificar", es un hueco FALTANTE de prioridad alta: un
> proyecto sin comando de verificación declarado es un proyecto donde nadie sabe si rompió
> algo.

## Estructura y entry points

```
<árbol de carpetas, 2-3 niveles, solo lo que significa algo>
```

**Entry points:**

| Ruta | Rol | Por dónde entra el flujo |
|---|---|---|
| `<src/main.jsx>` | <monta la app> | <index.html → main.jsx> |
| `<src/App.jsx>` | <estado y carga de datos> | <importado por main.jsx> |

> Un árbol de 40 líneas con los `package.json` de un monorepo no ayuda a nadie. Si el
> proyecto tiene frontends, backends y workers, una tabla por parte vale más que un `tree`
> recursivo completo.

## Convenciones de código

- <nombres, imports, estilo>
- <idioma de los mensajes, comentarios y strings>
- <qué framework o librería se usa y cuál explícitamente no>

> Se derivan de lo que el código hace de forma consistente, no de lo que un documento dice.
> Si el documento y el código discrepan, el código va en el brief y el documento aparece en el
> informe de inconsistencias.

## Comandos de verificación

Antes de dar por hecho que algo funciona:

```bash
<los comandos que de verdad pasan en este repo>
```

> Estos son los obligatorios. Los que existen pero no se ejecutan nunca (lint sin integrate,
> typecheck roto) se listan aparte como *conocidos pero no fiables*, con la razón.

## Glosario

| Término | Significa |
|---|---|
| `<Pedido>` | <borrador hasta que se confirma> |

> Solo términos propios del negocio o del dominio. Los nombres de funciones, clases y
> variables no van aquí: se deducen leyendo el código. Esto es lo que **no** se puede deducir,
> y por eso tiene valor.

## Trampas conocidas

- <lo que parece un bug pero es intencional, y por qué>
- <el comando que falla de forma confusa, y cuál es la causa real>
- <el archivo que parece fuente pero es generado>

> Si no hay ninguna, escribe "Ninguna documentada". Es información: significa que nadie ha
> encontrado ninguna, no que no exista ninguna.

## Qué NO está documentado

Lo que un recién llegado **no puede deducir** del código. Esta es la sección más útil del
brief y la que más se omite, porque documentar lo que falta se siente como no hacer nada.

- [ ] <regla de negocio sin respaldo en el código ni en ningún archivo>
- [ ] <script necesario para levantar el entorno, que nadie menciona>
- [ ] <requisito no obvio: versión mínima, servicio externo, credencial>
- [ ] <por qué existe un módulo que parece no usarse>

> No rellenes los huecos con suposiciones. Si un hueco es de decisión de negocio, déjalo como
> pregunta abierta y ponlo en el informe de la Fase 4.3. Es preferible un brief con huecos
> honestos que uno completo con datos fabricados.

## Origen de este brief

| Fuente | Tipo | Estado |
|---|---|---|
| `<AGENTS.md>` | convenciones | <al día / desactualizado en N cosas> |
| `<README.md>` | onboarding | <...> |
| `<código>` | ejecutable | <fuente de verdad> |
