// ============================================================================
// Usabilidad y UX
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Usabilidad y UX],
    author: [Tomás Domínguez Bolaño],
    date: [Curso 2025/2026 --- 2º Cuatrimestre],
  ),
)

#set text(lang: "es")
#set figure(supplement: none)

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

  Esta presentación reproduce y adapta material creado y compartido por el Android Open Source Project, utilizado según los términos de la licencia Creative Commons Attribution 2.5, y material de Material Design 3 (Google), bajo CC BY 4.0.

  Algunas imágenes reproducidas con fines educativos son propiedad de sus autores y no están cubiertas por la licencia CC BY 4.0: imágenes de Steven Hoober (_UXmatters_, 2013) y de Scott Hurff (2014).

  #v(0.5em)

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
// 1. INTRODUCCIÓN: UX vs UI
// ============================================================================

= Introducción: UX vs UI

== ¿Qué es UX?

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  align: top,
  [
    - *User Experience (UX)*: todos los aspectos de la experiencia de una persona con un sistema, producto o servicio.

    - *Término acuñado por Don Norman* en Apple (1993), primer _User Experience Architect_.

    - *No se limita a lo visual*: incluye flujos, tiempos de respuesta, feedback y satisfacción.
  ],
  [
    Norman quería un término que cubriera todos los aspectos de la experiencia, incluyendo:

    - El diseño industrial (hardware)
    - La interfaz gráfica (software)
    - El manual de instrucciones
    - El empaquetado y cómo se siente el producto en la mano

    #v(0.3em)
    #text(
      size: 0.9em,
      fill: luma(20%),
    )[_"Human interface y usabilidad eran conceptos demasiado limitados"_ — Don Norman]
  ],
)


== UX ≠ UI

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  align: top,
)[
  *UI (User Interface)*

  - Elementos visuales e interactivos
  - Colores, tipografía, iconos, layout
  - Botones, formularios, animaciones
  - _"Cómo se ve"_
][
  *UX (User Experience)*

  - La experiencia completa del usuario
  - Arquitectura de información
  - Flujos de interacción y navegación
  - Rendimiento, accesibilidad, emoción
  - _"Cómo se siente al usarlo"_
]

#v(1em)

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  Una app puede tener una *UI bonita* pero una *UX terrible* (y viceversa). La UI es un _subconjunto_ de la UX.
]


== Framework HEART (Google)

El framework *HEART* fue propuesto por Kerry Rodden, Hilary Hutchinson y Xin Fu en Google (2010) para medir la calidad de la experiencia de usuario a gran escala. Define cinco dimensiones complementarias:

#{
  let heart-row(letter, name, desc, clr) = block(
    fill: clr,
    inset: (x: 10pt, y: 10pt),
    radius: 5pt,
    width: 100%,
    below: 5pt,
  )[
    #text(weight: "bold", size: 1.2em)[#letter] #h(0.3em)#text(weight: "bold")[#name]:
    #desc
  ]
  heart-row("H", "Happiness", [Satisfacción subjetiva del usuario (medida mediante encuestas)], rgb("#fff8e1"))
  heart-row("E", "Engagement", [Frecuencia e intensidad de uso de la app], rgb("#e8f5e9"))
  heart-row("A", "Adoption", [Nuevos usuarios que empiezan a usar el producto en un período], rgb("#e3f2fd"))
  heart-row(
    "R",
    "Retention",
    [Usuarios activos en un período que siguen activos en un período posterior],
    rgb("#f3e5f5"),
  )
  heart-row("T", "Task Success", [Eficacia (completar tareas), eficiencia (tiempo) y tasa de error], rgb("#e0f2f1"))
}

#v(0.3em)

#text(size: 0.88em, fill: luma(15%))[
  Rodden, K., Hutchinson, H. & Fu, X. (2010). _Measuring the User Experience on a Large Scale: User-Centered Metrics for Web Applications_. CHI 2010.
  #link(
    "https://research.google/pubs/measuring-the-user-experience-on-a-large-scale-user-centered-metrics-for-web-applications/",
  )
]


== Por qué importa la UX

- El *25% de las apps* se usan solo una vez tras la descarga #h(0.3em) #text(size: 0.8em)[#link("https://www.statista.com/statistics/271628/percentage-of-apps-used-once-in-the-us/")[(Statista)]]

- El *86% de los usuarios* ha desinstalado al menos una app por mal rendimiento #h(0.3em) #text(size: 0.8em)[#link("https://www.apmdigest.com/nearly-90-percent-surveyed-stop-using-apps-due-to-poor-performance")[(AppDynamics App Attention Span, 2014)]]

- El usuario medio usa activamente *$≈$30 apps al mes* #h(0.3em) #text(size: 0.8em)[#link("https://buildfire.com/app-statistics/")[(BuildFire, 2024)]]

- Google Play Store: *más de 1,7 millones de apps* disponibles: competencia feroz #h(0.3em) #text(size: 0.8em)[#link("https://www.appbrain.com/stats")[(AppBrain, 2026)]]

#v(0.8em)

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  En el ecosistema móvil, la UX no es un "extra" --- es un *factor de supervivencia*.
]


== El coste de una mala UX

- *Valoraciones negativas* en Play Store → menor visibilidad y descargas

- *Mayor tasa de desinstalación* → peor retención, menores ingresos

- Adquirir un nuevo cliente cuesta *5--25 $times$ más* que retener uno existente (dato de industria general, aplicable también a apps) #h(0.3em) #text(size: 0.8em)[#link("https://hbr.org/2014/10/the-value-of-keeping-the-right-customers")[(Gallo, HBR, 2014; datos de Bain & Company)]]

#v(0.5em)

*Regla del 1-10-100* #h(0.3em) #text(size: 0.85em)[#link("https://akfpartners.com/growth-blog/1-10-100-rule-in-quality-software-development")[(heurística de gestión de calidad, Labovitz & Chang, 1992)]]:

#table(
  columns: (1fr, 1fr, 1fr),
  inset: (x: 5pt, y: 8pt),
  align: center,
  table.header([*1 $times$ Prevenir*], [*10 $times$ Corregir*], [*100 $times$ No actuar*]),
  [Detectar y resolver el problema en la fase de diseño],
  [Corregir el problema una vez detectado en desarrollo],
  [Asumir las consecuencias de un defecto en producción],
)

Originalmente formulada para calidad de datos en manufactura, la regla se aplica también al software: un problema de UX detectado en un prototipo se resuelve con un cambio de diseño; en producción puede requerir rediseño, desarrollo, testing y una actualización.


== Ejemplo UX: solicitud de permisos

// Conecta con tema 06 (geolocalización) --- ya conocéis la implementación técnica.
// Aquí el foco es CUÁNDO y CÓMO pedir el permiso.

Los *permisos peligrosos* (_dangerous permissions_) requieren aprobación explícita en tiempo de ejecución: cámara, micrófono, localización, contactos, almacenamiento...

*Enfoque incorrecto:*
- Pedir *todos los permisos al inicio* de la app, sin contexto
- El usuario no entiende para qué se necesita → deniega

*Enfoque correcto → patrón _in-context_:*
+ El usuario llega a una funcionalidad que requiere el permiso.
+ La app comprueba si ya está concedido (`ContextCompat.checkSelfPermission()`).
+ Si no está concedido: dependiendo del caso, se puede mostrar antes una pantalla explicativa.
+ Se lanza el diálogo de solicitud de permisos (mediante la Activity Result API).
+ Si concede → acceso al recurso; si deniega → la app *degrada la funcionalidad con elegancia*

---

#figure(
  align(center, image("images/workflow-runtime.svg", width: 82%)),
  caption: [
    Flujo de trabajo para solicitar permisos de tiempo de ejecución en Android.\ Fuente: https://developer.android.com/training/permissions/requesting.
  ],
)


// ============================================================================
// 2. RESTRICCIONES DEL DISPOSITIVO MÓVIL
// ============================================================================

= Restricciones del dispositivo móvil

== Restricciones del dispositivo móvil

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  align: top,
)[
  *Hardware y entorno*

  - *Pantalla pequeña*: espacio limitado para contenido e interacción
  - *Batería*: operaciones costosas impactan la autonomía
  - *Conectividad variable*: WiFi, 4G/5G, sin conexión
  - *Entrada imprecisa*: el dedo no es un ratón ($~$7 mm de contacto)
][
  *Contexto de uso*

  - *Atención dividida*: el usuario está en movimiento, multitarea
  - *Sesiones cortas*: media de ~72 segundos por sesión (escritorio: el doble)
  - *Manos ocupadas*: conduciendo, cargando bolsas, cocinando
  - *Entorno variable*: iluminación, ruido, movimiento
]

#v(0.3em)
#text(size: 0.8em, fill: luma(10%))[
  Fuentes: #link("https://www.nngroup.com/articles/mobile-ux/")[Budiu, R. (2015). _Mobile User Experience._ NN/g]\;
  #link(
    "https://www.uxmatters.com/mt/archives/2013/02/how-do-users-really-hold-mobile-devices.php",
  )[Hoober, S. (2013). _How Do Users Really Hold Mobile Devices?_ UXmatters]
]


== ¿Cómo sujetamos el móvil?

Steven Hoober (2013) observó a *1.333 personas* en calles, aeropuertos, cafeterías y transporte público:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
  [
    - *49%* *_one-handed_*: sujetaban el móvil con una sola mano, usando el pulgar
    - *36%* *_cradling_*: sujetan con una mano y tocan con la otra; de estos, el 72% usa el pulgar y el 28% otro dedo
    - *15%* *_two-handed_*: usaban las dos manos (sobre todo al escribir)

    Los usuarios *cambian de agarre constantemente*, a veces cada pocos segundos, según la tarea: una mano para hacer scroll, dos para escribir

  ],
  [
    #align(center, image("images/hoober-grips.png", width: 74%))

    #text(
      size: 0.8em,
      fill: luma(10%),
    )[Fuente: #link("https://www.uxmatters.com/mt/archives/2013/02/how-do-users-really-hold-mobile-devices.php")[Hoober, S. (2013). _How Do Users Really Hold Mobile Devices?_ UXmatters.] © Steven Hoober / UXmatters. Imagen reproducida con fines educativos.]
  ],
)


== Zonas del pulgar (_thumb zones_)

#grid(
  columns: (1.36fr, 1fr),
  column-gutter: 1em,
  [
    Sumando _one-handed_ (49%, todo pulgar) y _cradling_ con pulgar (≈26%), el *pulgar es el elemento de interacción en aprox. el 75% de los casos*. Las zonas de alcance varían según el agarre.
  ],
  [
    - #text(fill: green.darken(20%), weight: "bold")[Natural]: arco cómodo del pulgar
    - #text(fill: orange.darken(10%), weight: "bold")[Stretch]: requiere estirar el pulgar deliberadamente
    - #text(fill: red.darken(10%), weight: "bold")[Ow]: difícil o incómodo de alcanzar
  ],
)

#v(0.5em)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 1.5em,
  align: center + top,
  [
    *One-handed* (49%)
    #v(0.8em, weak: true)
    #block(stroke: 0.5pt + luma(30%), inset: 5pt, radius: 5pt)[
      #image("images/hoober-grip-types.png", fit: "cover", height: 6em)
    ]
  ],
  [
    *Cradling* (36%)
    #v(0.8em, weak: true)

    #block(stroke: 0.5pt + luma(30%), inset: 5pt, radius: 5pt)[
      #image("images/hoober-cradling.png", fit: "cover", height: 6em)
    ]
  ],
  [
    *Two-handed* (15%)
    #v(0.8em, weak: true)

    #block(stroke: 0.5pt + luma(30%), inset: 5pt, radius: 5pt)[
      #image("images/hoober-two-handed.png", fit: "cover", height: 6em)
    ]
  ],
)

#text(
  size: 0.8em,
  fill: luma(10%),
)[Fuente: #link("https://www.uxmatters.com/mt/archives/2013/02/how-do-users-really-hold-mobile-devices.php")[Hoober, S. (2013). _How Do Users Really Hold Mobile Devices?_ UXmatters.] © Steven Hoober / UXmatters. Imágenes reproducidas con fines educativos.]


== Pantallas grandes: el reto del pulgar

El pulgar *no escala* con el tamaño de pantalla: la zona _Natural_ se mantiene similar, pero la zona _Ow_ crece drásticamente en dispositivos grandes.

#align(center, image("images/thumb-zones-lineup.png", width: 65%))

#text(
  size: 0.8em,
  fill: luma(10%),
)[Fuente: #link("https://www.scotthurff.com/posts/how-to-design-for-thumbs-in-the-era-of-huge-screens/")[Hurff, S. (2014). _How to Design for Thumbs in the Era of Huge Screens._] © Scott Hurff. Imagen reproducida con fines educativos.]


== Pantallas grandes: implicaciones de diseño

*Hacer:*
- *Navegación inferior* (_bottom navigation_): Facebook comprobó que mover la barra de pestañas abajo mejoró _engagement_, satisfacción, y velocidad percibida
- *FAB* (_Floating Action Button_) en la parte inferior
- Gestos desde los bordes de pantalla como complemento
- Situar las acciones principales en la zona _Natural_ del pulgar
*Evitar:*
- Acciones principales en las esquinas superiores
- Escalar layouts de pantallas pequeñas sin adaptar → las pantallas $≥ 5,5\"$ son una experiencia de interacción diferente
- Asumir un único tipo de agarre


#v(0.5em)
#text(
  size: 0.8em,
  fill: luma(10%),
)[Fuentes: #link("https://www.lukew.com/ff/entry.asp?1927")[Wroblewski (2014)]; #link("https://www.scotthurff.com/posts/how-to-design-for-thumbs-in-the-era-of-huge-screens/")[Hurff (2014)]]



// ============================================================================
// 3. DARK PATTERNS
// ============================================================================

= Dark patterns


== Dark patterns

Término acuñado por Harry Brignull en 2010, investigador de UX y fundador de #link("https://www.deceptive.design/")[deceptive.design]

- *Definición*: trucos en interfaces que llevan al usuario a hacer cosas que no pretendía

- No son _bugs_ → son decisiones de diseño intencionales

#v(1.5em)

#block(
  fill: luma(92%),
  width: 100%,
  inset: 14pt,
  radius: 5pt,
)[
  _"A dark pattern is a user interface that has been carefully crafted to trick users into doing things they didn't mean to."_ #h(1fr) --- *Harry Brignull*
]


== Difícil de cancelar (_hard to cancel_)

Suscribirse es sencillo, pero cancelar es deliberadamente complicado: opciones enterradas, llamadas telefónicas obligatorias, y agentes de retención.

_Ejemplo:_ The New York Times. Suscripción online en segundos, pero cancelar requiere llamar a atención al cliente.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  #figure(
    image("images/dp-hard-to-cancel-1.png", width: 80%),
    gap: 0.4em,
    caption: [_"Cancel or pause anytime"_],
  )
][
  #figure(
    image("images/dp-hard-to-cancel-2.png", width: 80%),
    gap: 0.4em,
    caption: [_Para cancelar hay que llamar por teléfono_],
  )
]



== Suscripción oculta (_hidden subscription_)

El usuario cree que realiza una acción puntual pero queda inscrito en pagos recurrentes. La información clave está ausente o escondida en la interfaz.

#v(1.5em)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  align: horizon,
)[
  _Ejemplo:_ Figma. Al cambiar el permiso de un colaborador a _"can edit"_, se generaba silenciosamente una suscripción mensual cargada a quien compartía, sin ningún aviso en la interfaz.
][
  #figure(
    image("images/dp-hidden-subscription-2.png", width: 100%),
    caption: [Figma: diálogo _"Share project"_],
  )
]


== Interrupciones persistentes (_nagging_)

Cada interrupción consume atención del usuario. La acumulación agota su resistencia hasta que ceder es más fácil que resistir.

#grid(
  columns: (3.2fr, 1fr),
  column-gutter: 2em,
  align: horizon,
)[
  - La app repite la *misma solicitud* indefinidamente

  - Solo ofrece _"Not Now"_ — no existe un rechazo permanente

  - Explota el agotamiento: con el tiempo más usuarios acaban aceptando

  #v(1em)

  _Ejemplo:_ Instagram (2018) solicitaba activar notificaciones durante meses. La única opción disponible era _"Not Now"_, que simplemente posponía el diálogo.
][
  #image("images/dp-nagging-1.png", width: 100%, fit: "contain")
]


== Acción forzada (_forced action_)

El usuario quiere completar una acción legítima pero se le obliga a hacer otra cosa no deseada. Pasos opcionales aparecen disfrazados de obligatorios.

_Ejemplo:_ LinkedIn (2015). Durante el registro, un paso solicitaba acceso al email del usuario para "sugerir contactos", importando silenciosamente toda su libreta de direcciones. Al intentar saltarlo, un diálogo de disuasión preguntaba _"¿Seguro que quieres perderte esto?"_.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: bottom,
)[
  #figure(
    image("images/dp-forced-action-1.png", width: 100%),
    caption: [_Añadir el email: parece obligatorio_],
  )
][
  #figure(
    image("images/dp-forced-action-2.png", width: 100%),
    caption: [_Diálogo de disuasión al intentar saltarlo_],
  )
]




== Dark patterns y regulación

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  align: top,
)[
  *DSA (Digital Services Act)*
  #set text(size: 0.94em)

  - Art. 25: prohíbe dark patterns en _plataformas online_ (servicios que alojan y distribuyen contenido de usuarios: redes sociales, tiendas de apps...)
  - Muy grandes plataformas (+45M usuarios en la UE): desde agosto 2023
  - Resto de plataformas: desde febrero 2024
  - Pequeñas empresas: exentas de la mayoría de obligaciones
  - Sanciones: hasta 6% de la facturación global
][
  *GDPR*
  #set text(size: 0.94em)

  - Prohíbe dark patterns en los diálogos donde el usuario acepta o rechaza algo: cookies, permisos, privacidad...
  - en vigor desde mayo 2018
  - Se aplica a cualquier desarrollador que trate datos de residentes en la UE
  - El consentimiento debe ser libre, informado, específico e inequívoco
  - Rechazar debe ser tan fácil como aceptar
]

#v(0.5em)

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  *Google Play* exige desde 2023: eliminación de cuenta desde la app, transparencia en suscripciones y cumplimiento de la regulación europea.
]


// ============================================================================
// 4. MATERIAL DESIGN 3
// ============================================================================

= Material Design 3

== ¿Qué es Material Design?

#grid(
  columns: (1.25fr, 1fr),
  column-gutter: 1.5em
)[
  - *Sistema de diseño* creado por Google (2014), open-source y multiplataforma

  - Proporciona guías, componentes, y herramientas para crear interfaces consistentes

  - Sistema de diseño por defecto en Android

  - Referencia: #link("https://m3.material.io")[m3.material.io]
][
  #figure(
    image("images/Material_you_light.png", width: 100%),
    caption: [Material Design 3 en Android 12],
  )
]

== Evolución de Material Design

#grid(
  columns: (3fr, 1fr),
  column-gutter: 1em,
)[
  - *Material Design 1* (2014): primer sistema de diseño unificado de Google. Paleta de colores fija y diseño uniforme.

  - *Material Design 2* (2018): introduce _theming_ personalizable, dark theme y esquinas redondeadas configurables.

  - *Material Design 3 (Material You)* (2021): personalización con Dynamic Color (colores extraídos del fondo de pantalla) y accesibilidad como prioridad.

  - *Material 3 Expressive* (2025): expansión de M3 con animaciones, sistema de formas ampliado, y mayor impacto emocional. Introducido con Android 16.
][
  #figure(
    image("images/material-design-2.svg", width: 80%),
    gap: 0.4em,
    caption: [Material Design 2],
  )
  #figure(
    image("images/material-design-3.svg", width: 80%),
    gap: 0.4em,
    caption: [Material Design 3],
  )
]


== Material Design 3: implementaciones

#grid(
  columns: (2fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  M3 es un sistema de diseño con implementaciones para distintas plataformas:

  - *Jetpack Compose* (Android): incluye Material You y Material 3 Expressive.
  - *Flutter*: librería `material` integrada en el framework.
  - *Web*: componentes web (`material-web`).

  #v(0.8em)

  Para usarlo en Jetpack Compose, añadir la dependencia en `build.gradle`:

  #[
    #set text(size: 0.9em)
    ```kotlin
    implementation(
        "androidx.compose.material3:material3:$material3_version"
    )
    ```
  ]
][
  La librería de compose da acceso a los temas y componentes de M3. Por ejemplo, para botones:

  - `Button`
  - `ElevatedButton`
  - `FilledTonalButton`
  - `OutlinedButton`
  - `TextButton`

  #v(0.5em)

  Referencia completa: #link("https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary")[`androidx.compose.material3`]
]


== Material Theming

#grid(
  columns: (1fr, 1.5fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  Un tema Material 3 (M3) se compone de *tres subsistemas*:
  + *Color scheme*: esquema cromático de la app
  + *Typography*: escala tipográfica
  + *Shapes*: sistema de formas

  Se configuran a través del composable `MaterialTheme`:

  #[
    #set text(size: 0.95em)
    ```kotlin
    MaterialTheme(
        colorScheme = /* ... */,
        typography = /* ... */,
        shapes = /* ... */
    ) {
        // Contenido de la app M3
    }
    ```
  ]
][
  #figure(
    image("images/m3-theming.png", width: 100%),
    caption: [Los tres subsistemas de Material Design 3.],
  )
]


== Dark Theme

A partir de Android 10, el sistema ofrece un tema oscuro global. El usuario lo activa en *Ajustes → Pantalla → Tema oscuro*.

#grid(
  columns: (1fr, 1.2fr),
  column-gutter: 1.5em,
  align: top,
)[

  *Beneficios:*
  - *Baja luminosidad*: más cómodo en entornos con poca luz
  - *Accesibilidad*: mejora la visibilidad para usuarios con baja visión o sensibilidad a la luz
  - *Batería*: en pantallas OLED, los píxeles oscuros consumen menos energía

][
  #figure(
    image("images/google_dark_theme.png", width: 100%),
    caption: text(size: 0.95em)[Modo claro (izquierda) y modo oscuro (derecha).],
  )
]

*En Compose:* se definen dos esquemas (`lightColorScheme()` / `darkColorScheme()`) y se selecciona con `isSystemInDarkTheme()`.


== Esquema de colores

#grid(
  columns: (1fr, 0.9fr),
  column-gutter: 1.5em,
)[
  Un *esquema* de colores agrupa los $~$25 roles de color que usan los componentes (`primary`, `onPrimary`, `surface`, `outline`...) en modo claro y oscuro.

  - #link("https://m3.material.io/theme-builder")[Material Theme Builder]: herramienta oficial para generar un esquema de colores a partir de unos pocos colores clave.

  - Alternativa en runtime: Dynamic Color (Android 12+), el sistema genera el esquema a partir del fondo de pantalla del usuario.
][
  #figure(
    image("images/m3-light.png", width: 100%),
    caption: [Ejemplo de esquema de colores claro generado con Material Theme Builder.],
  )
]


== Roles de color

Los roles se agrupan en familias. Cada familia sigue el mismo patrón: un color base, su variante `container` más suave, y sus pares `on-*` para el contenido encima. // P.ej. la familia _Primary_ incluye: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`.

#grid(
  columns: (1fr, 1.4fr),
  column-gutter: 1.5em,
  align: top,
)[
  - *Primary*: componentes principales (acciones, botones, estados activos)
  - *Secondary*: componentes secundarios (menor énfasis)
  - *Tertiary*: acentos y variedad cromática
  - *Error*: estados de error y validación fallida
  - *Neutral*: fondos y bordes (`background`, `surface`, `outline`...)
][
  #figure(
    image("images/m3-container.png", width: 95%),
    caption: [
      Ejemplo de roles de color en un componente.
      // Componente usando los roles `primaryContainer` y `onPrimaryContainer`.
    ],
  )
]


== Accesibilidad en colores

#grid(
  columns: (1.5fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  Las paletas tonales de M3 están diseñadas para cumplir los ratios de contraste accesibles por defecto:

  - *Siempre emparejar un color con su variante on-*: p.ej. `primary` con `onPrimary`.

  - *No mezclar roles distintos*: p.ej. `tertiaryContainer` con `onPrimaryContainer`. Produce contraste insuficiente
][
  // Fuente: https://developer.android.com/develop/ui/compose/designsystems/material3
  #figure(
    image("images/m3-contrast.png", width: 100%),
    caption: [Contraste suficiente (izquierda) vs.\ contraste pobre (derecha).],
  )
]

#v(0.3em)

#[
  #set text(size: 0.92em)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
  )[
    ```kotlin
    val cs = MaterialTheme.colorScheme
    // Correcto: emparejar con on-
    Button(colors = ButtonDefaults.buttonColors(
        containerColor = cs.primary,
        contentColor = cs.onPrimary
    )) { Text("Aceptar") }
    ```
  ][
    ```kotlin
    val cs = MaterialTheme.colorScheme
    // Incorrecto: mezcla de roles
    Button(colors = ButtonDefaults.buttonColors(
        containerColor = cs.tertiaryContainer,
        contentColor = cs.primaryContainer
    )) { Text("Ignorar") }
    ```
  ]
]


== Esquema de colores en Compose

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  *1. Definir el esquema:*
  #v(0.5em, weak: true)
  #[
    #set text(size: 0.9em)
    ```kotlin
    private val LightColorScheme = lightColorScheme(
        primary = Color(0xFF6D5E0F),
        onPrimary = Color(0xFFFFFFFF),
        primaryContainer = Color(0xFFF8E287),
        // ... otros roles
    )

    private val DarkColorScheme = darkColorScheme(
        primary = Color(0xFFDBC66E),
        onPrimary = Color(0xFF3A3000),
        primaryContainer = Color(0xFF534600),
        // ... otros roles
    )
    ```
  ]
][
  *2. Aplicar al tema:*
  #v(0.5em, weak: true)
  #[
    #set text(size: 0.9em)
    ```kotlin
    @Composable
    fun AppTheme(
        darkTheme: Boolean =
          isSystemInDarkTheme(),
        content: @Composable () -> Unit
    ) {
        val colorScheme =
            if (darkTheme) DarkColorScheme
            else LightColorScheme

        MaterialTheme(
            colorScheme = colorScheme,
            content = content
        )
    }
    ```
  ]
]

*3. Usar un color:*
#v(0.5em, weak: true)
#[
  // #set text(size: 0.9em)
  ```kotlin
  Text(text = "Hola", color = MaterialTheme.colorScheme.primary)
  ```
]


== Dynamic Color

#grid(
  columns: (1fr, 1.0fr),
  column-gutter: 0em,
  align: horizon,
)[
  - Genera un esquema personalizado a partir del fondo de pantalla del usuario o del contenido de la app (p.ej. la portada de un álbum)

  - Disponible a partir de Android 12 (API 31)

  - En dispositivos anteriores: se usa el esquema estático de la app como _fallback_
][
  #figure(
    image("images/m3-dynamic.png", fit: "contain", width: 76%),
    caption: text(size: 0.8em)[
      Esquema generado dinámicamente desde el fondo de pantalla (izq.) y con esquema estático predefinido (der.).
    ],
  )
]


== Dynamic Color en Compose

#grid(
  columns: (1.4fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  #[
    #set text(size: 0.83em)
    ```kotlin
    @Composable
    fun AppTheme(
        darkTheme: Boolean = isSystemInDarkTheme(),
        dynamicColor: Boolean = true,
        content: @Composable () -> Unit
    ) {
        val dynamicAvailable = Build.VERSION.SDK_INT
            >= Build.VERSION_CODES.S
        val colorScheme = when {
            dynamicColor && dynamicAvailable -> {
                val ctx = LocalContext.current
                if (darkTheme) dynamicDarkColorScheme(ctx)
                else dynamicLightColorScheme(ctx)
            }
            darkTheme -> DarkColorScheme
            else -> LightColorScheme
        }
        MaterialTheme(
            colorScheme = colorScheme,
            content = content
        )
    }
    ```
  ]
][
  Las funciones `dynamicLightColorScheme()` y `dynamicDarkColorScheme()` generan el esquema a partir del fondo de pantalla del dispositivo.

  La expresión `when` selecciona el esquema según:

  + Color dinámico disponible → esquema del fondo de pantalla
  + Tema oscuro → esquema oscuro estático
  + Caso por defecto → esquema claro estático
]


== Tipografía

Material 3 define una tipografía con 5 categorías (_display_, _headline_, _title_, _body_, y _label_) $times$ 3 tamaños (_large_, _medium_, y _small_) $=$ *15 estilos*. La siguiente tabla muestra la fuente y el tamaño/interlineado por defecto en Material 3.

#[
  #set text(size: 0.75em)
  #let s = 0.75

  #table(
    columns: (5em, 1.55fr, 1.25fr, 1fr),
    inset: (x: 5pt, y: 15pt),
    fill: (x, y) => if x == 0 or y == 0 { luma(92%) } else { none },
    stroke: (x, y) => (
      bottom: if y == 0 { 0.7pt + black } else { none },
      right: if x == 0 { 0.7pt + black } else { none },
    ),
    align: left,
    table.header([], [*Large*], [*Medium*], [*Small*]),
    [*Display*],
    [#text(font: "Roboto", size: s * 57pt)[Roboto 57/64]],
    [#text(font: "Roboto", size: s * 45pt)[Roboto 45/52]],
    [#text(font: "Roboto", size: s * 36pt)[Roboto 36/44]],

    [*Headline*],
    [#text(font: "Roboto", size: s * 32pt)[Roboto 32/40]],
    [#text(font: "Roboto", size: s * 28pt)[Roboto 28/36]],
    [#text(font: "Roboto", size: s * 24pt)[Roboto 24/32]],

    [*Title*],
    [#text(font: "Roboto", size: s * 22pt, weight: 500)[Roboto Medium 22/28]],
    [#text(font: "Roboto", size: s * 16pt, weight: 500)[Roboto Medium 16/24]],
    [#text(font: "Roboto", size: s * 14pt, weight: 500)[Roboto Medium 14/20]],

    [*Body*],
    [#text(font: "Roboto", size: s * 16pt)[Roboto 16/24]],
    [#text(font: "Roboto", size: s * 14pt)[Roboto 14/20]],
    [#text(font: "Roboto", size: s * 12pt)[Roboto 12/16]],

    [*Label*],
    [#text(font: "Roboto", size: s * 14pt, weight: 500)[Roboto Medium 14/20]],
    [#text(font: "Roboto", size: s * 12pt, weight: 500)[Roboto Medium 12/16]],
    [#text(font: "Roboto", size: s * 11pt, weight: 500)[Roboto Medium 11/16]],
  )
]


== Unidades de texto: sp (_Scale-independent Pixels_)

#grid(
  columns: (2.8fr, 1fr, 1fr),
  column-gutter: 1.5em,
  // align: top,
)[
  - *dp* (_density-independent pixels_): unidad para dimensiones de UI (márgenes, tamaños de componentes). Permite ajustar el tamaño físico de los elementos independientemente de la densidad de la pantalla.

  - *sp* (_scale-independent pixels_): la unidad equivalente para texto. Además de la densidad de pantalla, tiene en cuenta las preferencias del usuario sobre tamaño de fuente y pantalla.

  - Los usuarios ajustan estos valores en Ajustes → Pantalla → Tamaño de fuente / Tamaño de pantalla.
][
  #figure(
    image("images/google_font_size.png", width: 100%),
    caption: text(size: 0.8em)[Ajuste de _Font size_.],
  )
][
  #figure(
    image("images/google_display_size.png", width: 100%),
    caption: text(size: 0.8em)[Ajuste de _Display size_.],
  )
]


== Tipografía en Compose

#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  *1. Definir la tipografía:*

  ```kotlin
  val appTypography = Typography(
      titleLarge = TextStyle(
          fontWeight = FontWeight.SemiBold,
          fontSize = 22.sp,
          lineHeight = 28.sp,
          letterSpacing = 0.sp
      ),
      bodyLarge = TextStyle(
          fontWeight = FontWeight.Normal,
          fontFamily = FontFamily.SansSerif,
          fontSize = 16.sp,
          lineHeight = 24.sp,
          letterSpacing = 0.15.sp
      ),
      // ...
  )
  ```
][
  *2. Aplicar al tema y usar:*

  ```kotlin
  MaterialTheme(
      typography = appTypography,
  ) {
      // Contenido de la app
  }
  ```

  ```kotlin
  Text(
      text = "Título de la pantalla",
      style = MaterialTheme
          .typography.titleLarge
  )
  Text(
      text = "Cuerpo del contenido",
      style = MaterialTheme
          .typography.bodyMedium
  )
  ```

  // #figure(
  //   image("images/m3-body.png", width: 90%),
  //   caption: [Uso de _body large_, _body medium_ y _label medium_.],
  // )
]


== Forma

#grid(
  columns: (1fr, 1.1fr),
  column-gutter: 1.5em,
  align: horizon,
)[
  Las superficies M3 usan distintas formas para dirigir la atención, identificar componentes y expresar la identidad visual de la app.

  - Escala: _Extra Small_, _Small_, _Medium_, _Large_, y _Extra Large_

  #v(1em)

  #figure(
    image("images/m3-shape.png", width: 100%),
    caption: text(size: 0.95em)[_Medium_ en un Card y _Large_ en botones.],
  )

][
  ```kotlin
  val appShapes = Shapes(
      extraSmall = RoundedCornerShape(4.dp),
      small = RoundedCornerShape(8.dp),
      medium = RoundedCornerShape(12.dp),
      large = RoundedCornerShape(16.dp),
      extraLarge = RoundedCornerShape(28.dp)
  )

  MaterialTheme(shapes = appShapes) {
      // Contenido de la app
  }
  ```

  M3 usa `RoundedCornerShape` en toda su escala. Otras formas disponibles:
  - `CutCornerShape` (esquinas cortadas)
  - `CircleShape` (`RoundedCornerShape(50%)`)
  - `GenericShape` (path personalizado).
]

== Elevación

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  #set text(size: 0.98em)
  La elevación representa la distancia entre superficies (en dp). M3 la expresa mediante tres recursos visuales:
  - *Tono*: a mayor elevación, tinte más prominente del color _primary_
  - *Sombra*:
    - pequeñas y nítidas → poca distancia
    - grandes y difusas → mucha distancia
  - *Scrim*: superposición semitransparente bajo modales; en Compose es gestionado automáticamente por los componentes.

  ```kotlin
  Surface(
      tonalElevation = 3.dp,
      shadowElevation = 1.dp
  ) { /* ... */ }
  ```
][
  #image("images/m3-elevation-methods.png", width: 100%)

  1. El Floating action button (FAB) usa elevación para separarse del contenido.

  2. Un scrim aparece bajo el modal para indicar importancia.

  3. El tono diferencia la barra de navegación del contenido.
]


== Componentes: jerarquía de botones

// Fuente: https://developer.android.com/develop/ui/compose/designsystems/material3

#grid(
  columns: (1fr, 1.3fr),
  column-gutter: 1.5em,
  align: (center, horizon),
)[
  #image("images/m3-emphasis2.png", width: 100%)
][
  M3 define tres niveles de énfasis para acciones en pantalla. El nivel se expresa mediante el tipo de componente elegido.

  #v(1em)

  #[
    #set enum(spacing: 35pt)

    1. *Alto*: acción principal o más importante
      #v(0.8em, weak: true)
      `ExtendedFloatingActionButton`, `Button`

    2. *Medio*: acción importante que no distrae de la tarea principal
      #v(0.8em, weak: true)
      `FilledTonalButton`, `OutlinedButton`

    3. *Bajo*: acción opcional o complementaria
      #v(0.8em, weak: true)
      `TextButton`
  ]
]


== Componentes: navegación

// Fuente: https://developer.android.com/develop/ui/compose/designsystems/material3

#grid(
  columns: (1fr, 1.2fr),
  column-gutter: 1.5em,
  align: top,
)[
  #[
    #set text(size: 0.95em)
    M3 ofrece tres componentes de navegación según el tamaño de pantalla:
    - *`NavigationBar`*: dispositivos compactos, hasta 5 destinos, parte inferior
    - *`NavigationRail`*: tablets pequeñas o modo _landscape_, barra lateral estrecha
    - *`NavigationDrawer`*: tablets grandes, drawer permanente con etiquetas
  ]

  #v(0.75em, weak: true)

  #[
    #set text(size: 0.82em)
    ```kotlin
    NavigationBar {
        destinations.forEach { dest ->
            NavigationBarItem(
                selected = current == dest,
                onClick = { navigate(dest) },
                icon = { Icon(dest.icon, null) },
                label = { Text(dest.label) }
            )
        }
    }
    ```
  ]
][
  // Fuente: https://developer.android.com/develop/ui/compose/designsystems/material3
  #figure(
    image("images/m3-showcasebottom.png", width: 100%),
    caption: text(size: 0.9em)[`NavigationBar` (izquierda) y `NavigationRail` (derecha).],
  )
]


== Componentes: campos de texto

#grid(
  columns: (1fr, 1.35fr),
  column-gutter: 1.5em,
  // align: top,
)[
  M3 proporciona dos variantes de campo de texto, cada una con un nivel de énfasis visual distinto:

  + *Filled* (`TextField`): fondo con relleno, mayor prominencia visual. Es el estilo por defecto.

  + *Outlined* (`OutlinedTextField`): borde sin relleno, apariencia más ligera.

  Ambos soportan etiqueta flotante, texto de ayuda, iconos y estados de error.


][
  #figure(
    image("images/google_text_fields.png", width: 90%),
    caption: text(size: 0.8em)[1\. Filled text field. #h(1em) 2. Outlined text field.],
  )

  #[
    #set text(size: 0.9em)
    ```kotlin
    OutlinedTextField(
        value = text,
        onValueChange = { text = it },
        label = { Text("Email") },
        leadingIcon = {Icon(Icons.Default.Email, null)},
        isError = !isValid
    )
    ```
  ]
]


== Componentes: FAB, Snackbar y Cards

#grid(
  columns: (1.5fr, 2fr),
  column-gutter: 1.5em,
  row-gutter: 0.5em,
  align: horizon,
)[
  #image("images/google_fab_types.png", width: 100%)
][
  *Floating Action Button*: acción principal de la pantalla. Tres tamaños: `FloatingActionButton`, `SmallFloatingActionButton` y `ExtendedFloatingActionButton` (con texto).
][
  #set align(right)
  #image("images/google_snackbar.png", height: 33%)
][
  *Snackbar*: mensajes breves en la parte inferior. Puede incluir una acción opcional.
][
  #set align(right)
  #image("images/google_cards.png", height: 33%)
][
  *Cards*: contenedor para agrupar contenido y acciones de un mismo elemento. M3 ofrece 3 variantes: `Card` (filled), `ElevatedCard` y `OutlinedCard`.
]


// ============================================================================
// 5. PANTALLAS ADAPTABLES
// ============================================================================

= Pantallas adaptables

== Diferentes factores de forma

// Imagen: Diferentes dispositivos Android (teléfono, tablet, plegable, ChromeOS)
// Fuente: https://developer.android.com/guide/topics/large-screens


#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 14pt,
  radius: 5pt,
)[
  Android se ejecuta en una amplia variedad de dispositivos.

  Una app de calidad debe adaptarse al dispositivo, no simplemente "estirarse".
]

#table(
  columns: (9em, 1fr, 8em),
  inset: (x: 8pt, y: 14pt),
  align: left,
  table.header([*Factor de forma*], [*Características*], [*Ancho típico*]),
  [Teléfono], [Una mano, pantalla vertical], [< 600 dp],
  [Tablet], [Dos manos o sobre superficie, más espacio], [600--840 dp+],
  [Plegable], [Modo plegado (teléfono) y desplegado (tablet)], [Variable],
  [ChromeOS], [Teclado, ratón, ventanas redimensionables], [840 dp+],
  [Android Auto], [Interacción mínima, atención en la carretera], [Variable],
)


== Window size classes

// Fuente: https://developer.android.com/develop/ui/compose/layouts/adaptive/use-window-size-classes

Las Window size classes son una abstracción que clasifica el espacio disponible para la app en categorías, facilitando las decisiones de layout. Cambian dinámicamente (rotación, multi-window, plegado).

#align(center)[
  #image("images/window_size_classes_width.png", width: 95%)
]

---

#grid(
  columns: (1fr, 2fr),
  column-gutter: 1.5em,
  align: top,
)[
  #[
    Hay 5 clases según el ancho y 3 según el alto.

    #v(0.5em)

    *Ancho:*
    #v(0.6em, weak: true)
    #[
      #set text(size: 0.95em)
      #table(
        columns: (1fr, 1fr),
        inset: (x: 6pt, y: 6pt),
        align: left + top,
        stroke: (x, y) => (
          top: if (y == 0) { luma(20%) } else { none },
          bottom: if (y == 4) { luma(20%) } else { none },
        ),
        [Compact], [< 600 dp],
        [Medium], [600--840 dp],
        [Expanded], [840--1200 dp],
        [Large], [1200--1600 dp],
        [Extra-large], [≥ 1600 dp],
      )
    ]

    #v(0.5em)

    *Alto:*
    #v(0.6em, weak: true)
    #[
      #set text(size: 0.95em)
      #table(
        columns: (1fr, 1fr),
        inset: (x: 6pt, y: 6pt),
        align: left + top,
        stroke: (x, y) => (
          top: if (y == 0) { luma(20%) } else { none },
          bottom: if (y == 2) { luma(20%) } else { none },
        ),
        [Compact], [< 480 dp],
        [Medium], [480--900 dp],
        [Expanded], [≥ 900 dp],
      )
    ]
  ]
][
  #[
    #set text(size: 1em)
    Se consultan con `isWidthAtLeastBreakpoint` / `isHeightAtLeastBreakpoint`. Esto permite a la app cambiar el layout según el tamaño de la pantalla:

    #set text(size: 0.95em)
    ```kotlin
    @Composable
    fun MyApp(
        windowSizeClass: WindowSizeClass =
            currentWindowAdaptiveInfo(
                supportLargeAndXLargeWidth = true
            ).windowSizeClass
    ) {
        val showTopAppBar =
            windowSizeClass.isHeightAtLeastBreakpoint(
                WindowSizeClass.HEIGHT_DP_MEDIUM_LOWER_BOUND
            )

        MyScreen(showTopAppBar = showTopAppBar)
    }
    ```
  ]
]


== Canonical layouts

// Fuente: https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts

Google define 3 layouts canónicos derivados de las guías de Material Design. Son patrones probados que proporcionan una buena experiencia en cualquier factor de forma:

#v(1em, weak: true)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 1em,
  align: top,
)[
  #figure(
    image("images/layout_list-detail_wireframe.png", width: 90%),
    gap: 0.4em,
    caption: text(size: 0.8em)[*List-detail*],
  )
][
  #figure(
    image("images/layout_feed_wireframe.png", width: 90%),
    gap: 0.4em,
    caption: text(size: 0.8em)[*Feed*],
  )
][
  #figure(
    image("images/layout_supporting_pane_wireframe.png", width: 90%),
    gap: 0.4em,
    caption: text(size: 0.8em)[*Supporting pane*],
  )
]

#v(1em, weak: true)

#[
  #set text(size: 0.9em)
  #table(
    columns: (6.5em, 1fr, 1fr, 6em),
    inset: (x: 5pt, y: 5pt),
    align: left,
    fill: (x, y) => if x == 0 or y == 0 { luma(92%) } else { none },
    stroke: 0.7pt + luma(40%),
    table.header([*Layout*], [*Descripción*], [*Comportamiento adaptable*], [*Ejemplos*]),
    [*List-detail*],
    [Lista + panel de detalle del elemento seleccionado],
    [_Compact_: solo lista o detalle \ _Expanded_: ambos paneles],
    [Gmail, Contactos],

    [*Feed*],
    [Grid de tarjetas; el nº de columnas se adapta al ancho],
    [_Compact_: 1 columna \ _Expanded_: 3+ columnas],
    [Play Store, noticias],

    [*Supporting pane*],
    [Contenido principal (~70%) + panel complementario (~30%)],
    [_Compact_: panel oculto o debajo \ _Expanded_: panel lateral],
    [Google Docs, Maps],
  )
]


== Canonical layouts: implementación en Compose

// Fuente: https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts

Compose proporciona _scaffolds_ para cada canonical layout. Ejemplo de list-detail:
#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  #[
    #set text(size: 0.85em)
    ```kotlin
    val navigator =
        rememberListDetailPaneScaffoldNavigator<Any>()

    ListDetailPaneScaffold(
        directive = navigator.scaffoldDirective,
        value = navigator.scaffoldValue,
        listPane = { AnimatedPane {
            ItemList(onItemClick = { item ->
                navigator.navigateTo(
                    ListDetailPaneScaffoldRole.Detail,
                    item)
            })
        } },
        detailPane = { AnimatedPane {
            ItemDetail(
                navigator.currentDestination?.content)
        } }
    )
    ```
  ]
][
  // Fuente: https://developer.android.com/develop/ui/compose/layouts/adaptive/support-different-display-sizes
  #figure(
    image("images/adaptive-list-detail.png", width: 100%),
    caption: text(size: 0.8em)[List-detail en tablet con Navigation Rail.],
  )
]

== Orientación y redimensionado (Android 16)

// Fuente: https://developer.android.com/develop/ui/compose/layouts/adaptive/app-orientation-aspect-ratio-resizability

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  #set text(size: 0.95em)
  Las apps pueden declarar en el manifest restricciones que limitan su presentación:

  - *`screenOrientation`*: forzar solo portrait o landscape. En tablets, la app aparecía en una ventana pequeña centrada (_letterboxing_).
  - *`resizeableActivity = false`*: impedir el modo multi-ventana.
  - *`minAspectRatio` / `maxAspectRatio`*: limitar la proporción. Podía generar bandas negras.

  A partir de Android 16 (API 36), el sistema ignora estos atributos en dispositivos con smallest width ≥ 600 dp y estira la app para ocupar toda la pantalla. A partir de API 37 no será posible desactivar este comportamiento.
][
  #block(
    fill: rgb("#fff2df"),
    width: 100%,
    inset: 12pt,
    radius: 5pt,
  )[
    #warning_symb *Buenas prácticas:*

    - *No bloquear* orientación ni aspect ratio
    - Diseñar layouts que funcionen en *cualquier orientación*
    - *Preservar estado* durante cambios de configuración
    - Usar *window size classes* en vez de asumir un dispositivo concreto
  ]

  Excepción: apps declaradas como juegos (`android:appCategory="game")` y pantallas < 600 dp no se ven afectadas.
]


== Niveles de calidad adaptable

// Fuente: https://developer.android.com/docs/quality-guidelines/large-screen-app-quality
// Fuente imágenes: https://developer.android.com/guide/topics/large-screens/tier-2-overview

#grid(
  columns: (2.4fr, 1fr),
  column-gutter: 1em,
  align: bottom,
  // stroke: black,
)[
  #[
    Google define *3 niveles* (_tiers_) de calidad para apps en pantallas grandes. Google Play prioriza en el ranking las apps con mejor nivel:

    #set text(size: 0.78em)
    #table(
      columns: (6.5em, 13.5em, 1fr),
      inset: (x: 6pt, y: 7pt),
      align: left,
      table.header([*Nivel*], [*Qué implica*], [*Requisitos clave*]),
      [*Tier 3* \ _Adaptive Ready_],
      [La app funciona en pantallas grandes sin _letterboxing_ ni modo de compatibilidad],
      [Ocupa toda la pantalla \ Soporta multi-window \ Preserva estado en rotación],

      [*Tier 2* \ _Adaptive Optimized_],
      [La app se adapta al espacio disponible con layouts optimizados],
      [Layouts de 2 paneles \ Navigation Rail / Drawer \ Atajos de teclado],

      [*Tier 1* \ _Adaptive Differentiated_],
      [La app ofrece una experiencia diferenciada imposible en pantalla pequeña],
      [Multi-instancia y drag \& drop \ Posturas de plegable \ Soporte avanzado de stylus],
    )
  ]
  *Tier 3* es el mínimo para publicar en Play Store para tablets (obligatorio desde agosto 2026 con API 36).
][
  #figure(
    image("images/tier_2_dont.png", width: 100%),
    gap: 0.3em,
    caption: text(size: 0.8em)[Tier 3: UI estirada sin adaptar.],
  )
  #figure(
    image("images/tier_2_do.png", width: 100%),
    gap: 0.3em,
    caption: text(size: 0.8em)[Tier 2: atajos de teclado, navigation rail.],
  )
]


// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

== Recursos y Documentación

#grid(
  columns: 2,
  column-gutter: 1.5em,
  align: top,
)[
  *Diseño y desarrollo Android*

  - #link("https://developer.android.com/design")[Android Design Guidelines]
  - #link("https://m3.material.io")[Material Design 3]
  - #link("https://developer.android.com/jetpack/compose/designsystems/material3")[Material 3 en Jetpack Compose]
  - #link("https://developer.android.com/guide/navigation/principles")[Navigation Principles]
  - #link("https://developer.android.com/guide/topics/large-screens")[Large Screens Guide]
  - #link("https://developer.android.com/guide/topics/ui/accessibility")[Accessibility Guide]
  - #link("https://developer.android.com/docs/quality-guidelines/core-app-quality")[Core App Quality]
  - #link("https://developer.android.com/docs/quality-guidelines/large-screen-app-quality")[Large Screen App Quality]
][
  *UX y dark patterns*

  - #link("https://www.deceptive.design/")[Deceptive Design (Harry Brignull)]
  - #link("https://www.deceptive.design/types")[Tipos de deceptive patterns]
  - #link("https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32022R2065")[DSA --- Reglamento (UE) 2022/2065]

  *Herramientas y ejemplos*

  - #link(
      "https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.auditor",
    )[Accessibility Scanner]
  - #link("https://material-foundation.github.io/material-theme-builder/")[Material Theme Builder]
  - #link("https://github.com/android/compose-samples/tree/main/Reply")[Reply --- Compose Sample App]
]
