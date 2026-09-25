# Rutas de contexto conocidas

Tabla de dónde suele esconderse el contexto de un proyecto y qué se espera encontrar en cada
sitio. No es exhaustiva a propósito: las rutas que nadie usa no sirven de mucho, y la
heurística por contenido (abajo) cubre el resto.

## Archivos en la raíz

| Ruta | Qué es realmente | Peso |
|---|---|---|
| `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` | Instrucciones para el agente. Convención de OpenAI / Anthropic / Google. | **Alto** — es lo que el agente ya lee solo |
| `CLAUDE.local.md` | Igual, pero personal, y se gitignora. | Alto para quien lo escribió, cero para el equipo |
| `.cursorrules` | Reglas para Cursor, YAML plano. | Medio — a menudo desactualizado frente al `AGENTS.md` |
| `.github/copilot-instructions.md` | Instrucciones para Copilot. | Medio |
| `README.md` | Qué es, cómo se corre, cómo se instala. | **Medio, no alto**: es el primero que se escribe y el último que se actualiza |
| `CONTRIBUTING.md` | Flujo de PR, estilo, pruebas. | Medio |
| `ARCHITECTURE.md` | Mapa del sistema. | Alto, si existe y está al día |
| `CHANGELOG.md` / `ROADMAP.md` | Historial y planes. Contexto de *intención*, no de *cómo funciona*. | Bajo como referencia técnica, alto para entender por qué algo existe |
| `CODEOWNERS` | Quién manda en cada ruta. Contexto de equipo. | Bajo |
| `skills-lock.json` | Qué skills están fijadas y de dónde salen. | Configuración |
| `opencode.json` / `opencode.jsonc` | Config del agente en el proyecto. | Configuración |
| `.mcp.json` | Servidores MCP declarados. **Declarados, no necesariamente conectados.** | Configuración |

## Carpetas

| Ruta | Contenido esperado |
|---|---|
| `.context/`, `.contexto/`, `context/` | Contexto estructurado. Si aparece `.contexto/estado.json`, es el resultado de esta misma skill. |
| `docs/` | Documentación general. Contenido mixto: a veces mapa, a veces historial, a veces notas sueltas. |
| `doc/` | Lo mismo, en español o francés. |
| `docs/adr/`, `docs/decisions/`, `adr/` | Decisiones con contexto. **Valor alto**: un ADR explica el porqué, que es justo lo que el código no puede decir. |
| `docs/architecture/`, `docs/runbooks/` | Mapa del sistema y procedimientos. |
| `.cursor/rules/`, `.claude/`, `.codex/` | Configuración y reglas por directorio. |
| `.github/workflows/`, `.gitlab-ci.yml`, `azure-pipelines.yml` | Comandos de verificación **en código ejecutable**, no en prosa. Contradice a cualquier doc que diverja. |

## Jerarquía por cercanía — el detalle que se olvida

Los archivos de instrucciones **anidan por directorio**. Un `AGENTS.md` en `src/` aplica a
`src/` y a todo lo que cuelgue de ahí; uno en la raíz aplica al resto. Cuando existen varios, el
más cercano al archivo que vas a tocar gana.

Consecuencia práctica: cuando dos `AGENTS.md` se contradigan, **no es un error del repo, es el
diseño funcionando**. Se reporta la jerarquía en vez de elegir uno.

```
AGENTS.md           → reglas generales
src/AGENTS.md       → reglas de src/  (gana dentro de src/)
src/api/AGENTS.md   → reglas de src/api/ (gana dentro de src/api/)
```

## Heurísticas: cuando el nombre no delata

Los equipos que no adoptaron ninguna convención siguen documentando; solo que con nombres
propios. Busca en la raíz y en el primer nivel de subcarpetas:

`CONVENTIONS`, `GUIDELINES`, `STYLE`, `ONBOARDING`, `GETTING_STARTED`, `SETUP`, `INSTALL`,
`RUNBOOK`, `PLAYBOOK`, `CHEATSHEET`, `ARCHITECTURE`, `MAPA`, `STRUCTURE`, `SYSTEM`,
`DESIGN`, `DECISIONS`, `ADR`, `RFC`, `HANDOFF`, `NOTES`, `GLOSSARY`.

Y para los que no tienen nombre reconocible, el criterio de contenido: **lee el primer bloque**
(unas 40 líneas) de cualquier `.md` o `.txt` que no hayas descartado. Cuenta como contexto si
habla de:

- cómo se ejecuta o se construye el proyecto
- cómo está estructurado o qué hace cada módulo
- qué reglas hay que seguir al escribir código
- por qué se decidió algo
- a qué se referían siglas o nombres raros

Ese último caso es el que más valor tiene y el que más se pasa por alto: un `notas.txt` con
cinco líneas que dicen "ojo, `Pedido` significa borrador hasta que se confirma" es contexto
crítico disfrazado de archivo suelto.

## Lo que NO es contexto

Para no inflar el informe, aunque se encuentre en el repo:

- `LICENSE`, `CODE_OF_CONDUCT.md`, `.github/PULL_REQUEST_TEMPLATE.md` — boilerplate legal.
- `*.log` y cualquier lock salvo `package-lock.json` — generados.
- README traducido a seis idiomas, si el original está en inglés.
- Todo lo que esté dentro de un directorio ignorado por git. No está en el repo, no se
  sincroniza, no forma parte del contexto del equipo.
