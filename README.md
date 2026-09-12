# Entornos de Desarrollo — 1.º CFGS DAM/DAW

[![Publicar documentación](https://github.com/dcsibon/entornosdesarrollo/actions/workflows/pages.yml/badge.svg)](https://github.com/dcsibon/entornosdesarrollo/actions/workflows/pages.yml)

Apuntes, ejemplos y prácticas del módulo profesional de **Entornos de Desarrollo**
para el alumnado de primer curso de Desarrollo de Aplicaciones Multiplataforma
(DAM) y Desarrollo de Aplicaciones Web (DAW).

El material se mantiene en Markdown y se convierte en una web con **MkDocs Material**.
Este repositorio reúne las fuentes, los recursos y la automatización de publicación:
no es necesario mantener un segundo repositorio con el HTML generado.

- [Web del curso](https://dcsibon.github.io/entornosdesarrollo/)
- [Repositorio en GitHub](https://github.com/dcsibon/entornosdesarrollo)
- [Estado de las publicaciones](https://github.com/dcsibon/entornosdesarrollo/actions/workflows/pages.yml)

## Contenido del curso

La navegación organiza el material en estas unidades, que se van completando y revisando:

1. Introducción a los entornos de desarrollo.
2. Eclipse.
3. Git y GitHub.
4. Diagramas de clases UML.
5. Documentación con JavaDoc.
6. Pruebas del software.
7. Principios SOLID.
8. Prácticas del módulo.

Para consultar los apuntes basta con abrir la web. Los pasos siguientes son para
quien quiera mantener o ampliar el proyecto.

## Estructura del repositorio

```text
entornosdesarrollo/
├── docs/                  # Fuentes Markdown, imágenes y recursos de la web
├── mkdocs.yml             # Navegación y configuración de MkDocs Material
├── requirements.txt       # Dependencias de Python
├── .github/workflows/
│   └── pages.yml           # Construcción y despliegue en GitHub Pages
├── AGENTS.md              # Instrucciones generales para Codex
├── .codex/config.toml     # Configuración de Codex para el proyecto
├── .agents/skills/        # Procedimientos especializados del agente
├── scripts/               # Ayudas de PowerShell para cuentas, inicio y validación
├── GUIA_CODEX.md           # Guía detallada de trabajo con Codex
├── GUIA_GITHUB.md          # Preparación de cuentas GitHub y claves SSH
├── README.md              # Descripción y guía de entrada al proyecto
├── .venv/                 # Entorno Python local; ignorado por Git
└── site/                  # Web generada; ignorada por Git
```

`docs/` contiene lo que se publica. Las guías de mantenimiento de la raíz no se
incorporan automáticamente a la web del alumnado.

## Preparar el entorno local

### Requisitos

- Git y acceso al repositorio.
- Python para previsualizar y construir la web.
- PowerShell para los ejemplos y scripts de esta guía.
- Codex CLI, solo si se quiere trabajar con el agente.
- GitHub CLI (`gh`), opcional, para consultar Actions o gestionar PR desde la terminal.

El workflow actual utiliza Python 3.12. Si tu entorno local ya construye el sitio
correctamente, no necesitas recrearlo para usar este README. Ante un fallo que solo
ocurra en GitHub, compara primero las versiones de Python y las dependencias.

### Obtener el proyecto

Si ya tienes el clon, entra en él; no lo clones de nuevo:

```powershell
Set-Location C:\Projects\entornosdesarrollo
git status --short
```

En otro ordenador, con acceso SSH ya preparado:

```powershell
Set-Location C:\Projects
git clone git@github.com:dcsibon/entornosdesarrollo.git
Set-Location entornosdesarrollo
```

La carpeta `C:\Projects` es un ejemplo de ubicación; puedes elegir otra.

### Instalar las dependencias

Crea el entorno solo si no existe:

```powershell
py -m venv .venv
```

Instala las dependencias dentro de ese entorno:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

Los comandos usan directamente su Python, por lo que no es necesario activar
`.venv` ni instalar MkDocs globalmente.

## Ver y comprobar la web en local

Desde la raíz del proyecto:

```powershell
.\.venv\Scripts\python.exe -m mkdocs serve
```

Abre la dirección que muestre la terminal, normalmente [http://127.0.0.1:8000/](http://127.0.0.1:8000/).
Al guardar cambios, el servidor regenera la vista previa. Para detenerlo, pulsa `Ctrl+C`.

Antes de publicar, ejecuta en otra terminal:

```powershell
.\scripts\Comprobar-Sitio.ps1
git diff --check
git diff
```

La comprobación del sitio equivale a:

```powershell
.\.venv\Scripts\python.exe -m mkdocs build --strict
```

Revisa también las páginas modificadas en el navegador: una compilación correcta
no garantiza que todos los enlaces externos funcionen o que el diseño sea el esperado.

## Trabajar con Codex

La preparación completa está en la [guía de Codex](GUIA_CODEX.md).
El agente debe respetar las [instrucciones del proyecto](AGENTS.md).

### Seleccionar la cuenta del proyecto

Cada persona configura su cuenta y su clave SSH localmente siguiendo la
[guía de GitHub y SSH](GUIA_GITHUB.md). El README no debe contener correos personales,
perfiles privados ni rutas específicas del ordenador de un colaborador.

El script `Configurar-Cuenta.ps1` guarda la selección en la configuración local de
Git: no cambia otros repositorios, no transfiere su propiedad y no concede permisos
a otra cuenta. Si ya tienes una clave válida para la cuenta elegida, reutilízala.

Para no exponer tu correo personal en futuros commits, utiliza la dirección
`noreply` exacta que proporciona GitHub en los ajustes de correo de tu cuenta.
Consulta la [documentación de GitHub](https://docs.github.com/en/account-and-profile/how-tos/email-preferences/setting-your-commit-email-address).
Cambiarla ahora no modifica los metadatos de commits anteriores.

### Iniciar una sesión

```powershell
.\scripts\Iniciar-Codex.ps1 -Diagnostico
.\scripts\Iniciar-Codex.ps1
```

El diagnóstico muestra los ajustes locales; no prueba la autenticación remota.
El iniciador prepara el perfil de GitHub CLI correspondiente a la cuenta seleccionada.
Si también quieres usar `gh`, instálalo y autentica una vez ese perfil con:

```powershell
.\scripts\Iniciar-Codex.ps1 -LoginGitHub
```

Elige la cuenta indicada por la terminal y, al terminar, ejecuta de nuevo el iniciador
sin opciones. La autenticación de Git por SSH, la de GitHub CLI y la sesión de
ChatGPT son independientes.

### Skills y tareas habituales

El proyecto incluye dos skills en `.agents/skills/`:

- **`editar-material-dam-daw`**: redacción y revisión de apuntes y prácticas.
- **`mantener-mkdocs-pages`**: diagnóstico de navegación, construcción y publicación.

Puedes pedir dentro de Codex:

> Revisa AGENTS.md, la rama y el estado de Git. Crea una rama para esta tarea
> antes de editar, o continúa en la suya si ya existe. Usa $editar-material-dam-daw para mejorar
> la claridad de la práctica que te indique, conservando sus enlaces. Valida los
> cambios y presenta un resumen para revisión. No hagas commit, push ni fusiones.

O para un problema técnico:

> Usa $mantener-mkdocs-pages para diagnosticar este error. Explica la causa antes
> de modificar archivos.

Editar o validar no equivale a autorizar una publicación. Revisa el resultado antes
de pedir al agente que haga commit y push. Puedes trabajar también sin Codex,
editando Markdown y utilizando los mismos comandos de validación.

## Flujo habitual de trabajo y publicación

1. Comprueba el estado local y la rama actual. No descartes cambios pendientes ni
   mezcles tareas. No borres ni descartes trabajo existente.
2. Antes de modificar archivos, crea una rama específica desde `main` actualizado,
   por ejemplo `contenido/introduccion` o `docs/mejorar-readme`. Las revisiones de una
   misma tarea continúan en esa rama. No trabajes directamente sobre `main`.
3. Edita las fuentes, previsualiza la web y ejecuta las comprobaciones necesarias.
4. Revisa el diff, los archivos nuevos y la ausencia de datos personales o secretos.
5. Presenta el resultado para aprobación. Codex no debe hacer commit, push ni fusionar
   sin autorización expresa. Aprobar subir una rama no implica aprobar su fusión
   ni la publicación.
6. Si se autoriza el commit y la subida de la rama, comprueba primero la identidad
   y el destino, selecciona solo los archivos de la tarea y súbelos a esa rama.
   Mantén las correcciones de la revisión en ella, con las mismas reglas de autorización.
7. Solo después de aprobar expresamente la fusión, integra la rama en `main`.
   Si aparecen conflictos o cambios inesperados, detente y revísalos.
   Sube `main` cuando esté autorizada la publicación y comprueba Actions y la web.
   No elimines la rama sin permiso.

Estas reglas están recogidas en [AGENTS.md](AGENTS.md) para las sesiones del agente.
La configuración, las guías y el README siguen el mismo flujo por ramas que los apuntes.

Para una tarea nueva, comprueba primero la situación local:

```powershell
git branch --show-current
git status --short
```

Si estás en `main` y los cambios pendientes están identificados y se pueden conservar
sin mezclar tareas, crea la rama antes de editar:

```powershell
git switch -c docs/mejorar-readme
```

Si estás revisando esa misma tarea, continúa en su rama. No cambies de rama ni
actualices `main` si eso pone en riesgo trabajo pendiente.

El workflow [pages.yml](.github/workflows/pages.yml) se activa al recibir un push
en `main`, incluso cuando solo cambia el README. Instala las dependencias, construye
el sitio y despliega el artefacto en GitHub Pages. Subir una rama de tarea no activa
este workflow. También admite ejecución manual, sujeta a la autorización de
publicación y a la aprobación previa de la fusión.

Comprueba que la ejecución correspondiente a tu commit termina correctamente en
[Actions](https://github.com/dcsibon/entornosdesarrollo/actions/workflows/pages.yml)
y revisa después la web. Si el despliegue falla, consulta los registros antes de
dar por publicada la actualización.

**No edites ni subas `site/`.** Es una salida regenerable: las fuentes que se
versionan están en `docs/`. Guardar un archivo local no publica nada; enviar los
cambios a `main` sí activa la publicación automática.

## Criterios de mantenimiento

- Mantén un lenguaje claro y adecuado para alumnado de primer curso de FP.
- Conserva nombres de archivos y enlaces: algunos materiales están enlazados desde Moodle.
- Comprueba las mayúsculas de las rutas; la compilación de GitHub se ejecuta en Linux.
- No presentes contenido pendiente o recién redactado como si fuera material recuperado.
- No publiques información personal del alumnado ni materiales que deban permanecer reservados.
- No copies correos personales, credenciales ni rutas privadas a documentación,
  ejemplos, capturas o mensajes de commit. Usa ejemplos genéricos y configuración local.
- Mantén las claves, credenciales, `.venv/` y `site/` fuera del control de versiones.
- Conserva los cambios de otras personas y limita cada commit a una tarea comprensible.

Para ampliar la configuración, empieza por [GUIA_CODEX.md](GUIA_CODEX.md) y
[GUIA_GITHUB.md](GUIA_GITHUB.md), sin duplicar sus procedimientos en cada unidad del curso.
