# Archlinux-JAGEX-LAUNCHER-WRAPPER

Una pequeña herramienta que ayuda a optimizar el uso de la GPU y a utilizar **gamemode** en Arch Linux al ejecutar el Jagex Launcher.

## ¿Qué es esto?

Este proyecto es un wrapper del repositorio [com.jagexlauncher.JagexLauncher](https://github.com/nmlynch94/com.jagexlauncher.JagexLauncher). Su objetivo es mejorar la experiencia de juego en Arch Linux mediante:

- **Optimización de GPU**: configura las variables de entorno necesarias para aprovechar al máximo la tarjeta gráfica (NVIDIA, AMD o Intel).
- **Gamemode**: integra [gamemode](https://github.com/FeralInteractive/gamemode) para que el sistema aplique automáticamente optimizaciones de rendimiento mientras el juego está en ejecución.

## Requisitos

- Arch Linux (o derivados)
- [com.jagexlauncher.JagexLauncher](https://github.com/nmlynch94/com.jagexlauncher.JagexLauncher) instalado
- `gamemode` instalado (`sudo pacman -S gamemode`)
- Drivers de GPU correctamente instalados

## Uso

Ejecuta el script en lugar del lanzador original para que las optimizaciones se apliquen automáticamente:

```bash
./jagex-launcher-wrapper.sh
```

## Licencia

Consulta el archivo [LICENSE](LICENSE) para más información.
