// ============================================================================
// Servicios, Corrutinas, Procesos y Threads
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@preview/touying:0.6.1": speaker-note
#import "@local/touying-gtec-simple:0.1.0": *


#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-common(
    show-notes-on-second-screen: none,
  ),
  ty.config-info(
    title: [Servicios, Corrutinas, Procesos y Threads],
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
// BLOQUE 1: PROCESOS Y THREADS
// ============================================================================

= Procesos y Threads

== El Modelo de Procesos de Android

- Cuando se lanza una aplicación, Android crea un *proceso Linux* con un *único hilo de ejecución*: el *hilo principal* (_main thread_).

- Por defecto, *todos los componentes* de la misma app (Activities, Services, etc.) se ejecutan en el *mismo proceso y el mismo hilo*.

- El sistema puede *matar procesos* cuando necesita liberar recursos. La prioridad depende del estado de los componentes:
  - *Proceso en primer plano*: el usuario interactúa con él (mayor prioridad).
  - *Proceso visible*: visible pero sin foco (ej: Activity detrás de un diálogo).
  - *Proceso de servicio*: ejecuta un Service iniciado.
  - *Proceso en caché*: no tiene componentes activos (menor prioridad).


== El Hilo Principal (_Main Thread / UI Thread_)

El hilo principal es *crítico* porque es el responsable de:

- *Despachar eventos* a los widgets de la UI (toques, clicks...).
- *Dibujar* la interfaz de usuario (rendering).
- *Ejecutar callbacks* del sistema (`onCreate`, `onStart`...).

#v(0.5em)

Android impone *dos reglas fundamentales*:

#block(
  fill: luma(95%),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  + *No bloquear el hilo de UI.* Las operaciones lentas (red, disco, BD) deben ejecutarse en hilos secundarios.
  + *No acceder a la UI desde fuera del hilo principal.* Solo el hilo principal puede modificar la interfaz.
]


== #warning_symb ANR: Application Not Responding

#[
  #set text(size: 0.92em)
  Si el hilo principal se bloquea durante demasiado tiempo, el sistema muestra el diálogo *ANR* (_Application Not Responding_).

  *MAL:* bloquea el hilo principal #sym.arrow la UI se congela
  #v(0.4em, weak: true)
  ```kotlin
  fun onClick() {
      val bitmap = processBitMap("image.png")  // Operación lenta — bloquea la UI
      mostrarImagen(bitmap)
  }
  ```

  *BIEN:* ejecutar el trabajo pesado en un hilo secundario y comunicar el resultado al hilo de UI con `runOnUiThread()` o *corrutinas* (que veremos más adelante).
  #v(0.4em, weak: true)
  ```kotlin
  fun onClick() {
      Thread {
          val bitmap = processBitMap("image.png")  // Hilo secundario
          runOnUiThread {  // Encola la lambda en el hilo de UI
              mostrarImagen(bitmap)
          }
      }.start()
  }
  ```
]

#speaker-note[
  #set text(size: 0.85em)
  `Thread` es de la API de Java (`java.lang.Thread`), accesible desde Kotlin por interoperabilidad. Kotlin no tiene su propia clase Thread, usa la de Java. La sintaxis `Thread { ... }` puede parecer una llamada a función, pero es una llamada al constructor de `Thread` pasando una lambda — Kotlin la convierte automáticamente en un `Runnable` (SAM conversion, Single Abstract Method). Es equivalente a `Thread(Runnable { ... }).start()` o `new Thread(() -> { ... }).start()` en Java.

  Diferencia Thread vs Service: `Thread` es un mecanismo de bajo nivel para ejecutar código en paralelo dentro de un componente (Activity, etc.), y su vida está ligada al proceso. Un `Service` es un componente de Android que indica al sistema que la app tiene trabajo en segundo plano, potencialmente más allá de la interacción del usuario. Un Service puede sobrevivir al cambio de app; un Thread lanzado desde una Activity no necesariamente, ya que el sistema puede matar el proceso si no tiene componentes activos.
]


== Acceder al Hilo de UI desde Otro Hilo

Para comunicarse con el hilo de UI desde otro hilo:

#v(0.5em)

- *`Activity.runOnUiThread(action: Runnable)`*: ejecuta una lambda (`action`) en el hilo de UI directamente desde una Activity.

#v(0.5em)

- *Corrutinas de Kotlin*: el enfoque moderno y recomendado. Permiten cambiar de dispatcher fácilmente sin bloquear hilos (lo veremos más adelante).



// ============================================================================
// BLOQUE 2: SERVICIOS
// ============================================================================

= Servicios (_Services_)

== ¿Qué es un Service?

Un *Service* es un componente de la aplicación que ejecuta operaciones de *larga duración en segundo plano*, sin proporcionar una interfaz de usuario.

- Puede seguir ejecutándose incluso cuando el usuario cambia a otra aplicación.
- Es uno de los 4 componentes fundamentales de Android (junto con Activity, BroadcastReceiver, ContentProvider).

#v(0.5em)

#block(
  fill: rgb("#fff2df"),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  #warning_symb *Importante*: un Service se ejecuta en el *hilo principal* del proceso por defecto. *No crea su propio hilo.* Las operaciones pesadas deben ejecutarse en hilos secundarios o usando corrutinas.
]

#v(0.5em)

Ejemplos de uso: reproducir música de fondo, descargar archivos, sincronizar datos con un servidor.

#speaker-note[
  #set text(size: 0.74em)
  La definición "en segundo plano" es la que usa la documentación oficial de Android, pero es imprecisa: un Background Service se mata cuando la app pasa a segundo plano (desde API 26), así que en realidad no puede ejecutarse "en segundo plano" de forma prolongada. Solo los Foreground Services (con notificación visible) pueden continuar cuando la app no está en primer plano. Lo que define realmente a un Service es que opera sin interfaz de usuario — no que necesariamente corra en background.

  Un Service NO ejecuta trabajo concurrente por sí mismo. Es un componente que, a través de sus callbacks (`onCreate`, `onStartCommand`, `onBind`...), le dice al sistema qué trabajo debe realizarse. El sistema invoca estos callbacks en los momentos adecuados del ciclo de vida. La concurrencia (ejecutar ese trabajo sin bloquear el hilo principal) hay que implementarla aparte, con threads o corrutinas.

  ¿Por qué se ejecuta en el hilo principal? Android usa un modelo de event loop con un único hilo (el Looper del Main Thread). Los callbacks del Service son mensajes en esa cola, igual que los de las Activities. No se ejecutan simultáneamente, sino secuencialmente. Por eso es crítico no bloquear el hilo principal: si un callback del Service hace trabajo pesado, bloquea también la UI.
]


== Dos Formas de Usar un Service

#[
  #set text(size: 0.93em)
  Existen *dos modos fundamentales* de usar un Service, según cómo se lance:

  #table(
    columns: (auto, 1fr, 1fr),
    inset: (x: 10pt, y: 8pt),
    align: (left, left, left),
    table.header([], [*Started Service*], [*Bound Service*]),
    [*Paradigma*],
    [Ejecuta una tarea de principio a fin (_fire & forget_).],
    [Ofrece una API a otros componentes (_cliente-servidor_).],

    [*Se inicia con*], [`startService()`], [`bindService()`],

    [*Dónde está\ el trabajo*],
    [En `onStartCommand()`: el servicio recibe una orden y la ejecuta.],
    [En *métodos públicos* del Service que los clientes invocan bajo demanda.],

    [*Ciclo de vida*],
    [Independiente: sigue vivo aunque el componente que lo inició se destruya. Debe pararse explícitamente.],
    [Ligado a los clientes: se destruye cuando el último cliente se desconecta.],
  )

  Un mismo Service puede ser *started y bound a la vez* (ej: reproductor de música que sigue sonando y además permite controlar la reproducción desde la Activity).
]


#speaker-note[
  #set text(size: 0.8em)
  Analogía útil: un Started Service es como un mensajero — le das un paquete (Intent) y se va a entregarlo; no vuelves a hablar con él. Un Bound Service es como un bibliotecario — te conectas y le haces peticiones: "búscame este libro", "¿está abierta la sala?". El trabajo ocurre bajo demanda.

  La diferencia clave es *quién inicia el trabajo*: en un Started Service, el trabajo empieza automáticamente en `onStartCommand()`; en un Bound Service, el servicio se pone a disposición y los clientes llaman a métodos cuando necesitan algo.

  Ejemplo híbrido (Spotify): `startService()` para que la música no se pare al cerrar la app; `bindService()` para que la Activity pueda controlar la reproducción (pause, skip, ver progreso). Si el usuario cierra la app, se hace `unbind`, pero el servicio sigue vivo porque también fue started.
]


== Foreground y Background Services

Dentro de los Started Services, Android distingue:

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 14pt),
  align: (left, left),
  table.header([*Tipo*], [*Descripción*]),
  [*Foreground Service*\ (primer plano)],
  [
    Realiza operaciones *perceptibles para el usuario* (ej: reproducir música, navegación GPS).
    - *Debe mostrar una notificación* permanente.
    - Continúa ejecutándose aunque el usuario cambie de app.
  ],

  [*Background Service*\ (segundo plano)],
  [
    Realiza operaciones *no percibidas* directamente por el usuario.
    - Desde API 26+, el sistema lo *mata* cuando la app pasa a segundo plano.
    - Recomendación: usar *WorkManager* para trabajo diferido.
  ],
)

#speaker-note[
  #set text(size: 0.85em)
  ¿Para qué valen los Background Services si se restringen? Las restricciones de API 26 no los eliminan: pueden ejecutarse mientras la app está en primer plano (para trabajo que el usuario no percibe directamente, como pre-cachear datos). Lo que se restringe es que sigan corriendo indefinidamente cuando la app pasa a segundo plano (antes de API 26 sí podían). Para trabajo que necesita continuar en background: usar Foreground Service (con notificación) si es perceptible, o WorkManager si es diferido.

  Modelo mental: Service → Started Service (Foreground / Background) o Bound Service. Un Service puede ser Started + Bound a la vez.
]


== Ciclo de Vida: Started Service

#grid(
  columns: (1fr, 35%),
  column-gutter: 1.5em,
  align: horizon,
  [
    #set text(size: 0.94em)
    Se inicia con `startService()`. Android crea el servicio si no existe y llama al callback `onStartCommand()`, donde se lanza el trabajo. El servicio corre de forma independiente: aunque el componente que lo inició se destruya, el servicio sigue corriendo. Debe pararse explícitamente.

    + `onCreate()`: creación inicial (solo la primera vez).
    + `onStartCommand()`: se recibe la orden y se lanza el trabajo.
    + Ejecuta su trabajo...
    + `onDestroy()`: alguien llama a `stopService()` o el servicio se detiene con `stopSelf()`.

    #block(
      fill: rgb("#fff2df"),
      inset: 10pt,
      radius: 5pt,
      width: 100%,
    )[
      #warning_symb El sistema *no lo detiene automáticamente*. Si no se llama a `stopSelf()` o `stopService()`, el servicio sigue corriendo indefinidamente.
    ]
  ],
  image("images/service_lifecycle.png", height: 90%),
)

== Ciclo de Vida: Bound Service

#grid(
  columns: (1fr, 35%),
  column-gutter: 1.5em,
  align: horizon,
  [
    #set text(size: 0.92em)
    Se inicia con `bindService()`. Android crea el servicio si no existe. El servicio actúa como un *servidor local*: se pone a disposición de los clientes, que invocan sus métodos bajo demanda. Vive mientras haya al menos un cliente conectado.

    + `onCreate()`: creación inicial (solo la primera vez)
    + `onBind()`: un cliente se conecta; devuelve un `IBinder` para comunicarse
    + Los clientes llaman a métodos del servicio...
    + `onUnbind()`: todos los clientes se desconectan
    + `onDestroy()`: el servicio se destruye

    #block(
      fill: luma(94%),
      inset: 10pt,
      radius: 5pt,
      width: 100%,
    )[
      Un Service puede ser *started y bound a la vez*. En ese caso, al desconectarse todos los clientes el servicio *no se destruye*, sigue vivo hasta que se llame a `stopSelf()` o `stopService()`.
    ]
  ],
  image("images/service_lifecycle.png", height: 90%),
)


== Declarar un Service en el manifest

#[
  #set text(size: 0.9em)
  Todo Service *debe declararse* en `AndroidManifest.xml`:

  ```xml
  <manifest ... >
      <application ... >
          <service
              android:name=".MiServicio"
              android:exported="false"
              android:description="@string/mi_servicio_desc" />
      </application>
  </manifest>
  ```

  Atributos principales:
  #v(0.6em, weak: true)
  #[
    #set text(size: 0.9em)
    #table(
      columns: (auto, 1fr),
      inset: (x: 8pt, y: 5pt),
      align: (left, left),
      table.header([*Atributo*], [*Descripción*]),
      [`android:name`], [Clase del Service _(obligatorio)_.],
      [`android:exported`], [`false` = solo accesible desde tu app. `true` = otras apps pueden usarlo.],
      [`android:foregroundServiceType`],
      [Tipo de foreground service: `location`, `mediaPlayback`, `camera`, `microphone`, `dataSync`...],

      [`android:permission`], [Permiso necesario para iniciar, enlazar o detener el Service.],
      [`android:description`], [Descripción para el usuario (puede ver y parar servicios activos).],
    )
  ]
]

#speaker-note[
  #set text(size: 0.56em)
  Tipos de `foregroundServiceType`: `location`, `mediaPlayback`, `camera`, `microphone`, `dataSync`, `phoneCall`, `connectedDevice`, `mediaProjection`, `health`, `remoteMessaging`, `shortService`, `specialUse`, entre otros. Cada tipo requiere permisos específicos y desde Android 14 (API 34) es obligatorio declarar al menos uno para foreground services. Por ejemplo, `location` requiere `ACCESS_FINE_LOCATION` o `ACCESS_COARSE_LOCATION`.


  Las APIs de acceso a hardware (ubicación, cámara...) son las que exigen los permisos al usuario: el `foregroundServiceType` no los reemplaza. Sin embargo, el tipo aporta información adicional al sistema con la que puede:
  1. Mostrar al usuario en Ajustes qué recursos usa cada servicio en segundo plano (transparencia).
  2. Activar indicadores de privacidad: Android muestra el icono de ubicación o cámara en la barra de estado cuando un servicio de ese tipo está activo.
  3. Hacer cumplir que el tipo coincida con el uso real — desde API 34, si el servicio accede a la cámara pero declara `dataSync`, el sistema puede rechazarlo. 4. Aplicar restricciones específicas por tipo: por ejemplo, `shortService` tiene un límite de tiempo de ejecución y el sistema lo termina si se alarga demasiado.
  5. Permitir a Google Play hacer cumplir sus políticas sobre acceso a recursos sensibles en background. En resumen, es un mecanismo de declaración de intención para que el sistema pueda tomar decisiones informadas sobre batería, privacidad y seguridad.

  Sobre `android:permission`: cualquier componente (de tu app u otra) que quiera iniciar (`startService`), enlazar (`bindService`) o detener (`stopService`) este Service necesita tener el permiso declarado. Es un mecanismo de control de acceso; si no se tiene, la llamada lanza `SecurityException`. Especialmente útil para servicios con `android:exported="true"` que exponen funcionalidad a otras apps.
]

== Crear un Service: Ejemplo Básico

#grid(
  columns: (auto, 35%),
  column-gutter: 1.5em,
)[
  #set text(size: 0.86em)
  ```kotlin
  class MiServicio : Service() {

      override fun onCreate() {
          // El servicio se crea (una sola vez)
      }

      override fun onStartCommand(
        intent: Intent?, flags: Int, startId: Int): Int {
          // Se recibe la orden (Intent).
          // Aquí se lanza el trabajo en un hilo/corrutina.
          return START_STICKY
      }

      override fun onBind(intent: Intent): IBinder? {
          return null  // No soporta binding en este ejemplo
      }

      override fun onDestroy() {
          // El servicio se destruye. Liberar recursos.
      }
  }
  ```
][
  *Callbacks principales:*

  - `onCreate()`: inicialización (se llama una sola vez).

  - `onStartCommand()`: se llama cada vez que se inicia con `startService()`.

  - `onBind()`: se llama cuando un cliente se enlaza con `bindService()`.

  - `onDestroy()`: limpieza final.
]


== Iniciar y Detener un Service

*Iniciar* un Service:
#v(0.8em, weak: true)
```kotlin
// Desde una Activity u otro componente
val intent = Intent(this, MiServicio::class.java)
startService(intent)
```

*Detener* un Service:
#v(0.8em, weak: true)
```kotlin
// Desde fuera del Service
stopService(Intent(this, MiServicio::class.java))

// Desde dentro del propio Service
stopSelf()
```

#v(0.5em)

#block(
  fill: rgb("#fff2df"),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  #warning_symb Un Service que recibe llamadas a `onStartCommand()` debe gestionar su propio ciclo de vida. El sistema *no lo detiene automáticamente*. Si no se llama a `stopSelf()` o `stopService()`, se desperdician recursos y batería.
]

#speaker-note[
  ¿Quién llama a las funciones stop? La responsabilidad recae en el desarrollador. `stopSelf()` se llama desde dentro del propio Service cuando termina su trabajo. `stopService()` se llama desde fuera (ej: una Activity que inició el Service). Si nadie llama a ninguna de las dos, el Service sigue vivo indefinidamente consumiendo recursos (aunque el sistema puede matarlo por presión de memoria, lo recreará según el valor de retorno de `onStartCommand()`). En Bound Services la gestión es automática: el sistema destruye el Service cuando todos los clientes se desenlacen con `unbindService()`.
]


== Valores de Retorno de `onStartCommand()`

El valor devuelto por `onStartCommand()` indica al sistema qué hacer si mata el servicio por falta de memoria:

#v(0.5em)

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 12pt),
  align: (left, left),
  table.header([*Constante*], [*Comportamiento*]),
  [`START_NOT_STICKY`],
  [*No recrear* el servicio si el sistema lo mata. Opción más segura para evitar ejecuciones innecesarias.],

  [`START_STICKY`],
  [*Recrear* el servicio, pero `onStartCommand()` recibe `null` como intent. Adecuado para servicios indefinidos (ej: reproductor de música).],

  [`START_REDELIVER_INTENT`],
  [*Recrear* el servicio y re-entregar el último Intent. Adecuado para tareas que deben completarse (ej: descargas).],
)


== Foreground Services

#[
  #set text(size: 0.88em)
  Un *Foreground Service* realiza trabajo *visible para el usuario*. Se inicia con `startService()` y dentro del Service se llama a `startForeground()` para promoverlo a primer plano. Requiere mostrar una *notificación permanente*:
  #v(0.5em, weak: true)
  ```kotlin
  // Iniciar un Foreground Service
  val intent = Intent(this, MusicService::class.java)
  startService(intent)
  ```

  Dentro del Service, se debe llamar a `startForeground()`:
  #v(0.5em, weak: true)
  ```kotlin
  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
      val notification = buildNotification()  // Crear notificación
      startForeground(NOTIFICATION_ID, notification)
      // ... ejecutar trabajo
      return START_STICKY
  }
  ```

  Desde Android 9 (API 28), se debe declarar el tipo en el manifiesto:
  #v(0.5em, weak: true)
  ```xml
  <service
      android:name=".MusicService"
      android:foregroundServiceType="mediaPlayback" />
  ```
]

#speaker-note[
  Sí, los 5 segundos son una restricción impuesta por Android (desde API 26). Si no se llama a `startForeground()` dentro de ese plazo tras `startForegroundService()`, el sistema lanza `ForegroundServiceDidNotStartInTimeException` y la app crashea. Desde Android 12 (API 31) hay restricciones adicionales: no se pueden iniciar foreground services desde background salvo excepciones específicas (ej: tras recibir un mensaje FCM de alta prioridad, desde un BroadcastReceiver de alta prioridad, etc.). En Android 14+ las restricciones son aún más estrictas.
]

== Notificaciones a los Usuarios

Un Service puede notificar eventos al usuario mediante:

#grid(
  columns: (1fr, 1fr),
  rows: (auto, auto, auto),
  column-gutter: 1.5em,
  row-gutter: 0.75em,
  align: top,
  [
    *Toast*: mensaje breve que aparece temporalmente y desaparece solo.
  ],
  [
    *Notificación*: mensaje en la barra de estado, el cajón de notificaciones o como notificación emergente.
  ],

  [
    #align(center + horizon)[
      #image("images/toast.png", width: 75%)
    ]
  ],
  [
    #align(center + horizon)[
      #image("images/notification-headsup.png", width: 55%)
    ]
  ],

  [
    https://developer.android.com/guide/topics/ui/notifiers/toasts.html
  ],
  [
    https://developer.android.com/develop/ui/views/notifications
  ],
)


== #warning_symb Precauciones con Services

+ *No bloquear el hilo principal*: un Service *no crea su propio hilo*. Usa corrutinas o hilos secundarios.

+ *Restricciones desde API 26*: Android limita los Background Services cuando la app no está en primer plano. Usar *WorkManager* o *Foreground Services* en su lugar.

// + *Usar solo Intents explícitos*: nunca usar intents implícitos para iniciar un Service (lanza excepción desde API 21).

// + *`IntentService` está deprecated*: desde Android 11. Reemplazar con `JobIntentService` o, mejor aún, con *corrutinas + WorkManager*.

+ *El sistema puede matar Services*: diseñar para un reinicio. Usar el valor de retorno de `onStartCommand()` para controlar el comportamiento tras un kill.

+ *Los usuarios pueden parar Services*: el usuario puede ver y detener servicios activos. Incluir una `android:description` clara para evitar que los paren por accidente.


== Service vs. Thread/Corrutina

#table(
  columns: (1fr, 1fr),
  inset: (x: 12pt, y: 12pt),
  align: (left, left),
  table.header([*Usar Service cuando...*], [*Usar Thread/Corrutina cuando...*]),
  [
    - El trabajo debe continuar cuando la app *no está en primer plano* #sym.arrow solo Foreground Service.
    // (requiere notificación).
    - El trabajo es prolongado y *perceptible* por el usuario (música, GPS...).
    - Se necesita señalizar al sistema que la app tiene trabajo activo.
  ],
  [
    - El trabajo solo es necesario *mientras la Activity está activa*.
    - La tarea es *puntual* (cargar datos, hacer una petición).
    - No se necesita que el trabajo sobreviva al ciclo de vida del componente.
  ],
)

#block(
  fill: luma(94%),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  *Recomendación de Google*: para la mayoría de tareas en segundo plano, usar *WorkManager* en lugar de Services directamente. WorkManager gestiona compatibilidad, restricciones de batería y reintentos automáticamente.
]


// ============================================================================
// BLOQUE 4: CORRUTINAS DE KOTLIN
// ============================================================================

= Corrutinas de Kotlin

== De AsyncTask a Corrutinas

Históricamente, Android ofrecía `AsyncTask` para ejecutar trabajo en segundo plano. Fue *deprecated en API 30* (Android 11) por problemas de memory leaks y mal manejo del ciclo de vida.

#v(0.5em)

Problemas de `AsyncTask`:
- Memory leaks y mal manejo del ciclo de vida.
- Callback hell con tareas encadenadas.
- API compleja (`doInBackground`, `onPostExecute`...).

#v(0.5em)

La migración recomendada de código con `AsyncTask` es a *corrutinas de Kotlin*.


== Dependencia Gradle

#[
  #set text(size: 0.95em)
  Para usar corrutinas en un proyecto Android, añadir la dependencia en `build.gradle.kts`:

  ```kotlin
  // build.gradle.kts (módulo app)
  dependencies {
      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
  }
  ```

  Para las extensiones de ciclo de vida (`viewModelScope`, `lifecycleScope`):

  ```kotlin
  dependencies {
      // viewModelScope
      implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.7")
      // lifecycleScope + repeatOnLifecycle
      implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
  }
  ```

  #block(
    fill: luma(95%),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    En proyectos nuevos con Android Studio, estas dependencias suelen estar incluidas por defecto.
  ]
]

#speaker-note[
  ¿Por qué hay que añadir una dependencia si las corrutinas son de Kotlin? El lenguaje Kotlin incluye en su stdlib solo la palabra clave `suspend` y el soporte mínimo del compilador. La implementación completa (builders como `launch`, `async`, dispatchers, scopes, `Flow`...) está en la librería separada `kotlinx.coroutines`, mantenida por JetBrains pero distribuida aparte. La variante `-android` añade `Dispatchers.Main` (basado en el Looper de Android). Las dependencias de `lifecycle-*-ktx` proporcionan los scopes integrados con el ciclo de vida (`viewModelScope`, `lifecycleScope`).
]

== ¿Qué es una Corrutina?

Una *corrutina* es una computación que puede *suspenderse* y reanudarse más tarde. Cuando una corrutina se suspende, libera el hilo y otra corrutina puede ejecutarse en él — esto permite *concurrencia en un mismo hilo*, sin bloquear.

#v(1em)

Ventajas principales:
- *Ligeras*: se pueden ejecutar miles en un solo hilo (a diferencia de los threads).
- *Menos memory leaks*: al cancelar el scope (ej: Activity destruida), todas sus corrutinas se cancelan — no quedan tareas huérfanas con referencias a componentes destruidos.
- *Cancelación automática*: se propaga por toda la jerarquía de corrutinas.
- *Integración con Jetpack*: `viewModelScope`, `lifecycleScope`, etc.


#speaker-note[
  ¿Funcionan como en JS/Python (un solo hilo, cooperative multitasking)? No exactamente. En JS las corrutinas (async/await) son siempre single-threaded (event loop). En Kotlin, las corrutinas pueden ejecutarse en múltiples hilos gracias a los Dispatchers (se ven más adelante). Cuando una corrutina se suspende (ej: espera red), libera su hilo y otra corrutina puede usarlo — eso sí es similar a JS. Pero además pueden repartirse entre un pool de hilos, lo que permite paralelismo real en CPU.
]

== Corrutinas vs Callbacks

Sin corrutinas, las operaciones asíncronas (red, disco...) necesitan *callbacks* para recibir el resultado sin bloquear el hilo. Con corrutinas, las funciones `suspend` pausan la corrutina (no el hilo), y el código queda secuencial:

*Sin corrutinas* (callbacks):
```kotlin
fetchUser { user ->
    fetchOrders(user.id) { orders ->
        updateUI(orders)
    }
}
```

*Con corrutinas* (secuencial):
```kotlin
val user = fetchUser()
val orders = fetchOrders(user.id)
updateUI(orders)
```

#speaker-note[
  Sobre `fetchUser()` y `fetchOrders()`: en el ejemplo "Con corrutinas", ambas serían funciones `suspend`. Se llaman secuencialmente como código normal, sin necesidad de `await` como en JS. En Kotlin, al llamar a una función `suspend` la corrutina se suspende automáticamente si es necesario — el `await` está implícito. Cuando se quiere paralelismo, se usa `async { ... }.await()` explícitamente (se ve más adelante).
]

== Funciones `suspend`

#[
  #set text(size: 0.98em)
  Una función `suspend` puede *pausar* su ejecución y *reanudarse* más tarde sin bloquear el hilo. Similar a `async def` en Python o `async function` en JS.
  // El ejemplo usa `withContext` y `Dispatchers`, que se explican en las siguientes diapositivas:

  ```kotlin
  // suspend: puede pausar su ejecución y reanudarla más tarde
  suspend fun fetchUser(userId: String): User {
      return api.getUser(userId)  // api.getUser también es suspend
  }
  ```

  - Solo se pueden llamar desde *otra función `suspend`* o desde una *corrutina*.
  - `suspend` *no ejecuta automáticamente en otro hilo*: el hilo depende del dispatcher de la corrutina que la llama.

  #block(
    fill: luma(95%),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    La clave de `suspend` es que libera el hilo mientras espera, permitiendo que otros trabajos se ejecuten en él.
  ]
]

#speaker-note[
  #set text(size: 0.66em)
  Las funciones `suspend` no son las corrutinas. Una corrutina es una instancia de ejecución (lo que se crea al llamar a `launch` o `async`). Una función `suspend` es una función que puede ejecutarse dentro de una corrutina y que tiene la capacidad de suspenderse. La relación: las corrutinas ejecutan funciones `suspend`; las funciones `suspend` solo pueden ejecutarse dentro de corrutinas (o desde otras funciones `suspend`). Es como la relación entre un thread y un `Runnable`: el thread es la unidad de ejecución, el `Runnable` es el código que ejecuta.

  ¿Son como `async`/`await` en Python o JS? En parte sí: igual que allí, una función `suspend` puede pausarse y ceder el control para que otras tareas avancen. La diferencia clave: en Python y JS el modelo es single-threaded (event loop), mientras que en Kotlin las corrutinas pueden repartirse entre múltiples hilos mediante los Dispatchers.

  ¿Qué causa la suspensión? Llamar a otra función `suspend` que internamente necesita esperar: `delay()` (espera un tiempo), operaciones de red o disco declaradas como `suspend` (Retrofit, Room), o `withContext()` al cambiar de dispatcher. El compilador transforma el código para que la suspensión sea implícita — no hace falta `await` explícito como en JS.

  Equivalentes a los primitivos de `asyncio` de Python: `Deferred<T>` (≈ `Future`, devuelto por `async {}`), `Channel<T>` (≈ `Queue`, comunicación productor/consumidor), `Flow<T>` (≈ streams / async generators, muy usado con Room y StateFlow), `Mutex` (≈ `Lock`), `Semaphore`. Todos forman parte de `kotlinx.coroutines`.
]


== Lanzar Corrutinas: `launch` y `async`

#[
  #set text(size: 0.98em)
  Toda corrutina debe lanzarse dentro de un *`CoroutineScope`*. El más directo es `GlobalScope` (global al proceso).

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align: top,
    [
      *`launch`*: "lanza y olvida".
      No devuelve resultado. Para operaciones con efectos secundarios.

      ```kotlin
      GlobalScope.launch {
          saveToDatabase(data)
      }
      ```
    ],
    [
      *`async`*: devuelve un `Deferred<T>`. Se obtiene el resultado con `await()`.

      ```kotlin
      val deferred = GlobalScope.async {
          fetchFromNetwork()
      }
      val result = deferred.await()
      ```
    ],
  )

  #v(0.3em)

  #warning_symb `GlobalScope` *no se recomienda* en apps Android: las corrutinas no tienen ciclo de vida controlado y pueden causar leaks. En Android usar `viewModelScope`, `lifecycleScope`, etc.

  #v(0.3em)

  Diferencia en el *manejo de excepciones*:
  - `launch`: una excepción no capturada *crashea la app*.
  - `async`: la excepción se retiene y se re-lanza al llamar a `await()`.
]

#speaker-note[
  #set text(size: 0.9em)
  ¿Qué es un `CoroutineScope`? Es un objeto que controla el ciclo de vida de las corrutinas lanzadas dentro de él. Define un contexto (dispatcher, job) y garantiza la concurrencia estructurada: si el scope se cancela, todas sus corrutinas hijas se cancelan. En Android se usan scopes predefinidos (`viewModelScope`, `lifecycleScope`) que se cancelan automáticamente con el componente. Se puede crear uno manualmente con `CoroutineScope(Job() + Dispatchers.Main)` (se ve más adelante en esta presentación).

  Sobre las excepciones en `launch`: sí, se pueden capturar con `try-catch` dentro de la lambda: `scope.launch { try { ... } catch(e: Exception) { ... } }`. Si no se capturan, la excepción se propaga al scope padre y crashea la app. En `async`, la excepción queda encapsulada en el `Deferred` y se re-lanza al llamar a `await()`, por lo que el `try-catch` se pone alrededor del `await()`.
]


== `withContext()`: Ejecutar en Otro Hilo

#block(
  fill: rgb("#fff2df"),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  `withContext()` suspende la corrutina, ejecuta el bloque en el *dispatcher* indicado y *vuelve automáticamente* al dispatcher original. Recibe como parámetro un *dispatcher*, que especifica en qué hilo o pool de hilos se ejecuta una corrutina.
]

```kotlin
// Esta función es "main-safe": puede llamarse desde el hilo de UI
suspend fun loadUser(id: String): User {
    return withContext(Dispatchers.IO) {
        // Este bloque se ejecuta en un hilo de I/O
        api.getUser(id)
    }
    // Vuelve automáticamente al dispatcher original
}
```

Una función es *main-safe* cuando no bloquea el hilo de UI. `withContext()` es la forma estándar de garantizarlo.


== Dispatchers: ¿En Qué Hilo Se Ejecuta?

Los *Dispatchers* determinan en qué hilo (o pool de hilos) se ejecuta una corrutina:

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 10pt),
  align: (left, left),
  table.header([*Dispatcher*], [*Uso*]),
  [`Dispatchers.Main`], [Hilo principal de UI. Para actualizar la interfaz y trabajo rápido.],
  [`Dispatchers.IO`],
  [Pool de hilos pensado para realizar *operaciones de entrada/salida*: red, disco, base de datos, etc.],

  [`Dispatchers.Default`],
  [Pool con tantos hilos como cores de CPU. Para trabajo que *usan activamente la CPU*: ordenar listas, parsear JSON, etc.],
)

```kotlin
suspend fun loadData(): List<Item> {
    return withContext(Dispatchers.IO) {  // Cambia al hilo de I/O
        database.getAllItems()            // Operación de disco
    }
}
```

#speaker-note[
  #set text(size: 0.9em)
  Los Dispatchers determinan en qué hilo se ejecuta una corrutina. El código de ejemplo usa `withContext()`, introducido en la diapositiva anterior.

  Diferencia real entre IO y Default: los hilos son los mismos internamente (comparten pool), pero con límites distintos. `Dispatchers.IO` permite hasta 64 hilos concurrentes (las operaciones de I/O pasan tiempo esperando, por eso se necesitan más). `Dispatchers.Default` limita al número de cores de CPU (más hilos no ayudan si la CPU ya está al 100%).

  Se pueden crear dispatchers personalizados a partir de un Executor de Java: `Executors.newSingleThreadExecutor().asCoroutineDispatcher()`. También existe `Dispatchers.Unconfined` (raramente usado: ejecuta en el hilo actual hasta el primer punto de suspensión).
]


== `runBlocking`

#[
  #set text(size: 0.92em)
  #block(
    fill: rgb("#fff2df"),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    `runBlocking` *crea un `CoroutineScope`* y *bloquea el thread actual* hasta que todas las corrutinas dentro del scope terminan. Se usa para lanzar corrutinas desde código síncrono (fuera de corrutinas): `main()` y tests.
  ]

  - Recibe una lambda que tiene el `CoroutineScope` como `this`, por lo que `launch` y `async` pueden llamarse directamente en su interior.

  #grid(
    columns: (1fr, 1.2fr),
    column-gutter: 1.5em,
    align: top,
    [
      *Secuencial*: las llamadas `suspend` se ejecutan en orden.

      ```kotlin
      fun main() = runBlocking {
          tarea("Tarea 1")
          tarea("Tarea 2")
          println("Tareas 1 y 2 finalizadas")
      }
      ```
    ],
    [
      *Concurrente*: con `launch`.

      ```kotlin
      fun main() = runBlocking {
          val job1 = this.launch { tarea("Tarea 1") }
          val job2 = this.launch { tarea("Tarea 2") }

          job1.join()  // suspende
          job2.join()  // suspende

          println("Tareas 1 y 2 finalizadas")
      }
      ```
    ],
  )
]

#speaker-note[
  #set text(size: 0.8em)
  `runBlocking` es de la librería `kotlinx.coroutines`. Se usa principalmente en `main()` y en tests para crear un puente entre código síncrono y corrutinas.

  Sobre "concurrente" vs "paralelo": dentro de `runBlocking` el dispatcher por defecto es el propio thread que lo llama, por lo que las dos corrutinas se intercalan en los puntos de suspensión (concurrencia) pero nunca se ejecutan simultáneamente en hilos distintos (paralelismo). Para paralelismo real habría que usar `Dispatchers.Default` o `Dispatchers.IO`.

  Sobre `join()`: `runBlocking` espera a todos sus hijos antes de retornar — es parte de la concurrencia estructurada. En el ejemplo, ambas versiones (con y sin `join()`) son equivalentes: `runBlocking` no retorna hasta que `job1` y `job2` terminen. La diferencia es que `join()` sirve para ordenar operaciones *dentro* del bloque: si hubiera código después de los joins que necesite ejecutarse cuando ambos hayan terminado, `join()` lo garantiza explícitamente.
]


== `coroutineScope`: Agrupar Corrutinas

#[
  #set text(size: 0.96em)
  #block(
    fill: rgb("#fff2df"),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    `coroutineScope` es una función `suspend` que crea un *scope hijo*. Se usa *dentro de otras funciones `suspend`* para lanzar corrutinas y esperar a que todas terminen, sin bloquear el thread.
  ]

  - Recibe una lambda que tiene el `CoroutineScope` como `this` (igual que runBlocking), por lo que `launch` y `async` pueden llamarse directamente. Suspende la corrutina actual hasta que todos sus hijos terminan.

  ```kotlin
  suspend fun cargarDatos() {
      coroutineScope {
          this.launch { tarea("A") }  // A y B se lanzan a la vez
          this.launch { tarea("B") }
      }
      println("A y B finalizadas")
  }
  ```

  - Si un hijo falla, *cancela a los demás* y propaga la excepción.
]

== `delay`

#block(
  fill: rgb("#fff2df"),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  `delay` es una función `suspend` que *pausa la corrutina* durante el tiempo indicado sin bloquear el thread.
]

#v(1em)

```kotlin
suspend fun saludarConRetraso() {
    delay(1000)        // pausa 1 segundo; el thread queda libre
    println("¡Hola!")
}
```

#v(0.5em)

- Solo puede llamarse desde corrutinas o funciones `suspend`.

#v(0.5em)

#block(
  fill: luma(95%),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  #warning_symb No usar `Thread.sleep` en corrutinas: *bloquea el thread* por completo e impide que otras corrutinas se ejecuten en él.
]


== CoroutineScope

#[
  #set text(size: 0.92em)
  #block(
    fill: rgb("#fff2df"),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    Un *`CoroutineScope`* agrupa corrutinas y controla su ciclo de vida.
  ]

  #v(0.75em, weak: true)

  - `scope.cancel()` *cancela todas las corrutinas* del scope a la vez.
  - No se pueden lanzar corrutinas en un scope cancelado: evita trabajo huérfano.

  ```kotlin
  class MiClase {
      val scope = CoroutineScope(Dispatchers.Main)

      fun hacerTrabajo() {
          scope.launch {
              val datos = withContext(Dispatchers.IO) { cargarDatos() }
              mostrarDatos(datos)
          }
      }

      fun limpiar() {
          scope.cancel()  // Cancela TODAS las corrutinas del scope
      }
  }
  ```
]

== Concurrencia Estructurada

#[
  #set text(size: 0.92em)
  #block(
    fill: rgb("#fff2df"),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    Las corrutinas lanzadas en un scope son *hijas* de ese scope. El scope *no termina* hasta que todas sus hijas completan.
  ]

  #v(0.5em)

  ```kotlin
  suspend fun doWork() = coroutineScope {  // crea un scope hijo
      this.launch { delay(1000); println("Tarea 1") }  // hija 1
      this.launch { delay(2000); println("Tarea 2") }  // hija 2
      // coroutineScope espera a que ambas terminen
  }
  ```

  #v(0.5em)

  Consecuencias de esta jerarquía:
  - Cancelar un *padre* cancela automáticamente *todos sus hijos*.
  - Un scope *espera* a que todos sus hijos terminen antes de completarse.
]

== Job

#block(
  fill: rgb("#fff2df"),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  Un *`Job`* es un handle que representa el ciclo de vida de una corrutina.
]

#v(0.5em)

- `scope.launch` devuelve un `Job`;
- `scope.async` devuelve un `Deferred<T>` (que extiende `Job`).
- Estados: *active* → *completed* / *cancelled*.

#v(0.5em)

```kotlin
val job = scope.launch { /* trabajo */ }
job.cancel()         // Cancela solo esta corrutina
job.join()           // Suspende hasta que la corrutina termine
job.cancelAndJoin()  // Atajo: cancel() + join()
```

- `cancel()` marca el Job para cancelación, pero *no espera* a que termine.
- `join()` suspende hasta que el Job termine (por completar o por cancelar).


#speaker-note[
  `Deferred<T>` es una interfaz que extiende `Job` y añade la capacidad de devolver un valor de tipo `T` mediante `await()`. La `T` es el tipo del resultado del bloque `async`, no `Job`. Es similar a `Future<T>` de Java o `Promise<T>` de JS. Ejemplo: `val d: Deferred<String> = scope.async { "hola" }; val resultado: String = d.await()`.
]

== Cancelación de Corrutinas

#[
  // #set text(size: 0.95em)
  La cancelación es *cooperativa*: Kotlin no interrumpe la corrutina a la fuerza. La corrutina debe comprobar la cancelación para terminar.

  - Las funciones `suspend` de `kotlinx.coroutines` (`delay`, `withContext`...) ya comprueban la cancelación automáticamente: lanzan `CancellationException` si el Job fue cancelado.

  - En bucles con trabajo intensivo (sin llamar a funciones `suspend`) se debe comprobar manualmente si el Job fue cancelado:

  #grid(
    columns: (auto, auto),
    column-gutter: 1em
  )[
    ```kotlin
    val job = scope.launch {
        while (this.isActive) {
            procesarSiguienteItem()
        }  // Sale limpiamente al cancelar
    }

    job.cancel()  // isActive pasa a false
    job.join()    // Espera a que termine
    ```
  ][
    - *`isActive`*: la lambda de `launch` recibe el `CoroutineScope` como `this`. `isActive` es una propiedad de ese scope que indica si el Job fue cancelado.

    - *`ensureActive()`*: función que lanza `CancellationException` directamente si el Job fue cancelado.
  ]
]

#speaker-note[
  #set text(size: 0.8em)
  Cuando se cancela una corrutina, el mecanismo interno es lanzar una `CancellationException` en el siguiente punto de suspensión. Regla importante: nunca atrapar `CancellationException` con un `catch(e: Exception)` genérico sin re-lanzarla, ya que impediría que la cancelación se propague correctamente.

  Tres formas de comprobar la cancelación en código que no suspende:
  - `isActive`: comprobar manualmente en un bucle (como en el ejemplo).
  - `ensureActive()`: lanza `CancellationException` si el Job está cancelado — más conciso que `if (!isActive) return`.
  - `yield()`: suspende la corrutina, comprueba cancelación, y cede el hilo a otras corrutinas.

  Las funciones `suspend` de la librería (`delay`, `withContext`, `channel.receive`, etc.) ya cooperan con la cancelación internamente — solo hace falta comprobar manualmente en bucles con trabajo intensivo de CPU que no llaman a funciones `suspend`.
]

== `withTimeout`


#block(
  fill: rgb("#fff2df"),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  `withTimeout` cancela automáticamente una corrutina si excede el tiempo indicado.
]

*`withTimeout`*: lanza `TimeoutCancellationException` si se excede el tiempo.

```kotlin
withTimeout(3000) {
    val datos = fetchDatos()
    procesarDatos(datos)
}
```

*`withTimeoutOrNull`*: devuelve `null` si se excede el tiempo.

```kotlin
val datos = withTimeoutOrNull(3000) {
    fetchDatos()
}
// datos es null si se agotó el tiempo
```


// ============================================================================
// BLOQUE 5: CORRUTINAS CON CICLO DE VIDA
// ============================================================================

= Corrutinas y Ciclo de Vida de Android

== Scopes Integrados con el Ciclo de Vida

#[
  #set text(size: 0.90em)
  Android proporciona scopes que se *cancelan automáticamente* cuando el componente se destruye:

  #table(
    columns: (auto, 1fr),
    inset: (x: 10pt, y: 8pt),
    align: (left, left),
    table.header([*Scope*], [*Descripción*]),
    [`viewModelScope`],
    [Vinculado al *ViewModel*. Se cancela cuando el ViewModel se limpia (`onCleared()`). Dispatcher por defecto: `Main`.],

    [`lifecycleScope`],
    [Vinculado al *ciclo de vida* de una Activity o Fragment. Se cancela cuando se destruye (`DESTROYED`).],
  )

  ```kotlin
  class MyViewModel : ViewModel() {
      init {
          viewModelScope.launch {
              val data = repository.fetchData()  // Suspend function
              _uiState.value = data
          }
          // Si el ViewModel se destruye, la corrutina se cancela automáticamente
      }
  }
  ```
]

#speaker-note[
  #set text(size: 0.88em)
  Correcto: si el ViewModel se destruye (por ejemplo, al cerrar definitivamente la pantalla, no en un cambio de configuración), se llama a `onCleared()` y `viewModelScope` se cancela automáticamente. Esto cancela todas las corrutinas en curso lanzadas en ese scope. La corrutina recibe una `CancellationException` y se detiene. Esto previene memory leaks y trabajo innecesario (ej: no seguir haciendo una petición de red si el usuario ya salió de esa pantalla).

  `viewModelScope` es una *extension property* de la clase `ViewModel` definida en `lifecycle-viewmodel-ktx`: `val ViewModel.viewModelScope: CoroutineScope`. Solo es accesible desde dentro de una subclase de `ViewModel` (o una extension function sobre ella) — funciona como un atributo de instancia. Fuera de un `ViewModel` no existe: en Activity/Fragment se usa `lifecycleScope`, y en otras clases hay que crear un `CoroutineScope` manualmente.
]


== `viewModelScope`: Ejemplo — ViewModel

#[
  #set text(size: 0.92em)
  #block(
    fill: rgb("#fff2df"),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    `viewModelScope` es el scope de corrutinas de un `ViewModel`. Se cancela automáticamente cuando el ViewModel se destruye.
  ]

  #v(0.5em)

  El patrón estándar: `viewModelScope.launch` en el ViewModel + `withContext(IO)` en el Repository.

  ```kotlin
  class LoginViewModel(
      private val repo: LoginRepository
  ) : ViewModel() {

      fun login(user: String, token: String) {
          viewModelScope.launch {  // Corrutina en Main
              val result = repo.makeLoginRequest(user, token)  // suspend
              _uiState.value = result
          }
      }
  }
  ```
]

#speaker-note[
  `_uiState` es una convención de Android: una propiedad privada mutable del ViewModel declarada típicamente como `private val _uiState = MutableStateFlow<Result>(Result.Loading)`. Se expone públicamente como solo lectura: `val uiState: StateFlow<Result> = _uiState`. La UI observa `uiState` y se actualiza cada vez que cambia. `MutableStateFlow` y `StateFlow` son parte de los Kotlin Flows, que no se explican en este curso.
]

== `viewModelScope`: Ejemplo — Repository

#[
  #set text(size: 0.92em)
  El *Repository* es una capa intermedia entre el ViewModel y las fuentes de datos (API, base de datos). Su responsabilidad es ser *main-safe*: usa `withContext(Dispatchers.IO)` internamente para que el ViewModel pueda llamarlo directamente desde `Dispatchers.Main`.

  ```
  UI → ViewModel → Repository → (API / Base de datos)
  ```

  ```kotlin
  class LoginRepository(private val api: LoginService) {

      // Función main-safe: puede llamarse desde Dispatchers.Main
      suspend fun makeLoginRequest(
          user: String,
          token: String
      ): Result<LoginResponse> {
          return withContext(Dispatchers.IO) {  // Cambia a hilo de I/O
              api.login(user, token)            // Petición de red
          }
          // Vuelve a Dispatchers.Main automáticamente
      }
  }
  ```
]

#speaker-note[
  #set text(size: 0.8em)
  El patrón Repository es parte de la arquitectura MVVM recomendada por Google. Las responsabilidades de cada capa son:

  - *UI* (Activity/Fragment): muestra el estado y envía eventos al ViewModel. No contiene lógica de negocio.
  - *ViewModel*: gestiona el estado de la UI y lanza corrutinas con `viewModelScope`. No accede directamente a la red ni a la base de datos — delega en el Repository.
  - *Repository*: abstrae las fuentes de datos (API REST, Room, caché...). Es la única capa que sabe de dónde vienen los datos. Usa `withContext(Dispatchers.IO)` internamente para ser "main-safe", de forma que el ViewModel puede llamar a sus funciones `suspend` directamente desde `Dispatchers.Main` sin preocuparse de los hilos.

  La ventaja de esta separación: el ViewModel no necesita saber si los datos vienen de la red, de una caché local, o de ambos — eso lo decide el Repository. Además, facilita los tests: se puede sustituir el Repository por un fake en los tests del ViewModel.
]


== `lifecycleScope`

#[
  #set text(size: 0.92em)
  #block(
    fill: rgb("#fff2df"),
    inset: 12pt,
    radius: 5pt,
    width: 100%,
  )[
    `lifecycleScope` es el scope de corrutinas de una Activity. Se cancela automáticamente cuando la Activity se destruye.
  ]

  #v(0.5em)

  ```kotlin
  class LoginActivity : AppCompatActivity() {
      private val viewModel: LoginViewModel by viewModels()

      override fun onCreate(savedInstanceState: Bundle?) {
          super.onCreate(savedInstanceState)
          lifecycleScope.launch {
              val result = viewModel.loadData()  // función suspend
              updateUI(result)
          }
      }
  }
  ```
]



== Resumen: Scopes y Cuándo Usar Cada Uno

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 8pt, y: 8pt),
  align: (left, left, left),
  table.header([*Scope*], [*Se cancela cuando...*], [*Caso de uso*]),
  [`viewModelScope`], [ViewModel se limpia], [Operaciones de datos, lógica de negocio.],
  [`lifecycleScope`], [Lifecycle se destruye], [Trabajo vinculado a Activity/Fragment.],
  [`repeatOnLifecycle`], [Lifecycle baja de estado], [Recolectar Flows en la UI (recomendado).],
  [`CoroutineScope` manual], [Se llama a `cancel()`], [Componentes custom con ciclo de vida propio.],
)

#block(
  fill: rgb("#fff2df"),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  #warning_symb *No usar `GlobalScope`*. Las corrutinas lanzadas en `GlobalScope` no se cancelan automáticamente, lo que puede provocar memory leaks y trabajo innecesario. Siempre vincular las corrutinas a un scope con ciclo de vida definido.
]


// ============================================================================
// BLOQUE 6: WORKMANAGER
// ============================================================================

= WorkManager

== ¿Qué es WorkManager?

#[
  #set text(size: 0.92em)
  *WorkManager* es la API recomendada por Google para ejecutar *trabajo en segundo plano diferible*: tareas que deben ejecutarse pero no necesariamente al instante.

  Problema con los servicios en segundo plano: desde Android 8 (API 26), el sistema *mata los background services* para ahorrar batería. Solo los *foreground services* (con notificación visible) pueden ejecutarse de forma prolongada.

  WorkManager *delega el trabajo en el sistema operativo*. Las tareas se registran en el planificador del sistema (`JobScheduler`), que se encarga de ejecutarlas. Aunque la app este cerrada o el dispositivo se reinicie el sistema sigue sabiendo que tiene trabajo pendiente.

  - *Persiste* las tareas: se ejecutan aunque la app muera o el dispositivo se reinicie.
  - El sistema *programa* la ejecución cuando se cumplen las condiciones (red, batería, carga...).
  - *Reintentos automáticos* si la tarea falla.
  - *No es inmediato*: el sistema decide cuándo ejecutar. Para trabajo inmediato, usar un foreground service.

  Casos de uso: sincronizar datos periódicamente, subir logs, procesar imágenes en segundo plano.
]

#speaker-note[
  #set text(size: 0.5em)
  Ejemplos de casos de uso donde la persistencia de tareas es clave: (1) Subir fotos a la nube — el usuario toma una foto y cierra la app; la subida debe completarse aunque tarde horas o haya un corte de red. (2) Sincronización offline — el usuario edita documentos sin conexión (Google Docs, Notion); cuando hay red, los cambios deben sincronizarse aunque hayan pasado días. (3) Enviar métricas/analytics — registrar eventos de uso y enviarlos al servidor en lote cuando haya WiFi, sin importar si la app está abierta. (4) Comprimir/procesar archivos — comprimir un video grabado antes de subirlo; puede tardar minutos y el usuario puede cerrar la app. (5) Descargas programadas — descargar el periódico o podcast a las 6am para que esté disponible offline. El patrón común: el usuario inicia una operación y no debería tener que mantener la app abierta para que se complete.

  Conexión con lo visto en Services: en la sección de Tipos de Services se mencionó que los Background Services tienen restricciones desde API 26 y que para trabajo diferible en segundo plano se recomienda WorkManager. Esta es esa API. WorkManager NO es un reemplazo de todos los Services: los Foreground Services siguen siendo necesarios para trabajo inmediato y perceptible (música, navegación GPS). WorkManager es para tareas que pueden diferirse, que deben sobrevivir a reinicios del dispositivo, y que el sistema puede programar respetando restricciones de batería y conectividad.

  Sobre "Doze mode": desde Android 6, cuando el dispositivo está inactivo y sin cargar, el sistema entra en modo de ahorro de energía donde restringe la red, pospone alarmas, y mata trabajo en segundo plano. WorkManager respeta estas restricciones y programa el trabajo para las "ventanas de mantenimiento" que el sistema abre periódicamente.

  Internamente WorkManager usa JobScheduler (API 23+) o AlarmManager + BroadcastReceiver como fallback en dispositivos antiguos. No necesita Google Play Services, a diferencia de alternativas anteriores como Firebase JobDispatcher.

  Sobre las condiciones de ejecución: al crear una tarea con WorkManager se pueden definir `Constraints` que deben cumplirse para que el sistema la ejecute. Ejemplo: `setRequiredNetworkType(NetworkType.CONNECTED)` (solo con red), `setRequiresCharging(true)` (solo cargando), `setRequiresBatteryNotLow(true)` (batería suficiente). WorkManager persiste la tarea en una base de datos interna (SQLite). Cuando el sistema detecta que se cumplen todas las restricciones y hay recursos disponibles, ejecuta la tarea. Si el dispositivo se reinicia, WorkManager recupera las tareas pendientes de la base de datos y las reprograma. Esto es lo que lo diferencia de un servicio: el servicio muere con el proceso, WorkManager sobrevive porque la petición de trabajo está persistida.
]


== Worker y CoroutineWorker

#[
  #set text(size: 0.95em)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align: top,
    [
      *`Clase Worker`*: ejecución síncrona

      ```kotlin
      class DownloadWorker(
          context: Context,
          params: WorkerParameters
      ) : Worker(context, params) {

          override fun doWork(): Result {
              // Se ejecuta en hilo de fondo
              downloadFile()
              return Result.success()
          }
      }
      ```

      - `doWork()` se ejecuta *síncronamente* en un hilo de fondo gestionado por WorkManager.
      - Devuelve `Result.success()`, `Result.failure()` o `Result.retry()`.
    ],
    [
      *`Clase CoroutineWorker`*: con corrutinas

      ```kotlin
      class DownloadWorker(
          context: Context,
          params: WorkerParameters
      ) : CoroutineWorker(context, params) {

          override suspend fun doWork(): Result {
              // Función suspend: usa corrutinas
              withContext(Dispatchers.IO) {
                  downloadFile()
              }
              return Result.success()
          }
      }
      ```

      - Expone una función `suspend` para usar corrutinas.
      - *Recomendado para proyectos Kotlin*.
    ],
  )
]

#speaker-note[
  "Síncronamente" en este contexto significa que `doWork()` se ejecuta de principio a fin en un hilo de fondo, de forma bloqueante. Si `doWork()` hace una operación de disco o red, sí, ese hilo se bloquea esperando — pero es un hilo de fondo gestionado por WorkManager (no el Main Thread), así que la UI no se ve afectada. `Worker` usa un `Executor` con un pool de hilos en background. `CoroutineWorker`, en cambio, expone una función `suspend` y usa `Dispatchers.Default` por defecto, permitiendo suspender sin bloquear el hilo, lo que es más eficiente para operaciones de I/O.
]

== Encolar Trabajo

#[
  #set text(size: 0.88em)
  Para ejecutar trabajo, se crea una *petición* con restricciones opcionales y se encola en WorkManager. El sistema ejecuta el Worker cuando las condiciones se cumplan:

  ```kotlin
  // 1. Definir restricciones (opcional)
  val constraints = Constraints.Builder()
      .setRequiredNetworkType(NetworkType.CONNECTED)
      .build()

  // 2. Crear la petición de trabajo (DownloadWorker es nuestra clase)
  val request = OneTimeWorkRequestBuilder<DownloadWorker>()
      .setConstraints(constraints)
      .build()

  // 3. Encolar — WorkManager gestiona el resto
  WorkManager.getInstance(context).enqueue(request)
  ```

  - `OneTimeWorkRequest`: se ejecuta *una sola vez*.
  - `PeriodicWorkRequest`: se repite periódicamente (mínimo cada 15 minutos).
  - Se puede encolar desde cualquier punto: ViewModel, Repository, Activity...
]

== Cancelación en Worker
#[
  #set text(size: 0.9em)
  Si `doWork()` hace trabajo prolongado (bucles, descargas por partes...), conviene comprobar `isStopped` para detectar cancelaciones y *salir limpiamente*. Si no se comprueba, `doWork()` sigue ejecutándose innecesariamente hasta terminar — consumiendo recursos para un trabajo que ya se descartó.

  #v(0.5em)

  ```kotlin
  override fun doWork(): Result {
      repeat(100) { i ->
          if (isStopped) return Result.success()  // Sale al cancelar

          try {
              downloadChunk(i)
          } catch (e: IOException) {
              return Result.failure()
          }
      }
      return Result.success()
  }
  ```

  Una vez detenido el Worker, el `Result` devuelto por `doWork()` se ignora.
]

// ============================================================================
// BLOQUE 7: RESUMEN GENERAL
// ============================================================================

= Resumen

== Resumen: Servicios y UI

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 10pt),
  fill: (x, y) => if y == 0 { luma(92%) } else { none },
  align: (left, left),
  table.header([*Concepto*], [*Descripción*]),
  [*Hilo principal*], [Único hilo de UI. No bloquear nunca. No acceder a la UI desde otro hilo.],
  [*Service*],
  [Componente de Android para trabajo en segundo plano sin UI. Corre en el hilo principal por defecto; necesita un hilo o corrutina para trabajo largo.],

  [*Foreground Service*],
  [Service con notificación visible obligatoria. El sistema no lo mata cuando la app pasa a segundo plano. Para trabajo prolongado perceptible (música, GPS...).],

  [*Background Service*],
  [Service sin notificación. Desde API 26 el sistema lo mata cuando la app pasa a segundo plano. Usar WorkManager en su lugar.],

  [*Toast / Notificación*], [Toast: feedback breve. Notificación: información persistente.],
)

== Resumen: Corrutinas

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 12pt),
  fill: (x, y) => if y == 0 { luma(92%) } else { none },
  align: (left, left),
  table.header([*Concepto*], [*Descripción*]),
  [*Corrutina*], [Computación que puede suspenderse y reanudarse. Concurrencia ligera en un mismo hilo.],
  [*`suspend`*],
  [Función que puede pausarse y reanudarse sin bloquear el hilo. Similar a `async def` en Python o `async function` en JS.],

  [*Dispatcher*], [`Main` (UI), `IO` (red/disco), `Default` (CPU). Controlan en qué hilo se ejecuta una corrutina.],
  [*`CoroutineScope`*], [Agrupa corrutinas y controla su ciclo de vida. `cancel()` cancela todas.],
  [*`Job`*], [Handle al ciclo de vida de una corrutina individual. Permite cancelar y esperar.],
)

== Resumen: Scopes y WorkManager

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 14pt),
  fill: (x, y) => if y == 0 { luma(92%) } else { none },
  align: (left, left),
  table.header([*Concepto*], [*Descripción*]),
  [*`viewModelScope`*], [Scope vinculado al ViewModel. Se cancela automáticamente al destruirse.],
  [*`lifecycleScope`*], [Scope vinculado a la Activity. Se cancela automáticamente al destruirse.],
  [*WorkManager*], [API para trabajo persistente en segundo plano. Sobrevive a reinicios.],
)


== ¿Cuándo Usar Qué?

#table(
  columns: (auto, 1fr),
  inset: (x: 10pt, y: 16pt),
  fill: (x, y) => if y == 0 { luma(92%) } else { none },
  align: (left, left),
  table.header([*Necesidad*], [*Solución recomendada*]),
  [Tarea rápida asíncrona\ (petición de red, lectura de BD)],
  [*Corrutinas* con `viewModelScope` + `withContext(Dispatchers.IO)`.],

  [Trabajo perceptible por el usuario\ (reproducir música, navegación GPS)], [*Foreground Service* con notificación.],

  [Trabajo persistente en segundo plano\ (sincronizar datos, subir archivos)],
  [*WorkManager* (con `CoroutineWorker` en Kotlin).],

  [Feedback breve al usuario], [*Toast*.],

  [Información importante para el usuario], [*Notificación* en la barra de estado.],
)


== Buenas Prácticas

+ *No bloquear el hilo de UI*: toda operación lenta (red, disco, cálculo) debe ejecutarse fuera del hilo principal.

+ *Usar corrutinas* (no Threads manuales): son más ligeras, se integran con el ciclo de vida, y son más fáciles de cancelar.

+ *Vincular corrutinas a un scope*: usar `viewModelScope` o `lifecycleScope`, nunca `GlobalScope`.

+ *Hacer funciones main-safe*: usar `withContext(Dispatchers.IO)` dentro de las funciones `suspend` para no bloquear el hilo principal (UI).

+ *Preferir WorkManager sobre Services para trabajo diferido y persistente*. Gestiona restricciones, reintentos y compatibilidad automáticamente. Para trabajo inmediato y perceptible, usar un Foreground Service.


// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

== Recursos y Documentación

*Procesos y threads:*
- Processes and threads overview: #link("https://developer.android.com/guide/components/processes-and-threads")

*Servicios:*
- Services overview: #link("https://developer.android.com/develop/background-work/services")
- Service class reference: #link("https://developer.android.com/reference/kotlin/android/app/Service")
- `<service>` manifest element: #link("https://developer.android.com/guide/topics/manifest/service-element")

*Notificaciones:*
- Notifications overview: #link("https://developer.android.com/develop/ui/views/notifications")
- Toasts overview: #link("https://developer.android.com/guide/topics/ui/notifiers/toasts")

---

#[
  #set text(size: 0.98em)
  *Corrutinas:*
  - Kotlin coroutines on Android: #link("https://developer.android.com/kotlin/coroutines")
  - Advanced coroutines concepts: #link("https://developer.android.com/kotlin/coroutines/coroutines-adv")
  - Lifecycle-aware coroutines: #link("https://developer.android.com/topic/libraries/architecture/coroutines")

  *WorkManager:*
  - Threading in WorkManager: #link("https://developer.android.com/develop/background-work/background-tasks/persistent/threading")

  *Codelabs:*
  - Introduction to Coroutines in Android Studio: https://developer.android.com/codelabs/basic-android-kotlin-compose-coroutines-android-studio
  - Background Work with WorkManager: https://developer.android.com/codelabs/basic-android-kotlin-compose-workmanager?hl=en
]
