# Configurar GitHub por proyecto

Esta guía es compartible: no contiene correos reales ni un inventario de cuentas
personales. Cada colaborador introduce sus datos en su terminal, fuera de los
archivos versionados del proyecto.

## Qué se configura

- **Autoría de commits:** nombre y correo en la configuración local de Git.
- **Acceso por SSH:** clave elegida para este clon mediante `core.sshCommand`.
- **Cuenta esperada:** `codex.githubUser`, etiqueta usada por los scripts del proyecto.
- **GitHub CLI:** perfil seleccionado por `Iniciar-Codex.ps1` para la sesión.

Estas capas son independientes de la sesión de ChatGPT. Cambiar la cuenta local
no cambia el propietario del repositorio ni concede permisos de acceso.

## 1. Elegir una clave existente

Si ya tienes una clave que autentica como la cuenta deseada, reutilízala. No hace
falta crearla de nuevo ni cambiar su nombre. Puedes listar solo los nombres:

```powershell
Get-ChildItem "$env:USERPROFILE\.ssh" -File | Select-Object Name
```

El archivo terminado en `.pub` es la clave pública. No muestres ni compartas el
contenido del archivo privado, que normalmente tiene el mismo nombre sin `.pub`.

Para una cuenta diferente, prepara una clave distinta y registra únicamente su
parte pública en esa cuenta. Si necesitas generar una, elige una ruta nueva,
comprueba que no exista y utiliza un comentario genérico, sin correo personal:

```powershell
$newKeyPath = Read-Host 'Ruta completa y nueva para la clave SSH'
if ([string]::IsNullOrWhiteSpace($newKeyPath)) { throw 'Falta la ruta' }
if ((Test-Path -LiteralPath $newKeyPath) -or (Test-Path -LiteralPath "$newKeyPath.pub")) {
    throw 'La ruta ya existe. No sobrescribas una clave existente.'
}
ssh-keygen -t ed25519 -C 'acceso-github' -f $newKeyPath
```

La carpeta de destino debe existir. Protege la clave con una frase de contraseña.
Añade el archivo `.pub` en **Settings → SSH and GPG keys** de la cuenta correcta.
Crear claves es opcional si ya dispones de una válida.

## 2. Proteger el correo de los commits

En GitHub, abre **Settings → Emails**, activa **Keep my email addresses private**
y copia la dirección `noreply` que te proporciona tu cuenta. No inventes su formato.
Para los commits locales, también debes configurar esa dirección en Git.

Consulta la [documentación oficial sobre el correo de commits](https://docs.github.com/en/account-and-profile/how-tos/email-preferences/setting-your-commit-email-address).
El cambio se aplica a nuevos commits: no elimina correos del historial anterior.
No reescribas el historial para limpiarlo sin evaluar el impacto y autorizarlo expresamente.

## 3. Asociar la cuenta al clon

Ejecuta desde la raíz del proyecto. Introduce los valores cuando la terminal los
pida; no sustituyas este ejemplo por tus datos reales en la guía:

```powershell
$projectUser = Read-Host 'Usuario de GitHub para este proyecto'
$projectCommitEmail = Read-Host 'Direccion noreply exacta proporcionada por GitHub'
$projectKey = Read-Host 'Ruta completa de tu clave SSH privada existente (sin .pub)'
ssh -T -i "$projectKey" -o IdentitiesOnly=yes git@github.com
```

Comprueba que el saludo identifica al usuario elegido. GitHub indica que no ofrece
acceso a una shell; ese mensaje es normal tras una autenticación correcta. Ante un
error, una cuenta distinta o una huella de host no verificada, detente y revísalo.

Solo después de verificar la cuenta:

```powershell
.\scripts\Configurar-Cuenta.ps1 -Usuario $projectUser -Correo $projectCommitEmail -ClaveSSH $projectKey
.\scripts\Iniciar-Codex.ps1 -Diagnostico
```

El script guarda los valores en `.git/config`, no en un archivo versionado. Esa
configuración no se copia al clonar el repositorio en otro ordenador. El diagnóstico
muestra los valores locales: evita compartir capturas o salidas sin revisarlas.

## 4. Trabajar con Codex y GitHub CLI

```powershell
.\scripts\Iniciar-Codex.ps1
```

Para editar y validar no es obligatorio tener GitHub CLI. Si necesitas gestionar
Actions o PR mediante `gh`, instala GitHub CLI y autentica el perfil una vez:

```powershell
.\scripts\Iniciar-Codex.ps1 -LoginGitHub
```

Elige la cuenta esperada en el navegador. Después inicia Codex sin opciones.
El script selecciona un perfil de GitHub CLI por usuario mediante `GH_CONFIG_DIR`
y el repositorio mediante `GH_REPO`. Restaura las variables al terminar la sesión.
Las terminales abiertas por separado no heredan esta selección.

El iniciador se detiene ante variables como `GH_TOKEN` o `GITHUB_TOKEN` que podrían
sustituir las credenciales elegidas. Revisa su procedencia sin compartir sus valores.
Antes de una operación remota, verifica la cuenta y el repositorio de destino.

## 5. Cambiar de cuenta

Sal de Codex, repite la selección local con los valores de la otra cuenta, verifica
su autenticación y vuelve a iniciar Codex. No hace falta editar esta guía ni cambiar
la configuración global de Git.

La nueva cuenta debe tener acceso al repositorio. Los cambios locales de identidad
afectan a las demás terminales que usen el mismo clon: no los cambies durante una
publicación en curso. Los commits anteriores conservan su autoría.

## Flujo por ramas y autorizaciones

Antes de empezar una tarea, comprueba:

```powershell
git branch --show-current
git status --short
```

Toda tarea que modifique archivos se realiza en una rama específica, nunca
directamente en `main`. Desde `main`, tras revisar los cambios pendientes, puedes
crear una rama con `git switch -c docs/actualizar-guia-github`. Conserva los archivos
copiados y el trabajo existente; no borres, descartes ni mezcles cambios ajenos.
Las correcciones de una misma tarea continúan en su rama.

Valida los cambios y presenta un resumen para revisión antes de pedir autorización.
No hagas commit, push ni fusiones sin autorización expresa. Antes de un commit
autorizado, comprueba `git var GIT_AUTHOR_IDENT` y selecciona archivos concretos.
Antes de un push autorizado, comprueba la rama, `git remote get-url --push origin`
y la autenticación SSH con la clave elegida, como se explica en el paso 3.
Si utilizas `gh`, comprueba además `gh api user --jq .login` y el repositorio de destino
en la sesión preparada por el iniciador. Detente si la cuenta no es la esperada.

Autorizar la subida de una rama no autoriza su fusión ni la publicación. Solo tras
aprobar expresamente la fusión se integra en `main`; la publicación posterior debe
estar dentro del alcance autorizado. Un push a `main` activa GitHub Pages, mientras
que subir la rama de una tarea no activa el workflow de publicación. La ejecución
manual también requiere autorización de publicación tras aprobar la fusión.
No elimines ramas locales ni remotas sin permiso, incluso después de integrarlas.

## Antes de publicar documentación

- Revisa contenido, ejemplos, archivos nuevos y diff en la rama de la tarea.
- No incluyas correos reales, claves, tokens, rutas privadas ni datos del alumnado.
- No guardes `.git/config`, carpetas de credenciales o copias de claves en el repositorio.
- No subas los ZIP de instalación ni copias antiguas de guías con datos personales.
- Las instrucciones compartidas deben ser genéricas; la selección personal vive en el PC.
- Fusionar y publicar requiere aprobación explícita según AGENTS.md.
