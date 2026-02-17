// ============================================================================
// Ciclo de Vida de las Actividades Android
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Introducción a Android y Ciclo de Vida de Actividades],
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


#outline-slide(
  title: [Contenidos],
  outline-args: (depth: 1),
)


// ============================================================================
// BLOQUE 1: INTRODUCCIÓN A ANDROID
// ============================================================================

= Introducción a Android

== ¿Qué es una aplicación Android?

- Una app Android se distribuye como un archivo *APK* (_Android Package_): contiene todo lo necesario para instalar y ejecutar la app en un dispositivo.

- El SO Android es un *sistema Linux multi-usuario*: cada app es tratada como un usuario diferente, con su propio ID de usuario y permisos de ficheros.

- Cada app corre en su propio *proceso* con su propia instancia del *Android Runtime (ART)*, aislada del resto de apps (*sandbox* de seguridad).

- Principio de *mínimo privilegio*: cada app solo tiene acceso a los recursos y componentes que necesita.

---

== Programación Dirigida por Eventos

- A diferencia de una aplicación tradicional con un único `main()`, una app Android tiene *múltiples puntos de entrada*.

- El flujo de ejecución *no lo controla el programador*: lo gestiona el *sistema operativo Android*.

- Esto se conoce como *EDP* (Event-Driven Programming, Programación Dirigida por Eventos).

- El programador *sobreescribe métodos predefinidos* (_callbacks_) para responder a eventos del sistema o del usuario.

- El sistema llama a esos callbacks en momentos concretos: cuando la app se abre, cuando se minimiza, cuando se rota el dispositivo...

---

== Arquitectura de la Plataforma Android

#grid(
  columns: (1fr, 40%),
  column-gutter: 1em,
  [
    #set text(size: 0.95em)

    La plataforma se organiza en *5 capas*:

    + *Linux Kernel*: base del sistema. Gestión de memoria, threads, seguridad y drivers de hardware.
    + *HAL* (Hardware Abstraction Layer): interfaces estándar que exponen el hardware (cámara, Bluetooth, GPS...) al software.
    + *ART + Librerías nativas C/C++*: ejecuta el bytecode de las apps. Compilación AOT/JIT y garbage collection.
    + *Java API Framework*: las APIs de alto nivel para el desarrollador: Activity Manager, View System, Resource Manager...
    + *System Apps*: aplicaciones del sistema (correo, SMS, contactos...) y de terceros.
  ],
  image("images/android_stack.png", width: 100%, fit: "contain"),
)

= Componentes de Android

== Los 4 Componentes de una App Android

Las apps Android se construyen a partir de 4 tipos de *componentes*:

#v(0.5em)

#table(
  columns: (auto, 1fr),
  inset: 8pt,
  align: (left, left),
  table.header([*Componente*], [*Descripción*]),
  [`Activity`], [Pantalla con interfaz de usuario. *Punto de entrada* para la interacción del usuario.],
  [`Service`], [Componente sin UI para operaciones en *segundo plano* (música, sincronización...).],
  [`BroadcastReceiver`], [Escucha *eventos del sistema*: batería baja, pantalla apagada, foto tomada...],
  [`ContentProvider`], [Gestiona y comparte datos entre apps (contactos, fotos...) mediante una interfaz URI.],
)

---

== Comunicación entre Componentes: Intents

- Los componentes de Android se comunican mediante *Intents*: mensajes asíncronos que solicitan a un componente que realice una acción.

- Un Intent puede transportar *datos* (texto, URIs, extras...).

- Activities, Services y BroadcastReceivers se activan mediante Intents.

- Excepción: los *ContentProviders* no se activan con Intents, sino a través de un `ContentResolver`.

#v(1em)

Ejemplo: al pulsar "Compartir" en una app, se envía un Intent con la acción `ACTION_SEND` y el texto a compartir. Android busca las apps que declaren saber manejar esa acción y muestra el menú de selección.

---

== Activities: El Componente Principal

- Una *Activity* es el componente que representa una *única pantalla* con interfaz de usuario.

- En móvil, la interacción del usuario *no siempre empieza en el mismo sitio*. Ej: puedes abrir la app de email desde el launcher y ver la bandeja de entrada, o desde otra app y ir directamente a redactar un correo.

- Una app puede tener *múltiples Activities*, cada una correspondiente a una pantalla distinta. Ej: una app de email puede tener: bandeja de entrada, redactar correo, y leer correo.

- Cuando una app invoca a otra, *invoca una Activity concreta*, no la app como un todo. La Activity es el *punto de entrada* para la interacción con el usuario.

---

== El `AndroidManifest.xml`

- Cada app tiene un fichero *`AndroidManifest.xml`* en la raíz del proyecto Android.

- El sistema *no puede ejecutar* ningún componente que no esté declarado en el manifest.

- El manifest también especifica:
  - *Permisos* necesarios (internet, cámara, contactos...).
  - *Versión mínima* de Android compatible.
  - *Hardware* requerido (cámara, GPS...).

---

== Declarar una Activity en el Manifest

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest>
    <application android:icon="@drawable/app_icon" ...>
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

- `MAIN` / `LAUNCHER`: indica la *Activity de inicio* (se abre al pulsar el icono de la app).
- `exported="true"`: permite que otras apps puedan iniciar esta Activity.

// ============================================================================
// BLOQUE 2: CICLO DE VIDA DE ACTIVITIES
// ============================================================================

= Ciclo de Vida de Activities

== ¿Qué es el Ciclo de Vida?

- En Android, una *Activity* es el componente que proporciona la pantalla con la que el usuario interactúa.

- A lo largo de su existencia, una Activity pasa por diferentes *estados*: se crea, se muestra, se oculta, se destruye...

- El *ciclo de vida* (_lifecycle_) es el conjunto de estados por los que transita una Activity desde su creación hasta su destrucción.

- Comprender el ciclo de vida es fundamental para:
  - Evitar *bugs* y comportamientos inesperados.
  - Gestionar *recursos* correctamente (cámara, sensores, red...).
  - Preservar el *estado* de la aplicación ante cambios de configuración.

---

== Analogía: Ciclo de Vida Natural

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    - Similar a un ciclo de vida biológico, una Activity pasa por etapas.

    - *Diferencia clave:* a diferencia de un ciclo biológico, una Activity puede *ir hacia atrás y hacia adelante* entre estados.

    - Ejemplo: una Activity puede pasar de _visible_ a _en segundo plano_ y volver a ser _visible_ múltiples veces.
  ],
  image("images/butterfly_lifecycle.png", width: 100%, fit: "contain"),
)


// ============================================================================
// SECCIÓN 2: ESTADOS Y CALLBACKS
// ============================================================================

= Estados y Callbacks del Ciclo de Vida

== Diagrama del Ciclo de Vida

#grid(
  columns: (1fr, 40%),
  column-gutter: 1em,
  [
    La Activity tiene *7 callbacks* principales:

    + `onCreate()` --- Creación
    + `onStart()` --- Visible
    + `onResume()` --- En primer plano
    + `onPause()` --- Pierde el foco
    + `onStop()` --- No visible
    + `onRestart()` --- Reinicio
    + `onDestroy()` --- Destrucción

    Cada callback corresponde a una transición de estado.
  ],
  image("images/activity_lifecycle_official.png", width: 100%, fit: "contain"),
)

---

== Estados del Ciclo de Vida (`Lifecycle.State`)

#grid(
  columns: (1fr, 35%),
  column-gutter: 1em,
  [
    El enum `Lifecycle.State` define los siguientes estados:

    - *Initialized:* el objeto Activity se ha creado en memoria, pero `onCreate()` aún no se ha ejecutado.
    - *Created:* la Activity se considera creada (`onCreate()` ejecutado).
    - *Started:* la Activity es visible en pantalla.
    - *Resumed:* la Activity tiene el foco y el usuario puede interactuar.
    - *Destroyed:* la Activity se ha eliminado de memoria.
  ],
  image("images/activity_lifecycle_states.png", width: 100%, fit: "contain"),
)

---

== Estados Paused y Stopped

#grid(
  columns: (1fr, 35%),
  column-gutter: 1em,
  [
    #set text(size: 0.85em)
    - La documentación clásica de Android también describe los estados *Paused* y *Stopped*:
      - *Paused:* la Activity pierde el foco pero puede seguir parcialmente visible (ej: diálogo encima).
      - *Stopped:* la Activity ya no es visible, pero el objeto sigue en memoria.

    - Sin embargo, el enum `Lifecycle.State` *no tiene valores* para estos estados. En su lugar, los mapea a estados existentes:

    #align(center)[
      #table(
        columns: (auto, auto, auto),
        inset: 8pt,
        align: (left, left, left),
        table.header([*Estado conceptual*], [*`Lifecycle.State`*], [*Callback*]),
        [Paused], [`STARTED`], [`onPause()`],
        [Stopped], [`CREATED`], [`onStop()`],
      )
    ]

    - Es decir: cuando `onPause()` se ejecuta, el `Lifecycle.State` vuelve a `STARTED`. Cuando `onStop()` se ejecuta, vuelve a `CREATED`.
  ],
  image("images/activity_lifecycle_states.png", width: 100%, fit: "contain"),
)

== `onCreate()`

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    - Se ejecuta *una sola vez* al crear la Activity.
    - Equivalente al _punto de entrada_ de la aplicación (como `main()` en otros lenguajes).
    - Es donde se debe:
      - Llamar a `setContent { }` para establecer la UI.
      - Inicializar variables de clase.
      - Realizar la configuración inicial.
    - Recibe un `Bundle?` con el estado guardado previamente (o `null` si es la primera vez).
    - *Siempre* debe llamar a `super.onCreate()`.
  ],
  image("images/oncreate_lifecycle.png", width: 100%, fit: "contain"),
)

---

== `onCreate()` --- Código

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)  // Siempre llamar a super

        // Establecer la interfaz de usuario con Compose
        setContent {
            DessertClickerTheme {
                DessertClickerApp()
            }
        }
    }
}
```

- `savedInstanceState` contiene el estado previamente guardado (lo veremos más adelante).
- `setContent { }` define la UI usando Jetpack Compose.

== `onStart()`

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    - Se ejecuta después de `onCreate()` (o de `onRestart()`).
    - La Activity se hace *visible* en pantalla.
    - Puede ejecutarse *múltiples veces* durante la vida de la Activity.
    - Es el lugar para:
      - Inicializar código de mantenimiento de la UI.
      - Registrar listeners que actualizan la UI.
    - Se empareja con `onStop()`.
  ],
  image("images/onstart_lifecycle.png", width: 100%, fit: "contain"),
)

== `onResume()`

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    - Se ejecuta cuando la Activity obtiene el *foco* y el usuario puede interactuar.

    - La Activity está ahora en el estado *Resumed* (en primer plano).

    - A pesar de su nombre, se llama *siempre* al iniciar la Activity, no solo al continuar.

    - Es el lugar adecuado para:
      - Iniciar la *cámara*.
      - Iniciar *animaciones*.
      - Adquirir recursos exclusivos (GPS, micrófono...).

    - Se empareja con `onPause()`.
  ],
  image("images/onresume_lifecycle.png", width: 100%, fit: "contain"),
)


---

== `onPause()`


#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    #set text(size: 0.90em)
    - Se ejecuta cuando la Activity *pierde el foco* pero puede seguir parcialmente visible.

    - Ejemplos de situaciones que provocan `onPause()`:
      - Aparece un *diálogo* por encima (ej: compartir).
      - En modo *multi-ventana*, otra app tiene el foco.
      - Una nueva Activity transparente se abre encima.

    - #warning_symb El código en `onPause()` debe ser *ligero*: un código pesado puede retrasar la visualización de la siguiente Activity o la notificación del sistema (ej: llamada entrante).

    - Se empareja con `onResume()`.
  ],
  image("images/onpause_lifecycle.png", width: 100%, fit: "contain"),
)

== `onStop()`

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    - Se ejecuta cuando la Activity *ya no es visible* en pantalla.

    - La Activity pasa al estado *Stopped* (`Lifecycle.State` = `CREATED`), pero el objeto sigue en memoria.

    - Es el lugar adecuado para:
      - Liberar recursos que no se necesitan cuando la Activity no es visible.
      - Realizar operaciones de CPU intensivas de cierre.
      - *Guardar datos* (ej: guardar un borrador en base de datos).

    - Se empareja con `onStart()`.
  ],
  image("images/onstop_lifecycle.png", width: 100%, fit: "contain"),
)

---

== `onRestart()`

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    - Se ejecuta *solo* si la Activity fue detenida con `onStop()` y se va a reiniciar.

    - Flujo: `onStop()` #sym.arrow `onRestart()` #sym.arrow `onStart()` #sym.arrow `onResume()`

    - Útil para código que solo se necesita ejecutar cuando la Activity *no* se inicia por primera vez.

    - No se utiliza con frecuencia en la práctica.
  ],
  image("images/onstart_lifecycle.png", width: 100%, fit: "contain"),
)

== `onDestroy()`

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    - Se ejecuta *justo antes* de que la Activity sea destruida.

    - Se llama cuando:
      - El usuario pulsa el botón *Atrás* (o desliza).
      - Se llama a `finish()` desde el código.
      - El sistema destruye la Activity por un *cambio de configuración* (ej: rotación).
      - El sistema destruye la Activity por *falta de recursos*.

    - Es el lugar para liberar todos los recursos restantes.

    - *No debe usarse* para guardar datos: en ese punto puede ser demasiado tarde.
  ],
  image("images/ondestroy_lifecycle.png", width: 100%, fit: "contain"),
)

// ============================================================================
// SECCIÓN 3: SECUENCIA COMPLETA DE CALLBACKS
// ============================================================================

= Secuencia de Callbacks

== Visión Completa de los Callbacks

#grid(
  columns: (1fr, 40%),
  column-gutter: 1em,
  [
    *Callbacks emparejados:*

    - `onCreate()` #sym.arrow.l.r `onDestroy()`
      - Se ejecutan una sola vez.

    - `onStart()` #sym.arrow.l.r `onStop()`
      - Pueden ejecutarse múltiples veces.

    - `onResume()` #sym.arrow.l.r `onPause()`
      - Pueden ejecutarse múltiples veces.

    *Nota:* `onRestart()` solo se llama después de `onStop()`, si la Activity no fue destruida.
  ],
  image("images/lifecycle_callbacks.png", width: 100%, fit: "contain"),
)

---

== Implementación de los Callbacks

#[
  #set text(size: 0.82em)
  ```kotlin
  private const val TAG = "MainActivity"

  class MainActivity : ComponentActivity() {
      override fun onCreate(savedInstanceState: Bundle?) {
          super.onCreate(savedInstanceState)
          Log.d(TAG, "onCreate Called")
          setContent { DessertClickerApp() }
      }

      override fun onStart() {
          super.onStart()
          Log.d(TAG, "onStart Called")
      }

      override fun onResume() {
          super.onResume()
          Log.d(TAG, "onResume Called")
      }

      override fun onPause() {
          super.onPause()
          Log.d(TAG, "onPause Called")
      }

      override fun onStop() {
          super.onStop()
          Log.d(TAG, "onStop Called")
      }

      override fun onRestart() {
          super.onRestart()
          Log.d(TAG, "onRestart Called")
      }

      override fun onDestroy() {
          super.onDestroy()
          Log.d(TAG, "onDestroy Called")
      }
  }
  ```
]


// ============================================================================
// SECCIÓN 4: LOGGING CON LOGCAT
// ============================================================================

= Logging con Logcat

== La Clase `Log`

- Android proporciona la clase `Log` para escribir mensajes de depuración.

- Cada mensaje tiene: *prioridad*, *tag* y *mensaje*.

#v(0.5em)

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Método*], [*Prioridad*], [*Uso*]),
    [`Log.v(tag, msg)`], [Verbose], [Mensajes muy detallados],
    [`Log.d(tag, msg)`], [Debug], [Mensajes de depuración],
    [`Log.i(tag, msg)`], [Info], [Mensajes informativos],
    [`Log.w(tag, msg)`], [Warning], [Advertencias],
    [`Log.e(tag, msg)`], [Error], [Errores],
  )
]

#v(0.5em)

- El *tag* es una cadena que identifica el origen del mensaje (típicamente, el nombre de la clase).

---

== Logcat en Android Studio

- *Logcat* es la consola de Android Studio donde aparecen los mensajes de log.

- Se encuentra en la parte inferior del IDE.

- Permite *filtrar* y *buscar* mensajes:
  - Filtrar por tag: `tag:MainActivity`
  - Filtrar por paquete de la app.
  - Filtrar por nivel de prioridad.

- Ejemplo de salida en Logcat:

#[
  #set text(size: 0.85em)
  ```
  2025-02-10 14:56:48.684  5484-5484  MainActivity  com.example.app  D  onCreate Called
  2025-02-10 14:56:48.710  5484-5484  MainActivity  com.example.app  D  onStart Called
  2025-02-10 14:56:48.713  5484-5484  MainActivity  com.example.app  D  onResume Called
  ```
]

== Buenas Prácticas de Logging

- Definir el *tag* como una constante a nivel de fichero:

```kotlin
private const val TAG = "MainActivity"
```

- Usar `Log.d()` para mensajes de depuración durante el desarrollo.

- Usar `Log.e()` para errores que necesitan atención.

- *No dejar logs de depuración en producción*: pueden afectar al rendimiento y exponer información sensible.

- Añadir mensajes de log en los callbacks del ciclo de vida es una técnica fundamental para entender el comportamiento de la app.


// ============================================================================
// SECCIÓN 5: ESCENARIOS DEL CICLO DE VIDA
// ============================================================================

= Escenarios del Ciclo de Vida

== Escenario 1: Abrir y Cerrar la App

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    *Al abrir la app:*
    + `onCreate()` --- se crea la Activity
    + `onStart()` --- se hace visible
    + `onResume()` --- obtiene el foco

    *Al pulsar el botón Atrás:*
    + `onPause()` --- pierde el foco
    + `onStop()` --- deja de ser visible
    + `onDestroy()` --- se destruye

    La Activity se destruye completamente y se libera de la memoria.
  ],
  image("images/lifecycle_callbacks.png", width: 100%, fit: "contain"),
)

---

== Escenario 1: Log

```
// Al abrir la app:
onCreate Called
onStart Called
onResume Called

// Al pulsar Atrás:
onPause Called
onStop Called
onDestroy Called
```

- La Activity se crea con `onCreate()` y se destruye con `onDestroy()`.
- Este par de callbacks solo se ejecuta *una vez* por instancia de la Activity (salvo cambios de configuración).

== Escenario 2: Ir a Home y Volver

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    *Al pulsar Home:*
    + `onPause()` --- pierde el foco
    + `onStop()` --- deja de ser visible
    - La Activity *no se destruye*: el objeto sigue en memoria.

    *Al volver (desde Recientes):*
    + `onRestart()` --- se reinicia
    + `onStart()` --- se hace visible de nuevo
    + `onResume()` --- obtiene el foco

    Los valores de la Activity se *mantienen* (no se pierde el estado).
  ],
  image("images/onstop_lifecycle.png", width: 100%, fit: "contain"),
)

---

== Escenario 2: Log

```
// Al abrir la app:
onCreate Called
onStart Called
onResume Called

// Al pulsar Home:
onPause Called
onStop Called

// Al volver desde Recientes:
onRestart Called
onStart Called
onResume Called
```

- `onCreate()` *no se vuelve a llamar*: la Activity no se destruyó, solo se detuvo.
- `onRestart()` se llama porque la Activity viene de `onStop()`.

== Escenario 3: Activity Parcialmente Oculta

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    *Al abrir un diálogo de compartir:*
    - Solo se llama a `onPause()`.
    - `onStop()` *no* se llama: la Activity sigue parcialmente visible.
    - La Activity pierde el *foco* pero mantiene la *visibilidad*.

    *Diferencia clave:*
    - *Visible* = la Activity está en pantalla (`onStart()`)
    - *Foco* = el usuario puede interactuar (`onResume()`)

    La Activity puede ser visible pero no tener el foco.
  ],
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.5em,
    [
      #image("images/application.png", width: 100%, fit: "contain")
      #place(
        top + left,
        dx: 133pt,
        dy: 26pt,
        square(
          size: 20pt,
          stroke: 3pt + red.darken(20%),
          radius: 3pt
        ),
      )
    ],
    image("images/application_share_dialog.png", width: 100%, fit: "contain"),
  ),
)

---

== Escenario 3: Log

```
// Se pulsa Compartir:
onPause Called

// Se cierra el diálogo:
onResume Called
```

- Solo se llama `onPause()` / `onResume()`.
- La Activity *nunca* pasa a _Stopped_.
- #warning_symb Por esto, el código en `onPause()` debe ser ligero: un código pesado retrasa la transición.

== Visibilidad vs Foco

#v(0.5em)

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Concepto*], [*Definición*], [*Callback*]),
    [*Visible*], [La Activity está en pantalla], [`onStart()` / `onStop()`],
    [*Foco*], [El usuario puede interactuar], [`onResume()` / `onPause()`],
  )
]

#v(1em)

- Una Activity puede estar *visible sin tener foco* (ej: diálogo encima, modo multi-ventana).
- Una Activity con foco siempre es visible, pero una Activity visible no siempre tiene foco.
- Esto explica por qué `onPause()` y `onStop()` son callbacks separados.


// ============================================================================
// SECCIÓN 6: CAMBIOS DE CONFIGURACIÓN
// ============================================================================

= Cambios de Configuración

== ¿Qué es un Cambio de Configuración?

- Un *cambio de configuración* ocurre cuando el estado del dispositivo cambia de forma tan radical que el sistema considera más fácil *destruir y recrear* la Activity.

- Ejemplos de cambios de configuración:
  - *Rotación del dispositivo* (portrait #sym.arrow.l.r landscape).
  - Cambio de *idioma* del dispositivo.
  - Conexión de un *teclado externo*.
  - Cambio de *tamaño de ventana* (modo multi-ventana).

- #warning_symb Al ocurrir un cambio de configuración, la Activity se destruye y se crea *una nueva instancia*.

---

== Rotación del Dispositivo

#grid(
  columns: (1fr, 35%),
  column-gutter: 1em,
  [
    Al rotar el dispositivo:

    *Se destruye la Activity original:*
    + `onPause()`
    + `onStop()`
    + `onDestroy()`

    *Se crea una nueva Activity:*
    + `onCreate()` #sym.arrow se llama a `onCreate()`, *no* a `onRestart()`
    + `onStart()`
    + `onResume()`

    Consecuencia: *todo el estado se pierde* si no se ha guardado correctamente.
  ],
  image("images/device_rotation.png", width: 100%, fit: "contain"),
)

---

== Rotación del Dispositivo: Log

```
// App en funcionamiento:
onCreate Called
onStart Called
onResume Called

// Se rota el dispositivo:
onPause Called
onStop Called
onDestroy Called
onCreate Called    // Nueva instancia, no onRestart
onStart Called
onResume Called
```

- La Activity se destruye por completo y se crea una nueva.
- Todas las variables se reinicializan a sus valores por defecto.
- Ejemplo: los contadores de la app "Dessert Clicker" se resetean a 0.


// ============================================================================
// SECCIÓN 7: PRESERVAR EL ESTADO
// ============================================================================

= Preservar el Estado

== El Problema de la Pérdida de Estado

- Cuando la Activity se destruye y recrea (ej: rotación), *todo el estado se pierde*:
  - Variables locales se reinicializan.
  - Contadores vuelven a 0.
  - Datos del usuario desaparecen.

- Ejemplo con la app "Dessert Clicker":
  - El usuario ha comprado 5 postres (total: \$50).
  - Al rotar el dispositivo, el contador vuelve a 0 y el total a \$0.

- Este es un *bug común* en aplicaciones Android que no gestionan correctamente el estado.

---

== Estado en Compose: Recomposición

- En Jetpack Compose, la *composición* es el proceso de ejecutar funciones `@Composable` para construir la UI.

- La *recomposición* es la re-ejecución de estas funciones cuando el estado cambia.

- El estado se puede declarar de varias formas, con distintos niveles de persistencia:

#v(0.5em)

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Declaración*], [*Recomposición*], [*Cambio de config.*]),
    [`var x = 0`], [Se pierde], [Se pierde],
    [`mutableStateOf(0)`], [Se pierde], [Se pierde],
    [`remember { mutableStateOf(0) }`], [*Se mantiene*], [Se pierde],
    [`rememberSaveable { mutableStateOf(0) }`], [*Se mantiene*], [*Se mantiene*],
  )
]

== `remember` vs `rememberSaveable`

- `remember` guarda el valor durante las *recomposiciones*, pero lo pierde ante un cambio de configuración:

```kotlin
var revenue by remember { mutableStateOf(0) }
// Se mantiene durante recomposiciones
// Se PIERDE al rotar el dispositivo
```

- `rememberSaveable` guarda el valor durante recomposiciones *y* cambios de configuración:

```kotlin
var revenue by rememberSaveable { mutableStateOf(0) }
// Se mantiene durante recomposiciones
// Se MANTIENE al rotar el dispositivo
```

- #warning_symb Se recomienda usar `rememberSaveable` para todo estado importante del usuario.

---

== Ejemplo: Corrigiendo Dessert Clicker

*Antes (estado se pierde al rotar):*

```kotlin
var revenue by remember { mutableStateOf(0) }
var dessertsSold by remember { mutableStateOf(0) }
var currentDessertIndex by remember { mutableStateOf(0) }
```

*Después (estado se mantiene al rotar):*

```kotlin
var revenue by rememberSaveable { mutableStateOf(0) }
var dessertsSold by rememberSaveable { mutableStateOf(0) }
var currentDessertIndex by rememberSaveable { mutableStateOf(0) }
```

- Solo cambia `remember` por `rememberSaveable`.
- El sistema se encarga de guardar y restaurar los valores automáticamente.

== Muerte del Proceso

- El sistema Android puede *matar el proceso* de una app en segundo plano si necesita liberar recursos.

- Cuando esto ocurre:
  - *No se ejecuta ningún callback* adicional.
  - El proceso se cierra silenciosamente.
  - Cuando el usuario vuelve a la app, Android la *reinicia desde cero*.

- `rememberSaveable` asegura que los datos estén disponibles incluso cuando la Activity se restaura después de la muerte del proceso.

- Para datos más complejos o persistentes, se deben usar otros mecanismos:
  - *ViewModel*: preserva datos durante cambios de configuración (no sobrevive a la muerte del proceso).
  - *Base de datos local*: para datos que deben persistir de forma permanente.
  - *DataStore/SharedPreferences*: para preferencias y configuración.


// ============================================================================
// SECCIÓN 8: MEJORES PRÁCTICAS
// ============================================================================

= Mejores Prácticas

== Resumen de Callbacks y su Uso

#v(0.3em)

#[
  #set text(size: 0.85em)
  #align(center)[
    #table(
      columns: (auto, auto, auto),
      inset: 6pt,
      align: (left, left, left),
      table.header([*Callback*], [*Qué hacer*], [*Qué NO hacer*]),
      [`onCreate()`], [Inicializar UI, variables], [Operaciones pesadas],
      [`onStart()`], [Registrar listeners de UI], [---],
      [`onResume()`], [Iniciar cámara, animaciones], [Inicializaciones largas],
      [`onPause()`], [Pausar animaciones, liberar sensores], [Guardar datos pesados],
      [`onStop()`], [Guardar datos, liberar recursos], [Acceder a la UI],
      [`onDestroy()`], [Liberar recursos finales], [Guardar datos],
    )
  ]
]

#v(0.5em)

- *Siempre* llamar a `super.callback()` al sobreescribir un callback.
- Usar `onStop()` (no `onPause()`) para guardar datos: mejor para modo multi-ventana.

---

== Escenarios Resumidos

#v(0.5em)

#[
  #set text(size: 0.85em)
  #align(center)[
    #table(
      columns: (auto, auto),
      inset: 6pt,
      align: (left, left),
      table.header([*Escenario*], [*Callbacks ejecutados*]),
      [Abrir la app], [`onCreate` #sym.arrow `onStart` #sym.arrow `onResume`],
      [Pulsar Atrás], [`onPause` #sym.arrow `onStop` #sym.arrow `onDestroy`],
      [Pulsar Home], [`onPause` #sym.arrow `onStop`],
      [Volver desde Recientes], [`onRestart` #sym.arrow `onStart` #sym.arrow `onResume`],
      [Diálogo encima], [`onPause`],
      [Cerrar diálogo], [`onResume`],
      [Rotar dispositivo],
      [`onPause` #sym.arrow `onStop` #sym.arrow `onDestroy` #sym.arrow `onCreate` #sym.arrow `onStart` #sym.arrow `onResume`],
    )
  ]
]

== Preservación de Estado: Resumen

#v(0.5em)

#align(center)[
  #let crossmark = text(fill: red.darken(25%))[#sym.crossmark.heavy]
  #let checkmark = text(fill: green.darken(25%))[#sym.checkmark]

  #table(
    columns: (auto, auto, auto, auto),
    inset: 8pt,
    align: (left, center, center, center),
    table.header([*Mecanismo*], [*Recomposición*], [*Cambio config.*], [*Muerte proceso*]),
    [Variable local], [#crossmark], [#crossmark], [#crossmark],
    [`remember`], [#checkmark], [#crossmark], [#crossmark],
    [`rememberSaveable`], [#checkmark], [#checkmark], [#checkmark],
    [`ViewModel`], [#checkmark], [#checkmark], [#crossmark],
    [Base de datos], [#checkmark], [#checkmark], [#checkmark],
  )
]

#v(0.5em)

- Usar `rememberSaveable` para estado de UI simple (contadores, selecciones...).
- Usar `ViewModel` para estado de UI más complejo.
- Usar base de datos o DataStore para datos persistentes.


// ============================================================================
// SECCIÓN 9: ACTIVIDAD A → ACTIVIDAD B
// ============================================================================

= Transiciones entre Activities

== Iniciar otra Activity

#[
  #set text(size: 0.95em)

  - Cuando la Activity A inicia la Activity B, la secuencia de callbacks es:

    + `onPause()` de la Activity A
    + `onCreate()` de la Activity B
    + `onStart()` de la Activity B
    + `onResume()` de la Activity B #sym.arrow B tiene el foco
    + `onStop()` de la Activity A (si A ya no es visible)

  - La Activity A *no se detiene hasta que B esté completamente iniciada*.

  - Si el usuario vuelve a A (pulsando Atrás):
    + `onPause()` de B
    + `onRestart()` de A
    + `onStart()` de A
    + `onResume()` de A
    + `onStop()` de B
    + `onDestroy()` de B
]

// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

== `onSaveInstanceState()` (Enfoque Tradicional)

- Antes de Compose, el mecanismo principal para guardar estado era `onSaveInstanceState()`:

```kotlin
override fun onSaveInstanceState(outState: Bundle) {
    super.onSaveInstanceState(outState)
    outState.putInt("SCORE", currentScore)
    outState.putInt("LEVEL", currentLevel)
}

override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if (savedInstanceState != null) {
        currentScore = savedInstanceState.getInt("SCORE")
        currentLevel = savedInstanceState.getInt("LEVEL")
    }
}
```

- En Compose, `rememberSaveable` es la alternativa recomendada.

---

== Prioridad de Procesos

El sistema Android decide qué procesos matar según la prioridad:

#v(0.5em)

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Probabilidad de ser eliminado*], [*Estado del proceso*], [*Estado de la Activity*]),
    [Más baja], [Primer plano (con foco)], [Resumed],
    [Baja], [Visible (sin foco)], [Started / Paused],
    [Alta], [En segundo plano], [Stopped],
    [Más alta], [Vacío], [Destroyed],
  )
]

#v(0.5em)

- Las apps en primer plano casi nunca son eliminadas.
- Las apps en segundo plano pueden ser eliminadas en cualquier momento.

---

== Recursos y Documentación

*Introducción a Android:*
- Application fundamentals: #link("https://developer.android.com/guide/components/fundamentals")
- Platform architecture: #link("https://developer.android.com/guide/platform")
- Introduction to activities: #link("https://developer.android.com/guide/components/activities/intro-activities")

*Ciclo de vida — Codelab:*
- Stages of the Activity lifecycle: #link("https://developer.android.com/codelabs/basic-android-kotlin-compose-activity-lifecycle")

---

*Ciclo de vida — Documentación:*
- Activity lifecycle: #link("https://developer.android.com/guide/components/activities/activity-lifecycle")
- Saving UI states: #link("https://developer.android.com/topic/libraries/architecture/saving-states")
- Handle configuration changes: #link("https://developer.android.com/guide/topics/resources/runtime-changes")

*Jetpack Compose:*
- State in Compose: #link("https://developer.android.com/develop/ui/compose/state")
- Lifecycle-aware components: #link("https://developer.android.com/topic/libraries/architecture/lifecycle")
