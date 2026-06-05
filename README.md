# Arch Linux Jagex Launcher | ALPHA 0.1 (EXPERIMENTAL)

[![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-blue?logo=arch-linux)](https://archlinux.org/)
[![GameMode](https://img.shields.io/badge/Performance-GameMode-orange)](https://github.com/FeralInteractive/gamemode)
[![Flatpak](https://img.shields.io/badge/Sandbox-Flatpak-purple)](https://flatpak.org/)

Un script de automatización idempotente diseñado para instalar, aislar y optimizar el entorno de ejecución del **Jagex Launcher (Flatpak)** en Arch Linux. Este wrapper modifica dinámicamente el comportamiento del sistema operativo a nivel de kernel para exprimir el rendimiento del hardware y maximizar la tasa de cuadros por segundo (FPS) mientras juegas, restaurando el estado original del sistema inmediatamente al cerrar la sesión. 

Además, este script **NO realiza ninguna modificación, inyección ni alteración en los archivos internos del juego ni en su ejecutable**. Su único propósito es optimizar la asignación de recursos del sistema anfitrión (CPU, GPU y gestión de memoria) para garantizar una tasa de FPS más fluida y estable, siendo completamente seguro y respetuoso con las políticas del juego. 

Instalador Laucher (flatpak) por [nmlynch94](https://github.com/nmlynch94/com.jagexlauncher.JagexLauncher).

## ⚠️ Aviso Importante (Uso bajo discreción)

> **PRECAUCIÓN:** Este script es actualmente un **side project** personal y se encuentra en fase de desarrollo. **Aún no se han realizado todas las pruebas exhaustivas y necesarias** en diferentes entornos y configuraciones de hardware. (Únicamente probado en Hardware AMD).
>
> Úsalo **bajo tu propia discreción y riesgo**. Se recomienda revisar el código fuente antes de ejecutarlo para asegurarte de que es compatible con las necesidades y la configuración actual de tu sistema Arch Linux.


## 🛠 Requisitos Previos

* Sistema operativo basado en **Arch Linux**.
* Tener configurado `sudo` para el usuario que ejecuta el script (requerido para la configuración inicial de Polkit y pacman).

## 📥 Instalación y Uso Rápido

Puedes ejecutar la suite de optimización directamente con el siguiente comando:

```bash
curl -sSL https://raw.githubusercontent.com/NeTenebraes/Archlinux-JAGEX-LAUNCHER-WRAPPER/main/jagex.sh | bash
```

---

## 🚀 ¿Qué hace exactamente este script?

Desglose técnico de las modificaciones que realiza el script en tu sistema:

### 1. Gestión de Dependencias e Instalación
* Instala de forma segura los paquetes críticos vía `pacman`: `flatpak`, `gamemode`, `cpupower`, `curl` y `libnotify`.
* Detecta si el flatpak de Jagex ya existe; si no, automatiza su instalación utilizando el [repositorio base de nmlynch94](https://github.com/nmlynch94/com.jagexlauncher.JagexLauncher).

### 2. Rompiendo el Sandbox (Flatpak Overrides)
Los Flatpaks están aislados por defecto. El script inyecta overrides a nivel de usuario para permitir que el juego se comunique con el sistema operativo:
* Fuerza la precarga de `libgamemodeauto.so.0` dentro del contenedor.
* Permite la comunicación por DBus con el demonio de **GameMode** y el servidor de **Notificaciones** del sistema de ventanas.

### 3. Ajustes Dinámicos de Rendimiento (`/etc/gamemode.ini`)
Configura GameMode para ejecutar tareas específicas en el ciclo de vida del juego:
* **Al Iniciar el Juego:** Cambia el gobernador de la CPU a `performance`, eleva el nivel de energía de las GPUs AMD a `high`, **mata el proceso de MEGAsync** (para mitigar picos de lag por sincronización de red/disco) y reduce el `swappiness` a `10` para priorizar la memoria RAM/zRAM y evitar el uso de swap en disco.
* **Al Cerrar el Juego:** Devuelve la CPU al gobernador `schedutil`, cambia el `swappiness` de Linux a `60` y vuelve a levantar **MEGAsync** en segundo plano.

> 💡 **Nota sobre MEGASync:** Este script **NO instala MEGASync**. La integración está diseñada para optimizar el rendimiento deteniendo su consumo de CPU/red mientras juegas si ya lo usas en tu día a día. Si **no** utilizas MEGASync, el script funcionará exactamente igual de forma segura, ignorando de manera silenciosa las directivas de control del proceso sin afectar en nada a tu sistema.

### 4. Elevación de Privilegios Segura sin Contraseñas (Polkit)
Modificar parámetros del sistema (`cpupower` y `sysctl`) para evitar que una ventana emergente de `sudo` o `pkexec` interrumpa la carga de tu juego a mitad de camino exigiendo tus credenciales (requiere root).
* **Creación de Entorno Privilegiado:** El script valida la existencia del grupo de sistema `gamemode` y añade automáticamente a tu usuario local a dicho grupo.
* **Inyección de Regla JavaScript para Polkit:** Genera el archivo `/etc/polkit-1/rules.d/10-gamemode.rules`. Esta regla actúa como un bypass de seguridad selectivo: autoriza al demonio Polkit a validar y ejecutar de forma transparente y automatizada los comandos específicos de optimización de hardware invocados por `gamemode`, **únicamente** si el usuario que los ejecuta pertenece al grupo autorizado, manteniendo el resto del sistema completamente protegido.

### 5. Inyección en el Entorno de Escritorio
* Modifica tu archivo local `.desktop` (`~/.local/share/applications/...`) anteponiendo el prefijo `gamemoderun` a la directiva `Exec=`, asegurando que el juego siempre se optimice sin importar si lo lanzas desde la terminal, dmenu/rofi o tu launcher de aplicaciones.

## 🔁 ¿Tengo que ejecutar este script cada vez que vaya a jugar?

**No. El script solo se ejecuta UNA VEZ.**

Está diseñado como una herramienta de aprovisionamiento e instalación inicial. Una vez completado el proceso y tras haber reiniciado tu sesión para aplicar los permisos de grupo:

1. **Automatización en segundo plano:** El archivo `.desktop` de tu sistema ya queda modificado de forma permanente para anteponer `gamemoderun`.
2. **Carga transparente:** Puedes abrir el Jagex Launcher directamente desde tu menú de aplicaciones, dmenu/rofi o interfaz gráfica habitual. 
3. **Disparador automático:** Al lanzar el juego, el demonio de **GameMode** detectará la ejecución e inyectará los perfiles de hardware, modificará el `swappiness` y gestionará el proceso de MEGASync por sí solo, revirtiendo todo al cerrarlo sin necesidad de volver a tocar este script.

## 🔒 Seguridad: ¿Cómo funciona el bypass con `pkexec`?

Cuando un script necesita cambiar perfiles de hardware (como el gobernador de la CPU) o parámetros del núcleo (como `vm.swappiness`), tradicionalmente requiere el uso de `sudo`. El problema de usar `sudo` dentro de herramientas de automatización como **GameMode** es que requiere que el usuario ingrese su contraseña manualmente en la terminal, lo cual rompe la experiencia fluida al lanzar un juego desde interfaces gráficas o entornos de escritorio.

Para resolver esto, este script implementa **Polkit (PolicyKit)** y el comando `pkexec`.

### El Rol de `pkexec` y Polkit
A diferencia de `sudo`, que otorga privilegios totales de `root` a todo un script o comando a nivel de terminal, `pkexec` es la herramienta de Polkit diseñada para ejecutar un binario específico con privilegios elevados basados en **reglas de políticas declarativas**.

El script define una política estricta en `/etc/polkit-1/rules.d/10-gamemode.rules` que funciona bajo el principio de **privilegio mínimo**:

1. **Aislamiento por Grupo:** Solo los usuarios que pertenezcan explícitamente al grupo de sistema `gamemode` pueden beneficiarse de esta regla.
2. **Restricción de Binarios:** La regla no otorga acceso libre a `root`. Únicamente permite la ejecución sin contraseña de las acciones asociadas a:
   * El cambio de parámetros del kernel a través del subsistema de Polkit (`org.freedesktop.policykit.exec`).
   * La gestión de perfiles de energía de la CPU a través de Arch Linux (`org.archlinux.pkexec.cpupower`).

### ¿Por qué es este enfoque más seguro?
* **Sin elevación ciega:** El Jagex Launcher y el sandbox de Flatpak siguen ejecutándose bajo los privilegios de tu usuario local estándar. Ningún proceso del juego obtiene acceso de superusuario.
* **Sin Hardcoding de contraseñas:** No hay necesidad de almacenar contraseñas en texto plano ni de alterar el archivo `/etc/sudoers` de forma masiva (lo cual podría dejar una brecha abierta para que cualquier script ejecute cualquier comando como root).
* **Supervisión del Demonio:** Es el propio demonio de Polkit del sistema operativo el que intercepta las llamadas de GameMode, valida que tu usuario sea miembro del grupo autorizado y aplica estrictamente los cambios limitados a la CPU y la zRAM, cerrando la ventana de privilegios inmediatamente después de terminar la tarea.
