// ============================================================================
// Sensorización
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@preview/cetz:0.5.0": canvas, draw
#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Sensorización],
    author: [Tomás Domínguez Bolaño],
    date: [Curso 2025/2026 --- 2º Cuatrimestre],
  ),
  ty.config-colors(
    neutral-dark: luma(60%),
  ),
)

#set text(lang: "es")
#set figure(supplement: none)

#set table(stroke: 1pt)

#show link: set text(fill: blue)

#show raw.where(block: true): set block(
  fill: luma(94%),
  width: 100%,
  inset: 5pt,
  radius: 5pt,
)

#show raw.where(block: true): set text(size: 0.9em)

// Function to place inline emojis / symbols with scaling
// but without changing the line spacing
#let scaled_symbol(content, scale_factor: 125%, ..args) = {
  context {
    let h_space = h(measure(content).width * (scale_factor - 100%) / 2)
    box()[
      #h_space
      #box(scale(scale_factor, content))
      #h_space
    ]
  }
}


#let warning_symb = scaled_symbol(
  text(size: 0.7em, font: "Noto Emoji")[#emoji.warning],
)


// ============================================================================
// PORTADA
// ============================================================================

#title-slide(
  header: [
    Máster Universitario en Ingeniería Informática\
    Arquitecturas y Plataformas Móviles
  ],
)


#slide(
  config: ty.config-page(
    margin: (top: 1.5em, bottom: 1.5em),
    header: none,
    footer: none,
  ),
)[
  #set text(size: 1.2em)
  Esta presentación está licenciada bajo Creative Commons Attribution 4.0.

  #v(0.8em)

  Esta presentación reproduce y adapta material creado y compartido por el Android Open Source Project, utilizado según los términos de la licencia Creative Commons Attribution 2.5.

  #v(1.5em)

  #align(center)[
    #link("https://creativecommons.org/licenses/by/4.0/")[
      #image("images/cc-by.svg", height: 58pt)
    ]
  ]
]

#outline-slide(
  title: [Contenidos],
  outline-args: (depth: 1),
)



// ============================================================================
// BLOQUE 1: INTRODUCCIÓN
// ============================================================================

= Introducción

== El móvil como ventana sensorial al mundo

Un smartphone moderno incorpora multitud de sensores que transforman fenómenos físicos en datos digitales:

- *Movimiento*: acelerómetro, giroscopio.
- *Posición*: magnetómetro (brújula), sensor de proximidad, GPS.
- *Entorno*: luz, presión barométrica, temperatura, humedad.
- *Biometría*: huella dactilar, ritmo cardíaco (en algunos modelos).
- *Otros*: cámara(s), micrófono(s), sensores de efecto Hall (tapa cerrada)...

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  #grid(
    columns: (1.1fr, 1fr),
    column-gutter: 1.5em,
  )[
    *Computación física*: disciplina que estudia cómo el software interactúa con el mundo físico a través de sensores y actuadores. El móvil es hoy el dispositivo de computación física más extendido.
  ][
    #image("images/physical_computing.svg", width: 100%)
  ]
]


== Usos de los sensores en un móvil

Los sensores son la base de muchas funciones que el usuario da por sentadas:

#v(0.3em)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  row-gutter: 0.5em,
)[
  - *Rotación automática* de la pantalla.
  - *Brillo automático* según la luz ambiente.
  - *Apagar la pantalla* al acercar el móvil a la cara.
  - *Navegación* y brújula en mapas.
  - *Fitness*: contar pasos, detectar actividad.
][
  - *Realidad aumentada* (ARCore).
  - *Videojuegos* controlados por inclinación o rotación.
  - *Estabilización* de cámara e imagen.
  - *Salud*: pulsaciones, SpO#sub[2] (en wearables).
  - *Localización en interiores* (barómetro para detectar plantas).
]

#v(0.5em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  La mayoría de estas funciones no requieren permisos específicos: los sensores inerciales (acelerómetro, giroscopio) son accesibles por cualquier app.
]


== Transductor, Sensor, y Actuador

Un *transductor* convierte energía de un tipo en otro. Hay dos tipos: sensores y actuadores.

#v(0.6em)

- *Sensor*:
  #v(0.7em, weak: true)
  Transductor que convierte una magnitud física (luz, aceleración, presión, etc.) en una señal eléctrica que el sistema puede procesar.

- *Actuador*:
  #v(0.7em, weak: true)
  Transductor que convierte una señal eléctrica en una acción física (motor, relé, vibrador, altavoz...).

#v(0.6em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  En un móvil, la cámara o el acelerómetro son sensores; el vibrador y el altavoz son actuadores. Ambos son transductores.
]


// == Índice del tema

// + *Conceptos básicos de sensores*: tipos, MEMS, características.

// + *Tipos de sensores en Android*: movimiento, posición, entorno.

// + *Fusión de sensores*: combinar varios sensores para obtener magnitudes más fiables.

// + *Manejo de sensores en Android*: API de `android.hardware`.

// + *Buenas prácticas y limitaciones* de la plataforma.

// + *Casos de uso y tendencias*.



// ============================================================================
// BLOQUE 2: CONCEPTOS BÁSICOS
// ============================================================================

= Conceptos básicos de sensores

== Sensores hardware y sensores software

Android distingue dos tipos de sensores:

#table(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  inset: (x: 12pt, y: 12pt),
  align: top,
  table.header([*Hardware (físicos)*], [*Software (virtuales o compuestos)*]),
  [
    Chip físico integrado en el dispositivo que mide directamente una magnitud.

    *Ejemplos*: acelerómetro, giroscopio, magnetómetro, barómetro, sensor de luz, proximidad.
  ],
  [
    No existen como hardware: sus datos se derivan combinando uno o varios sensores físicos y aplicando algoritmos.

    *Ejemplos*: gravedad, aceleración lineal, vector de rotación, contador de pasos, detector de movimiento significativo.
  ],
)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  *Ejemplo*: el sensor de gravedad es un sensor de software que se obtiene aplicando un filtro paso bajo al acelerómetro para aislar la componente constante de 9,81 m/s².
]


== MEMS: Micro-Electro-Mechanical Systems

#grid(
  columns: (1fr, 1.2fr),
  column-gutter: 1.5em
)[
  Los sensores de movimiento y posición del móvil (acelerómetro, giroscopio, magnetómetro...) son *MEMS*: sistemas electromecánicos miniaturizados (dimensiones entre 1 µm y 1 mm).

  #v(0.4em)

  - Se fabrican sobre silicio mediante *fotolitografía*, con técnicas similares a las de los circuitos integrados.

  - Combinan estructuras mecánicas (masas, muelles) y electrónica en un mismo chip.

  - Permiten producción masiva a bajo coste y con alta fiabilidad.
][
  #figure(
    image("images/lithography_process.svg", height: 95%),
    caption: [Proceso de fotolitografía],
  )
]


== Acelerómetro MEMS

Un acelerómetro MEMS mide el desplazamiento de una masa suspendida (_proof mass_) ante una aceleración. Tanto la masa como el sustrato tienen placas conductoras enfrentadas que forman condensadores

#grid(
  columns: (2.5fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  - La masa está unida al sustrato por muelles flexibles (K).

  - Cuando la masa se desplaza, la distancia entre placas cambia y con ella la capacitancia.

  - La electrónica integrada convierte la variación de capacitancia en tensión.

  *Ventajas*: tamaño reducido, bajo consumo, bajo coste, alta fiabilidad.
][
  #figure(
    image("images/acceleration_meter.svg", width: 100%),
    caption: [Modelo físico de un acelerómetro MEMS],
  )
]


== Acelerómetro MEMS: ejemplo real

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  La _proof mass_ y los muelles son estructuras de silicio suspendidas sobre el sustrato, fabricadas por grabado.

  #v(0.6em)

  Las variaciones de capacitancia entre los peines entrelazados se traducen en tensión mediante electrónica integrada en el mismo chip.

  #v(0.6em)

  #block(
    fill: rgb("#fff2df"),
    width: 100%,
    inset: 14pt,
    radius: 5pt,
  )[
    Una *IMU* (Inertial Measurement Unit) integra acelerómetro y giroscopio en un único chip. A veces también integran magnetómetro.
  ]
][
  #figure(
    image("images/mems_accelerometer.jpg", height: 80%),
    caption: text(
      size: 0.95em,
    )[Estructura de un acelerómetro MEMS vista con microscopio electrónico. Fuente: #link("https://doi.org/10.3390/s18020643")[He et al., _Sensors_ 2018, 18, 643]],
  )
]


== Características relevantes de un sensor

Desde el punto de vista del programador, los parámetros más importantes son:

#table(
  columns: (auto, 1fr),
  inset: (x: 12pt, y: 7pt),
  align: (left, left),
  table.header([*Característica*], [*Descripción*]),
  [*Rango*], [Valores mínimo y máximo que puede medir (p. ej., ±16 g en un acelerómetro).],
  [*Resolución*], [Mínimo cambio detectable en la magnitud medida.],
  [*Frecuencia de muestreo*],
  [Número máximo de muestras por segundo (Hz). Su inverso es el retardo mínimo entre muestras consecutivas (µs).],

  [*Consumo*], [Corriente consumida por el sensor cuando está activo (mA).],
  [*Ruido y calibración*], [Todos los sensores tienen un cierto nivel de ruido y pueden requerir calibración previa.],
)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  La API de Android expone casi todos estos parámetros a través de la clase `Sensor` (`getMaximumRange()`, `getResolution()`, `getMinDelay()`, `getPower()`, etc.).
]


== Categorías de sensores

La documentación de Android distingue entre tres categorías de sensores:

#[
  #show grid.cell: it => block(stroke: luma(70%) + 1.5pt, radius: 8pt, inset: 10pt, width: 100%, height: 8.5em)[#it]

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 0.75em,
    [
      *#text(size: 1.2em, fill: rgb("#1565c0"))[Movimiento]*
      #v(1em, weak: true)

      Aceleraciones y rotaciones.

      Acelerómetro, giroscopio, gravedad, aceleración lineal, vector de rotación.
    ],
    [
      *#text(size: 1.2em, fill: rgb("#2e7d32"))[Posición]*
      #v(1em, weak: true)

      Posición física del dispositivo en el espacio.

      Magnetómetro (brújula), proximidad.
    ],
    [
      *#text(size: 1.2em, fill: rgb("#c62828"))[Entorno]*
      #v(1em, weak: true)

      Parámetros del entorno.

      Luz ambiente, presión atmosférica, temperatura, humedad.
    ],
  )
]

#[
  #show grid.cell: it => block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt, stroke: luma(70%) + 1.5pt)[
    #set text(size: 0.95em)
    #it
  ]

  #grid(
    columns: (1.2fr, 1fr),
    column-gutter: 1em,
    [
      La API `android.hardware` expone todos estos sensores con una interfaz común (`SensorManager`, `Sensor`, `SensorEvent`, `SensorEventListener`), independientemente de si son _hardware_ o _software_.
    ],
    [
      Todos los sensores son opcionales a nivel de hardware: ninguno está garantizado en todos los dispositivos. Siempre hay que comprobar disponibilidad antes de usarlos.
    ],
  )
]


== Modos de reporte de sensores

Android clasifica los sensores según cómo entregan sus datos:

#v(0.4em)

#table(
  columns: (0.5fr, 1.58fr, 1fr),
  inset: (x: 10pt, y: 18pt),
  align: (left, left, left),
  stroke: 0.5pt,
  [*Modo*], [*Comportamiento*], [*Ejemplos*],
  [Continuo], [Emite lecturas a la tasa de muestreo configurada, sin parar], [Acelerómetro, giroscopio, magnetómetro],
  [On-change], [Solo emite un evento cuando el valor cambia], [Proximidad, luz ambiente],
  [One-shot],
  [Emite un único evento al detectar la condición y se desactiva automáticamente],
  [Movimiento significativo],
)


== Sensores con APIs propias

Algunos elementos que capturan información física no forman parte de la API `android.hardware.Sensor` y disponen de APIs dedicadas:

#table(
  columns: (0.28fr, 1fr, auto),
  inset: (x: 10pt, y: 12pt),
  align: (left, left, left),
  table.header([*Sensor*], [*API en Android*], [*Permiso*]),
  [GPS / Localización],
  [`FusedLocationProviderClient` (Google Play Services) o `LocationManager` (Android).],
  [`ACCESS_FINE_LOCATION`],

  [Micrófono], [`AudioRecord`, `MediaRecorder`, `SpeechRecognizer`.], [`RECORD_AUDIO`],

  [Cámara], [`CameraX` / `Camera2`.], [`CAMERA`],
)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  A diferencia de los sensores inerciales, estos requieren permisos peligrosos: el usuario debe aprobarlos explícitamente en tiempo de ejecución (Android 6.0+).
]


// ============================================================================
// BLOQUE 3: SENSORES DE MOVIMIENTO
// ============================================================================

= Sensores de movimiento

== Sistema de coordenadas del dispositivo

#grid(
  columns: (1.6fr, 1fr),
  column-gutter: 1.5em,
  align: (horizon, center),
)[
  Los sensores de movimiento y posición usan un sistema de coordenadas relativo al dispositivo, con origen en el centro de la pantalla:

  #v(0.3em)

  - *Eje X*: horizontal, apunta hacia la derecha.

  - *Eje Y*: vertical, apunta hacia arriba.

  - *Eje Z*: perpendicular a la pantalla, apunta hacia fuera de ésta.

  #v(0.3em)

  #block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
    El sistema de coordenadas no cambia con la orientación de la pantalla. Si la app soporta rotación, los ejes no coinciden con los de la interfaz.
  ]
][
  #image("images/axis_device.png", width: 85%)
]


== Acelerómetro

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  El acelerómetro mide la *aceleración* aplicada al dispositivo en los tres ejes (m/s²).

  #v(0.3em)

  - Incluye todas las fuerzas que actúan sobre el dispositivo, incluida la gravedad.

  - En posición vertical (como en la figura), marca aproximadamente `(0, 9.81, 0)` m/s².

  - En caída libre, todos los ejes tienden a 0.

  #v(0.4em)

  *Usos*: detección de inclinación, sacudida (_shake_), golpes, vibraciones, orientación aproximada, contador de pasos...
][
  #figure(
    canvas(length: 1.5cm, {
      import draw: *

      let ax = 2
      let gl = 2
      let lx = -2
      let rx = 2
      let col-g = rgb("#7b2d8b")
      let col-x = red
      let col-y = green.darken(30%)

      let sa = calc.sin(35deg)
      let ca = calc.cos(35deg)

      let draw-phone(cx, cy, angle: 0deg) = group({
        translate((cx, cy))
        rotate(angle)
        let w = 0.55
        let h = 1
        rect((-w, -h), (w, h), radius: 0.15, fill: white, stroke: (paint: black, thickness: 0.9pt))
        rect((-w + 0.06, -h + 0.18), (w - 0.06, h - 0.055), radius: 0.04, fill: luma(88%), stroke: none)
        circle((0, -h + 0.09), radius: 0.048, fill: none, stroke: (paint: luma(35%), thickness: 0.7pt))
        line((0, 0), (ax, 0), stroke: (paint: col-x, thickness: 1.2pt), mark: (end: "stealth", fill: col-x))
        content((ax + 0.19, 0.02), text(fill: col-x, size: 1.5em)[$x$])
        line((0, 0), (0, ax), stroke: (paint: col-y, thickness: 1.2pt), mark: (end: "stealth", fill: col-y))
        content((-0.1, ax + 0.30), text(fill: col-y, size: 1.5em)[$y$])
      })

      draw-phone(lx, 0)
      draw-phone(rx, 0, angle: -35deg)

      // g en el teléfono vertical
      line((lx, 0), (lx, -gl), stroke: (paint: col-g, thickness: 1.5pt), mark: (end: "stealth", fill: col-g))
      content((lx + 0.3, -gl * 0.7), text(fill: col-g, size: 1.5em)[$arrow(g)$])

      // g en el teléfono inclinado (world frame, apunta hacia abajo)
      line((rx, 0), (rx, -gl), stroke: (paint: col-g, thickness: 1.5pt), mark: (end: "stealth", fill: col-g))
      content((rx + 0.3, -gl * 0.7), text(fill: col-g, size: 1.5em)[$arrow(g)$])

      // Componentes de g en los ejes del dispositivo inclinado
      // gx_tip y gy_tip son los extremos de las proyecciones ortogonales de g
      // sobre los ejes X e Y del dispositivo (coordenadas world)
      let gx_x = rx + gl * sa * ca
      let gx_y = -gl * sa * sa
      let gy_x = rx - gl * ca * sa
      let gy_y = -gl * ca * ca

      // Flechas de las componentes (desde el centro del teléfono)
      line(
        (rx, 0),
        (gx_x, gx_y),
        stroke: (paint: col-x, thickness: 1.0pt, dash: "dashed"),
        mark: (end: "stealth", fill: col-x),
      )
      content((gx_x + 0.3, gx_y + 0.3), text(fill: col-x, size: 1.3em)[$g_x$])

      line(
        (rx, 0),
        (gy_x, gy_y),
        stroke: (paint: col-y, thickness: 1.0pt, dash: "dashed"),
        mark: (end: "stealth", fill: col-y),
      )
      content((gy_x - 0.32, gy_y + 0.05), text(fill: col-y, size: 1.3em)[$g_y$])

      // Líneas de cierre del paralelogramo (gris punteado)
      line((gx_x, gx_y), (rx, -gl), stroke: (paint: luma(55%), thickness: 0.7pt, dash: "dashed"))
      line((gy_x, gy_y), (rx, -gl), stroke: (paint: luma(55%), thickness: 0.7pt, dash: "dashed"))
    }),
    gap: 1.5em,
    caption: align(left)[
      Detección de la orientación: $arrow(g)$ apunta siempre hacia abajo. Si el dispositivo está vertical, g recae íntegramente sobre el eje Y; si está inclinado, aparecen componentes en los ejes X e Y.
    ],
  )
]


== Acelerómetro: rangos típicos

Los móviles manejan rangos modestos de aceleración, pero con buena resolución.

- *Rango típico*: ±2 g a ±16 g
- *Unidades*: m/s² (1 g ≈ 9,81 m/s²).

#v(0.3em)

#table(
  columns: (1fr, auto),
  inset: (x: 12pt, y: 10pt),
  align: (left, center),
  table.header([*Situación*], [*Aceleración*]),
  [Persona de pie al nivel del mar], [1 g],
  [Tesla Model S Plaid acelerando de 0 a 100 km/h ($approx$ 2,1 s)], [$approx$ 1.3 g],
  [Despegue de un transbordador espacial (máximo)], [3 g],
  [Coche de Fórmula 1 en curva], [4-6.5 g],
  [Impacto con daños muy graves o mortales], [$approx$ 50 g],
  [Caída de un móvil desde 1 m sobre superficie dura], [$approx$ 500 g],
)


== Acelerómetro: aplicaciones

El acelerómetro es el sensor más usado en apps móviles. Ejemplos de uso:

#v(0.3em)

- *Orientación de pantalla*: detectar si el móvil está en vertical u horizontal.
- *Detección de sacudidas* (_shake to undo_, _shake to shuffle_).
- *Detección de caídas*: apps de seguridad para mayores que alertan tras una caída.
- *Contador de pasos*: analizando el patrón de aceleración al caminar.
- *Juegos* controlados por inclinación (laberintos con bola, carreras...).
- *Fitness*: estimación de actividad física (correr, caminar, subir escaleras).
- *Detección de vibraciones*: diagnóstico de lavadoras, detección sísmica colaborativa (p. ej., MyShake de Berkeley).

#v(0.4em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  Muchas de estas aplicaciones no usan el acelerómetro directamente: usan sensores software derivados (gravedad, aceleración lineal, step counter).
]


== Giroscopio

#grid(
  columns: (1.6fr, 1fr),
  column-gutter: 1.5em,
  align: (horizon, center),
)[
  Mide la *velocidad angular* del dispositivo en los tres ejes (rad/s).

  #v(0.3em)

  - Detecta rotaciones, no orientaciones absolutas.
  - Mide la rotación alrededor de cada uno de los tres ejes del dispositivo.
  - Dispositivo en reposo: valores cercanos a cero.
  - Integrando la velocidad angular en el tiempo se obtiene el ángulo girado.

  #v(0.3em)

  #block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
    #set text(size: 0.95em)
    *Limitación*: la integración de la velocidad angular tiene deriva (_drift_): pequeños errores se acumulan con el tiempo. Se corrige combinándolo con el acelerómetro y el magnetómetro (_fusión de sensores_).
  ]
][
  #image("images/axis_rotation_device.svg", width: 85%)
]


== Giroscopio: aplicaciones

- *Realidad aumentada*: necesita conocer la orientación del móvil con alta frecuencia y baja latencia.

- *Videojuegos*: control por rotación (volantes, apuntado).

- *Estabilización óptica de imagen* (OIS): la cámara compensa las rotaciones detectadas por el giroscopio.

- *Panorámicas fotográficas*: el móvil combina fotos usando la rotación para alinearlas.

- *Navegación inercial* a corto plazo (metros) cuando el GPS no está disponible (interiores, túneles).


== Sensores de movimiento derivados (software)

A partir del acelerómetro (y a veces giroscopio + magnetómetro), Android expone varios sensores virtuales:

#table(
  columns: (0.35fr, 1fr),
  inset: (x: 12pt, y: 12pt),
  align: (left, left),
  table.header([*Sensor*], [*Valores devueltos*]),
  [Gravedad], [Vector de gravedad en los tres ejes (m/s²).],
  [Aceleración lineal], [Aceleración sin la gravedad: sólo la debida al movimiento (m/s²).],
  [Contador de pasos], [Número total de pasos desde el último reinicio del dispositivo.],
  [Detector de pasos], [Evento cada vez que se detecta un paso.],
  [Movimiento significativo],
  [Evento cuando el dispositivo cambia de ubicación (andar, coche). No se activa por vibraciones.],

  [Sensores gestuales], [_Pick-up_, _glance_, _wake-up_ (el gesto concreto lo define el fabricante).],
)


== Sensores de movimiento: constantes de la API

Cada sensor en Android se identifica por una constante entera definida en la clase `Sensor`. Se usa al pedir el sensor (`getDefaultSensor(tipo)`) y para identificarlo en los eventos recibidos (`event.sensor.type`).

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 12pt, y: 10pt),
  align: (left, left, center),
  table.header([*Sensor*], [*Constante de Android*], [*Unidades*]),
  [Acelerómetro], [`TYPE_ACCELEROMETER`], [m/s²],
  [Gravedad], [`TYPE_GRAVITY`], [m/s²],
  [Aceleración lineal], [`TYPE_LINEAR_ACCELERATION`], [m/s²],
  [Giroscopio], [`TYPE_GYROSCOPE`], [rad/s],
  [Movimiento significativo], [`TYPE_SIGNIFICANT_MOTION`], [---],
  [Contador de pasos], [`TYPE_STEP_COUNTER`], [pasos],
  [Detector de pasos], [`TYPE_STEP_DETECTOR`], [---],
)



// ============================================================================
// BLOQUE 4: SENSORES DE POSICIÓN
// ============================================================================

= Sensores de posición

== Magnetómetro

#grid(
  columns: (1.45fr, 1fr),
  column-gutter: 0.5em,
  align: horizon,
)[
  Mide el *campo magnético* aplicado al dispositivo en los tres ejes en microteslas (µT).

  - Usa los mismos ejes que el acelerómetro.
  - También llamado brújula o compás.
  - Es muy sensible a interferencias: imanes, motores eléctricos, estructuras metálicas.

  #v(0.3em)

  *Usos principales*:
  #v(0.8em, weak: true)

  - Brújula / orientación respecto al Norte magnético.
  - Detección de accesorios con imanes (p. ej., fundas _smart cover_ para apagar/encender pantalla)
  #v(0.8em, weak: true)
  #block(
    fill: rgb("#fff2df"),
    inset: 10pt,
    radius: 5pt,
    width: 100%,
  )[
    Combinado con el acelerómetro, Android es capaz de calcular la orientación absoluta.
  ]
][
  #align(center)[
    #image("images/axis_device.png", width: 55%)
  ]
  #[
    #set text(size: 0.93em)
    #set figure.caption(position: top)
    #show figure.caption: set align(left)

    #figure(
      table(
        columns: (auto, auto),
        inset: (x: 5pt, y: 6pt),
        align: (left, right),
        table.header([*Fuente*], [*Valor*]),
        [Campo terrestre (ecuador)], [$approx$31 µT],
        [Imán de nevera], [$approx$5 mT],
        [Imán de neodimio], [$approx$1,25 T],
        [Resonancia magnética], [1,5--3 T],
      ),
      caption: [
        Intensidades de referencia.
      ],
    )
  ]
]


== Sensor de proximidad

#grid(
  columns: (1.6fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  Mide la distancia a un objeto cercano al dispositivo.

  #v(0.3em)

  - Situado junto al auricular

  - Implementación habitual: LED infrarrojo + fotodetector, que mide la reflexión.

  - Muchos móviles sólo reportan dos estados (_cerca_ / _lejos_), no una distancia real en cm.

  #v(0.4em)

  *Casos de uso principales*
  #v(0.9em, weak: true)
  - Apagar la pantalla cuando el usuario acerca el móvil a la oreja durante una llamada.

  - Detectar si el móvil está dentro de un bolsillo o bolso para evitar pulsaciones accidentales.
][
  #figure(
    image("images/samsung_galaxy_s7_proximity_sensor.svg", width: 70%),
    caption: text(
      size: 0.9em,
    )[Sensor de proximidad en un Samsung Galaxy S7. Fuente: #link("https://www.samsung.com/es/support/model/SM-G935FZDAPHE/", [Manual de Usuario de Samsung Galaxy S7]).],
  )
]


== Sistema de coordenadas global

#grid(
  columns: (1.6fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  Además del sistema de coordenadas del dispositivo, Android define un sistema global (_World coordinate system_) referenciado a la Tierra:

  #v(0.3em)

  - Eje *X*: tangente al suelo, apunta al Este (producto vectorial entre Y y Z).
  - Eje *Y*: tangente al suelo, apunta al Norte magnético.
  - Eje *Z*: perpendicular al suelo, apunta al cielo.

  #v(0.3em)

  Este sistema de referencia lo utilizan los sensores de rotación (ver diapositiva siguiente) para expresar la orientación del dispositivo: el azimut, el pitch y el roll.
][
  #align(center)[
    #image("images/axis_globe.svg", width: 95%)
  ]
]



== Sensores derivados: vectores de rotación

Android expone varios sensores software para conocer la orientación del dispositivo:

#v(0.8em, weak: true)

#[
  #table(
    columns: (1fr, 2.5fr),
    inset: (x: 10pt, y: 9pt),
    align: (left, left),
    table.header([*Sensor*], [*Permite obtener*]),
    [Vector de rotación], [Orientación absoluta del dispositivo (fusiona acelerómetro, giroscopio, y magnetómetro).],

    [Vector de rotación para juegos],
    [Como el vector de rotación pero sin magnetómetro. No apunta al Norte, pero es inmune a interferencias magnéticas.],

    [Vector de rotación geomagnético],
    [Orientación usando sólo acelerómetro + magnetómetro (sin giroscopio). Menor consumo, más ruido.],
  )
]

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  Internamente, estos sensores devuelven un cuaternión. Para obtener ángulos interpretables hay que convertirlo, la API proporciona `getOrientation()`, que devuelve el *azimut* (rumbo respecto al Norte), el *pitch* (inclinación adelante/atrás) y el *roll* (inclinación lateral), todos en radianes.
]


== Sensores de posición: constantes de la API

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 10pt, y: 18pt),
  align: (left, left, center),
  table.header([*Sensor*], [*Constante de Android*], [*Unidades*]),
  [Magnetómetro], [`TYPE_MAGNETIC_FIELD`], [µT],
  [Proximidad], [`TYPE_PROXIMITY`], [cm],
  [Vector de rotación], [`TYPE_ROTATION_VECTOR`], [---],
  [Vector de rotación para juegos], [`TYPE_GAME_ROTATION_VECTOR`], [---],
  [Vector de rotación geomagnético], [`TYPE_GEOMAGNETIC_ROTATION_VECTOR`], [---],
)


// ============================================================================
// BLOQUE 5: SENSORES DE ENTORNO
// ============================================================================

= Sensores de entorno

== Sensores de entorno en Android

Miden magnitudes físicas del entorno. Son siempre hardware y devuelven un único valor por lectura.

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 10pt, y: 9pt),
  align: (left, left, center),
  table.header([*Sensor*], [*Constante de Android*], [*Unidades*]),
  [Luz ambiente], [`TYPE_LIGHT`], [lx],
  [Presión atmosférica], [`TYPE_PRESSURE`], [hPa (mbar)],
  [Temperatura ambiente], [`TYPE_AMBIENT_TEMPERATURE`], [°C],
  [Humedad relativa], [`TYPE_RELATIVE_HUMIDITY`], [%],
  [Temperatura dispositivo (_deprecated_)], [`TYPE_TEMPERATURE`], [°C],
)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  *Disponibilidad*: el sensor de luz está en prácticamente todos los móviles. El barómetro es cada vez más habitual. Temperatura ambiente y humedad son muy poco frecuentes, casi exclusivos de modelos específicos.
]


== Luz y presión: aplicaciones

*Sensor de luz (`TYPE_LIGHT`)*

#v(0.8em, weak: true)

- Ajuste automático del brillo de pantalla.
- Apps de fotografía: medición aproximada de luz.

#v(0.5em)

*Barómetro (`TYPE_PRESSURE`)*

#v(0.8em, weak: true)

#grid(
  columns: (1fr, 1.5fr),
  column-gutter: 1.5em
)[
  - Estimación de altitud (apps de senderismo y deporte).
  - Localización en interiores: diferenciar plantas de un edificio (precisión submétrica en altura).
  - Apoyo al GPS: mejora la precisión de la altitud y reduce el tiempo hasta obtener posición.
  - Previsión meteorológica.
][
  #block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
    #set text(size: 0.96em)
    *Limitación*: la presión atmosférica varía con el tiempo meteorológico, no solo con la altitud. Para altitud absoluta fiable, el barómetro necesita calibración con la presión de referencia local (obtenida de servicios meteorológicos o del GPS).

    Para desnivel relativo durante una actividad es muy preciso, ya que los cambios meteorológicos son mucho más lentos que el movimiento del usuario.
  ]
]


// ============================================================================
// BLOQUE 6: FUSIÓN DE SENSORES
// ============================================================================

= Fusión de sensores

== ¿Qué es la fusión de sensores?

*Fusión de sensores*: técnica que combina datos de varios sensores para obtener una magnitud más fiable que la que aportaría cualquiera de ellos por separado.

*Motivación*: cada sensor tiene limitaciones que se compensan con otros.

#table(
  columns: 3,
  inset: (x: 10pt, y: 12pt),
  align: (left, left, left),
  table.header([*Sensor*], [*Ventaja*], [*Limitación*]),
  [Acelerómetro], [Referencia absoluta (gravedad).], [Ruido alto en movimiento.],
  [Giroscopio], [Muy preciso a corto plazo, baja latencia.], [_Drift_: deriva con el tiempo.],
  [Magnetómetro], [Referencia absoluta al Norte magnético.], [Muy sensible a interferencias.],
)

#v(0.4em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  Combinando los tres se obtiene una orientación estable, precisa, y sin _drift_.
]


== Fusión de sensores en Android

Varios de los sensores software que expone Android ya realizan la fusión automáticamente:

#v(0.3em)

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 10pt),
  align: (left, left),
  table.header([*Sensor software*], [*Sensores físicos que combina*]),
  [`TYPE_GRAVITY`], [Acelerómetro (+ giroscopio si está disponible)],
  [`TYPE_LINEAR_ACCELERATION`], [Acelerómetro - componente de gravedad],
  [`TYPE_ROTATION_VECTOR`], [Acelerómetro + giroscopio + magnetómetro],
  [`TYPE_GAME_ROTATION_VECTOR`], [Acelerómetro + giroscopio],
  [`TYPE_GEOMAGNETIC_ROTATION_VECTOR`], [Acelerómetro + magnetómetro],
)

#v(0.4em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  *Implicación práctica*: en la mayoría de casos no hay que implementar la fusión a mano. Basta con pedir el sensor de alto nivel (`TYPE_ROTATION_VECTOR`).
]



// ============================================================================
// BLOQUE 7: MANEJO DE SENSORES EN ANDROID
// ============================================================================

= Manejo de sensores en Android

== El paquete `android.hardware`

La API de sensores se articula en torno a cuatro clases/interfaces principales:

#[
  #set text(size: 0.95em)
  #table(
    columns: (auto, 1fr),
    inset: (x: 12pt, y: 8pt),
    align: (left, left),
    table.header([*Clase / Interfaz*], [*Responsabilidad*]),
    [`SensorManager`],
    [Punto de entrada al servicio de sensores. Permite listar los sensores disponibles, obtener uno concreto, y registrar/desregistrar _listeners_.],

    [`Sensor`],
    [Representa un sensor concreto y proporciona sus metadatos: nombre, fabricante, tipo, rango, resolución, consumo...],

    [`SensorEvent`],
    [Evento generado por un sensor: valores medidos (`values`), sensor de origen, precisión, y _timestamp_.],

    [`SensorEventListener`],
    [Interfaz que implementan las clases que quieran recibir eventos: `onSensorChanged()` y `onAccuracyChanged()`.],
  )
]

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  El flujo típico es: _obtener SensorManager_ → _obtener un Sensor_ → _registrar un SensorEventListener_ → _recibir SensorEvents_.
]


== Obtener el `SensorManager`

Se obtiene como un servicio del sistema:

```kotlin
class MainActivity : AppCompatActivity() {

    private lateinit var sensorManager: SensorManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }
}
```

`SensorManager` es un _singleton_: Android devuelve siempre la misma instancia. No es necesario liberarla.


== `SensorManager`: métodos principales

#[
  #set text(size: 0.95em)
  #table(
    columns: (0.95fr, 1fr),
    inset: (x: 10pt, y: 10pt),
    align: (left, left),
    table.header([*Método*], [*Descripción*]),
    [`getSensorList(type: Int): List<Sensor>`],
    [Devuelve todos los sensores disponibles de un tipo. `Sensor.TYPE_ALL` lista todos.],

    [`getDefaultSensor(type: Int): Sensor?`], [Devuelve el sensor por defecto de un tipo, o `null` si no hay.],

    [`registerListener(listener, sensor, samplingPeriodUs): Boolean`],
    [Registra un _listener_ para un sensor con una frecuencia de muestreo.],

    [`unregisterListener(listener, sensor)`], [Desregistra el _listener_ de un sensor concreto.],

    [`unregisterListener(listener)`], [Desregistra el _listener_ de todos los sensores.],
  )
]

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  Hay también una sobrecarga de `registerListener` que acepta un `Handler` para indicar en qué hilo se entregan los eventos.
]


== Frecuencias de muestreo

El argumento `samplingPeriodUs` puede ser una de las siguientes constantes o un valor en microsegundos:

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 10pt, y: 14pt),
  align: (left, center, left),
  table.header([*Constante*], [*Período aprox.*], [*Uso típico*]),
  [`SENSOR_DELAY_FASTEST`], [0 µs], [Máxima frecuencia posible. Alto consumo.],
  [`SENSOR_DELAY_GAME`], [20 ms (50 Hz)], [Juegos, realidad aumentada (AR).],
  [`SENSOR_DELAY_UI`], [66 ms (15 Hz)], [Actualización de la UI (p. ej., rotación, brillo).],
  [`SENSOR_DELAY_NORMAL`], [200 ms (5 Hz)], [Usos genéricos, bajo consumo.],
)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  *El valor es orientativo*: Android puede entregar eventos a una frecuencia distinta. Además desde Android 12 la tasa está limitada.
]


== Ejemplo: listar los sensores del dispositivo

```kotlin
val sm = getSystemService(Context.SENSOR_SERVICE) as SensorManager
val sensores: List<Sensor> = sm.getSensorList(Sensor.TYPE_ALL)

for (s in sensores) {
    Log.i("Sensores", "${s.name} (${s.vendor}) tipo=${s.stringType}")
}
```

*Ejemplo de salida en un Pixel 6:*

#v(0.6em, weak: true)

#block(fill: luma(95%), inset: 10pt, radius: 5pt, width: 100%)[
  #set text(size: 0.85em)
  ```
  LSM6DSO Accelerometer (STMicro) tipo=android.sensor.accelerometer
  LSM6DSO Gyroscope (STMicro) tipo=android.sensor.gyroscope
  AK09918 Magnetometer (AKM) tipo=android.sensor.magnetic_field
  STK3X6X Proximity Sensor (Sensortek) tipo=android.sensor.proximity
  STK3X6X Light Sensor (Sensortek) tipo=android.sensor.light
  LPS22HH Barometer (STMicro) tipo=android.sensor.pressure
  Gravity (Google) tipo=android.sensor.gravity
  Linear Acceleration (Google) tipo=android.sensor.linear_acceleration
  Step Detector (Google) tipo=android.sensor.step_detector
  ...
  ```
]


== La clase `Sensor`: metadatos de un sensor

Una vez obtenido un `Sensor`, podemos consultar sus características:

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 10pt),
  align: (left, left),
  table.header([*Método*], [*Resultado*]),
  [`getName(): String`], [Nombre comercial (p. ej., "LSM6DSO Accelerometer").],
  [`getVendor(): String`], [Fabricante.],
  [`getType(): Int`], [Tipo numérico (p. ej., `TYPE_ACCELEROMETER`).],
  [`getVersion(): Int`], [Versión del driver/firmware.],
  [`getMaximumRange(): Float`], [Valor máximo medible (en las unidades del sensor).],
  [`getResolution(): Float`], [Mínimo cambio detectable.],
  [`getMinDelay(): Int`], [Retardo mínimo entre dos muestras (µs), o 0 si el sensor sólo emite ante cambios.],
  [`getPower(): Float`], [Consumo en mA (valor orientativo).],
)


== `SensorEventListener` y `SensorEvent`

#grid(
  columns: (1fr, 0.48fr),
  column-gutter: 1.5em,
  align: top,
)[
  *`SensorEventListener`* se implementa con dos métodos:

  #v(0.8em, weak: true)

  - `onSensorChanged(event: SensorEvent)`: llamado cuando hay una nueva lectura.
  - `onAccuracyChanged(sensor: Sensor, accuracy: Int)`: llamado si cambia la fiabilidad.
][
  #set text(size: 0.95em)
  *`accuracy`* indica la fiabilidad de la lectura del sensor:

  #v(0.5em, weak: true)

  #table(
    columns: (1fr, auto),
    inset: (x: 5pt, y: 5pt),
    [`HIGH`], [Error pequeño],
    [`MEDIUM`], [Error moderado],
    [`LOW`], [Error alto],
    [`UNRELIABLE`], [Descartar],
  )
]

*`SensorEvent`* contiene los datos de una lectura:

#v(0.8em, weak: true)

```kt
values: FloatArray, sensor: Sensor, accuracy: Int, timestamp: Long
```

#v(0.8em, weak: true)

- `values` contiene los valores medidos. El tamaño y significado dependen del sensor (3 para acelerómetro/giroscopio, 4 para vector de rotación, 1 para luz...).
- _timestamp_ indica el tiempo en ns desde el _boot_. Es útil para calcular deltas temporales (p. ej., integrar el giroscopio).


== Ejemplo: leer el acelerómetro (1/2)

#[
  #set text(size: 0.90em)
  ```kotlin
  class MainActivity : AppCompatActivity(), SensorEventListener {
      private lateinit var sensorManager: SensorManager
      private var acelerometer: Sensor? = null

      override fun onCreate(savedInstanceState: Bundle?) {
          super.onCreate(savedInstanceState)
          setContentView(R.layout.activity_main)
          sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
          acelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
      }

      override fun onResume() {
          super.onResume()
          acelerometer?.also { sensor ->
              sensorManager.registerListener(
                  this, sensor, SensorManager.SENSOR_DELAY_NORMAL
              )
          }
      }
      // ...
  ```
]


== Ejemplo: leer el acelerómetro (2/2)

#grid(
  columns: (2.7fr, 1fr),
  column-gutter: 1.5em
)[
  #set text(size: 0.90em)
  ```kotlin
      override fun onSensorChanged(event: SensorEvent) {
          // El acelerómetro devuelve [ax, ay, az] en m/s²
          val ax = event.values[0]
          val ay = event.values[1]
          val az = event.values[2]
          Log.i("Acel", "x=$ax  y=$ay  z=$az  t=${event.timestamp}")
      }

      override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
          // Acciones cuando cambia la precisión del sensor
      }

      override fun onPause() {
          super.onPause()
          sensorManager.unregisterListener(this)
      }
  }
  ```
][
  #block(fill: rgb("#fff2df"), width: 100%, inset: 18pt, radius: 5pt)[
    Patrón habitual: registrar el _listener_ en `onResume()` y desregistrarlo en `onPause()`. Así se ahorra batería cuando la app no está en primer plano.
  ]
]


== Comprobar disponibilidad de un sensor

`getDefaultSensor()` devuelve `null` si el sensor no existe en el dispositivo:

#v(0.8em, weak: true)

```kotlin
val giroscopio = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
if (giroscopio == null) {
    // No hay giroscopio: deshabilitar funcionalidad dependiente
}
```

#v(0.4em)

Para indicar en el `AndroidManifest.xml` que la aplicación requiere un sensor concreto:

#v(0.8em, weak: true)

```xml
<uses-feature
    android:name="android.hardware.sensor.gyroscope"
    android:required="true" />
```

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  Con `required="true"`, Google Play oculta la app en dispositivos sin giroscopio. // Con `required="false"`, se instala y la app debe adaptarse.
]


// ============================================================================
// BLOQUE 8: LIMITACIONES
// ============================================================================

= Limitaciones

== Limitaciones de la plataforma

- *Disponibilidad variable*: cada dispositivo incorpora sensores distintos. Sobre todo giroscopio, barómetro y temperatura/humedad ambiental son opcionales.

- *Sensores no estándar*: el mismo tipo (`TYPE_ACCELEROMETER`) puede tener características muy distintas entre dispositivos (rango, resolución, ruido).

- *Datasheets incompletos*: los fabricantes no siempre documentan qué procesado (filtros, calibración) aplican sus drivers.

- *Inconsistencias en sensores software*: no todos los dispositivos implementan todos los sensores virtuales. Por ejemplo, sin giroscopio no hay `ROTATION_VECTOR` completo.

- *No es tiempo real*: Android no garantiza la entrega de eventos con latencia acotada. Para aplicaciones críticas (control industrial, medicina) no es la plataforma adecuada.


== Restricciones en segundo plano (Android 9+)

A partir de Android 9 (API 28), una app en segundo plano tiene acceso limitado a sensores:

#v(0.3em)

- Los sensores en modo continuo (acelerómetro, giroscopio, magnetómetro...) y en modo on-change (proximidad, luz) no entregan eventos a apps en _background_.

- Los sensores en modo one-shot (movimiento significativo) sí funcionan.

#v(0.4em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  *Solución*: usar un *_foreground service_* (con notificación persistente) cuando la app necesite leer sensores durante un período prolongado (p. ej., apps de fitness que siguen contando pasos al bloquear la pantalla).
]


== Límite de frecuencia de muestreo (Android 12+)

A partir de Android 12 (API 31), Android limita la frecuencia máxima a la que las apps pueden leer acelerómetro, giroscopio y magnetómetro:

#v(0.3em)

- *Vía `registerListener`*: máximo 200 Hz.
- *Vía `SensorDirectChannel`*: máximo `RATE_NORMAL` (≈ 50 Hz).

#v(0.3em)

Para solicitar frecuencias mayores, hay que declarar un permiso normal en el _manifest_:

#v(0.2em)

```xml
<uses-permission android:name="android.permission.HIGH_SAMPLING_RATE_SENSORS" />
```

#v(0.3em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 12pt, radius: 5pt)[
  *Motivación*: datos de sensores a alta frecuencia pueden revelar información sensible del usuario (pulsaciones del teclado, reconocimiento del habla a partir de vibraciones, identificación por marcha).
]


== Android Emulator: sensores virtuales

#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 1em,
  align: horizon,
)[
  El emulador de Android Studio incluye controles de sensores virtuales muy útiles para desarrollo:

  #v(0.3em)

  - Acelerómetro (rotación e inclinación interactiva).
  - Magnetómetro, giroscopio.
  - Temperatura ambiente, presión, humedad.
  - Luz ambiente, proximidad.

  #v(0.3em)

  #block(fill: rgb("#fff2df"), width: 100%, inset: 10pt, radius: 5pt)[
    _Extended controls → Virtual sensors_

    Permite simular escenarios sin mover el PC, aunque el realismo no reemplaza a las pruebas en dispositivos físicos.
  ]
][
  #align(center)[
    #image("images/emulator-sensors.png", width: 100%)
  ]
]


// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

== Recursos y documentación

*Documentación oficial de Android*:

- #link("https://developer.android.com/develop/sensors-and-location/sensors/sensors_overview", [Sensors overview])

- #link("https://developer.android.com/develop/sensors-and-location/sensors/sensors_motion", [Motion sensors])

- #link("https://developer.android.com/develop/sensors-and-location/sensors/sensors_position", [Position sensors])

- #link("https://developer.android.com/develop/sensors-and-location/sensors/sensors_environment", [Environment sensors])

- #link("https://developer.android.com/develop/sensors-and-location/sensors/gnss", [Raw GNSS measurements])


