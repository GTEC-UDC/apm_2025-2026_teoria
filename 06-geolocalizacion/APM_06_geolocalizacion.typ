// ============================================================================
// Geolocalización en Android
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Geolocalización en Android],
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

= Introducción a la Geolocalización

== Nota Terminológica: _Localization_ vs _Location_

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  En inglés se distinguen dos términos que en español se traducen ambos como "localización":

  - *Localization* (_l10n_): proceso de adaptar una app a distintos idiomas y regiones (internacionalización).
  - *Location*: posicionamiento geográfico del dispositivo (latitud, longitud, altitud).
]

En esta presentación usamos *geolocalización* y *localización* como sinónimos de *posicionamiento geográfico* (_location_).

Al buscar en la documentación de Android en inglés, hay que tener cuidado de no confundir ambos términos: buscar _"location"_ para posicionamiento y _"localization"_ para internacionalización.


== ¿Por qué Geolocalización?

La geolocalización es una de las capacidades más distintivas de los dispositivos móviles. Permite crear experiencias que no son posibles en un ordenador de escritorio:

- *Navegación y mapas*: rutas, indicaciones paso a paso.
- *Servicios basados en ubicación*: restaurantes cercanos, gasolineras, transporte.
- *Redes sociales*: check-ins, compartir ubicación en tiempo real.
- *Geofencing*: acciones automáticas al entrar o salir de una zona (domótica, alertas).
- *Seguimiento y logística*: rastreo de vehículos, entregas, flotas.
- *Juegos de realidad aumentada*: Pokémon GO, Ingress.

Sin embargo, la localización plantea retos importantes: *consumo de batería*, *privacidad del usuario* y *precisión variable* según el entorno.


== API de localización de Android: `LocationManager`

Android incluye en su framework la clase `LocationManager`, que permite a las apps solicitar localización directamente al sistema operativo. Es la API original de localización, disponible desde Android 1.0.

`LocationManager` trabaja con *proveedores de localización* (_location providers_): cada proveedor obtiene la posición usando una tecnología diferente. La app solicita localización a un proveedor concreto (o a varios) a través del `LocationManager`.

#[
  #set text(size: 0.95em)
  ```kotlin
  // Obtener el LocationManager del sistema
  val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

  // Solicitar localización al proveedor GPS
  locationManager.requestLocationUpdates(
      LocationManager.GPS_PROVIDER, // proveedor
      10_000L,                      // intervalo mínimo entre actualizaciones (ms)
      10f,                          // desplazamiento mínimo entre actualizaciones (m)
      listener                      // callback que recibe las actualizaciones
  )
  ```
]


== Proveedores de Localización

Cada proveedor de `LocationManager` usa una tecnología distinta para estimar la posición:

#table(
  columns: (auto, 1fr, auto),
  inset: 8pt,
  align: (left, left, left),
  table.header([*Proveedor*], [*Tecnología*], [*Precisión*]),
  [`GPS_PROVIDER`],
  [Señales de satélites GNSS (GPS, Galileo, GLONASS...). Requiere cielo despejado. Alto consumo de batería.],
  [$~$2--10 m],

  [`NETWORK_PROVIDER`],
  [Torres de telefonía móvil y puntos de acceso Wi-Fi. Funciona en interiores. Bajo consumo.],
  [$~$15--50 m],

  [`PASSIVE_PROVIDER`],
  [
    #set text(size: 0.95em)
    No activa hardware propio: recibe las posiciones que el sistema ya calculó para otras apps (vía `GPS_PROVIDER` o `NETWORK_PROVIDER`). Si ninguna app solicita localización, no recibe nada. Útil en segundo plano cuando no se necesita alta frecuencia ni precisión garantizada.
  ],
  [Variable],
)

La app debe *elegir qué proveedor usar* según sus necesidades de precisión y consumo, y gestionar manualmente los cambios entre proveedores.


== Estimación de posición: Trilateración

#[
  #grid(
    columns: (1.2fr, 1fr),
    column-gutter: 1.5em,
    align: horizon,
    [
      La *trilateración* estima la posición a partir de la distancia a varios emisores cuya posición geográfica es conocida.

      #v(0.5em)

      La distancia medida a cada emisor define una *circunferencia* centrada en él: el dispositivo se encuentra en algún punto de esa circunferencia.

      #v(0.5em)

      Con un solo emisor la posición es ambigua; con dos se obtienen dos candidatos; con *tres o más* se determina un *punto único* de intersección.
    ],
    [
      #align(center)[
        #image("images/trilateration.svg", width: 100%)
      ]
    ],
  )
]


== Estimación de posición: Técnicas de Medición

#[
  #set text(size: 0.95em)

  #grid(
    columns: (1.2fr, 1fr),
    column-gutter: 1.5em,
    align: horizon,
    [
      La distancia al emisor se estima de forma diferente según la tecnología:

      - *Tiempo de llegada* (ToA/TDoA): usado en *GPS* y redes celulares modernas (*LTE, 5G*). Muy preciso, pero GPS requiere visibilidad de los satélites y LTE/5G requiere sincronización de la red.
      - *RSSI* (intensidad de señal): funciona con *Wi-Fi y torres de telefonía*. Es el método más común pero menos preciso, ya que la señal varía con obstáculos e interferencias.
      - *Wi-Fi Round Trip Time (RTT)* (802.11mc): variante temporal para *Wi-Fi*, disponible desde Android 9. Muy precisa ($~$1--2 m), pero requiere APs compatibles (aún poco habitual).
    ],
    [
      #align(center)[
        #image("images/trilateration.svg", width: 100%)
      ]
    ],
  )
]


== `GPS_PROVIDER`

#[
  #set text(size: 0.9em)
  #grid(
    columns: (1.5fr, 1fr),
    column-gutter: 1.5em,
    align: horizon,
    [
      El `GPS_PROVIDER` usa señales de los sistemas GNSS (GPS, Galileo, GLONASS, BeiDou). Cada satélite emite continuamente su posición orbital y la hora exacta (relojes atómicos).

      El receptor mide el *tiempo de llegada* de cada señal y calcula su distancia a ese satélite (ToA). Con señales de *cuatro o más satélites* determina latitud, longitud, altitud y corrige su propio error de reloj.

      - *Ventajas:* muy preciso ($~$2--10 m), no requiere conexión de red.
      - *Limitaciones:* necesita visibilidad directa del cielo, no funciona en interiores. Alto consumo de batería.
    ],
    [
      #align(center)[
        #image("images/GPS24goldenSML.png", width: 80%)
        #text(size: 0.95em)[
          Constelación GPS (24 satélites).\ Fuente: #link("https://commons.wikimedia.org/wiki/File:GPS24goldenSML.gif")[Wikimedia Commons]
        ]
      ]
    ],
  )
]


== `NETWORK_PROVIDER`

#[
  #set text(size: 0.94em)
  Obtiene la posición mediante trilateración de torres de telefonía y puntos de acceso Wi-Fi.

  *Torres de telefonía:*
  - Mide la intensidad de señal (o tiempo de llegada) de varias antenas cercanas.
  - Consulta sus identificadores (Cell ID, MCC, MNC, LAC) en la base de datos online.

  *Wi-Fi:*
  - Escanea redes cercanas *sin conectarse*, obteniendo el BSSID e intensidad de señal (RSSI) de cada punto de acceso.
  - Consulta esos identificadores en la base de datos online.

  Ambas tecnologías consultan bases de datos online para obtener las coordenadas de los emisores:
  - *Con Google Play Services*: Google mantiene sus propias bases de datos (recopiladas por Street View y los propios dispositivos Android).
  - *Sin Google Play Services*: el fabricante proporciona su propia implementación.

  #warning_symb A diferencia del GPS (señal satelital), el `NETWORK_PROVIDER` requiere *conexión a internet* para consultar las coordenadas de torres y APs.
]


== Limitaciones de `LocationManager`

Trabajar directamente con `LocationManager` presenta varios problemas:

- *Gestión manual de proveedores:* la app debe decidir cuándo usar GPS, red o ambos, y cambiar entre ellos según la disponibilidad.

- *Sin fusión de datos:* no combina automáticamente datos de GPS, Wi-Fi y sensores inerciales para mejorar la estimación.

- *Optimización de batería manual:* la app es responsable de ajustar la frecuencia y parar las solicitudes.

// - *API de bajo nivel:* más código para conseguir los mismos resultados.

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  Por estas razones, Google desarrolló una API de más alto nivel: el *Fused Location Provider*, disponible a través de *Google Play Services*. Es la API recomendada por Google para obtener la geolocalización del sistema
]

== Google Play Services

*Google Play Services* es un conjunto de APIs y servicios de Google que se ejecutan como un proceso en segundo plano en los dispositivos Android. Se actualizan de forma *independiente al sistema operativo* a través de Google Play Store.

Entre sus servicios se incluyen los *Location Services*, que proporcionan APIs de localización de alto nivel:

- *Fused Location Provider*: obtención de localización fusionando múltiples fuentes.
- *Geofencing*: detección de entrada/salida de zonas geográficas.
- *Activity Recognition*: detección de la actividad del usuario (andar, conducir...).

Al ser parte de Google Play Services, estas APIs están disponibles en la mayoría de dispositivos Android sin depender de la versión del SO. No están disponibles en dispositivos sin Google Play Services (AOSP puro, Amazon Fire, Huawei sin GMS...).


== Fused Location Provider

El *Fused Location Provider* (FLP) es la API de localización de Google Play Services y la *recomendada por Google*. Abstrae las complejidades de `LocationManager`.

#[
  #set text(size: 0.85em)
  #table(
    columns: (0.3fr, 0.8fr, 1fr),
    inset: (x: 8pt, y: 8pt),
    align: (left, left, left),
    table.header([*Aspecto*], [*`LocationManager`*], [*Fused Location Provider*]),
    [*Selección de fuente*],
    [Manual: la app elige entre GPS, red móvil o pasivo.],
    [Automática: el sistema decide qué fuentes usar sin intervención de la app.],

    [*Fusión de datos*],
    [No. Usa un solo proveedor a la vez.],
    [Sí. Combina simultáneamente GPS, Wi-Fi, red móvil y sensores inerciales para mayor precisión.],

    [*Batería*], [Gestión manual por la app.], [Optimización automática según la prioridad solicitada.],
    [*Requisitos*], [Incluido en Android (sin dependencias).], [Requiere Google Play Services en el dispositivo.],
  )
]

En este curso nos centraremos en el *Fused Location Provider*, ya que es la opción recomendada para la gran mayoría de apps Android.


// ============================================================================
// BLOQUE 2: PERMISOS DE LOCALIZACIÓN
// ============================================================================

= Permisos de Localización

== Tipos de Permisos de Localización

#[
  #set text(size: 0.95em)
  Android define tres permisos relacionados con la localización, con distintos niveles de acceso:

  #table(
    columns: (auto, 1fr, 0.4fr),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Permiso*], [*Descripción*], [*Precisión*]),
    [`ACCESS_COARSE_LOCATION`], [Localización *aproximada*. Basada en torres de telefonía y Wi-Fi.], [$~$100--300 m],

    [`ACCESS_FINE_LOCATION`], [Localización *precisa*. Usa GPS además de red y Wi-Fi.], [$~$1--50 m],

    [`ACCESS_BACKGROUND_LOCATION`],
    [Permite acceder a la localización cuando la app *no está en primer plano*. Requiere uno de los dos anteriores.],
    [Igual al permiso de primer plano concedido],
  )

  - `ACCESS_COARSE_LOCATION` y `ACCESS_FINE_LOCATION` son permisos de *localización en primer plano* (_foreground_).
  - `ACCESS_BACKGROUND_LOCATION` es un permiso adicional necesario a partir de Android 10 (API 29).
]


== Declarar Permisos en el Manifest

Los permisos se declaran en el fichero `AndroidManifest.xml`.

#warning_symb Declarar un permiso en el Manifest *no lo concede automáticamente*: el usuario debe aceptarlo en tiempo de ejecución (_runtime_).

#[
  #set text(size: 0.88em)
  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">

      <!-- Localización aproximada (siempre incluir) -->
      <uses-permission
          android:name="android.permission.ACCESS_COARSE_LOCATION" />

      <!-- Localización precisa (solo si la app lo necesita) -->
      <uses-permission
          android:name="android.permission.ACCESS_FINE_LOCATION" />

      <!-- Localización en segundo plano (Android 10+, solo si es necesario) -->
      <uses-permission
          android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

  </manifest>
  ```
]


== Solicitar Permisos en Runtime

Desde Android 6.0 (API 23), los permisos peligrosos (_dangerous permissions_) como la localización se solicitan en *tiempo de ejecución*. Una vez concedido, el permiso se persiste entre ejecuciones de la app (no se vuelve a preguntar).

Las opciones disponibles en el diálogo de permisos han evolucionado a lo largo de las diferentes versiones de Android:

#[
  #set text(size: 0.9em)
  #table(
    columns: (auto, 1fr),
    inset: 8pt,
    align: (left, left),
    table.header([*Versión*], [*Opciones del diálogo de permisos*]),
    [Android 6--9], [*Permitir* (persistente) o *Denegar*.],
    [Android 10],
    [Añade *"Solo mientras se usa la app"* para localización: el permiso solo se aplica cuando la app está en primer plano.],

    [Android 11+],
    [Añade *"Solo esta vez"* (_one-time permission_): el permiso se revoca automáticamente al salir de la app, y debe solicitarse de nuevo en el siguiente acceso.],
  )
]

== Activity Result API
#[
  #set text(size: 0.92em)
  Muchas operaciones en Android se implementan como *Activities independientes* con su propia pantalla: el diálogo de permisos, el selector de ficheros, la cámara... La *Activity Result API* (Jetpack) proporciona un mecanismo para *lanzar una de estas Activities y recibir su resultado* de forma type-safe.

  Se basa en *contratos* (`ActivityResultContract<Input, Output>`): cada contrato define qué datos se envían al lanzar la operación y qué tipo de resultado se recibe. Algunos contratos predefinidos:

  #[
    #set text(size: 0.92em)

    #table(
      columns: (auto, auto, auto, 1fr),
      inset: 8pt,
      align: (left, left, left, left),
      table.header([*Contrato*], [*Input*], [*Output*], [*Uso*]),
      [`RequestPermission`], [`String`], [`Boolean`], [Solicitar un permiso.],
      [`RequestMultiplePermissions`], [`Array<String>`], [`Map<String, Boolean>`], [Solicitar varios permisos.],
      [`TakePicture`], [`Uri`], [`Boolean`], [Capturar foto y guardarla en una Uri.],
      [`GetContent`], [`String` (MIME)], [`Uri?`], [Seleccionar un fichero del dispositivo.],
    )
  ]
]


== Registrar el callback para un resultado de actividad

Cuando se lanza una Activity externa, el proceso de la app puede ser destruido por el sistema (p.ej. por falta de memoria). Por eso, la Activity Result API *separa el registro del callback del momento en que se lanza la operación*: el callback debe registrarse siempre al crear el Composable, no dentro de un evento de usuario.

En Compose, *`rememberLauncherForActivityResult`* registra el callback y devuelve un `ManagedActivityResultLauncher`. Debe llamarse en el cuerpo del Composable, *nunca* dentro de un `onClick` u otro lambda:

```kotlin
// Correcto: en el cuerpo del Composable (se registra siempre)
val launcher = rememberLauncherForActivityResult(
    contract = ActivityResultContracts.RequestMultiplePermissions()
) { resultado ->
    // callback: se ejecuta cuando el usuario responde al diálogo
}
```

El prefijo `remember` garantiza que el mismo launcher se reutiliza entre recomposiciones.


== Lanzar la operación de la activity externa

Una vez registrado el launcher, se llama a *`.launch(input)`* para disparar la operación, normalmente en respuesta a un evento del usuario:

#v(0.5em)

```kotlin
Button(onClick = {
    launcher.launch(arrayOf(
        Manifest.permission.ACCESS_FINE_LOCATION,
        Manifest.permission.ACCESS_COARSE_LOCATION
    ))
}) {
    Text("Solicitar permisos de localización")
}
```

#v(0.5em)

El sistema lanza la Activity correspondiente (en este ejemplo, el diálogo de permisos). Cuando el usuario responde, se ejecuta el callback registrado anteriormente.


== Ejemplo: Solicitar Permisos con Activity Result API

#grid(
  columns: (1fr, 0.5fr),
  column-gutter: 1.5em
)[
  #set text(size: 0.75em)
  ```kotlin
  // 1. Definir el launcher para solicitar permisos
  val locationPermissionRequest = rememberLauncherForActivityResult(
      contract = ActivityResultContracts.RequestMultiplePermissions()
  ) { permissions ->
      when {
          permissions.getOrDefault(
              Manifest.permission.ACCESS_FINE_LOCATION, false) -> {
              // El usuario concedió localización precisa
          }
          permissions.getOrDefault(
              Manifest.permission.ACCESS_COARSE_LOCATION, false) -> {
              // Solo localización aproximada disponible
          }
          else -> {
              // El usuario denegó los permisos
          }
      }
  }

  // 2. Lanzar la solicitud de permisos
  locationPermissionRequest.launch(arrayOf(
      Manifest.permission.ACCESS_FINE_LOCATION,
      Manifest.permission.ACCESS_COARSE_LOCATION
  ))
  ```
][
  //#set text(size: 0.9em)
  - Contrato para solicitar permisos de localización: *`RequestMultiplePermissions`*

  - Devuelve un `Map<String, Boolean>` con el resultado de cada permiso.

  - Dentro del callback el usuario puede comprobar los permisos que el usuario ha aprobado o denegado.
]


== Diálogo de Permisos en Android 12+

A partir de Android 12 (API 31), el diálogo de permisos de localización ofrece al usuario *dos niveles de precisión*:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    #block(
      fill: luma(95%),
      width: 100%,
      inset: 12pt,
      radius: 5pt,
    )[
      *Opciones del diálogo:*
      - *Precisa* (_Precise_): concede `ACCESS_FINE_LOCATION`.
      - *Aproximada* (_Approximate_): concede solo `ACCESS_COARSE_LOCATION`.
    ]

    - El usuario puede elegir un nivel *inferior* al solicitado por la app.
    - La app debe funcionar correctamente con localización aproximada si el usuario la elige.
  ],
  [
    #align(center)[
      #grid(
        columns: (1fr, 1fr),
        [
          #image("images/permission-dialog-full.svg", width: 76%)
          #v(0.5em, weak: true)
          #set text(size: 0.9em)
          #align(center)[`FINE` + `COARSE`]
        ],
        [
          #image("images/permission-dialog-approximate.svg", width: 76%)
          #v(0.5em, weak: true)
          #set text(size: 0.9em)
          #align(center)[Solo `COARSE`]
        ],
      )
    ]
  ],
)


== Solicitar `FINE` y `COARSE` juntos

#grid(
  columns: (1fr, 0.35fr),
  column-gutter: 1.5em,
  align: (left, center + horizon),
  [
    `ACCESS_FINE_LOCATION` incluye implícitamente `ACCESS_COARSE_LOCATION`. Sin embargo, desde Android 12 el usuario puede *degradar* la precisión: aunque la app pida `FINE`, puede conceder solo `COARSE`.

    Por eso se recomienda solicitar ambos y manejar los tres escenarios posibles en el callback:

    + *`FINE` concedido* → localización precisa disponible.
    + *Solo `COARSE` concedido* → la app funciona con menor precisión.
    + *Ambos denegados* → la app funciona sin localización.

    #warning_symb Si solo se solicita `FINE` y el usuario elige aproximada, la app no lo detecta y puede interpretar el resultado como denegación.
  ],
  [
    #image("images/permission-dialog-full.svg", width: 90%)
    #v(0.5em, weak: true)
    #set text(size: 0.9em)
    #align(center)[`FINE` + `COARSE`]
  ],
)



== Permisos de Localización en Segundo Plano


#[
  #set text(size: 0.84em)
  #grid(
    columns: (1fr, 0.28fr),
    column-gutter: 1.5em,
    align: (left, center + horizon),
    [
      El permiso `ACCESS_BACKGROUND_LOCATION` permite acceder a la localización cuando la app *no está visible* (ni en una Activity visible ni en un foreground service).

      #warning_symb La *Google Play Store* restringe el uso de localización en segundo plano a apps que lo necesiten como *funcionalidad esencial*: geofencing, navegación y registro de rutas, compartir ubicación familiar de forma continua, domótica, etc.

      *Restricciones por versión de Android:*
      #v(0.8em, weak: true)
      #table(
        columns: (auto, 1fr),
        inset: 8pt,
        align: (left, left),
        table.header([*Versión*], [*Comportamiento*]),
        [Android 9 y anterior], [El permiso de primer plano incluye automáticamente el de segundo plano.],
        [Android 10 (API 29)], [Se debe declarar y solicitar `ACCESS_BACKGROUND_LOCATION` *por separado*.],
        [Android 11+ (API 30)],
        [El diálogo del sistema ya no muestra "Permitir siempre". El usuario debe ir a *Ajustes* manualmente y seleccionar "Permitir siempre" para permitir la lolalización en segundo plano.],
      )


    ],
    [
      #image("images/background-location-settings.svg", width: 95%)
      #set text(size: 0.84em)
      #align(center)[Ajustes de permisos de localización en Android 11+]
    ],
  )
]


// ============================================================================
// BLOQUE 3: FUSED LOCATION PROVIDER
// ============================================================================

= Fused Location Provider

== Dependencia de Google Play Services

#[
  #set text(size: 0.96em)
  El *Fused Location Provider* es el API principal de Google Play Services para obtener la localización del dispositivo.

  Para usar el Fused Location Provider, el dispositivo debe tener Google Play Services instalado y se debe añadir la dependencia de `play-services-location` en el fichero `build.gradle.kts` del módulo `app`:

  ```kotlin
  dependencies {
      implementation("com.google.android.gms:play-services-location:21.3.0")
  }
  ```

  Esta dependencia proporciona:
  - `FusedLocationProviderClient`: cliente principal para solicitar localización.
  - `LocationRequest`: configuración de las solicitudes de localización.
  - `LocationCallback`: callback para recibir actualizaciones.
  - `GeofencingClient`: cliente para geofencing.
  - `Priority`: constantes de prioridad (precisión vs. batería).
]

== Crear el Cliente de Localización

El primer paso es crear una instancia de `FusedLocationProviderClient`. En una Activity, se inicializa en `onCreate()`:
#v(0.5em, weak: true)
#[
  #set text(size: 0.85em)
  ```kotlin
  private lateinit var fusedLocationClient: FusedLocationProviderClient

  override fun onCreate(savedInstanceState: Bundle?) {
      super.onCreate(savedInstanceState)
      fusedLocationClient =
          LocationServices.getFusedLocationProviderClient(this)
  }
  ```
]

En Jetpack Compose, se obtiene a partir del contexto:
#v(0.5em, weak: true)
#grid(
  columns: (1fr, 0.48fr),
  column-gutter: 1.5em,
  align: (left, top),
  [
    #set text(size: 0.85em)
    ```kotlin
    @Composable
    fun LocationScreen() {
        val context = LocalContext.current
        val fusedLocationClient = remember {
            LocationServices.getFusedLocationProviderClient(context)
        }
    }
    ```
  ],
  [
    #set text(size: 0.75em)
    *`LocalContext.current`*: proporciona el `Context` de Android desde un composable. Da acceso a los servicios del sistema (GPS, red, etc.).
    *`LocationServices`*: clase de Google Play Services que actúa como punto de entrada para obtener los clientes de las APIs de localización.
  ],
)


== Obtener la Posición Actual: `getCurrentLocation`

*Forma recomendada por Google* para obtener la posición en un momento concreto. Solicita al sistema una posición actualizada, activando si es necesario el GPS u otras fuentes.

#grid(
  columns: (1fr, 0.5fr),
  column-gutter: 1.5em,
  align: (left, top),
  [
    #[
      #set text(size: 0.75em)
      ```kotlin
      val priority = Priority.PRIORITY_HIGH_ACCURACY
      val cancellationToken = CancellationTokenSource().token

      // Requiere permiso ACCESS_FINE_LOCATION o ACCESS_COARSE_LOCATION
      fusedLocationClient.getCurrentLocation(priority, cancellationToken)
          .addOnSuccessListener { location: Location? ->
              if (location != null) {
                  val lat = location.latitude
                  val lng = location.longitude
                  Log.d("Location", "Lat: $lat, Lng: $lng")
              }
          }
          .addOnFailureListener { exception ->
              Log.e("Location", "Error", exception)
          }
      ```
    ]

    #[
      #set text(size: 0.85em)
      #warning_symb `getCurrentLocation()` puede devolver *`null`* si la localización está desactivada en el dispositivo o si la solicitud se cancela mediante el token de cancelación.
    ]
  ],
  [
    #set text(size: 0.85em)
    Las APIs de Google Play Services son *asíncronas*: devuelven un *`Task<T>`* en lugar del resultado directamente.

    `addOnSuccessListener` y `addOnFailureListener` registran callbacks que se ejecutan cuando la operación termina, sin bloquear el hilo principal.

    El *token de cancelación* permite abortar la solicitud si ya no se necesita (p.ej. al salir de la pantalla).
  ],
)


== Última Posición Conocida: `lastLocation`

Alternativa a `getCurrentLocation`: devuelve la *última posición almacenada en caché* por el sistema, sin activar hardware directamente.

```kotlin
// Requiere permiso ACCESS_FINE_LOCATION o ACCESS_COARSE_LOCATION
fusedLocationClient.lastLocation
    .addOnSuccessListener { location: Location? ->
        if (location != null) {
            val lat = location.latitude
            val lng = location.longitude
            Log.d("Location", "Lat: $lat, Lng: $lng")
        }
    }
```

#warning_symb `lastLocation` puede devolver *`null`*: si la localización está desactivada, el dispositivo nunca ha registrado una posición, o Google Play Services se reinició sin solicitudes posteriores.


== Configurar la Solicitud: `LocationRequest`

Para recibir *actualizaciones periódicas* de localización se usa un `LocationRequest`, que define los parámetros de la solicitud:

#v(0.5em)

```kotlin
val locationRequest = LocationRequest.Builder(
    Priority.PRIORITY_HIGH_ACCURACY,  // Prioridad
    10_000L                           // Intervalo preferido en milisegundos (10 s)
)
    .setMinUpdateIntervalMillis(5_000L)  // Intervalo mínimo en milisegundos (5 s)
    .build()
```

#v(0.5em)

*Parámetros principales:*
- *Prioridad*: nivel de precisión deseado.
- *Intervalo*: frecuencia preferida de actualizaciones en milisegundos.
- *Intervalo mínimo*: frecuencia mínima de actualizaciones en milisegundos. Si otra app solicita posiciones más frecuentes, el sistema podría enviarlas también, este parámetro limita la tasa máxima a la que la app las procesará.


== Niveles de Prioridad

La prioridad indica a Google Play Services qué fuentes de localización priorizar.

#v(0.5em)

#[
  #set text(size: 0.9em)
  #table(
    columns: (auto, 1fr, auto, auto),
    inset: 8pt,
    align: (left, left, left, left),
    table.header([*Prioridad*], [*Uso típico*], [*Precisión*], [*Batería*]),
    [`PRIORITY_HIGH_ACCURACY`], [Navegación, mapas en tiempo real], [$~$1--50 m], [Alta],

    [`PRIORITY_BALANCED_POWER_ACCURACY`], [Localización general (ciudad, barrio)], [$~$100 m], [Media],

    [`PRIORITY_LOW_POWER`], [Solo necesidad a nivel de ciudad], [$~$10 km], [Baja],

    [`PRIORITY_PASSIVE`], [Recibir actualizaciones solo si otra app las solicita], [Variable], [Mínima],
  )
]

#v(0.5em)

#warning_symb La prioridad es una *sugerencia*, no una garantía: si el GPS no tiene señal, `HIGH_ACCURACY` puede devolver una localización de red con menor precisión.


== Suscribirse a Actualizaciones de Localización

Para recibir la posición del dispositivo *de forma periódica*, se usa el método `requestLocationUpdates()`:

#grid(
  columns: (1fr, 0.45fr),
  column-gutter: 1em,
)[
  #set text(size: 0.85em)
  ```kotlin
  // 1. Crear el callback que recibirá las actualizaciones
  private val locationCallback = object : LocationCallback() {
      override fun onLocationResult(locationResult: LocationResult) {
          for (location in locationResult.locations) {
              val lat = location.latitude
              val lng = location.longitude
              Log.d("Location", "Lat: $lat, Lng: $lng")
          }
      }
  }

  // 2. Solicitar actualizaciones periódicas
  fusedLocationClient.requestLocationUpdates(
      locationRequest,  // Configuración (prioridad, intervalo, etc.)
      locationCallback,  // Callback a ejecutar
      Looper.getMainLooper()  // Looper para ejecutar el callback
  )
  ```
][
  #set text(size: 0.85em)
  *`object : LocationCallback()`*: clase anónima de Kotlin que hereda de `LocationCallback`. // Se usa cuando solo se necesita una instancia sin darle nombre.

  *`onLocationResult`*: se invoca cada vez que el sistema obtiene una nueva posición. Puede recibir varias posiciones a la vez en `locationResult.locations`.

  *`Looper.getMainLooper()`*: indica que el callback se ejecutará en el hilo principal (UI thread), necesario para poder actualizar la interfaz desde él.
]

== Detener Actualizaciones de Localización

Es *fundamental* detener las actualizaciones cuando ya no se necesitan, para evitar un consumo innecesario de batería:

```kotlin
// Dejar de recibir actualizaciones
fusedLocationClient.removeLocationUpdates(locationCallback)
```

*¿Cuándo detener las actualizaciones?*
- Cuando el usuario *sale de la pantalla* que las necesita.
- Cuando la Activity pasa a `onPause()` o `onStop()` (según el caso).
- Cuando la app ya no necesita la localización.

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  *Error común:* olvidarse de llamar a `removeLocationUpdates()`. Si la app solicita actualizaciones y no las detiene, el GPS sigue activo en segundo plano, *drenando la batería del usuario*.
]


== Datos Disponibles en un Objeto `Location`

El objeto `Location` que se recibe en las actualizaciones contiene múltiples datos:

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 12pt),
  align: (left, left),
  table.header([*Propiedad*], [*Descripción*]),
  [`latitude`], [Latitud en grados (ej: $43.3623 degree$).],
  [`longitude`], [Longitud en grados (ej: $-8.4115 degree$).],
  [`altitude`], [Altitud en metros sobre el nivel del mar (si está disponible).],
  [`accuracy`],
  [Radio de precisión estimado en metros: la posición real está dentro de este radio con un 68% de probabilidad.],

  [`speed`], [Velocidad en metros por segundo.],
  [`bearing`], [Dirección de movimiento en grados (0° = norte, 90° = este).],
  [`time`], [Timestamp UTC en milisegundos de cuándo se calculó la posición.],
)


// ============================================================================
// BLOQUE 4: GOOGLE MAPS
// ============================================================================

= Google Maps

== Integración de Google Maps

Google proporciona el *Maps SDK for Android* para mostrar mapas interactivos en apps Android. Existe una librería específica para Jetpack Compose: *Maps Compose*.

*Requisitos previos:*
+ Obtener una *API Key* en Google Cloud Console con la API "Maps SDK for Android" habilitada.
+ Configurar la API Key en el proyecto (normalmente en `local.properties` o mediante el Secrets Gradle Plugin).
+ Añadir las dependencias necesarias.

*Dependencias* en `build.gradle.kts`:

```kotlin
dependencies {
    // Maps Compose (incluye el Maps SDK automáticamente)
    implementation("com.google.maps.android:maps-compose:6.12.0")
}
```


== Configurar la API Key

La API Key se declara en el `AndroidManifest.xml` dentro del bloque `<application>`:

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="${MAPS_API_KEY}" />
</application>
```

El valor `${MAPS_API_KEY}` se resuelve desde `local.properties` usando el *Secrets Gradle Plugin*:

```properties
# local.properties (NO subir al control de versiones)
MAPS_API_KEY=AIzaSyB...tu_clave_aqui
```

#warning_symb *Nunca incluir la API Key directamente en el código fuente* ni en ficheros que se suban al repositorio.


== La Cámara del Mapa

// Fuente imágenes: https://developers.google.com/maps/documentation/android-sdk/views
El mapa se visualiza como una *cámara mirando hacia abajo* sobre un plano. La cámara tiene cuatro propiedades independientes:

#grid(
  columns: (1fr, 0.7fr),
  column-gutter: 1.5em,
  align: (left, horizon),
  [
    - *Target*: coordenadas del centro del viewport.
    - *Zoom*: nivel de detalle. Cada paso duplica el ancho visible. Referencias: 1 (mundo), 5 (continente), 10 (ciudad), 15 (calles), 20 (edificios).
    - *Bearing*: rotación del mapa en grados desde el norte (0° = norte arriba).
    - *Tilt*: inclinación de la cámara (0° = vista cenital, hasta ~67.5° = perspectiva 3D).

    #v(0.5em)

    La cámara se puede mover de forma instantánea (`moveCamera`) o con *animación* (`animateCamera`).
  ],
  [
    #image("images/camera-diagram.png", width: 100%)
  ],
)


== Niveles de Zoom

// Fuente imágenes: https://developers.google.com/maps/documentation/android-sdk/views
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 0.5em,
  align: center,
  [
    #image("images/zoom-level-low.png", width: 85%)
    #set text(size: 0.85em)
    *Zoom ~5* — Continente
  ],
  [
    #image("images/zoom-level-mid.png", width: 85%)
    #set text(size: 0.85em)
    *Zoom ~15* — Calles
  ],
  [
    #image("images/zoom-level-high.png", width: 85%)
    #set text(size: 0.85em)
    *Zoom ~20* — Edificios
  ],
)


== Mostrar un Mapa y Marcadores

// Fuente imágenes: https://developers.google.com/maps/documentation/android-sdk/marker
#grid(
  columns: (1fr, 0.5fr),
  column-gutter: 1.5em,
  align: (left, center + horizon),
  [
    El composable principal es *`GoogleMap`*. Se configura con una *posición de cámara* (coordenadas + nivel de zoom) y puede contener elementos como *marcadores* (`Marker`) que se muestran sobre el mapa.

    #v(0.6em)

    Los marcadores permiten señalar puntos de interés. Al pulsar sobre uno se muestra un *título* y un texto adicional (_snippet_).

    #v(0.6em)

    La cámara se puede mover y animar programáticamente en respuesta a eventos del usuario.
  ],
  [
    #image("images/advanced-markers.png", width: 70%)
  ],
)


== Mi Ubicación en el Mapa

// Fuente imagen: https://developers.google.com/maps/documentation/android-sdk/location
#grid(
  columns: (1fr, 0.4fr),
  column-gutter: 1.5em,
  align: (left, center + horizon),
  [
    Maps SDK incluye una capa de *Mi Ubicación* que muestra la posición del usuario directamente sobre el mapa, sin necesidad de gestionar manualmente el Fused Location Provider:

    - Cuando el usuario está *estático*, muestra un *punto azul*.

    - Cuando está *en movimiento*, muestra un *chevron azul* apuntando en la dirección de desplazamiento.

    - Aparece un botón en la esquina superior derecha para *recentrar el mapa* en la posición actual.

    #v(0.5em)

    Requiere que la app tenga concedido el permiso `ACCESS_FINE_LOCATION` o `ACCESS_COARSE_LOCATION`.
  ],
  [
    #image("images/my-location-button.png", width: 100%)
  ],
)


== Controles y Tipos de Mapa

// Fuente imágenes: https://developers.google.com/maps/documentation/android-sdk/controls
#grid(
  columns: (1fr, 0.5fr),
  column-gutter: 1.5em,
  align: (left, horizon),
  [
    Maps Compose permite activar o desactivar los controles de interfaz del mapa:

    - *Zoom*: botones $+$ y $-$ en la esquina inferior derecha.

    - *Brújula*: aparece cuando el mapa está rotado o inclinado.

    - *Mi ubicación*: centra el mapa en la posición del usuario.

    //- *Barra de herramientas*: acceso directo a Google Maps.

    - *Selector de nivel*: en mapas de interiores, permite cambiar de planta. Aparece cuando hay uno o más edificios visibles.

    También se puede cambiar el *tipo de mapa*: `NORMAL` (calles), `SATELLITE` (imágenes aéreas), `TERRAIN` (relieve), `HYBRID` (satélite + calles).
  ],
  [
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.5em,
      row-gutter: 1em,
      align: center,
      [
        #figure(
          image("images/control-zoom.png", width: 5.5em),
          gap: 0.25em,
          caption: text(size: 0.7em, [Zoom]),
        )
      ],
      [
        #figure(
          image("images/control-compass.png", width: 5.5em),
          gap: 0.25em,
          caption: text(size: 0.7em, [Brújula]),
        )
      ],

      [
        #figure(
          box(height: 7.5em)[
            #image("images/control-mylocation.png", width: 5.5em)
          ],
          gap: 0.25em,
          caption: text(size: 0.7em, [Ubicación]),
        )
      ],
      [
        #figure(
          box(height: 7.5em)[
            #image("images/control-levelpicker.png", width: 5.5em)
          ],
          gap: 0.25em,
          caption: text(size: 0.7em, [Selector de nivel]),
        )
      ],
    )
  ],
)


// ============================================================================
// BLOQUE 5: GEOFENCING
// ============================================================================

= Geofencing

== ¿Qué es el Geofencing?

#[
  #set text(size: 0.95em)
  El *geofencing* (vallado geográfico) permite definir *perímetros virtuales* alrededor de ubicaciones geográficas y recibir notificaciones cuando el dispositivo *entra*, *sale* o *permanece* en esas zonas.

  #grid(
    columns: (1fr, 0.45fr),
    column-gutter: 1.5em,
    align: (left, center + top),
    [

      *Componentes de un geofence:*
      - *Centro*: coordenadas (latitud, longitud) del punto de interés.
      - *Radio*: distancia en metros alrededor del centro que delimita la zona.
      - *Transiciones*: eventos que se quieren detectar (entrada, salida, permanencia).
      - *Expiración*: duración máxima del geofence (o `NEVER_EXPIRE`).

      *Casos de uso:* enviar notificaciones al llegar a una tienda, activar dispositivos domóticos al llegar o salir de casa, registrar la entrada al trabajo.

      *Límite:* máximo *100 geofences* activos por app y usuario.
    ],
    [
      #image("images/geofence.png", width: 100%)
    ],
  )

]


== Consideraciones del Geofencing

*Precisión y radio mínimo:*
- Se recomienda un radio *mínimo de 100--150 metros* para resultados fiables.
- En zonas sin Wi-Fi (rurales), la precisión baja y se necesitan radios mayores.

*Latencia de detección:*
- En condiciones normales: *menos de 2 minutos*.
- Con límites de ejecución en segundo plano (Android 8+): *2--3 minutos*.
- Si el dispositivo está estacionario: hasta *6 minutos*.

*Consumo de batería:*
- Geofencing usa localización pasiva y de red, por lo que el *consumo es bajo*.
- Aumentar el `notificationResponsiveness` (ej: 5 minutos) reduce aún más el consumo.

*Permisos necesarios:*
- `ACCESS_FINE_LOCATION` (obligatorio) y `ACCESS_BACKGROUND_LOCATION` (obligatorio en Android 10+, ya que el geofencing funciona en segundo plano).


// ============================================================================
// BLOQUE 6: OPTIMIZACIÓN DE BATERÍA
// ============================================================================

= Optimización de Batería

== Optimización de Batería (I)

La localización es una de las funciones que *más batería consume*. Estas prácticas ayudan a minimizar el impacto:

- *Usar la mínima precisión necesaria:* si solo necesitas saber la ciudad, usa `PRIORITY_BALANCED_POWER_ACCURACY` o `PRIORITY_LOW_POWER` en lugar de `HIGH_ACCURACY`.

- *Aumentar el intervalo de actualización:* no solicitar actualizaciones cada segundo si basta con cada 30 segundos o cada minuto.

- *Detener las actualizaciones cuando no se necesiten:* llamar a `removeLocationUpdates()` en `onPause()`, `onStop()` o cuando el usuario salga de la pantalla.

- *Usar `PRIORITY_PASSIVE` en segundo plano:* recibir posiciones solo cuando otra app las solicite, sin coste propio. Con `setMaxWaitTime()` se pueden agrupar en lotes para reducir aún más el consumo.


== Optimización de Batería (II)

En lugar de solicitar localización continuamente, se puede combinar con otras APIs para activarla *solo cuando es necesaria*:

- *Combinar geofencing y localización:* registrar geofences en las zonas de interés y activar las actualizaciones de localización al entrar, desactivándolas al salir. Evita la localización continua cuando el usuario no está en el área relevante.

- *Combinar con Activity Recognition:* solicitar actualizaciones solo cuando la API de reconocimiento de actividad detecta que el usuario está realizando la actividad relevante (conduciendo, en bicicleta...) y detenerlas al terminar.

- *Preferir soluciones puntuales sobre suscripciones:* si solo se necesita la posición en un momento concreto (ej: al abrir la app), usar `getCurrentLocation()` en lugar de suscribirse a actualizaciones continuas.


// ============================================================================
// BLOQUE 7: RESUMEN
// ============================================================================

= Resumen

== Conceptos Clave

#[
  #set text(size: 0.85em)
  #align(center)[
    #table(
      columns: (auto, 1fr),
      inset: (x: 10pt, y: 8pt),
      align: (left, left),
      table.header([*Concepto*], [*Descripción*]),
      [*Fused Location Provider*],
      [API recomendado de Google Play Services. Fusiona GPS, Wi-Fi, red y sensores inerciales.],

      [`ACCESS_COARSE_LOCATION`], [Permiso de localización aproximada ($~$100--300 m).],
      [`ACCESS_FINE_LOCATION`], [Permiso de localización precisa ($~$1--50 m).],
      [`ACCESS_BACKGROUND_LOCATION`], [Permiso adicional (Android 10+) para localización en segundo plano.],
      [`client.lastLocation`], [Última posición en caché. Rápida pero puede ser obsoleta o null.],
      [`client.getCurrentLocation()`], [Posición actual calculada activamente. Más fiable.],
      [`LocationRequest`], [Configuración de actualizaciones: prioridad, intervalo, intervalo mínimo.],
      [`client.requestLocationUpdates()`], [Suscripción a actualizaciones periódicas de posición.],
      [*Maps Compose*], [Librería para integrar Google Maps en Jetpack Compose.],
      [*Geofencing*], [Perímetros virtuales con notificaciones al entrar/salir/permanecer.],
    )
  ]
]


== Flujo Típico de una App con Localización

#[
  #set text(size: 0.9em)
  + *Declarar permisos* en el `AndroidManifest.xml`.

  + *Solicitar permisos* en runtime cuando el usuario acceda a la funcionalidad.

  + *Crear el cliente* `FusedLocationProviderClient`.

  + *Verificar ajustes* de localización del dispositivo.

  + *Obtener localización*:
    - Puntual: `getCurrentLocation()` o `lastLocation`.
    - Periódica: configurar `LocationRequest` + `requestLocationUpdates()`.

  + *Usar la localización*: mostrar en mapa, calcular distancias, geofencing...

  + *Detener actualizaciones* cuando ya no se necesiten (`removeLocationUpdates()`).
]


// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

== Recursos y Documentación

#[
  #set text(size: 0.96em)
  *Geolocalización:*
  - Artículo interactivo sobre GPS: #link("https://ciechanow.ski/gps/")


  *Localización en Android:*
  - Build location-aware apps: #link("https://developer.android.com/training/location")
  - Get the last known location: #link("https://developer.android.com/training/location/retrieve-current")
  - Request location updates: #link("https://developer.android.com/training/location/request-updates")
  - Request location permissions: #link("https://developer.android.com/training/location/permissions")
  - Change location settings: #link("https://developer.android.com/training/location/change-location-settings")

  *Geofencing:*
  - Create and monitor geofences: #link("https://developer.android.com/training/location/geofencing")

  ---

  *Google Maps:*
  - Maps SDK for Android: #link("https://developers.google.com/maps/documentation/android-sdk/overview")
  - Maps Compose library: #link("https://developers.google.com/maps/documentation/android-sdk/maps-compose")

  *Optimización de batería:*
  - Optimize location for real-world scenarios: #link("https://developer.android.com/develop/sensors-and-location/location/battery/scenarios")

  *Codelabs:*
  - Receive location updates in Android with Kotlin: #link("https://codelabs.developers.google.com/codelabs/while-in-use-location/index.html")

  *Muestras de código:*
  - Android platform samples (location): #link("https://github.com/android/platform-samples/tree/main/samples/location")
]
