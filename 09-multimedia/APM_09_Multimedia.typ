// ============================================================================
// Multimedia
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Multimedia],
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
// BLOQUE 1: MULTIMEDIA EN ANDROID
// ============================================================================

= Multimedia en Android

== Panorama Multimedia en Android

Android proporciona un amplio conjunto de capacidades multimedia integradas en el sistema y expuestas mediante APIs de alto nivel:

#v(0.5em)

- *Cámara*: captura de fotos y vídeos, acceso al visor en tiempo real y análisis de imagen.

- *Audio*: grabación y reproducción, incluyendo micrófono, audio espacial y efectos de sonido.

- *Vídeo*: grabación y reproducción de vídeo local o en _streaming_ (DASH, HLS).

- *Imagen*: visualización, edición básica y análisis.

#v(0.5em)

En este tema nos centraremos principalmente en la cámara (con CameraX) y haremos una introducción a la reproducción multimedia y al análisis de imagen.


== Acceso a la Cámara: Dos Enfoques

Android ofrece dos opciones para acceder a la cámara del dispositivo:

#v(0.3em)

#table(
  columns: (1fr, 1fr),
  inset: (x: 12pt, y: 14pt),
  align: (left, left),
  table.header([*Delegar en la app del sistema*], [*Implementar nuestro propio visor*]),
  [
    - Mediante un _intent_ (#text(size: 0.95em)[`ActivityResultContracts.TakePicture`])
    - La app del sistema gestiona UI, permisos y guardado
    - Rápido de implementar
    - Poca personalización
  ],
  [
    - La app muestra un visor y gestiona la captura
    - Usando CameraX o Camera2
    - Control total sobre UI y funcionalidades
    - Requiere gestionar permisos y almacenamiento
  ],
)

#v(0.3em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  En este tema veremos el segundo enfoque con CameraX, recomendado por Google para la mayoría de apps.
]


== APIs de Cámara en Android

Han existido tres APIs de cámara a lo largo de la historia de Android:

#v(0.3em)

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 10pt, y: 12pt),
  align: (left, left, center),
  table.header([*API*], [*Descripción*], [*API mín.*]),
  [`Camera`], [API original, deprecated desde API 21. No usar en apps nuevas.], [---],

  [`Camera2`],
  [API de bajo nivel con control fino del hardware. Muy verbosa: gestión manual de estados y callbacks.],
  [21],

  [`CameraX`],
  [API de alto nivel sobre Camera2. Recomendada. _Lifecycle-aware_, consistente, simplifica los casos de uso comunes.],
  [21],
)

#v(0.3em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  *Regla práctica:* usar CameraX por defecto; recurrir a Camera2 solo si se necesita control avanzado que CameraX no expone.
]


== Permisos de Cámara y Audio

`CAMERA` y `RECORD_AUDIO` son permisos peligrosos: el usuario debe concederlos en runtime (API 23+).

#grid(
  columns: (1.6fr, 1fr),
  column-gutter: 1.5em,
)[
  #show raw: set text(size: 0.95em)
  ```xml
  <manifest ...>
    <!-- Permisos requeridos en runtime -->
    <uses-permission
      android:name="android.permission.CAMERA" />
    <uses-permission
      android:name="android.permission.RECORD_AUDIO" />

    <!-- Hardware opcional -->
    <uses-feature
      android:name="android.hardware.camera.any"
      android:required="false" />
    <uses-feature
      android:name="android.hardware.microphone"
      android:required="false" />
  </manifest>
  ```
][
  #set text(size: 0.95em)
  - `uses-permission`: el sistema solicita los permisos en runtime.
  - `uses-feature` con `required="false"`: la app se instala incluso sin cámara.

  Android infiere el hardware requerido a partir de los permisos declarados: `CAMERA` implica cámara obligatoria, `RECORD_AUDIO` implica micrófono. `uses-feature` con `required="false"` anula esa inferencia.
]



== Indicadores de Privacidad (API 31+)

// Fuente: https://developer.android.com/about/versions/12/behavior-changes-all

#grid(columns: (3.5fr, 1fr), column-gutter: 1.5em, align: horizon)[
  Desde Android 12 (API 31), el sistema muestra indicadores visuales cuando la cámara o el micrófono están activos:

  - Cuando una app usa cámara o micrófono aparece un indicador en la esquina superior derecha: primero un rectángulo redondeado con el icono del recurso, que luego se reduce a un punto verde.

  - Si la app los usa en segundo plano, al desplegar la barra de notificaciones se muestra qué app los está usando.

  #v(0.5em)

  #block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
    Implicación: la app debe liberar recursos tan pronto como no los necesite, si el indicador permanece activo innecesariamente, el usuario percibirá la app como intrusiva.
  ]
][
  #image("images/mic-camera-indicators.jpg", width: 100%)
]


== Controles Globales de Privacidad (API 31+)

#grid(columns: (3.5fr, 1fr), column-gutter: 1.5em, align: horizon)[
  Android 12 añade _toggles_ en los Ajustes Rápidos para desactivar el acceso a hardware de forma global, para todas las apps.

  #v(1em)

  #box(width: 95%)[
    #grid(
      columns: 3,
      rows: 2,
      row-gutter: 0.6em,
      column-gutter: 1em,
      align: center,
      [*Camara*], [*Micrófono*], [*Localización*],
      image("images/camera-toogle.svg", width: 100%),
      image("images/mic-toogle.svg", width: 100%),
      image("images/location-toogle.svg", width: 100%),
    )
  ]
][
  #image("images/mic-camera-toggles.jpg", width: 100%)
]



// ============================================================================
// BLOQUE 2: CAMERAX - ARQUITECTURA Y CONCEPTOS
// ============================================================================

= CameraX: Arquitectura y Conceptos

== ¿Por qué CameraX?

- *Consistencia entre dispositivos*: Camera2 expone el hardware directamente, por lo que su comportamiento varía según el fabricante (Samsung, Xiaomi, etc.) y la versión de Android. CameraX abstrae esas diferencias. Google valida cada release en un _CameraX Test Lab_ con cientos de dispositivos físicos.

- *Lifecycle-aware*: se vincula al ciclo de vida de la `Activity` mediante un `LifecycleOwner`. CameraX abre y cierra la cámara automáticamente al pasar a `RESUMED`/`CREATED`.

- *API basada en casos de uso*: `Preview`, `ImageCapture`, `VideoCapture`, e `ImageAnalysis`.

- *Extensions*: acceso a funciones avanzadas del fabricante (HDR, bokeh, modo nocturno).

#v(0.5em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  Versión actual: CameraX 1.6.0 (estable, marzo 2026). Requiere API mínima 21 (Android 5.0).
]


== Dependencias de CameraX

Añadir en `build.gradle.kts` (Kotlin DSL):

#v(0.2em)

```kotlin
dependencies {
    val cameraxVersion = "1.6.0"

    // Núcleo y backend Camera2
    implementation("androidx.camera:camera-core:$cameraxVersion")
    implementation("androidx.camera:camera-camera2:$cameraxVersion")

    // Integración con lifecycle
    implementation("androidx.camera:camera-lifecycle:$cameraxVersion")

    // PreviewView (visor) y utilidades
    implementation("androidx.camera:camera-view:$cameraxVersion")

    // Grabación de vídeo
    implementation("androidx.camera:camera-video:$cameraxVersion")
}
```


== Los 4 Casos de Uso de CameraX

CameraX organiza su API en torno a cuatro casos de uso combinables:

#v(0.5em)

#grid(
  columns: (1fr, 1fr),
  rows: (4.8em, 4.8em),
  column-gutter: 1em,
  row-gutter: 1em,
  align: horizon,
  block(stroke: luma(70%) + 1.5pt, radius: 8pt, inset: 8pt, width: 100%, height: 100%)[
    *#text(fill: rgb("#1565c0"))[Preview]*

    Visor en tiempo real del sensor. Se muestra en un `PreviewView`.
  ],
  block(stroke: luma(70%) + 1.5pt, radius: 8pt, inset: 8pt, width: 100%, height: 100%)[
    *#text(fill: rgb("#2e7d32"))[ImageCapture]*

    Captura de fotos. Guarda la imagen en archivo o buffer de memoria.
  ],

  block(stroke: luma(70%) + 1.5pt, radius: 8pt, inset: 8pt, width: 100%, height: 100%)[
    *#text(fill: rgb("#c62828"))[VideoCapture]*

    Grabación de vídeo con audio en archivo o buffer.
  ],
  block(stroke: luma(70%) + 1.5pt, radius: 8pt, inset: 8pt, width: 100%, height: 100%)[
    *#text(fill: rgb("#6a1b9a"))[ImageAnalysis]*

    Acceso a los _frames_ para análisis en tiempo real (ML Kit, visión por computador, etc.).
  ],
)

#v(0.5em)

Todos comparten el _stream_ del sensor gestionado por CameraX y se vinculan al ciclo de vida con `bindToLifecycle()`.


== CameraController vs CameraProvider

CameraX ofrece dos formas de usar los casos de uso:

#v(0.3em)

- *`LifecycleCameraController`*:
  - API simplificada de alto nivel.
  - Casos de uso se crean y gestionan internamente.
  - Mínima configuración.

- *`ProcessCameraProvider`*:
  - API completa con control fino.
  - Casos de uso configurables (calidad, flash, formato de imagen...)
  - Permite eliminar o añadir casos de uso en runtime
  - Selección la cámara de forma explícita.

#v(0.3em)

En este tema usaremos `ProcessCameraProvider` para ver la API completa.


== CameraSelector: Elegir la Cámara

Un `CameraSelector` es un objeto que le indica a CameraX qué cámara del dispositivo usar. La forma más sencilla de obtenerlo es mediante las dos instancias predefinidas:

#v(0.7em)

```kotlin
import androidx.camera.core.CameraSelector

val backSelector  = CameraSelector.DEFAULT_BACK_CAMERA   // cámara trasera
val frontSelector = CameraSelector.DEFAULT_FRONT_CAMERA  // cámara delantera

// Comprobar disponibilidad antes de usar el selector
val hasBack = cameraProvider.hasCamera(CameraSelector.DEFAULT_BACK_CAMERA)
```

// #v(0.7em)

// Para cambiar de cámara: llamar a `unbindAll()` y luego a `bindToLifecycle()` con el nuevo selector y los casos de uso deseados.


== CameraSelector: Selectores Personalizados

Cuando los selectores predefinidos no son suficientes (p. ej. una cámara USB externa), se construye el `CameraSelector` con su _builder_ y se filtra por la orientación del objetivo:

```kotlin
// Selector para una cámara externa (USB)
val externalSelector = CameraSelector.Builder()
    .requireLensFacing(CameraSelector.LENS_FACING_EXTERNAL)
    .build()
```

#v(0.3em)

`requireLensFacing()` acepta una de estas constantes `Int` definidas en `CameraSelector`:

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 10pt, y: 6pt),
  align: (left, center, left),
  table.header([*Constante*], [*Valor*], [*Cámara*]),
  [`LENS_FACING_FRONT`], [`0`], [Delantera #sym.arrow equivale a `DEFAULT_FRONT_CAMERA`],
  [`LENS_FACING_BACK`], [`1`], [Trasera #sym.arrow equivale a `DEFAULT_BACK_CAMERA`],
  [`LENS_FACING_EXTERNAL`], [`2`], [Externa (USB u otros)],
  [`LENS_FACING_UNKNOWN`], [`-1`], [Orientación desconocida],
)


== ProcessCameraProvider

`ProcessCameraProvider` es un singleton que gestiona la conexión con la cámara. Sus métodos principales son:

#v(0.8em)

- *`bindToLifecycle()`*: vincula casos de uso al ciclo de vida de un `LifecycleOwner` y abre la cámara
- *`unbindAll()`*: desvincula todos los casos de uso y cierra la cámara
- *`hasCamera()`*: comprueba si el dispositivo tiene una cámara con el selector dado

#v(1em)

Para obtener la instancia se llama a `ProcessCameraProvider.getInstance()`. Sin embargo, la instancia no está disponible de inmediato, ya que inicializarla requiere conectar con el hardware de la cámara. Por eso `getInstance()` devuelve un `ListenableFuture<ProcessCameraProvider>` en vez de la instancia directamente.


== Inicializar ProcessCameraProvider

Un `ListenableFuture<T>` representa un valor que estará disponible en el futuro. Permite registrar un _listener_ (callback) que se ejecutará cuando el valor esté listo, mediante `addListener(runnable, executor)`.

#v(0.3em)

#grid(
  columns: (1fr, 2fr),
  column-gutter: 1.5em,
)[
  #set text(size: 0.95em)
  - El primer argumento es el callback a ejecutar cuando el `Future` complete.

  - El segundo es un `Executor`: objeto que ejecuta el callback en un hilo concreto. `ContextCompat.` `getMainExecutor(context)` devuelve un `Executor` que lo ejecuta en el hilo principal.
][
  #set text(size: 0.95em)

  ```kotlin
  import androidx.camera.lifecycle.ProcessCameraProvider
  import androidx.core.content.ContextCompat

  val future = ProcessCameraProvider.getInstance(context)

  future.addListener(
      {
          val cameraProvider = future.get()

          // Usar cameraProvider ...
      },
      ContextCompat.getMainExecutor(context)
  )
  ```
]


== Vincular los Casos de Uso al Ciclo de Vida

CameraX es _lifecycle-aware_:

- Los casos de uso se asocian a un `LifecycleOwner`.

- `LifecycleOwner` es una interfaz de _Jetpack Lifecycle_ implementada por `Activity`, `Fragment`, y `NavBackStackEntry`. En Compose, `LocalLifecycleOwner.current` devuelve el `LifecycleOwner` más cercano en la jerarquía de composición.

- CameraX sigue las transiciones de estado para abrir y cerrar la cámara automáticamente.

#v(0.5em)

#grid(columns: (1fr, 1.24fr), column-gutter: 1.5em)[
  La firma de `bindToLifecycle()` es:
  #v(0.8em, weak: true)
  ```kotlin
  @MainThread
  fun bindToLifecycle(
      lifecycleOwner: LifecycleOwner,
      cameraSelector: CameraSelector,
      vararg useCases: UseCase?
  ): Camera
  ```
][
  Ejemplo de llamada con dos casos de uso:
  #v(0.8em, weak: true)
  ```kotlin
  cameraProvider.unbindAll()
  val camera = cameraProvider.bindToLifecycle(
      lifecycleOwner,
      cameraSelector,
      preview, imageCapture
  )
  ```
]

== Gestión Automática del Ciclo de Vida

Una vez vinculados los casos de uso, CameraX reacciona automáticamente a los cambios de estado del `LifecycleOwner`:

#v(0.3em)

- Cuando el owner entra en estado `STARTED` (app visible), CameraX abre la cámara y comienza a entregar frames a los casos de uso vinculados.

- Cuando pasa a `CREATED` (app en segundo plano), CameraX cierra la cámara y libera el sensor para que otras apps puedan usarlo.

- Cuando el owner se destruye (`DESTROYED`), CameraX libera los recursos asociados.

#v(0.3em)

Esto evita tener que abrir/cerrar la cámara manualmente en `onStart()` / `onStop()`, que era una fuente habitual de _bugs_ con Camera2.

#v(0.3em)

Para desvincular explícitamente (por ejemplo, antes de vincular con otro selector): `cameraProvider.unbindAll()`.


== Combinaciones Simultáneas

CameraX permite vincular varios casos de uso a la vez.

#v(0.3em)

#table(
  columns: 5,
  inset: (x: 8pt, y: 10pt),
  align: (center + horizon, center + horizon, center + horizon, center + horizon, left),
  table.header([*Preview*], [*ImageCapture*], [*VideoCapture*], [*ImageAnalysis*], []),
  [#sym.checkmark], [], [], [], [Solo visor],
  [#sym.checkmark], [#sym.checkmark], [], [], [Visor + foto (caso típico)],
  [#sym.checkmark], [], [#sym.checkmark], [], [Visor + vídeo (caso típico)],
  [#sym.checkmark], [#sym.checkmark], [], [#sym.checkmark], [Visor + foto + análisis],
  [#sym.checkmark], [], [#sym.checkmark], [#sym.checkmark], [Visor + vídeo + análisis],
  [#sym.checkmark], [#sym.checkmark], [#sym.checkmark], [], [Visor + foto + vídeo],
)

#v(0.3em)

Otras combinaciones (p.ej. foto + vídeo + análisis) requieren comprobar el nivel de hardware del dispositivo en runtime.


== Controles de Cámara en Runtime

`bindToLifecycle()` devuelve un objeto `Camera` con dos interfaces:

#v(0.3em)

#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  *`cameraControl`*: enviar comandos
  #set text(size: 1.05em)
  ```kotlin
  // Flash / torch
  camera.cameraControl.enableTorch(true)

  // Zoom (ratio absoluto o lineal 0f..1f)
  camera.cameraControl.setZoomRatio(2f)
  camera.cameraControl.setLinearZoom(0.5f)

  // Compensación de exposición
  camera.cameraControl
      .setExposureCompensationIndex(0)
  ```
][
  *`cameraInfo`*: leer estado

  #set text(size: 0.95em)
  - `hasFlashUnit(): Boolean`\ Indica si la cámara tiene flash físico.
  - `torchState: LiveData<Int>`\ Indica el estado del flash de la cámara.
  - `zoomState: LiveData<ZoomState>`\ Zoom actual, mínimo, y máximo.
  - `cameraState: LiveData<CameraState>`\ `OPENING`, `OPEN`, `CLOSING`, `CLOSED`.
  - `lensFacing: Int`\ Cámara activa (frontal, trasera, etc.).
]



== Funciones Avanzadas

Android y CameraX ofrecen funcionalidades adicionales que no cubriremos en detalle:

#v(0.3em)

- CameraX Extensions: modos avanzados del fabricante (HDR, _bokeh_, modo nocturno, _face retouch_, auto). Dependencia: `androidx.camera:camera-extensions`.

- Ultra HDR (Android 14+, API 34): fotos con mayor rango dinámico (formato JPEG/R).

- Audio espacial (Android 13+, API 33): reproducción con _head tracking_ en auriculares compatibles.

- Grabación concurrente (Android 13+): algunos dispositivos permiten grabar con cámara frontal y trasera simultáneamente.

#v(0.3em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  Estas funciones suelen requerir comprobar disponibilidad en runtime, ya que dependen del fabricante y nivel de API.
]



// ============================================================================
// BLOQUE 3: PREVIEW E IMAGECAPTURE CON COMPOSE
// ============================================================================

= Preview e ImageCapture con Compose

== Resumen del Flujo

#align(center)[
  #let flow_box(content) = box(stroke: 0.3pt, inset: 6pt, radius: 5pt, width: 24em)[#content]

  #grid(
    rows: 9,
    row-gutter: 0.8em,
    flow_box[*1. Permisos* (`CAMERA`)],
    sym.arrow.b,
    flow_box[*2. ProcessCameraProvider* (singleton del proceso)],
    sym.arrow.b,
    flow_box[*3. Crear casos de uso* (Preview, ImageCapture)],
    sym.arrow.b,
    flow_box[*4. `bindToLifecycle`* con `CameraSelector` y casos de uso],
    sym.arrow.b,
    flow_box[*5. Capturar foto* (`imageCapture.takePicture`) con MediaStore como destino],
  )
]

== Solicitar Permisos de Cámara en Compose

#grid(
  columns: (1fr, 0.6fr),
  column-gutter: 1em,
)[
  #set text(size: 0.86em)
  ```kotlin
  // 1. Registrar el launcher (en el cuerpo del Composable)
  val permissionLauncher = rememberLauncherForActivityResult(
      contract = ActivityResultContracts.RequestPermission()
  ) { granted ->
      if (granted) { /* Iniciar cámara */ }
      else { /* Informar al usuario */ }
  }

  // 2. Comprobar si ya está concedido; si no, solicitarlo
  LaunchedEffect(Unit) {
      if (ContextCompat.checkSelfPermission(
              context, Manifest.permission. CAMERA
            ) == PackageManager.PERMISSION_GRANTED
      ) {
          /* Iniciar cámara */
      } else {
          permissionLauncher.launch(
            Manifest.permission.CAMERA
          )
      }
  }
  ```
][
  #set text(size: 0.92em)
  - Se usa el contrato `RequestPermission` (un único permiso), que devuelve directamente un `Boolean`.

  - Comprobación previa: si el permiso ya está concedido, se inicia la cámara directamente sin mostrar el diálogo.

  - El launcher se registra en el cuerpo del Composable, nunca dentro de un `onClick`.

  - *`LaunchedEffect(Unit)`* ejecuta la comprobación al entrar en la pantalla.
]


== Obtener el ProcessCameraProvider con Corrutinas

En Compose, `LaunchedEffect` lanza una corrutina vinculada al ciclo de vida del composable. La librería `kotlinx-coroutines-guava` añade `.await()` a `ListenableFuture`: una _suspend function_ que espera el resultado sin bloquear el hilo.

#v(0.3em)

Dependencia adicional en `build.gradle.kts`:

```kotlin
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-guava:1.8.1")
```

#v(0.3em)

Uso con `LaunchedEffect`:

```kotlin
val cameraProviderFuture = remember { ProcessCameraProvider.getInstance(context) }

LaunchedEffect(cameraProviderFuture) {
    val cameraProvider = cameraProviderFuture.await()
    // Usar cameraProvider: bindToLifecycle(...)
}
```


== PreviewView en Compose

#grid(
  columns: (1fr, 1.1fr),
  column-gutter: 1.5em,
)[
  #set text(size: 0.95em)
  `PreviewView` no es un composable nativo sino un componente del sistema tradicional de vistas (_Views_); para integrarlo en Compose se usa `AndroidView`.

  #v(0.5em)

  #set list(spacing: 2em)
  - *`preview` se pasará después a `bindToLifecycle()`*.

  - La función `also` ejecuta un bloque como efecto secundario y devuelve el objeto original.

  - `AndroidView` recibe en `factory` una lambda que devuelve la _View_ y la incrusta en el árbol de Compose.
][
  ```kotlin
  val context = LocalContext.current

  val previewView = remember {
    PreviewView(context)
  }

  val preview = remember {
    Preview.Builder().build().also {
      it.setSurfaceProvider(
        previewView.surfaceProvider
      )
    }
  }

  AndroidView(
    factory = { previewView },
    modifier = Modifier.fillMaxSize()
  )
  ```
]


== Iniciar la Cámara en Compose

#grid(
  columns: (1fr, 1.4fr),
  column-gutter: 1.5em,
)[
  Con el `cameraProvider`, el `preview` y el `previewView` listos, se vincula todo al ciclo de vida dentro del `LaunchedEffect`:

  - `LocalLifecycleOwner.current` devuelve el `LifecycleOwner` más cercano en la jerarquía de composición (`Activity`, `Fragment`, o `NavBackStackEntry`).

  - `unbindAll()` garantiza que no quedan casos de uso vinculados de llamadas anteriores.
][
  ```kotlin
  val lifecycleOwner = LocalLifecycleOwner.current

  LaunchedEffect(cameraProviderFuture) {
      val cameraProvider =
          cameraProviderFuture.await()
      try {
          cameraProvider.unbindAll()
          cameraProvider.bindToLifecycle(
              lifecycleOwner,
              CameraSelector.DEFAULT_BACK_CAMERA,
              preview
          )
      } catch (exc: Exception) {
          Log.e(TAG, "Error al vincular", exc)
      }
  }
  ```
]


== Añadir ImageCapture

#grid(
  columns: (1fr, 1.3fr),
  column-gutter: 1em,
)[
  Añadimos un `ImageCapture` al `bindToLifecycle` para capturar fotos:

  #set list(spacing: 1.7em)
  - Se crea con `remember` y se añade como argumento adicional a `bindToLifecycle`.

  - `CAPTURE_MODE_MINIMIZE_LATENCY` prioriza la velocidad de captura sobre la calidad.

  - Después se invoca `imageCapture.takePicture(...)` desde un botón.
][
  ```kotlin
  val imageCapture = remember {
      ImageCapture.Builder()
          .setCaptureMode(
              ImageCapture.
              CAPTURE_MODE_MINIMIZE_LATENCY)
          .build()
  }

  LaunchedEffect(cameraProviderFuture) {
      val cameraProvider =
          cameraProviderFuture.await()
      cameraProvider.unbindAll()
      cameraProvider.bindToLifecycle(
          lifecycleOwner,
          CameraSelector.DEFAULT_BACK_CAMERA,
          preview, imageCapture
      )
  }
  ```
]


== Resolución y Aspect Ratio en ImageCapture

Para controlar la resolución de la foto capturada se usa `ResolutionSelector` en `ImageCapture.Builder()`.

#grid(
  columns: (1.8fr, 1fr),
  column-gutter: 1em,
)[
  ```kotlin
  val resolutionSelector = ResolutionSelector.Builder()
      .setAspectRatioStrategy(
          AspectRatioStrategy
              .RATIO_16_9_FALLBACK_AUTO_STRATEGY
      )
      .setResolutionStrategy(ResolutionStrategy(
          Size(1920, 1080),
          ResolutionStrategy
              .FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER
      ))
      .build()

  val imageCapture = ImageCapture.Builder()
      .setResolutionSelector(resolutionSelector)
      .build()
  ```
][
  - *`setAspectRatioStrategy()`*: relación de aspecto preferida y qué hacer si no está disponible. Las estrategias predefinidas cubren 4:3 y 16:9 con _fallback_ automático.

  - *`setResolutionStrategy()`*: resolución preferida (`Size`) y regla de _fallback_ si no está soportada (más cercana por encima, por debajo, etc.).
]


== Opciones de Fichero: OutputFileOptions

#grid(
  columns: (1.45fr, 1fr),
  column-gutter: 1em,
)[
  #set text(size: 0.92em)
  ```kotlin
  val name = SimpleDateFormat(
      "yyyy-MM-dd-HH-mm-ss-SSS", Locale.US
  ).format(System.currentTimeMillis())

  val contentValues = ContentValues().apply {
      put(MediaStore.MediaColumns.DISPLAY_NAME, name)
      put(MediaStore.MediaColumns.MIME_TYPE,
          "image/jpeg")
      put(MediaStore.MediaColumns.RELATIVE_PATH,
          "Pictures/CameraX-APM")
  }

  val outputOptions = ImageCapture.OutputFileOptions
      .Builder(
          context.contentResolver,
          MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
          contentValues
      ).build()
  ```
][
  *`ContentValues`*: mapa con los metadatos del fichero a crear en MediaStore: nombre, tipo MIME y directorio de destino.

  #v(0.8em)

  *`RELATIVE_PATH`*: directorio dentro del almacenamiento compartido. `Pictures/` es el estándar para fotos.

  #v(0.8em)

  *`OutputFileOptions`*: encapsula el destino y metadatos de la foto. `EXTERNAL_CONTENT_URI` apunta al almacenamiento compartido.
]


== Lanzar la Captura: `takePicture()`

#grid(
  columns: (1.55fr, 1fr),
  column-gutter: 1.5em,
)[
  ```kotlin
  imageCapture.takePicture(
      outputOptions,
      ContextCompat.getMainExecutor(context),
      object : ImageCapture.OnImageSavedCallback {
          override fun onImageSaved(
              output: ImageCapture.OutputFileResults
          ) {
              Log.d(TAG, "${output.savedUri}")
          }

          override fun onError(
            exc: ImageCaptureException
          ) {
              Log.e(TAG, exc.message, exc)
          }
      }
  )
  ```
][
  #set text(size: 0.98em)
  `takePicture()` acepta tres parámetros:

  - *`outputOptions`*: destino y metadatos construidos en el paso anterior.

  - *`executor`*: hilo donde se ejecutan los callbacks. `getMainExecutor` usa el hilo principal de la UI.

  - *`OnImageSavedCallback`*: objeto anónimo que implementa dos métodos:
    - `onImageSaved`: éxito
    - `onError`: fallo
]


// ============================================================================
// BLOQUE 4: VIDEOCAPTURE CON COMPOSE
// ============================================================================

= VideoCapture con Compose

== Resumen del Flujo

#align(center)[
  #let flow_box(content) = box(stroke: 0.3pt, inset: 6pt, radius: 5pt, width: 24em)[#content]

  #grid(
    rows: 9,
    row-gutter: 0.8em,
    flow_box[*1. Permisos* (`CAMERA` + `RECORD_AUDIO`)],
    sym.arrow.b,
    flow_box[*2. ProcessCameraProvider* (singleton del proceso)],
    sym.arrow.b,
    flow_box[*3. Crear casos de uso* (Preview, VideoCapture)],
    sym.arrow.b,
    flow_box[*4. `bindToLifecycle`* con `CameraSelector` y casos de uso],
    sym.arrow.b,
    flow_box[*5. Capturar / Grabar* con MediaStore como destino],
  )
]


== VideoCapture + Recorder

La grabación en CameraX se basa en dos clases:

- `VideoCapture<Recorder>`: caso de uso que se vincula al ciclo de vida.
- `Recorder`: captura el vídeo y audio proporcionado por el caso de uso `VideoCapture`, y lo codifica y escribe en un archivo.

#v(0.5em)

Pipeline interno simplificado:

#v(1em)

#align(center)[
  #let pl_box(content) = box(stroke: 0.5pt, inset: 14pt, radius: 4pt)[#content]

  #set text(size: 0.9em)
  #grid(
    columns: 5,
    column-gutter: 1.5em,
    align: center + horizon,
    pl_box[Fuentes\ (vídeo + audio)],
    sym.arrow,
    pl_box[Encoders\ (H.264, AAC...)],
    sym.arrow,
    pl_box[Muxer\ (archivo MP4)],
  )
]


== Solicitar Permisos de Cámara y Audio en Compose

#grid(
  columns: (1fr, 0.5fr),
  column-gutter: 1em,
)[
  #set text(size: 0.82em)
  ```kotlin
  val requiredPermissions = arrayOf(
      Manifest.permission.CAMERA,
      Manifest.permission.RECORD_AUDIO,
  )

  // 1. Registrar el launcher (en el cuerpo del Composable)
  val permissionLauncher = rememberLauncherForActivityResult(
      contract = ActivityResultContracts.RequestMultiplePermissions()
  ) { granted ->
      if (granted.values.all { it }) { /* Iniciar cámara */ }
      else { /* Informar al usuario */ }
  }

  // 2. Comprobar si ya están concedidos; si no, solicitarlos
  LaunchedEffect(Unit) {
      val allGranted = requiredPermissions.all {
          ContextCompat.checkSelfPermission(context, it) ==
              PackageManager.PERMISSION_GRANTED
      }
      if (allGranted) { /* Iniciar cámara */ }
      else permissionLauncher.launch(requiredPermissions)
  }
  ```
][
  #set text(size: 0.9em)
  - Se usa el contrato `RequestMultiplePermissions`, que devuelve `Map<String, Boolean>`.

  - Comprobación previa: si los permisos ya están concedidos, se inicia la cámara sin mostrar el diálogo.

  - El launcher se registra en el cuerpo del Composable, nunca dentro de un `onClick`.

  - *`LaunchedEffect(Unit)`* ejecuta la comprobación al entrar en la pantalla.
]


== QualitySelector

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    `QualitySelector` define la calidad del vídeo. CameraX elige la calidad real según lo que soporte el dispositivo.

    Calidades predefinidas:

    - `Quality.SD`: 480p
    - `Quality.HD`: 720p
    - `Quality.FHD`: 1080p
    - `Quality.UHD`: 2160p (4K)
    - `Quality.LOWEST` / `Quality.HIGHEST`
  ],
  [
    #set text(size: 1.1em)
    ```kotlin
    val selector = QualitySelector.from(
        Quality.FHD,
        FallbackStrategy
            .lowerQualityOrHigherThan(
                Quality.HD
            )
    )

    val recorder = Recorder.Builder()
        .setQualitySelector(selector)
        .build()
    ```

  ],
)

`FallbackStrategy` indica qué hacer si la calidad solicitada no está disponible: `lowerQualityThan`, `higherQualityThan` y sus variantes _OrHigher_/_OrLower_.



== Añadir VideoCapture al Ciclo de Vida

#grid(
  columns: (1fr, 1.2fr),
  column-gutter: 1.5em,
)[
  Añadimos `videoCapture` al `bindToLifecycle` junto con `preview`:

  #set list(spacing: 1.7em)
  - `QualitySelector.from(Quality.HD)` elige calidad HD con fallback automático.

  - `VideoCapture.withOutput(recorder)` vincula el `Recorder` al caso de uso.

  - Se añade `videoCapture` como argumento adicional a `bindToLifecycle`.
][
  #set text(size: 0.87em)
  ```kotlin
  val recorder = remember {
      Recorder.Builder()
          .setQualitySelector(
              QualitySelector.from(Quality.HD)
          )
          .build()
  }
  val videoCapture = remember {
      VideoCapture.withOutput(recorder)
  }

  LaunchedEffect(cameraProviderFuture) {
      val cameraProvider =
          cameraProviderFuture.await()
      cameraProvider.unbindAll()
      cameraProvider.bindToLifecycle(
          lifecycleOwner,
          CameraSelector.DEFAULT_BACK_CAMERA,
          preview, videoCapture
      )
  }
  ```
]


== Preparar la Grabación

#grid(
  columns: (1.45fr, 1fr),
  column-gutter: 1em,
)[
  #set text(size: 0.92em)
  ```kotlin
  val name = SimpleDateFormat(
      "yyyy-MM-dd-HH-mm-ss-SSS", Locale.US
  ).format(System.currentTimeMillis())

  val contentValues = ContentValues().apply {
      put(MediaStore.MediaColumns.DISPLAY_NAME, name)
      put(MediaStore.MediaColumns.MIME_TYPE,
          "video/mp4")
      put(MediaStore.MediaColumns.RELATIVE_PATH,
          "Movies/CameraX-APM")
  }

  val outputOptions = MediaStoreOutputOptions
      .Builder(
          context.contentResolver,
          MediaStore.Video.Media.EXTERNAL_CONTENT_URI
      ).setContentValues(contentValues).build()
  ```
][
  *`ContentValues`*: igual que en fotos: nombre, tipo MIME (`video/mp4`) y directorio de destino.

  #v(0.8em)

  *`RELATIVE_PATH`*: `Movies/` es el estándar para vídeos (vs `Pictures/` para fotos).

  #v(0.8em)

  *`MediaStoreOutputOptions`*: equivalente al `OutputFileOptions` de `ImageCapture`, específico para vídeo. El `ContentValues` se pasa con `.setContentValues()`.
]


== Iniciar la Grabación y Gestionar Eventos

#[
  #set text(size: 0.95em)
  ```kotlin
  var recording: Recording? = null

  recording = videoCapture.output
      .prepareRecording(context, outputOptions)
      .withAudioEnabled()
      .start(ContextCompat.getMainExecutor(context)) { event ->
          when (event) {
              is VideoRecordEvent.Start -> Log.d(TAG, "Iniciada")
              is VideoRecordEvent.Finalize -> {
                  if (!event.hasError()) {
                      Log.d(TAG, "Uri: ${event.outputResults.outputUri}")
                  } else {
                      Log.e(TAG, "Error: ${event.error}")
                  }
                  recording?.close()
                  recording = null
              }
          }
      }
  ```
]


== Pausar, Reanudar y Silenciar

Una vez iniciada, podemos interactuar con la grabación.

#v(0.3em)

```kotlin
// Detener y finalizar el archivo (dispara VideoRecordEvent.Finalize)
recording?.stop()

// Pausar y reanudar (API 24+): segmentos en un único archivo
recording?.pause()
recording?.resume()

// Silenciar / activar audio durante la grabación
recording?.mute(true)
recording?.mute(false)
```

#v(0.3em)

#block(fill: rgb("#fff2df"), width: 100%, inset: 14pt, radius: 5pt)[
  Hay que llamar a `recording.close()` tras `Finalize` para liberar recursos asociados.
]


== ViewModel con Estado de Grabación

#[
  #set text(size: 0.85em)

  ```kotlin
  class CameraViewModel : ViewModel() {
      val videoCapture = VideoCapture.withOutput(Recorder.Builder().build())
      private var recording: Recording? = null
      private val _isRecording = MutableStateFlow(false)
      val isRecording: StateFlow<Boolean> = _isRecording.asStateFlow()

      fun toggleRecording() {
          if (_isRecording.value) {
              recording?.stop()
          } else {
              recording = videoCapture.output
                  .prepareRecording(context, outputOptions).withAudioEnabled()
                  .start(executor) {
                      if (it is VideoRecordEvent.Finalize) {
                          recording?.close(); recording = null; _isRecording.value = false
                      }
                  }
              _isRecording.value = true
          }
      }
  }
  ```
]


== UI en Compose: Estado de Grabación

#[
  #set text(size: 0.9em)

  ```kotlin
  @Composable
  fun CameraScreen(viewModel: CameraViewModel) {
      val isRecording by viewModel.isRecording.collectAsState()
      val previewView = remember { PreviewView(LocalContext.current) }

      // LaunchedEffect: bindToLifecycle con preview y viewModel.videoCapture

      Box(modifier = Modifier.fillMaxSize()) {
          AndroidView(    // Vista previa de la cámara
              factory = { previewView },
              modifier = Modifier.fillMaxSize()
          )
          Button(         // Alterna entre "Grabar" y "Detener"
              onClick = { viewModel.toggleRecording() },
              modifier = Modifier.align(Alignment.BottomCenter).padding(24.dp)
          ) {
              Text(if (isRecording) "Detener" else "Grabar")
          }
      }
  }
  ```
]




// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

---

== Codelab de Referencia

*Getting Started with CameraX*

#link(
  "https://developer.android.com/codelabs/camerax-getting-started",
)[developer.android.com/codelabs/camerax-getting-started]

#v(0.5em)

Codelab oficial de Google que construye paso a paso una app de cámara con CameraX. Cubre:

#v(0.3em)

- Configuración del proyecto y dependencias.
- Solicitud de permisos en runtime.
- Implementación del visor con Preview.
- Captura de fotos con ImageCapture y MediaStore.
- Grabación de vídeo con VideoCapture.
- Análisis de frames con ImageAnalysis.


== Recursos y Documentación

*CameraX*
- Visión general: #link("https://developer.android.com/media/camera/camerax")[developer.android.com/media/camera/camerax]
- Arquitectura: #link("https://developer.android.com/media/camera/camerax/architecture")[developer.android.com/media/camera/camerax/architecture]
- Casos de uso: #link("https://developer.android.com/media/camera/camerax/preview")[preview], #link("https://developer.android.com/media/camera/camerax/take-photo")[take-photo], #link("https://developer.android.com/media/camera/camerax/video-capture")[video-capture], #link("https://developer.android.com/media/camera/camerax/analyze")[analyze]
- Samples: #link("https://github.com/android/camera-samples/")[github.com/android/camera-samples]

#v(1em)

*Permisos y almacenamiento*
- Runtime permissions: #link("https://developer.android.com/training/permissions/requesting")[developer.android.com/training/permissions/requesting]
- MediaStore: #link("https://developer.android.com/training/data-storage/shared/media")[developer.android.com/training/data-storage/shared/media]

