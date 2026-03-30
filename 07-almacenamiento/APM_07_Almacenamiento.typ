// ============================================================================
// Almacenamiento de Datos
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Almacenamiento de Datos],
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
// BLOQUE 1: ARQUITECTURA DE UNA APP ANDROID
// ============================================================================

= Arquitectura de una App Android

== Arquitectura de una App Android

La arquitectura recomendada por Google organiza una app en *capas* con responsabilidades bien definidas:

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
  [
    - *UI Layer* (capa de presentación): muestra los datos en pantalla. Contiene las pantallas Compose y los `ViewModel`.
    - *Domain Layer* (opcional): encapsula lógica de negocio reutilizable.
    - *Data Layer* (capa de datos): contiene la lógica de acceso a datos y las reglas de negocio. Expone datos al resto de la app.
  ],
  align(center, image("images/mad-arch-overview.png", width: 95%)),
)


== Flujo de Datos Unidireccional (UDF)

#[
  #set text(size: 0.95em)
  Una app Android moderna sigue el patrón *Unidirectional Data Flow* (UDF) en todas sus capas:

  #v(0.5em)

  #grid(
    columns: (1.2fr, 1fr),
    column-gutter: 1.5em,
    align: horizon,
    [
      - *El estado fluye hacia abajo*: el `ViewModel` transforma los datos de la aplicación en estado de UI, que la UI presenta.
      - *Los eventos fluyen hacia arriba*: la UI captura las acciones del usuario y las envía al `ViewModel`, que modifica los datos a través del repositorio.

      Ventajas de UDF:
      - *Consistencia*: fuente de verdad única
      - *Testabilidad*: la lógica de estado es independiente de la UI
      - *Mantenibilidad*: las mutaciones son predecibles y trazables
    ],
    align(center, image("images/mad-arch-ui-udf-in-action.png", width: 100%)),
  )
]

== La Capa de Datos: Repositorios y Fuentes de Datos

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
  [
    #set text(size: 0.95em)
    La *capa de datos* se compone de:

    - *Repositories* (repositorios): punto de entrada único a los datos. Coordinan una o varias fuentes de datos.
    - *Data Sources* (fuentes de datos): cada una trabaja con una sola fuente (red, base de datos local, fichero, DataStore...).

    Ejemplo: `NewsRepository` con dos fuentes:
    - `NewsLocalDataSource`: con datos locales
    - `NewsRemoteDataSource`: con una API remota

    El repositorio decide como y cuándo usar cada fuente. Cuando solo hay una fuente, repositorio y fuente se pueden combinar en una sola clase.
  ],
  align(center, image("images/mad-arch-data-overview.png", width: 95%)),
)


== Responsabilidades del Repositorio

Un repositorio actúa como *intermediario* entre las fuentes de datos y el resto de la app:

- *Exponer datos* al `ViewModel` de forma reactiva (mediante `Flow`).
- *Centralizar cambios*: toda modificación de datos pasa por el repositorio.
- *Resolver conflictos* entre múltiples fuentes de datos (red vs. local).
- *Abstraer* la implementación concreta: el `ViewModel` no sabe de que fuente son los datos.
- *Contener lógica de negocio* relacionada con los datos.

#v(1em)

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  *Principio clave:* *Los objetos de datos expuestos por un repositorio deben ser inmutables* (p.ej. `List` en lugar de `MutableList`). Esto evita que otras clases los modifiquen directamente y pongan los datos en un estado inconsistente. Para modificar los datos se llama a métodos del repositorio.
]


== API de un Repositorio

Un repositorio expone dos tipos de operaciones:

#[
  #set text(size: 0.95em)
  ```kotlin
  class UserRepository(
      private val localDataSource: UserLocalDataSource,
      private val remoteDataSource: UserRemoteDataSource
  ) {
      // Operaciones de lectura continua → Flow
      val users: Flow<List<User>> = localDataSource.getUsers()

      // Operaciones puntuales → suspend functions
      suspend fun addUser(user: User) {
          localDataSource.insertUser(user)
          remoteDataSource.syncUser(user)
      }
  }
  ```
]

- *`Flow`* para datos que cambian con el tiempo (listas, configuraciones).
- *`suspend fun`* para operaciones puntuales (insertar, eliminar, actualizar).



// ============================================================================
// BLOQUE 2: KOTLIN FLOW
// ============================================================================

= Tipos Flow de Kotlin

== ¿Qué es un Flow?

Un *`Flow`* es un tipo de Kotlin coroutines que puede *emitir múltiples valores de forma secuencial*, a diferencia de una `suspend fun` que devuelve un solo valor.

Un flujo de datos involucra tres entidades:

#grid(
  columns: (1fr, 1.2fr),
  column-gutter: 1.5em,
  align: horizon,
  [
    #set text(size: 0.95em)
    - *Productor* (_producer_): emite los datos al flujo. Mediante corrutinas puede producir datos de forma *asíncrona*.
    - *Intermediarios* (_intermediaries_): pueden *transformar* los valores emitidos o el flujo en sí (opcionales).
    - *Consumidor* (_consumer_): *consume* los valores del flujo (llamando a `collect`).
  ],
  align(center, image("images/flow-entities.png", width: 100%)),
)

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  En Android, el productor suele ser un `Repository` o `DataSource`, y el consumidor la UI.
]

== Crear y Consumir un Flow

Un `Flow` se crea con el constructor `flow { }` y se consume con `collect`:

#grid(
  columns: (1fr, 0.45fr),
  column-gutter: 1em,
  align: top,
)[
  ```kotlin
  // Productor: emite valores con emit()
  val countFlow: Flow<Int> = flow {
      for (i in 1..3) {
          delay(1000)  // simula trabajo asíncrono
          emit(i)      // emite un valor al flujo
      }
  }

  // Consumidor: consume valores con collect (suspend fun)
  viewModelScope.launch {
      countFlow.collect { value ->
          println(value)  // imprime 1, 2, 3 (cada segundo)
      }
  }
  ```
][
  #block(
    fill: rgb("#fff2df"),
    width: 100%,
    inset: 12pt,
    radius: 5pt,
  )[
    #set text(size: 0.95em)
    *`Flow` es lazy o frío (cold)*\

    El código del productor no se ejecuta hasta que un consumidor llama a `collect`.

    Cada nuevo `collect` reinicia la emisión desde el principio.
  ]
]

== Operadores Intermedios

Los operadores intermedios *transforman* el flujo sin consumirlo.

#v(0.5em)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  align: top,
)[
  Ejemplo:
  #v(0.8em, weak: true)
  ```kotlin
  val newsFlow: Flow<List<Article>> =
      newsRepository.latestNews
          .map { news ->
              // Transformar cada emisión
              news.filter { it.isFavorite }
          }
          .catch { exception ->
              // Manejar errores
              emit(emptyList())
          }
          .flowOn(Dispatchers.IO)
  ```
][
  Operadores más comunes:
  - `map { }`: transforma cada valor emitido.
  - `filter { }`: filtra valores según un predicado.
  - `catch { }`: captura excepciones del flujo ascendente.
  - `flowOn(dispatcher)`: cambia el dispatcher para las operaciones anteriores.
  - `combine(otherFlow) { a, b -> }`: fusiona dos flujos (se re-emite cuando cambia cualquiera).
]


== StateFlow: Estado Observable

`StateFlow` es una variante *caliente* (_hot_) de Flow diseñada para representar *estado*.

#v(1em)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    *`Flow` (lazy / frío)*
    - Se ejecuta al hacer `collect`

    - Cada collector reinicia la emisión

    - No tiene valor actual

    - Puede emitir un número finito o infinito de valores
  ],
  [
    *`StateFlow` (caliente)*
    - Siempre activo en memoria

    - Nuevos collectors reciben el último valor

    - Propiedad `.value` con el estado actual

    - Siempre tiene un valor (requiere valor inicial)
  ],
)


== Flow vs StateFlow: Ejemplo

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
  [
    *`Flow` frío*

    ```kotlin
    val nums: Flow<Int>
    // emite cada 100ms: 1, 2, 3, ...
    ```

    - *t=0:* Collector A empieza → recibe *1, 2, 3*
    - *t=150:* Collector B empieza → recibe *1, 2, 3*

    Cada collector ejecuta el bloque *desde el principio*, independientemente del otro.
  ],
  [
    *`StateFlow` caliente*

    ```kotlin
    val count: StateFlow<Int>
    // actualiza cada 100ms: 1, 2, 3, ...
    ```

    - *t=0:* Collector A empieza → recibe *1*
    - *t=100:* value = 2 → A recibe *2*
    - *t=150:* Collector B empieza → recibe *2*
    - *t=200:* value = 3 → A y B reciben *3*

    Collector B recibe el valor actual y los futuros; *no los anteriores*.
  ],
)


== MutableStateFlow

`MutableStateFlow` permite *crear y modificar* el estado directamente.

Ejemplo:
#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 1em,
  align: top,
)[
  #set text(size: 0.9em)
  ```kotlin
  class CounterViewModel : ViewModel() {
      // Backing property: mutable y privado
      private val _count = MutableStateFlow(0)

      // Exponer como StateFlow inmutable
      val count: StateFlow<Int> =
          _count.asStateFlow()

      fun increment() {
          _count.value++
      }

      fun reset() {
          _count.value = 0
      }
  }
  ```
][
  #set text(size: 0.88em)
  El `ViewModel` *expone el estado como `StateFlow`* para que la UI pueda reaccionar a los cambios sin consultar el `ViewModel` activamente.

  `StateFlow` siempre tiene en caché el último estado, lo que permite restaurarlo rápidamente tras un cambio de configuración.

  #v(0.5em)

  *Patrón _backing property_:*
  - `_count` (`MutableStateFlow`): mutable, privado, solo modificable dentro del `ViewModel`.
  - `count` (`StateFlow`): inmutable, público, expuesto a la UI.
]


== Convertir Flow a StateFlow con `stateIn`

Cuando la fuente de datos ya expone un `Flow` (Room, DataStore), se convierte a `StateFlow` con *`stateIn`*. Internamente, `stateIn` lanza una corrutina que colecta el `Flow` upstream y alimenta el `StateFlow` resultante:

#[
  #set text(size: 0.95em)
  ```kotlin
  class UserViewModel(private val repository: UserRepository) : ViewModel() {
      val users: StateFlow<List<User>> = repository.allUsers  // Flow<List<User>>
          .stateIn(
              scope = viewModelScope,
              started = SharingStarted.WhileSubscribed(5_000),
              initialValue = emptyList()
          )
  }
  ```
]

#v(0.5em, weak: true)

Parámetros de `stateIn`:
- *`scope`*: scope donde vive la corrutina interna (normalmente `viewModelScope`).
- *`started`*: cuándo arrancar/parar esa corrutina --- `WhileSubscribed(5000)` la detiene 5s después de que la UI deja de observar, ahorrando recursos.
- *`initialValue`*: valor del `StateFlow` mientras llega la primera emisión del `Flow`.


== Consumir un Flow en Compose

`collectAsState()` convierte el `StateFlow` en un `State<T>` de Compose.

// Internamente lanza una corrutina (ligada al ciclo de vida del composable) que recoge el `Flow` y actualiza el `State<T>` con cada nueva emisión.

#grid(
  columns: (1.5fr, 1fr),
  column-gutter: 1.5em,
  align: top
)[
  ```kotlin
  @Composable
  fun UserListScreen(viewModel: UserViewModel) {
      val users by viewModel.users.collectAsState()

      LazyColumn {
          items(users) { user ->
              Text(text = user.name)
          }
      }
  }
  ```

][
  Flujo completo:

  // *Fuente de datos → Flow → ViewModel (StateFlow) → Compose (collectAsState)*
  #set align(center)
  #grid(
    columns: 1,
    row-gutter: 0.4em,
    align: center,
    [*Fuente de datos*],
    [*🠟*],
    [*Flow*],
    [*🠟*],
    [*ViewModel (StateFlow)*],
    [*🠟*],
    [*Compose (collectAsState)*],
  )
]

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  `collectAsState()` lanza una corrutina (ligada al ciclo de vida del composable) que se suscribe al `StateFlow`. La UI se recompone cada vez que cambia el estado. Al salir de la composición, cancela la suscripción.
]


// ============================================================================
// BLOQUE 3: VISIÓN GENERAL DEL ALMACENAMIENTO
// ============================================================================

= Visión General del Almacenamiento

== Opciones de Almacenamiento en Android

Android proporciona varias formas de almacenar datos, cada una diseñada para un caso de uso distinto:

#v(1em)

- *Archivos específicos de la app*: solo accesibles por tu app. Se eliminan al desinstalarla.

- *Almacenamiento compartido*: archivos accesibles por otras apps (contenido multimedia, documentos y otros archivos).

- *Preferencias*: pares clave-valor simples para configuración del usuario.

- *Bases de datos*: datos estructurados en tablas con relaciones.


== Tabla Comparativa de Opciones

#[
  #set text(size: 0.7em)
  #table(
    columns: (6.5em, 13.75em, 17.5em, 1fr, 6em),
    inset: 5pt,
    align: left,
    table.header(
      [*Tipo de contenido*],
      [*Método de acceso*],
      [*Permisos requeridos*],
      [*¿Acceso de otras apps?*],
      [*¿Se elimina al desinstalar?*],
    ),
    [Archivos específicos de la app],
    [Almacenamiento interno:\
      `getFilesDir()`, `getCacheDir()` \
      Almacenamiento externo: `getExternalFilesDir()`, `getExternalCacheDir()`],
    [Nunca para almacenamiento interno. No requeridos para almacenamiento externo en API 19+],
    [No],
    [Sí],

    [Contenido multimedia],
    [API `MediaStore`],
    [API 30+: `READ_EXTERNAL_STORAGE` (ficheros de otras apps) \ API 29: `READ_EXTERNAL_STORAGE` o `WRITE_EXTERNAL_STORAGE` \ API 28−: permisos para _todos_ los ficheros],
    [Sí, la otra app necesita `READ_EXTERNAL_STORAGE`],
    [No],

    [Documentos y otros archivos],
    [Storage Access Framework],
    [Ninguno],
    [Sí, a través del selector de archivos del sistema],
    [No],

    [Preferencias de la app], [Librería Jetpack DataStore], [Ninguno], [No], [Sí],
    [Base de datos], [Librería de persistencia Room], [Ninguno], [No], [Sí],
  )
]


== Almacenamiento Interno vs Externo

Android distingue dos ubicaciones físicas de almacenamiento:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align: top,
  [
    *Almacenamiento interno*
    - Siempre disponible en todos los dispositivos
    - Protegido por el sistema; cifrado en Android 10+
    - Cada app tiene su propio directorio aislado, inaccesible para otras apps
    - Típicamente más pequeño que el almacenamiento externo.
    - Ideal para datos sensibles
  ],
  [
    *Almacenamiento externo*
    - Puede no estar disponible (tarjetas SD extraíbles)
    - Típicamente más grande que el almacenamiento interno
    - Cada app tiene también su propio directorio privado (`Android/data/`)
    - Otros apps pueden acceder al almacenamiento compartido (con permisos)
    - Ideal para archivos grandes no sensibles
  ],
)


== Archivos Específicos de la App

Para leer y escribir ficheros que solo tu app necesita, no se requieren permisos. Se usa la clase `File` de la biblioteca estándar de Kotlin:

```kotlin
// Almacenamiento interno - ficheros persistentes
val file = File(context.filesDir, "mi_fichero.txt")

// Almacenamiento interno - caché (el sistema puede borrarlo)
val cacheFile = File(context.cacheDir, "temp.txt")

// Almacenamiento externo - directorio raíz de la app
val externalFile = File(context.getExternalFilesDir(null), "datos.json")

// Almacenamiento externo - subdirectorio por tipo de contenido
val pictureFile = File(
    context.getExternalFilesDir(Environment.DIRECTORY_PICTURES), "foto.jpg"
)
```


== Scoped Storage (Android 10+)

*Antes de Android 10* una app tenía acceso a todo el almacenamiento externo: podía leer y escribir cualquier fichero de cualquier otra app. Esto era un problema de privacidad y causaba desorden (apps podían crear ficheros en cualquier parte del almacenamiento).

#v(1em)

*A partir de Android 10* se introdujo el *almacenamiento específico* (_scoped storage_) para restringir ese acceso:

- Acceso directo solo al directorio privado de la app

- Para multimedia de otras apps #sym.arrow `MediaStore API`

- Para documentos de otras apps #sym.arrow Storage Access Framework (SAF)

- Mejora la privacidad y el control del usuario


== Acceso a Contenido Compartido

Android proporciona dos mecanismos según el tipo de contenido:

- *Multimedia* (fotos, vídeos, audio): accesible con la *MediaStore API*. El *Photo Picker* es un selector del sistema construido sobre MediaStore que permite al usuario elegir contenido multimedia sin necesidad de permisos.

- *Documentos y otros archivos* (PDF, texto...): accesible con el *Storage Access Framework (SAF)*. Proporciona un selector de archivos del sistema similar al Photo Picker.



// ============================================================================
// BLOQUE 3: JETPACK DATASTORE
// ============================================================================

= Jetpack DataStore

== ¿Qué es Jetpack DataStore?

*Jetpack DataStore* es la solución moderna para almacenar datos simples de forma local, sustituyendo a SharedPreferences:

- *API asíncrona* basada en corrutinas y Flows de Kotlin.
- *Operaciones transaccionales*: lectura-escritura atómica.
- *Thread-safe*: seguro para uso concurrente.
- *Diseñado para datos pequeños y simples*

DataStore tiene dos implementaciones:

#table(
  columns: (auto, 1fr, 1fr),
  inset: 8pt,
  align: left,
  table.header([], [*Preferences DataStore*], [*Proto DataStore*]),
  [Datos], [Pares clave-valor], [Objetos tipados (Protocol Buffers)],
  [Esquema], [No requiere], [Requiere esquema `.proto`],
  [Seguridad de tipos], [No], [Sí (verificación en compilación)],
  [Uso típico], [Preferencias simples], [Configuración compleja y tipada],
)


== Configuración de Preferences DataStore

Añadir la dependencia en `build.gradle.kts`:

```kotlin
dependencies {
    implementation("androidx.datastore:datastore-preferences:1.1.4")
}
```

Crear la instancia como propiedad de extensión del `Context` (a nivel de fichero):

#grid(
  columns: (0.95fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  ```kotlin
  import androidx.datastore.preferences
      .preferencesDataStore

  // Declaración top-level (singleton)
  private val Context.dataStore
      by preferencesDataStore(
          name = "user_preferences"
      )
  ```
][
  *Se declara como propiedad de extensión* de `Context` porque el _property delegate_ (`by preferencesDataStore`) usa el `Context` para acceder al sistema de ficheros.

  *Se declara en _top-level_* para garantizar una única instancia (singleton) en toda la app.
]


== Definir Claves y Leer Datos

Las claves se definen con funciones tipadas (`booleanPreferencesKey`, `stringPreferencesKey`, `intPreferencesKey`...):

```kotlin
class UserPreferencesRepository(private val context: Context) {
    // Definir claves tipadas
    private val IS_LINEAR_LAYOUT = booleanPreferencesKey("is_linear_layout")
    private val FONT_SIZE = intPreferencesKey("font_size")

    // Exponer los datos como Flows
    val isLinearLayout: Flow<Boolean> = context.dataStore.data.map { preferences ->
        preferences[IS_LINEAR_LAYOUT] ?: true
    }

    val fontSize: Flow<Int> = context.dataStore.data.map { preferences ->
        preferences[FONT_SIZE] ?: 16
    }
}
```


== Escribir Datos

La escritura se realiza con `edit`, una función `suspend` transaccional:

#v(0.8em, weak: true)

```kotlin
class UserPreferencesRepository(private val context: Context) {
    // ... (claves y lectura definidas anteriormente)

    suspend fun saveLayoutPreference(isLinearLayout: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[IS_LINEAR_LAYOUT] = isLinearLayout
        }
    }
    suspend fun saveFontSize(size: Int) {
        context.dataStore.edit { preferences ->
            preferences[FONT_SIZE] = size
        }
    }
}
```

#v(0.8em, weak: true)

La operación `edit` es *atómica*: se lee el estado actual, se aplica la transformación y se escribe el resultado. Si falla, no se modifica nada.


== Ejemplo: Integración con ViewModel

Siguiendo el patrón UDF, el `ViewModel` convierte el `Flow` del repositorio en un `StateFlow` con `stateIn`, y expone funciones para modificar las preferencias:

```kotlin
class PreferencesViewModel(
    private val repository: UserPreferencesRepository
) : ViewModel() {

    val isLinearLayout: StateFlow<Boolean> =
        repository.isLinearLayout.stateIn(
          viewModelScope, SharingStarted.WhileSubscribed(5_000), true
        )

    fun toggleLayout() {
        viewModelScope.launch {
            repository.saveLayoutPreference(!isLinearLayout.value)
        }
    }
}
```


== Ejemplo: Integración con Compose

La UI observa el `StateFlow` con `collectAsState()` y envía eventos al `ViewModel` cuando el usuario interactúa:

#v(0.8em, weak: true)

#[
  #set text(size: 0.95em)
  ```kotlin
  @Composable
  fun SettingsScreen(viewModel: PreferencesViewModel) {
      val isLinearLayout by viewModel.isLinearLayout.collectAsState()

      Row {
          Text("Vista en lista")
          Switch(
              checked = isLinearLayout,
              onCheckedChange = { viewModel.toggleLayout() }
          )
      }
  }
  ```
]

#v(0.8em, weak: true)

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  Flujo completo:\
  *DataStore → Flow → ViewModel (StateFlow) → Compose (collectAsState)*.
]


// ============================================================================
// BLOQUE 5: ROOM
// ============================================================================

= Room: Base de Datos Local

== ¿Qué es Room?

*Room* es una biblioteca ORM (_Object-Relational Mapping_) de Jetpack que proporciona una capa de abstracción sobre *SQLite*:

- *Verificación en compilación* de las consultas SQL --- los errores se detectan antes de ejecutar la app.
- *Anotaciones* que minimizan el código boilerplate.
- *Migraciones* de esquema simplificadas entre versiones de la base de datos.
- *Integración nativa con corrutinas y Flow* para operaciones asíncronas y reactivas.

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  *¿Por qué no usar SQLite directamente?* \
  Con SQLite "crudo" hay que escribir código SQL como `String` (sin verificación en compilación), gestionar manualmente las conexiones, y convertir entre `Cursor` y objetos Kotlin. Room automatiza todo esto.
]


== Arquitectura de Room

Room se compone de *tres elementos principales* que interactúan entre sí:

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
  [
    - *Entity*: una clase que representa una tabla en la base de datos. Cada instancia de la clase representa una fila.

    - *DAO* (_Data Access Object_): una interfaz que define los métodos de acceso a la base de datos (consultas, inserciones, etc.).

    - *Database*: la clase principal que contiene la base de datos y sirve como punto de acceso a los DAOs.
  ],
  align(center, image("images/room_architecture.svg", width: 90%)),
)


== Configuración de Room

Añadir las dependencias en `build.gradle.kts`:

```kotlin
plugins {
    id("com.google.devtools.ksp") version "2.1.10-1.0.31"
}

dependencies {
    val room_version = "2.7.1"

    implementation("androidx.room:room-runtime:$room_version")
    ksp("androidx.room:room-compiler:$room_version")

    // Soporte para corrutinas y Flow
    implementation("androidx.room:room-ktx:$room_version")
}
```

Room utiliza *KSP* (Kotlin Symbol Processing) para generar código en tiempo de compilación.


== Definir una Entidad

Una *entidad* es una clase anotada con `@Entity` que representa una tabla. Normalmente se usa `data class` porque genera automáticamente `equals()`, `hashCode()` y `copy()`:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em
)[
  ```kotlin
  @Entity(tableName = "users")
  data class User(
      @PrimaryKey(autoGenerate = true)
      val id: Int = 0,

      @ColumnInfo(name = "first_name")
      val firstName: String,

      @ColumnInfo(name = "last_name")
      val lastName: String,

      val age: Int
  )
  ```
][
  - `@Entity` marca la clase como una tabla. `tableName` es opcional.

  - `@PrimaryKey` marca la clave primaria. Con `autoGenerate = true` Room asigna IDs automáticamente.

  - `@ColumnInfo` personaliza la columna: nombre (`name`), tipo (`typeAffinity`), si admite nulos (`notNull`), collation para comparaciones de texto, etc.
]

== Opciones Avanzadas de Entidades

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    *Clave primaria compuesta:*
    ```kotlin
    @Entity(primaryKeys =
        ["firstName", "lastName"])
    data class User(
        val firstName: String,
        val lastName: String
    )
    ```

    *Ignorar campos:*
    ```kotlin
    @Ignore val picture: Bitmap? = null
    ```
  ],
  [
    *Índices para búsquedas rápidas:*
    ```kotlin
    @Entity(indices = [
        Index(
            value = ["last_name"],
            unique = true
        )
    ])
    data class User(
        @PrimaryKey val id: Int,
        val last_name: String
    )
    ```
  ],
)


== ¿Qué es un DAO?

#grid(
  columns: (0.8fr, 1fr),
  column-gutter: 1.5em,
  align: top
)[
  Un *DAO* (_Data Access Object_) es una interfaz anotada con `@Dao` que define los métodos para interactuar con la base de datos.

  #set text(hyphenate: true)
  Cada método se anota para indicar qué operación realiza:

  - `@Insert`, `@Update`, `@Delete`: Room infiere la implementación a partir de la entidad recibida como parámetro.

  - `@Query`: hay que escribir el SQL manualmente; Room lo ejecuta y mapea el resultado a objetos Kotlin.
][
  ```kotlin
  @Dao
  interface UserDao {
      @Insert
      suspend fun insert(user: User)

      @Update
      suspend fun update(user: User)

      @Delete
      suspend fun delete(user: User)

      @Query(
        "SELECT * FROM users " +
        "ORDER BY first_name ASC"
      )
      fun getAllUsers(): Flow<List<User>>
  }
  ```
]


== Método `@Insert`

#grid(
  columns: (0.8fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  Genera el SQL `INSERT`. La función recibe como parámetro una entidad, una lista de entidades, o un `vararg`.

  El parámetro `onConflict` de \@Insert define qué hacer si ya existe un registro con la misma PK:

  - `ABORT` (por defecto): cancela la operación.
  - `REPLACE`: reemplaza el registro existente.
  - `IGNORE`: ignora el nuevo registro.
][
  ```kotlin
  @Dao
  interface UserDao {
      @Insert
      suspend fun insertUser(user: User)

      @Insert
      suspend fun insertUsers(
        users: List<User>
      )

      @Insert(onConflict =
          OnConflictStrategy.REPLACE)
      suspend fun upsertUser(user: User): Long
  }
  ```
]


== Métodos `@Update` y `@Delete`

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    *`@Update`*: actualiza por PK
    #[
      ```kotlin
      @Update
      suspend fun updateUser(
          user: User
      )

      // Devuelve nº de filas actualizadas
      @Update
      suspend fun updateUsers(
          users: List<User>
      ): Int
      ```
    ]
  ],
  [
    *`@Delete`*: elimina por PK
    #[
      ```kotlin
      @Delete
      suspend fun deleteUser(
          user: User
      )

      // Devuelve nº de filas eliminadas
      @Delete
      suspend fun deleteUsers(
          users: List<User>
      ): Int
      ```
    ]
  ],
)

Ambos métodos usan la *clave primaria* para identificar qué filas modificar.


== Consultas con `@Query`

#grid(
  columns: (0.7fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  Permite escribir SQL arbitrario, verificado en compilación por Room.

  El valor de retorno puede ser:
  - *`Flow<T>`*: para lecturas continuas; Room re-ejecuta la consulta y emite un nuevo resultado cada vez que cambia la tabla.

  - *`T` directamente* (función `suspend`): para lecturas puntuales.

  - *`Int` o `Unit`* (función `suspend`): para modificaciones (`DELETE`, `UPDATE`).
][
  #set text(size: 0.9em)
  ```kotlin
  @Dao
  interface UserDao {
      @Query("SELECT * FROM users")
      fun getAllUsers(): Flow<List<User>>

      @Query("SELECT * FROM users " +
             "WHERE age > :minAge")
      fun getUsersOlderThan(
          minAge: Int): Flow<List<User>>

      @Query("SELECT * FROM users " +
             "WHERE id IN (:userIds)")
      fun getUsersByIds(
          userIds: List<Int>): Flow<List<User>>

      @Query("DELETE FROM users " +
             "WHERE age < :minAge")
      suspend fun deleteYoungerThan(minAge: Int): Int
  }
  ```
]


== Consultas Observables con Flow

Una de las grandes ventajas de Room es la posibilidad de devolver *`Flow`* en las consultas:

```kotlin
@Query("SELECT * FROM users ORDER BY first_name ASC")
fun getAllUsers(): Flow<List<User>>
```

- Room observa la tabla internamente y, cuando detecta un cambio, re-ejecuta la consulta y emite el nuevo resultado por el `Flow`.

- La UI se actualiza de forma reactiva sin necesidad de polling ni callbacks manuales.

- Se integra directamente con `collectAsState()` en Compose.

#block(
  fill: rgb("#fff2df"),
  width: 100%,
  inset: 12pt,
  radius: 5pt,
)[
  Las funciones que devuelven `Flow` *no* son `suspend`. El `Flow` se crea inmediatamente y emite datos cuando se comienza a observar. Las funciones que realizan escrituras (`@Insert`, `@Update`, `@Delete`) sí deben ser `suspend`.
]


== Crear la Base de Datos

Para definir la base de datos hay que crear una clase abstracta que extienda `RoomDatabase` y anotarla con `@Database` indicando las entidades y la versión del esquema.

Para cada clase DAO asociada con la base de datos, se debe definir un método abstracto con cero argumentos y que devuelva una instancia de la clase DAO.

#grid(
  columns: (1fr, 0.82fr),
  column-gutter: 1.5em,
)[
  ```kotlin
  @Database(
      entities = [User::class],
      version = 1,
      exportSchema = false
  )
  abstract class AppDatabase : RoomDatabase() {
      abstract fun userDao(): UserDao
  }
  ```
][
  - `entities`: lista de todas las entidades (tablas) de la base de datos.
  - `version`: número de versión del esquema (se incrementa en migraciones).
  - `exportSchema`: si `true`, Room exporta el esquema a un fichero JSON para control de versiones.
]


== Patrón Singleton para la Base de Datos

Se recomienda tener una *única instancia* de la base de datos en toda la app:

#grid(
  columns: (1fr, 0.7fr),
  column-gutter: 1.5em,
  align: top,
)[
  #set text(size: 0.922em)
  ```kotlin
  object DatabaseProvider {
      @Volatile
      private var INSTANCE: AppDatabase? = null

      fun getDatabase(context: Context): AppDatabase {
          return INSTANCE ?: synchronized(this) {
              val instance = Room.databaseBuilder(
                  context.applicationContext,
                  AppDatabase::class.java,
                  "app_database"
              ).build()
              INSTANCE = instance
              return instance
          }
      }
  }
  ```
][
  #set text(size: 0.95em)
  - `@Volatile`: garantiza que los cambios en `INSTANCE` sean visibles inmediatamente para todos los hilos.

  - `synchronized`: evita que dos hilos creen la instancia simultáneamente.

  - `databaseBuilder()` permite encadenar opciones de configuración (migraciones, callbacks...), finalmente se debe llamar a `build()`.
]


== Objetos Embebidos con `@Embedded`

`@Embedded` permite descomponer un objeto en columnas dentro de la misma tabla:

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1.5em,
  align: top
)[
  ```kotlin
  data class Address(
      val street: String,
      val city: String,

      @ColumnInfo(name = "post_code")
      val postCode: Int
  )

  @Entity
  data class User(
      @PrimaryKey val id: Int,
      val firstName: String,
      @Embedded val address: Address
  )
  ```
][
  - `@Embedded` "aplana" los campos del objeto dentro de la tabla principal.

  - La tabla `User` contendrá las columnas: `id`, `firstName`, `street`, `city`, `post_code`.
]


== Relaciones entre Entidades


#grid(
  columns: (1fr, 1.6fr),
  column-gutter: 1.5em,
  align: top,
)[
  Room permite definir relaciones mediante claves foráneas y `@Relation`.

  *Tipos de relaciones soportados:*

  - *One-to-one*
  - *One-to-many*
  - *Many-to-many* (con tabla de unión / _junction table_)

  `@Relation` le indica a Room cómo hacer el JOIN entre las dos tablas al consultar `UserWithBooks`.
][
  #set text(size: 0.85em)
  ```kotlin
  @Entity
  data class User(
      @PrimaryKey val userId: Long, val name: String
  )

  @Entity(foreignKeys = [
    ForeignKey(entity = User::class,
        parentColumns = ["userId"],
        childColumns = ["userOwnerId"],
        onDelete = ForeignKey.CASCADE)])
  data class Book(
      @PrimaryKey val bookId: Long, val title: String,
      val userOwnerId: Long  // clave foránea
  )

  data class UserWithBooks(
      @Embedded val user: User,
      @Relation(parentColumn = "userId",
          entityColumn = "userOwnerId")
      val books: List<Book>
  )
  ```
  // parentColumn → columna de la entidad en @Embedded (User)
  // entityColumn → columna de la entidad del tipo de la propiedad (Book)
  // Room infiere las tablas a partir del tipo de @Embedded y del tipo de la lista/propiedad
]


== Integración con ViewModel

El `ViewModel` actúa como intermediario entre la base de datos y la UI:

```kotlin
class UserViewModel(private val userDao: UserDao) : ViewModel() {

    val allUsers: StateFlow<List<User>> = userDao.getAllUsers()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    fun addUser(firstName: String, lastName: String, age: Int) {
        viewModelScope.launch {
            userDao.insert(User(firstName = firstName,
                lastName = lastName, age = age))
        }
    }

    fun deleteUser(user: User) {
        viewModelScope.launch { userDao.delete(user) }
    }
}
```


== Integración con Compose


#grid(
  columns: (1fr, 2.1fr),
  column-gutter: 1em,
)[
  #set text(size: 0.95em)
  La pantalla observa el `StateFlow` del `ViewModel` y se actualiza automáticamente.

  #v(2em, weak: true)

  Flujo de datos unidireccional:
  #set align(center)
  #grid(
    columns: 1,
    row-gutter: 0.4em,
    align: center,
    [*Room*],
    [*🠟*],
    [*DAO (Flow)*],
    [*🠟*],
    [*ViewModel (StateFlow)*],
    [*🠟*],
    [*Compose (collectAsState)*],
  )
][
  #set text(size: 0.8em)
  ```kotlin
  @Composable
  fun UserScreen(viewModel: UserViewModel) {
      val users by viewModel.allUsers.collectAsState()
      var name by remember { mutableStateOf("") }
      var age by remember { mutableStateOf("") }

      Column {
          TextField(value = name, onValueChange = { name = it },
              label = { Text("Nombre") })
          TextField(value = age, onValueChange = { age = it },
              label = { Text("Edad") })
          Button(onClick = {
              age.toIntOrNull()?.let { viewModel.addUser(name, "", it) }
              name = ""; age = ""
          }) { Text("Añadir") }
          LazyColumn {
              items(users) { user ->
                  Text("${user.firstName} (${user.age} años)")
              }
          }
      }
  }
  ```
]


== Combinando Room y DataStore

La función `combine` permite combinar los valores más recientes de varios flujos. Un caso habitual es combinar datos de Room con preferencias de DataStore:

#grid(
  columns: (1.65fr, 1fr),
  column-gutter: 1.5em,
  align: top,
)[
  ```kotlin
  val items: StateFlow<List<Item>> = combine(
      itemDao.getAllItems(),  // Flow de Room
      prefsRepository.sortOrder  // Flow de DataStore
  ) { items, order ->
      when (order) {
          SortOrder.BY_NAME ->
              items.sortedBy { it.name }
          SortOrder.BY_PRICE ->
              items.sortedByDescending { it.price }
      }
  }.stateIn(viewModelScope,
      SharingStarted.WhileSubscribed(5000),
      emptyList())
  ```
][
  La función `combine` recoge las últimas emisiones de todos los flujos y llama al bloque de transformación cada vez que cualquiera de ellos emite un nuevo valor.

  En este ejemplo: cuando cambian los ítems o la preferencia de orden, la lista se recalcula automáticamente.
]


// ============================================================================
// BLOQUE 7: BUENAS PRÁCTICAS Y RESUMEN
// ============================================================================

= Resumen

== ¿Qué Almacenamiento Usar?

#table(
  columns: (1.8fr, 1fr, 2.6fr),
  inset: (x: 6pt, y: 12pt),
  align: left,
  table.header([*Escenario*], [*Solución*], [*Justificación*]),
  [Preferencias (tema, idioma)], [DataStore], [Pares clave-valor, API reactiva],
  [Datos estructurados propios], [Room], [SQL, relaciones, Flow],
  [Ficheros privados temporales], [Cache interna], [Sin permisos, auto-limpieza],
  [Ficheros privados grandes], [Externo propio], [Mayor capacidad, sin permisos],
  [Fotos/vídeos del usuario], [Photo Picker], [Archivos externos compartidos, sin permisos],
  [Documentos del usuario], [SAF], [Archivos externos compartidos, sin permisos],
)


== Buenas Prácticas de Almacenamiento

- *Datos inmutables*: los repositorios deben exponer datos inmutables para evitar modificaciones accidentales y garantizar seguridad entre hilos.

- *Fuente de verdad única*: cada repositorio debe definir una sola fuente de verdad. Para apps offline-first, es la base de datos local.

- *Main-safe*: todas las operaciones de acceso a datos deben ser seguras para llamar desde el hilo principal (usar `suspend` y `Flow`).

- *Separación de responsabilidades*: los `ViewModel` no deben acceder directamente a Room ni DataStore. Siempre a través de un repositorio.


== Flujo Completo de Datos

Cada capa tiene una *responsabilidad clara* y se comunica con la siguiente mediante `Flow` y funciones `suspend`.

#align(center)[
  #grid(
    columns: 1,
    row-gutter: 0.3em,
    align: center,
    [*Almacenamiento* #text(size: 0.85em)[\ Room · DataStore · ficheros internos/externos]],
    [*🠟*],
    [*API de acceso* #text(size: 0.85em)[\ DAO · DataStore API · File API · Photo Picker · SAF]],
    [*🠟*],
    [*Repository* #text(size: 0.85em)[\ Coordina fuentes de datos]],
    [*🠟*],
    [*ViewModel* #text(size: 0.85em)[\ `StateFlow` / `viewModelScope.launch`]],
    [*🠟*],
    [*Compose UI* #text(size: 0.85em)[\ `collectAsState()`]],
  )
]



// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

---

== Recursos y Documentación

#grid(
  columns: 2,
  column-gutter: 1.5em,
  align: top
)[
  *Documentación oficial de Android:*
  - #link("https://developer.android.com/kotlin/flow")[Kotlin flows on Android]

  - #link("https://developer.android.com/kotlin/flow/stateflow-and-sharedflow")[StateFlow and SharedFlow]

  - #link("https://developer.android.com/training/data-storage")[Data and file storage overview]

  - #link("https://developer.android.com/training/data-storage/room")[Save data in a local database using Room]

  - #link("https://developer.android.com/topic/libraries/architecture/datastore")[Jetpack DataStore]

  - #link("https://developer.android.com/training/data-storage/shared/photo-picker")[Photo Picker]

  - #link("https://developer.android.com/topic/architecture/data-layer")[Data layer]
][
  *Codelabs:*
  - #link(
      "https://developer.android.com/codelabs/basic-android-kotlin-compose-persisting-data-room",
    )[Cómo conservar datos con Room]

  - #link("https://developer.android.com/codelabs/android-preferences-datastore")[Preferences DataStore]

  *Arquitectura:*
  - #link("https://developer.android.com/topic/architecture/data-layer/offline-first")[Build an offline-first app]

  - #link("https://developer.android.com/training/data-storage/use-cases")[Storage use cases and best practices]
]
