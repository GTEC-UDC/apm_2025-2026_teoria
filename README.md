# Arquitecturas y Plataformas Móviles — Diapositivas de teoría (Curso 2025/2026)

Diapositivas de teoría de la asignatura **Arquitecturas y Plataformas Móviles (APM)** del [Máster Universitario en Ingeniería Informática](https://estudos.udc.es/es/study/start/4523V01) de la [Universidade da Coruña](https://www.udc.es/) (UDC). Curso 2025/2026.

## Contenidos

| Tema | Título |
|------|--------|
| 02 | [Introducción a Kotlin](02-kotlin/) |
| 03 | [Ciclo de vida](03-ciclo_vida/) |
| 04 | [Navegación](04-navegacion/) |
| 05 | [Servicios, corrutinas, procesos y threads](05-servicios_corrutinas_procesos/) |
| 06 | [Geolocalización](06-geolocalizacion/) |
| 07 | [Almacenamiento](07-almacenamiento/) |
| 08 | [Usabilidad, UX y UI](08-ui_ux/) |
| 09 | Multimedia *(pendiente)* |
| 10 | Sensórica *(pendiente)* |

Cada tema está en su propio directorio e incluye:

- Un fichero `.typ` con el código fuente de las diapositivas.
- Un subdirectorio `images/` con los recursos gráficos utilizados.

## Requisitos

### Typst

Las diapositivas están escritas en [Typst](https://typst.app/). Puedes descargar el compilador desde su [página oficial](https://github.com/typst/typst/releases), o usar la extensión [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) de VS Code.

### Plantilla touying-gtec-simple

Las diapositivas usan el paquete [touying](https://typst.app/universe/package/touying/) con la plantilla [touying-gtec-simple](https://github.com/GTEC-UDC/touying-gtec-simple).

Esta plantilla no está publicada en el repositorio de paquetes de Typst, por lo que es necesario instalarla manualmente. Hay dos opciones:

1. **Instalación como paquete local** (recomendado): seguir las instrucciones del [README de la plantilla](https://github.com/GTEC-UDC/touying-gtec-simple) para instalarla en el directorio de paquetes locales de Typst. Véase también la [documentación de paquetes locales de Typst](https://github.com/typst/packages?tab=readme-ov-file#local-packages).

2. **Uso directo desde un directorio local**: clonar el repositorio de la plantilla y referenciarla desde el código. En este caso habría que modificar los comandos de importación de la plantilla.

## Skill

La plantilla `touying-gtec-simple` incluye una *skill* de Claude que facilita la creación de diapositivas con [Claude Code](https://claude.com/claude-code) u otras herramientas de IA compatibles con el formato de skills de Claude. Este repositorio incluye además una versión adaptada de dicha skill en [.claude/skills/touying-gtec-simple/](.claude/skills/touying-gtec-simple/).

## Licencia

Las diapositivas están licenciadas bajo [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Véase el fichero [LICENSE](LICENSE) para más detalles.

Algunas diapositivas reproducen y adaptan material del [Android Open Source Project](https://source.android.com/), utilizado bajo los términos de la licencia [Creative Commons Attribution 2.5](https://creativecommons.org/licenses/by/2.5/).
