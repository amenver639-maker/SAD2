# Trabajar con Codex en Entornos de Desarrollo

## Qué se instala y por qué

Esta configuración adapta los ejemplos compartidos al proyecto real: conserva
las reglas docentes del sitio de referencia y la separación entre reglas generales,
skills y scripts de los otros proyectos. No copia su configuración de OpenCode,
sus rutas Linux ni herramientas para Moodle/Classroom que aquí no hacen falta.

Empezamos con un agente y dos skills, no con varios agentes independientes.
Una skill es un procedimiento reutilizable; AGENTS.md contiene las reglas comunes.

```text
entornosdesarrollo/
├── AGENTS.md
├── .codex/config.toml
├── .agents/skills/
│   ├── editar-material-dam-daw/SKILL.md
│   └── mantener-mkdocs-pages/SKILL.md
├── scripts/
│   ├── Iniciar-Codex.ps1
│   ├── Configurar-Cuenta.ps1
│   └── Comprobar-Sitio.ps1
├── GUIA_CODEX.md
├── GUIA_GITHUB.md
├── docs/                         (ya existente)
├── mkdocs.yml                    (ya existente)
└── .github/workflows/pages.yml   (ya existente)
```

No necesitas un fichero adicional para registrar skills: Codex descubre sus nombres
y descripciones en `.agents/skills/`. El índice de AGENTS.md sirve para entenderlas.
La configuración local solo se carga si el proyecto es de confianza.
Fuentes: [skills](https://learn.chatgpt.com/docs/build-skills) y
[configuración de Codex](https://learn.chatgpt.com/docs/config-file/config-basic).

## 1. Añadir los archivos

1. Sal de la sesión actual de Codex con `/exit`.
2. Antes de copiar o modificar archivos, comprueba la rama y los cambios pendientes
   con `git branch --show-current` y `git status --short`. Crea una rama específica
   con `git switch -c chore/configurar-flujo-codex`, o continúa en ella si esta tarea
   ya está en curso. No trabajes directamente en `main` ni descartes cambios existentes.
3. Extrae el ZIP nuevo en una carpeta temporal. Copia su contenido dentro de
   `C:\Projects\entornosdesarrollo`, sin crear otra carpeta intermedia.
4. Incluye las carpetas `.codex` y `.agents`. Si ya existe cualquiera de estos archivos,
   compara y combina su contenido; no lo sobrescribas sin revisar.
5. Si habías añadido la skill antigua `maintain-mkdocs-course` del primer paquete,
   retírala del proyecto tras comprobar que no contiene cambios tuyos: esta versión
   la sustituye con dos skills. No hace falta instalar el paquete antiguo primero.

El paquete no reemplaza tus apuntes, README, dependencias ni workflow y no contiene
claves ni credenciales. Añade opcionalmente al README existente:

```markdown
## Trabajo con Codex

Consulta [la guía de Codex](GUIA_CODEX.md) y [la configuración de cuentas](GUIA_GITHUB.md).
```

## 2. Preparar el proyecto y la cuenta

En PowerShell:

```powershell
Set-Location C:\Projects\entornosdesarrollo
git branch --show-current
git status --short
.\.venv\Scripts\python.exe --version
.\.venv\Scripts\python.exe -m mkdocs --version
```

Si `.venv` ya funciona, no lo recrees. Solo si falta, utiliza el Python que tienes
instalado para crearlo y luego instala las dependencias dentro de él:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

No necesitas bajar a Python 3.13 para añadir esta configuración. En este proyecto
la compilación local ya había funcionado con Python 3.14. El workflow usa 3.12:
conviene revisar esa diferencia si aparece un problema de compatibilidad; este
paquete no cambia ninguna versión automáticamente.

Completa después `GUIA_GITHUB.md`: identidad local, clave SSH y cuenta esperada.
La autenticación adicional de GitHub CLI es opcional para editar/compilar, pero
necesaria para que Codex consulte Actions o gestione PR mediante `gh`.

## 3. Iniciar Codex

```powershell
.\scripts\Iniciar-Codex.ps1 -Diagnostico
.\scripts\Iniciar-Codex.ps1
```

El diagnóstico muestra la selección local, no certifica la autenticación remota.
El iniciador selecciona el perfil de GitHub CLI del repositorio para esa sesión.
No cambia la sesión de ChatGPT y restaura las variables de la terminal al terminar.
Funciona para trabajo local sin conexión y sin `gh`; antes de operaciones remotas
el agente comprobará el usuario autenticado.

Si Windows bloquea los scripts descargados, revisa primero su contenido. Después
puedes desbloquear únicamente estos tres archivos, sin cambiar la política global:

```powershell
Unblock-File .\scripts\Iniciar-Codex.ps1
Unblock-File .\scripts\Configurar-Cuenta.ps1
Unblock-File .\scripts\Comprobar-Sitio.ps1
```

Una política administrada por el centro puede seguir restringiendo scripts; no la
eludas. En ese caso se puede trabajar con `codex` y los comandos de validación
directos, dejando las operaciones de GitHub pendientes de configurar la sesión.

Dentro de Codex usa `/skills` para ver si aparecen las dos skills. Si no aparecen,
comprueba la estructura y reinicia desde la raíz. Revisa `/status` y los permisos;
las reglas de AGENTS.md orientan al agente, no sustituyen las protecciones del entorno.

## 4. Primera sesión recomendada

Pega esto dentro de Codex, no en PowerShell:

> Lee AGENTS.md y enumera las skills del proyecto. Revisa el estado de Git,
> mkdocs.yml y el workflow. Comprueba la compilación y diagnostica por qué
> docs/1_intro.md solo muestra contenido pendiente. No modifiques archivos fuente,
> no hagas commits ni publiques. Distingue material recuperable de material que
> habría que redactar nuevo.

La compilación sí generará o actualizará `site/`, que es salida local ignorada.
Después decide si quieres recuperar la introducción o redactarla de nuevo.

## 5. Trabajo habitual

Para crear o mejorar contenido, por ejemplo:

> Lee AGENTS.md y comprueba la rama y los cambios pendientes. Crea una rama para
> esta tarea antes de editar, o continúa en la suya si ya existe. Conserva el trabajo
> existente. Usa $editar-material-dam-daw para revisar la práctica indicada. Mejora
> la claridad para 1º DAM/DAW, conserva su nombre y enlaces, y valida los cambios.
> Presenta un resumen para revisión. No hagas commit, push ni fusiones.

Para un problema técnico:

> Lee AGENTS.md y comprueba la rama y los cambios pendientes. Trabaja en una rama
> específica y conserva los cambios existentes. Usa $mantener-mkdocs-pages para
> corregir este enlace roto. Limita el cambio a su causa y comprueba la compilación.
> Presenta un resumen para revisión. No hagas commit, push ni fusiones.

Para previsualizar desde otra terminal:

```powershell
Set-Location C:\Projects\entornosdesarrollo
.\.venv\Scripts\python.exe -m mkdocs serve
```

Abre la dirección que indique la terminal. Para la comprobación final:

```powershell
.\scripts\Comprobar-Sitio.ps1
git diff --check
git diff
```

Revisa el resumen, el diff y los archivos nuevos; si afecta a la web, revisa también
contenido y apariencia. Las correcciones de la misma tarea continúan en su rama.
Para autorizar únicamente el commit y la subida de esa rama, puedes pedir:

> Comprueba la identidad del proyecto, la rama, el destino y el diff. Crea un commit
> solo con los cambios de esta tarea y sube la rama de la tarea. No fusiones con
> main, no publiques ni elimines la rama. No incluyas cambios ajenos.

Esa petición autoriza commit y push de la rama; no autoriza fusión ni publicación.
Después de revisar la rama, puedes autorizar expresamente la integración y publicación:

> Apruebo la fusión de la rama de esta tarea en main y su publicación. Comprueba
> identidad, destino y validaciones, integra los cambios aprobados y sube main.
> Verifica Actions y la página afectada. No elimines la rama.

Cada autorización se aplica solo a su alcance; no hace falta repetir una confirmación
ya concedida. Sin autorización expresa no se hace commit, push ni fusión. Solo tras
aprobar la fusión se integra en `main` y se publica. Eliminar ramas locales o remotas
requiere permiso adicional. No publiques material sensible, soluciones reservadas
o datos de alumnos.

## 6. Qué se automatiza

Codex ayuda a editar y comprobar. Al subir cambios a `main`, GitHub
Actions instala dependencias, construye la web y publica el artefacto. No hay que
subir `site/` ni mantener otro repositorio de HTML. No se publica por guardar un
archivo local ni al subir la rama de una tarea. La ejecución manual del workflow
también publica y requiere autorización de publicación tras aprobar la fusión.

Conserva Python/MkDocs en tu PC para previsualizar y validar. El despliegue remoto
tiene su propio entorno. No afirmes que una publicación funciona solo porque la
compilación local no dio errores.

Los archivos de configuración del agente pueden versionarse con el proyecto.
Los ajustes locales de cuenta y las claves NO viajan al clonar: cada ordenador
debe repetir la preparación de `GUIA_GITHUB.md`.
