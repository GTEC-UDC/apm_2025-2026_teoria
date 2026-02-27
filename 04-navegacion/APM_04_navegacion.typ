// ============================================================================
// Navegación
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Navegación],
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
  inset: 8pt,
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
// BLOQUE 1: FRAGMENTS (CONTEXTO HISTÓRICO)
// ============================================================================

= Fragments: Contexto Histórico

== El Problema: Activities y Pantallas Grandes

- En los primeros años de Android, cada pantalla correspondía a una *Activity*.

- En 2011, Google lanzó *Android 3.0 Honeycomb* (API 11), la primera versión diseñada para *tablets*.

- Las pantallas grandes plantearon un problema: las Activities eran *demasiado grandes* como unidad de UI.
  - En un teléfono: una Activity muestra una lista de emails, otra Activity muestra el detalle.
  - En una tablet: *ambas vistas* deberían aparecer en la misma pantalla (_master-detail_).

- Se necesitaba un componente más *modular* que la Activity.


== La Solución: Fragments

- Google introdujo los *Fragments*: componentes modulares de UI que son alojados *dentro* de una Activity u otros Fragments.

- Un Fragment es una *porción reutilizable* de la interfaz de usuario de una aplicación.

- Características de un Fragments:
  - Define y gestiona su *propio layout*.
  - Tiene su *propio ciclo de vida*.
  - Puede manejar sus *propios eventos* de entrada.
  - *No puede existir de forma independiente*: debe estar alojado en una Activity (o en otro Fragment).


== Fragments y Diseño Responsivo

Los Fragments permiten adaptar la UI según el tamaño de pantalla.

#grid(
  columns: (1fr, 50%),
  column-gutter: 2em,
  [
    #set text(size: 0.9em)
    - *Pantalla grande (tablet)*: la Activity aloja la navegación lateral y el Fragment muestra un grid de contenido.

    - *Pantalla pequeña (teléfono)*: la Activity proporciona una barra de navegación inferior y el Fragment muestra una lista lineal.
  ],
  image("images/fragment-screen-sizes.png", width: 100%),
)

#[
  // #set text(size: 0.9em)
  Posibilidades:
  + *Layout adaptable*: el mismo Fragment carga un layout distinto según configuración.
  + *Contexto distinto*: Fragments distintos, reutilizables en distintas Activities.
]


== El Ciclo de Vida de los Fragments

#grid(
  columns: (1fr, 40%),
  column-gutter: 1em,
  [
    #set text(size: 0.9em)
    Los Fragments tienen un ciclo de vida *más complejo* que las Activities:

    - *12 callbacks* (vs. 7 en Activities).
    - *Dos ciclos de vida separados*: uno para el Fragment y otro para su vista.
    - El Fragment no puede avanzar más allá del estado de su Activity anfitriona.

    Callbacks principales:

    `onCreate` #sym.arrow `onCreateView` #sym.arrow `onViewCreated` #sym.arrow `onStart` #sym.arrow `onResume` #sym.arrow `onPause` #sym.arrow `onStop` #sym.arrow `onDestroyView` #sym.arrow `onDestroy`
  ],
  image("images/fragment-view-lifecycle.png", height: 100%),
)


== Problemas de los Fragments

Con el tiempo, los Fragments acumularon una reputación de *complejidad*:

+ *Ciclo de vida complejo*: 12+ callbacks, dos ciclos de vida separados (Fragment + View). Principal fuente de bugs en Android.

+ *Transacciones frágiles*: `FragmentTransaction` debía ejecutarse en el momento correcto, lo que producía el infame `IllegalStateException`.

+ *Acoplamiento con el sistema de vistas*: los Fragments estaban ligados a layouts XML, `findViewById`, y View Binding.

+ *Back stack complejo*: gestionar fragments anidados y múltiples back stacks era propenso a errores.

+ *Difíciles de testear*: requerían una Activity anfitriona para ejecutar tests.


== De Fragments a Jetpack Compose

- En 2021, Google lanzó *Jetpack Compose* (estable), un toolkit de UI declarativo.

- Compose *reemplaza* tanto el sistema de vistas XML como los Fragments:
  - Sin callbacks de ciclo de vida: la recomposición gestiona los cambios automáticamente.
  - Sin layouts XML: la UI se define completamente en Kotlin.
  - Sin `FragmentManager`: la navegación se gestiona con *Navigation Compose*.

- Lo que antes era un Fragment ahora es simplemente una *función `@Composable`*.

#block(
  fill: luma(95%),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  *¿Dónde siguen siendo relevantes los Fragments?* En código legacy, librerías como ViewPager2, PreferenceFragmentCompat, y en proyectos que migran gradualmente a Compose.
]


// ============================================================================
// BLOQUE 2: PRINCIPIOS DE NAVEGACIÓN
// ============================================================================

= Principios de Navegación en Android

== ¿Qué es la Navegación?

- La *navegación* es el mecanismo que permite a los usuarios moverse entre las distintas pantallas de una aplicación.

- La documentación de Android define unos *principios de navegación* que toda app debería cumplir, para garantizar una experiencia de usuario consistente e intuitiva.

- El *Navigation component* es una librería de Jetpack diseñada para implementar estos principios de forma estándar y automática.

- En esta asignatura nos centraremos en *Navigation con Compose*.


== Principio 1: Destino de Inicio Fijo

#grid(
  columns: (1fr, 55%),
  column-gutter: 1.5em,
  align: horizon,
  [
    #set text(size: 0.9em)
    - Toda app tiene un *destino de inicio* (_start destination_) fijo: la primera pantalla al abrir la app desde el launcher.

    - Es también la *última pantalla* que el usuario ve antes de volver al launcher (al pulsar Atrás).

    - El destino de inicio debe ser *consistente* y predecible.

    - Las pantallas de login o configuración inicial *no* son destinos de inicio: son pantallas condicionales.
  ],
  image("images/navigation-start-destination.png", width: 100%),
)


== Principio 2: La Pila de Navegación (_Back Stack_)

El estado de navegación se representa como una *pila* (_stack_):

- *Base*: el destino de inicio (siempre al fondo).
- *Cima*: la pantalla que se está mostrando actualmente.

#grid(
  columns: (1fr, 65%),
  column-gutter: 1em,
  align: horizon,
  [
    #set text(size: 0.95em)

    La pila cambia de dos maneras:

    - *Navegar a un destino* (`navigate()`): lo añade a la cima.
    - *Botón Atrás*: elimina la cima y regresa al destino anterior.
  ],
  image("images/navigation-stack-example.png", width: 100%),
)


== Principio 3: Botón Arriba y Botón Atrás

#grid(
  columns: (1fr, 45%),
  column-gutter: 1em,
  [
    #grid(
      columns: (auto, auto),
      align: (center, auto),
      inset: (x: 12pt, y: 12pt),
      [
        #image("images/navigation-back.png", width: 50pt)
      ],
      [
        *Botón Arriba (_up_)*\ En la App Bar (arriba)
      ],

      [
        #image("images/navigation-up.png", width: 50pt)
      ],
      [
        *Botón Atrás (_back_)*\ En la barra del sistema (abajo)
      ],
    )

    #v(0.5em)

    - *Dentro de la app*: ambos botones se comportan igual (orden cronológico inverso).

    - *Diferencia clave*: el botón Arriba *nunca sale de la app*. Si estamos en el destino de inicio, simplemente no aparece.
  ],
  [
    #image("images/navigation-buttons-example.svg", width: 100%)
  ],
)


== Principio 4: Deep Linking

#grid(
  columns: (1fr, 55%),
  column-gutter: 1.5em,
  align: horizon,
  [
    #set text(size: 0.9em)
    - Un *deep link* abre la app directamente en una pantalla concreta (ej: desde una URL o una notificación).

    - El sistema crea un *back stack sintético* que simula que el usuario navegó manualmente hasta esa pantalla.

    - El destino de inicio *siempre está* en la base del back stack sintético.

    - Pulsar Arriba tras un deep link recorre el back stack sintético de forma realista.
  ],
  image("images/navigation-deep-linking.png", width: 100%),
)


// ============================================================================
// BLOQUE 3: COMPONENTES DE NAVEGACIÓN
// ============================================================================

= Componentes de Navigation de Jetpack Compose

== Componentes Clave

El Navigation component de Jetpack se compone de 3 elementos clave:

#v(0.5em)

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 14pt),
  align: (left, left),
  table.header([*Componente*], [*Descripción*]),
  [*`NavController`*],
  [Clase que actúa como coordinador central de la navegación: gestiona el back stack y las transiciones entre destinos.],

  [*`NavHost`*], [Función `@Composable` que define el contenedor visual, mostrando el destino activo en cada momento.],
  [*`NavGraph`*],
  [Clase que representa el grafo de navegación: define los destinos disponibles y las conexiones entre ellos.],
)


== Relación entre los Componentes

#grid(
  columns: (1fr, 40%),
  column-gutter: 1.5em,
  align: horizon,
  [
    - *`NavHost`* es la función `@Composable` que define el contenedor visual: muestra el destino activo en pantalla.

    - El *`NavGraph`* define *qué destinos* existen y cómo se conectan. Se declara dentro del `NavHost`.

    - El *`NavController`* es el *cerebro*: gestiona la navegación, mantiene el back stack, y ejecuta las transiciones.

    - Cada *destino* es una función `@Composable` asociada a una *ruta* (_route_).

    Lo habitual es tener un único `NavController` por app, asociado a un único `NavHost`.
  ],
  image("images/navhost-diagram.png", width: 100%),
)


== Dependencia: `navigation-compose`

Para usar Navigation con Compose, hay que añadir la dependencia en `build.gradle.kts`:

```kotlin
plugins {
    // Plugin de serialización para rutas type-safe (anotación @Serializable)
    kotlin("plugin.serialization") version "2.0.21"
}

dependencies {
    // Navigation Compose
    val nav_version = "2.9.7"
    implementation("androidx.navigation:navigation-compose:$nav_version")

    // Serialización JSON (necesaria para rutas type-safe)
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")
}
```


// ============================================================================
// BLOQUE 4: DEFINIR RUTAS Y DESTINOS
// ============================================================================

= Definir Rutas y Destinos

== ¿Qué es una Ruta?

Una *ruta* (_route_) es un identificador único que representa un destino en el grafo de navegación.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    *Enfoque clásico* (strings):
    ```kotlin
    // Ruta sin argumentos
    navController.navigate("profile")

    // Ruta con argumentos
    navController.navigate("profile/Ana")
    ```
    Si hay un error tipográfico o falta un argumento, el compilador no lo detecta: la app falla en tiempo de ejecución.
  ],
  [
    *Enfoque moderno* (`@Serializable`):
    ```kotlin
    @Serializable  // Ruta sin argumentos
    object Profile

    @Serializable  // Ruta con argumentos
    data class Profile(val name: String)
    ```
    Las rutas son instancias de clases u `objects` de Kotlin. El compilador verifica que los argumentos son correctos (*type safety*).
  ],
)


== Tipos de Rutas

#v(0.5em)

#table(
  columns: (21%, 48%, auto),
  inset: 8pt,
  align: (left, left, left),
  table.header([*Tipo*], [*Declaración*], [*Uso*]),
  [Sin argumentos],
  [
    ```kotlin
    @Serializable
    object Start
    ```
  ],
  [Pantallas que no necesitan datos de entrada.],

  [Con argumentos],
  [
    ```kotlin
    @Serializable
    data class Profile(val id: String)
    ```
  ],
  [Pantallas que necesitan datos (ej: ID de usuario).],

  [Argumentos opcionales],
  [
    ```kotlin
    @Serializable
    data class Search(
      val query: String? = null
    )
    ```
  ],
  [Parámetros con valor por defecto.],
)

- Usar `object` cuando el destino *no requiere* datos de entrada.
- Usar `data class` cuando el destino *necesita* parámetros.
- Los parámetros con valor por defecto son *opcionales*.


== Enfoque Alternativo: Enum como Rutas

En el codelab #link("https://developer.android.com/codelabs/basic-android-kotlin-compose-navigation")[_Navigate between screens with Compose_], las rutas se definen con un *enum* y se usan como cadenas de texto:

```kotlin
enum class CupcakeScreen(@StringRes val title: Int) {
    Start(title = R.string.app_name),
    Flavor(title = R.string.choose_flavor),
    Pickup(title = R.string.choose_pickup_date),
    Summary(title = R.string.order_summary)
}
```

- Se usa `CupcakeScreen.Start.name` como ruta (produce la cadena `"Start"`).
- Este enfoque es más simple pero *menos seguro*: no hay validación de argumentos en tiempo de compilación.
- El enfoque con `@Serializable` es el *recomendado* actualmente para nuevos proyectos.


// ============================================================================
// BLOQUE 5: CONFIGURAR EL NAVHOST
// ============================================================================

= Configurar el NavHost

== Crear el NavController

El primer paso es crear el `NavController` usando `rememberNavController()`:

```kotlin
@Composable
fun MyApp() {
    val navController = rememberNavController()
    // ...
}
```

- `rememberNavController()` crea y recuerda una instancia de `NavHostController`.
- El prefijo `remember` en el nombre es una convención de Compose: indica que la función usa `rememberSaveable` internamente, por lo que el `NavController` *sobrevive a las recomposiciones y a cambios de configuración* (como rotaciones de pantalla).
- Debe crearse en el composable de nivel más alto que necesite acceder a la navegación.


== Crear el NavHost con Destinos

El `NavHost` se declara proporcionando el `NavController`, el destino de inicio, y los destinos:

#[
  #set text(size: 0.95em)

  ```kotlin
  @Composable
  fun MyApp() {
      val navController = rememberNavController()

      NavHost(
          navController = navController,
          startDestination = Start
      ) {
          composable<Start> {
              StartScreen(/* ... */)
          }
          composable<Profile> { backStackEntry ->
              val profile: Profile = backStackEntry.toRoute()
              ProfileScreen(name = profile.name)
          }
      }
  }
  ```
]


== Anatomía del NavHost

#grid(
  columns: (1fr, 35%),
  column-gutter: 1.5em,
  [
    Parámetros del `NavHost`:
    - *`navController`*: la instancia de `NavHostController`.
    - *`startDestination`*: la ruta del destino de inicio.
    - *`modifier`*: modificador de layout (opcional).
    - *Lambda de contenido*: donde se registran los destinos con `composable<Ruta> { }`.

    Cada `composable<Ruta>` asocia:
    - Una *ruta* (la clase `@Serializable`) que identifica el destino.
    - Un *contenido* (función composable) que se muestra cuando se navega a esa ruta.
  ],
  image("images/navhost-diagram.png", width: 100%),
)


== Registrar Destinos con `composable`

Dentro del `NavHost`, cada destino se registra llamando a la función `composable`. La sintaxis varía según el enfoque de rutas:

#grid(
  columns: 2,
  column-gutter: 1.5em,
  align: top,
  [
    *Con strings*:
    #v(0.6em, weak: true)
    ```kotlin
    composable(route = "start") {
        StartScreen()
    }

    composable(route = "profile/{name}") {
        backStackEntry ->
        val name = backStackEntry
            .arguments?.getString("name")
        ProfileScreen(name = name)
    }
    ```
  ],
  [
    *Con `@Serializable`* (enfoque moderno):
    #v(0.6em, weak: true)
    ```kotlin
    composable<Start> {
        StartScreen()
    }

    composable<Profile> { backStackEntry ->
        val profile: Profile =
            backStackEntry.toRoute()
        ProfileScreen(name = profile.name)
    }
    ```
  ],
)

En ambos casos, la lambda contiene la función composable a mostrar cuando se navega a ese destino.


// ============================================================================
// BLOQUE 6: NAVEGAR ENTRE PANTALLAS
// ============================================================================

= Navegar entre Pantallas

== `navController.navigate()`

Para navegar a un destino, se llama a `navController.navigate()` con la ruta:

```kotlin
// Navegar a un destino sin argumentos
navController.navigate(FriendsList)

// Navegar a un destino con argumentos
navController.navigate(Profile(name = "Aisha Devi"))
```

- `navigate()` *añade* el destino a la cima del back stack (push).
- El `NavHost` muestra automáticamente el nuevo destino.
- Los argumentos se pasan como parámetros del constructor de la ruta.


== Extraer Argumentos en el Destino

Cuando un destino tiene argumentos, se pueden extraer del `backStackEntry`:

```kotlin
composable<Profile> { backStackEntry ->
    // Extraer los argumentos de la ruta
    val profile: Profile = backStackEntry.toRoute<Profile>()

    ProfileScreen(
        name = profile.name,
        onNavigateBack = { navController.navigateUp() }
    )
}
```

- `toRoute<T>()` deserializa los argumentos de la ruta en una instancia del tipo `T`.


== #text(size: 0.95em)[Buena Práctica: Pasar Callbacks, No el NavController]

#[
  // #set text(size: 0.95em)

  *No pasar* el `navController` directamente a las pantallas. En su lugar, pasar *callbacks* (funciones lambda):

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    [
      #text(fill: red.darken(25%), weight: "bold")[Incorrecto:]
      #v(0.6em, weak: true)
      ```kotlin
      @Composable
      fun ProfileScreen(
          navController: NavController
      ) {
          Button(onClick = {
              navController.navigate(Friends)
          }) {
              Text("Amigos")
          }
      }
      ```
    ],
    [
      #text(fill: green.darken(25%), weight: "bold")[Correcto:]
      #v(0.6em, weak: true)
      ```kotlin
      @Composable
      fun ProfileScreen(
          onNavigateToFriends: () -> Unit
      ) {
          Button(onClick = {
              onNavigateToFriends()
          }) {
              Text("Amigos")
          }
      }
      ```
    ],
  )

  Esto hace que las pantallas sean *reutilizables*, *testeables* y *desacopladas* de la navegación.
]


== Ejemplo Completo: Navegación con Callbacks

#[
  #set text(size: 0.7em)
  ```kotlin
  @Serializable object FriendsList
  @Serializable data class Profile(val name: String)

  @Composable
  fun MyApp() {
      val navController = rememberNavController()
      NavHost(navController, startDestination = Profile(name = "John")) {
          composable<Profile> { backStackEntry ->
              val profile: Profile = backStackEntry.toRoute()
              ProfileScreen(
                  profile = profile,
                  onNavigateToFriendsList = {
                      navController.navigate(route = FriendsList)
                  }
              )
          }
          composable<FriendsList> {
              FriendsListScreen(
                  onNavigateToProfile = { name ->
                      navController.navigate(route = Profile(name = name))
                  }
              )
          }
      }
  }
  ```
]


== Buena Práctica: No Pasar Objetos Complejos

- Se recomienda *no pasar objetos complejos* como argumentos de navegación, sino solo un *identificador* (ID).

- Los objetos complejos deben vivir en la *capa de datos* (repositorio), que es la fuente única de verdad.

- Una vez en el destino, se carga el objeto completo usando el ID recibido.

```kotlin
// Al navegar, pasar solo el ID
navController.navigate(Profile(id = "user1234"))

// En el destino, cargar los datos completos desde el repositorio usando el ID
val userInfo = userInfoRepository.getUserInfo(profile.id)
```

Esto evita *pérdida de datos* durante cambios de configuración e *inconsistencias* si el objeto se modifica.


== #text(size: 0.92em)[Recuperar Argumentos de Navegación en un ViewModel]

Un *ViewModel* es una clase que gestiona el estado de la UI y *sobrevive a los cambios de configuración* (rotación de pantalla, etc.).

Cuando la lógica de negocio vive en un ViewModel, los argumentos de navegación se pueden recuperar mediante `SavedStateHandle`, un objeto que el sistema inyecta automáticamente y que da acceso al estado guardado (incluidos los argumentos de la ruta):

#[
  #set text(size: 0.95em)
  ```kotlin
  class UserViewModel(
      savedStateHandle: SavedStateHandle,
      private val userInfoRepository: UserInfoRepository
  ) : ViewModel() {
      private val profile = savedStateHandle.toRoute<Profile>()

      // Carga los datos completos desde el repositorio usando el ID
      val userInfo: Flow<UserInfo> =
          userInfoRepository.getUserInfo(profile.id)
  }
  ```
]

// ============================================================================
// BLOQUE 7: GESTIÓN DEL BACK STACK
// ============================================================================

= Gestión del Back Stack

== Navegar Hacia Atrás: `popBackStack()`

- `popBackStack()` elimina el destino actual de la cima del back stack y vuelve al anterior.
- Devuelve un *booleano*: `true` si se pudo hacer pop, `false` si la pila está vacía.

#v(1em)

```kotlin
// Volver al destino anterior
navController.popBackStack()

// Volver a un destino específico
navController.popBackStack(route = Start, inclusive = false)
```


== `popBackStack()`: Parámetros

#image("images/popbackstack-diagram.png", width: 65%)

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 12pt),
  align: (left, left),
  table.header([*Parámetro*], [*Descripción*]),
  [`route`], [El destino al que se quiere volver.],
  [`inclusive`], [Si es `true`, también elimina el destino especificado de la pila. Si es `false`, lo mantiene.],
)

#v(0.5em)

Ejemplo: si la pila es `[Start, Flavor, Pickup, Summary]` y se ejecuta:

```kotlin
// Volver a Start, eliminando todo lo que hay encima
navController.popBackStack(route = Start, inclusive = false)
// Pila resultante: [Start]
```


== `navigateUp()`

`navigateUp()` está diseñada específicamente para el *botón Arriba* de la App Bar:

```kotlin
navController.navigateUp()
```

La diferencia con `popBackStack()` se manifiesta en la *navegación cross-app*. En Android, una *tarea* (_task_) es una pila de Activities con la que el usuario interactúa. Cuando otra app lanza una Activity de nuestra app (ej: para compartir contenido), nuestra Activity se añade a la *pila de la otra app*, no a la nuestra:

- *`popBackStack()`*: saca nuestra Activity de la pila → el usuario vuelve a la otra app.
- *`navigateUp()`*: detecta esa situación, finaliza nuestra Activity en la tarea ajena, y abre nuestra app en su propia tarea → el usuario se queda en nuestra app.

En la práctica habitual (navegación interna), ambas se comportan igual.


== ¿Cuándo Usar Cada Función?

#table(
  columns: (40%, auto),
  inset: (x: 12pt, y: 18pt),
  align: (left, left),
  table.header([*Caso*], [*Función*]),
  [*Botón Atrás* (sistema)], [Gestionado automáticamente por el Navigation component. No hay que hacer nada.],
  [*Botón Arriba* (App Bar)], [Llamar a `navigateUp()`.],
  [*Navegación desde el código* \ (ej: botón Cancelar)], [Llamar a `popBackStack()`.],
)


== Opciones de Navegación (`NavOptions`)

#[
  #set text(size: 0.98em)
  `navigate()` es polimórfico y permite pasar opciones de navegación de varias formas:

  *Forma explícita*: construir un objeto `NavOptions` y pasarlo como parámetro.

  ```kotlin
  val opts = NavOptions.Builder()
      .setPopUpTo<Login>(inclusive = true)
      .build()
  navController.navigate(Home, opts)
  ```

  *Forma DSL*: `navigate()` acepta también una *lambda con receiver* de tipo `NavOptionsBuilder`. En Kotlin, esto significa que dentro del bloque `{ }` se pueden llamar directamente los métodos de `NavOptionsBuilder`.

  ```kotlin
  navController.navigate(Home) {
      popUpTo(Login) { inclusive = true }
  }
  ```

  Ambas formas son equivalentes. La forma DSL es más concisa y es la más habitual.
]

== `popUpTo`: Limpiar la Pila al Navegar

La opción `popUpTo` *elimina destinos del back stack durante la navegación*:

#v(1em)

```kotlin
navController.navigate(Home) {
    popUpTo(Login) { inclusive = true }
}
```

#v(1em)

`navigate(Home)` primero ejecuta `popUpTo` (elimina `Login` y todo lo que hay encima) y luego añade `Home` a la pila. Útil en *flujos de login*: tras autenticarse, no queremos que el usuario pueda volver atrás.

#v(0.5em)

Antes: `[Login, Verify, Confirm]` #h(1em) #sym.arrow #h(1em) Después: `[Home]`


== `launchSingleTop`: Evitar Duplicados

La opción `launchSingleTop` evita que se creen *copias duplicadas* de un destino en la pila:

```kotlin
navController.navigate(Search) {
    launchSingleTop = true
}
```

- Si `Search` ya está en la cima del back stack, *no se añade otra copia*.

- Útil para pantallas de búsqueda, tabs, o cualquier destino al que se pueda navegar repetidamente.

#v(0.5em)

Sin `launchSingleTop`: `[Start, Search, Search, Search]`

Con `launchSingleTop`: `[Start, Search]`


// ============================================================================
// BLOQUE 8: EJEMPLO PRÁCTICO - CUPCAKE
// ============================================================================

= Ejemplo: App Cupcake

== App Cupcake

#grid(
  columns: (1fr, 25%),
  column-gutter: 1.5em,
  align: horizon,
  [
    El codelab de Android #link("https://developer.android.com/codelabs/basic-android-kotlin-compose-navigation", [Navigate between screens with Compose]) utiliza la app *Cupcake*, que tiene *4 pantallas*:

    + *Start*: seleccionar la cantidad de cupcakes.
    + *Flavor*: elegir el sabor.
    + *Pickup*: elegir la fecha de recogida.
    + *Summary*: resumen del pedido.

    Flujo de navegación:

    `Start` #sym.arrow `Flavor` #sym.arrow `Pickup` #sym.arrow `Summary`

    Cada pantalla tiene un botón *Next* (avanzar) y/o *Cancel* (cancelar y volver al inicio).
  ],
  image("images/cupcake-start.png", width: 90%),
)


== Pantallas de la App Cupcake

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 1em,
  figure(
    image("images/cupcake-start.png", height: 90%),
    caption: [Comenzar pedido],
  ),
  figure(
    image("images/cupcake-flavor.png", height: 90%),
    caption: [Seleccionar sabor],
  ),
  figure(
    image("images/cupcake-pickup.png", height: 90%),
    caption: [Seleccionar fecha],
  ),
  figure(
    image("images/cupcake-summary.png", height: 90%),
    caption: [Resumen del pedido],
  ),
)


== Paso 1: Definir las Rutas

En el codelab, las rutas se definen con un enum:

```kotlin
enum class CupcakeScreen(@StringRes val title: Int) {
    Start(title = R.string.app_name),  // title = "Cupcake"
    Flavor(title = R.string.choose_flavor),  // title = "Choose flavor"
    Pickup(title = R.string.choose_pickup_date),  // title = "Choose Pickup date"
    Summary(title = R.string.order_summary)  // title = "Order Summary"
}
```

Cada valor del enum tiene una propiedad `title` (recurso de string) que se muestra en la App Bar.


== Paso 2: Crear el NavHost

#[
  #set text(size: 0.9em)
  ```kotlin
  @Composable
  fun CupcakeApp(
      viewModel: OrderViewModel = viewModel(),
      navController: NavHostController = rememberNavController()
  ) {
      Scaffold(/* ... */) { innerPadding ->
          val uiState by viewModel.uiState.collectAsState()

          NavHost(
              navController = navController,
              startDestination = CupcakeScreen.Start.name,
              modifier = Modifier.padding(innerPadding)
          ) {
              composable(route = CupcakeScreen.Start.name) { /* ... */ }
              composable(route = CupcakeScreen.Flavor.name) { /* ... */ }
              composable(route = CupcakeScreen.Pickup.name) { /* ... */ }
              composable(route = CupcakeScreen.Summary.name) { /* ... */ }
          }
      }
  }
  ```
]


== Paso 3: Añadir Navegación con Callbacks


#v(0.5em)

#grid(
  columns: (auto, 20%),
  column-gutter: 1.5em,
)[
  *Ruta "Start" (comenzar pedido)*

  ```kotlin
  composable(route = CupcakeScreen.Start.name) {
      StartOrderScreen(
          quantityOptions = DataSource.quantityOptions,
          onNextButtonClicked = { quantity ->
              viewModel.setQuantity(quantity)
              navController.navigate(CupcakeScreen.Flavor.name)
          },
          modifier = Modifier.fillMaxSize()
              .padding(dimensionResource(R.dimen.padding_medium))
      )
  }
  ```
][
  #image("images/cupcake-start.png", height: 85%)
]

---

*Ruta "Flavor" (escoger sabor)*

#grid(
  columns: (auto, 20%),
  column-gutter: 1.5em,
)[
  #set text(size: 0.95em)
  ```kotlin
  composable(route = CupcakeScreen.Flavor.name) {
      val context = LocalContext.current
      SelectOptionScreen(
          subtotal = uiState.price,
          options = DataSource.flavors.map { id ->
              context.resources.getString(id)
          },
          onSelectionChanged = { viewModel.setFlavor(it) },
          onNextButtonClicked = {
              navController.navigate(CupcakeScreen.Pickup.name)
          },
          onCancelButtonClicked = {
              cancelOrderAndNavigateToStart(viewModel, navController)
          },
          modifier = Modifier.fillMaxHeight()
      )
  }
  ```
][
  #image("images/cupcake-flavor.png", height: 90%)
]


== Paso 4: Cancelar y Volver al Inicio

La función `cancelOrderAndNavigateToStart` resetea el pedido y vuelve al inicio:

```kotlin
private fun cancelOrderAndNavigateToStart(
    viewModel: OrderViewModel,
    navController: NavHostController
) {
    viewModel.resetOrder()
    navController.popBackStack(
        route = CupcakeScreen.Start.name,
        inclusive = false
    )
}
```

- `popBackStack` con `inclusive = false` elimina todo lo que hay *encima* de `Start` en la pila, pero mantiene `Start`.
- Resultado: la pila vuelve a `[Start]`.


== Paso 5: Datos Compartidos con ViewModel

#[
  #set text(size: 0.89em)
  En esta app, los datos del estado del pedido se comparten entre pantallas mediante un *ViewModel compartido*, no mediante argumentos de navegación:

  ```kotlin
  @Composable
  fun CupcakeApp(
      viewModel: OrderViewModel = viewModel(),  // ViewModel compartido
      navController: NavHostController = rememberNavController()
  ) {
      val uiState by viewModel.uiState.collectAsState()

      NavHost(/* ... */) {
          composable(route = CupcakeScreen.Flavor.name) {
              SelectOptionScreen(
                  subtotal = uiState.price,       // Lee del ViewModel
                  onSelectionChanged = { viewModel.setFlavor(it) },  // Escribe
                  // ...
              )
          }
      }
  }
  ```
]


== Paso 6: App Bar con Botón Arriba

#grid(
  columns: 2,
  column-gutter: 1.5em
)[
  #set text(size: 0.78em)
  ```kotlin
  @Composable
  fun CupcakeAppBar(
      currentScreen: CupcakeScreen,
      canNavigateBack: Boolean,
      navigateUp: () -> Unit = {},
      modifier: Modifier = Modifier
  ) {
      TopAppBar(
          title = { Text(stringResource(currentScreen.title)) },
          modifier = modifier,
          navigationIcon = {
              if (canNavigateBack) {
                  IconButton(onClick = navigateUp) {
                      Icon(
                          imageVector = Icons.Filled.ArrowBack,
                          contentDescription =
                              stringResource(R.string.back_button)
                      )
                  }
              }
          }
      )
  }
  ```
][
  #box()[
    #image("images/cupcake-flavor.png", height: 90%)
    #place(
      dy: -96%,
      rect(
        width: 100%,
        height: 12.5%,
        stroke: 5pt + red,
        radius: 5pt,
      ),
    )
  ]
]


== Paso 6: App Bar con Botón Arriba

#grid(
  columns: 2,
  column-gutter: 1.5em
)[
  #set text(size: 0.8em)
  ```kotlin
  @Composable
  fun CupcakeApp(/* ... */) {
      val backStackEntry by navController.currentBackStackEntryAsState()
      val currentScreen = CupcakeScreen.valueOf(
          backStackEntry?.destination?.route ?: CupcakeScreen.Start.name
      )

      Scaffold(
          topBar = {
              CupcakeAppBar(
                  currentScreen = currentScreen,
                  canNavigateBack = navController.previousBackStackEntry != null,
                  navigateUp = { navController.navigateUp() }
              )
          }
      ) { /* NavHost ... */ }
  }
  ```
  #v(0.5em, weak: true)
  - `navController.currentBackStackEntryAsState()` proporciona la entrada actual del back stack como estado de Compose.
  - `navController.previousBackStackEntry != null` indica si se puede navegar hacia atrás (para mostrar u ocultar el botón Arriba).
][
  #box()[
    #image("images/cupcake-flavor.png", height: 90%)
    #place(
      dy: -96%,
      rect(
        width: 100%,
        height: 12.5%,
        stroke: 5pt + red,
        radius: 5pt,
      ),
    )
  ]
]


// ============================================================================
// BLOQUE 9: RESUMEN
// ============================================================================

= Resumen

== Conceptos Clave

#v(0.3em)

#[
  #set text(size: 0.85em)
  #align(center)[
    #table(
      columns: (auto, 1fr),
      inset: (x: 10pt, y: 9pt),
      align: (left, left),
      table.header([*Concepto*], [*Descripción*]),
      [*Fragments*], [Componentes modulares de UI dentro de Activities. Relevantes históricamente y en código legacy.],
      [*NavController*], [Coordinador central: gestiona el back stack y las transiciones.],
      [*NavHost*], [Contenedor composable que muestra el destino actual.],
      [*NavGraph*], [Grafo con todos los destinos y conexiones. Se declara dentro de `NavHost`.],
      [*Ruta*], [String u objeto `@Serializable` que representa un destino.],
      [`navigate()`], [Añade un destino a la cima del back stack.],
      [`popBackStack()`], [Elimina destinos del back stack.],
      [`navigateUp()`], [Navega hacia arriba, nunca sale de la app.],
      [`popUpTo`], [Limpia la pila durante una navegación.],
      [`launchSingleTop`], [Evita destinos duplicados en la pila.],
    )
  ]
]


== Buenas Prácticas

+ Pasar *callbacks* (`() -> Unit`) a los composables, no el `NavController`.

+ No pasar *objetos complejos* como argumentos de navegación. Pasar solo identificadores y cargar los datos desde el repositorio.

+ Usar `@Serializable` para definir rutas *type-safe* en proyectos nuevos.

+ Usar un *ViewModel compartido* cuando varias pantallas necesitan acceder al mismo estado.

+ Usar `popUpTo` con `inclusive = true` para limpiar el back stack en flujos como login.

+ Usar `launchSingleTop = true` para evitar destinos duplicados.


// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

== Recursos y Documentación

*Fragments:*
- Fragments overview: #link("https://developer.android.com/guide/fragments")
- Fragment lifecycle: #link("https://developer.android.com/guide/fragments/lifecycle")

*Principios de navegación:*
- Navigation principles: #link("https://developer.android.com/guide/navigation/principles")
- Navigation design: #link("https://developer.android.com/guide/navigation/design")

*Navegación con Compose:*
- Navigation with Compose: #link("https://developer.android.com/develop/ui/compose/navigation")
- Back stack management: #link("https://developer.android.com/guide/navigation/backstack")

*Codelab:*
- Navigate between screens with Compose: #link("https://developer.android.com/codelabs/basic-android-kotlin-compose-navigation")
