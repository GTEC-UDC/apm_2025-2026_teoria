// ============================================================================
// Introducción a Kotlin
// Arquitecturas y Plataformas Móviles (APM)
// Máster Universitario en Ingeniería Informática - Universidade da Coruña
// Curso 2025/2026
// ============================================================================

#import "@local/touying-gtec-simple:0.1.0": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Introducción a Kotlin],
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

  #v(1.5em)

  #align(center)[
    #link("https://creativecommons.org/licenses/by/4.0/")[
      #image("images/cc-by.svg", height: 58pt)
    ]
  ]
]


---

#outline-slide(
  title: [Contenidos],
  outline-args: (depth: 1),
)

// ============================================================================
// SECCIÓN 1: INTRODUCCIÓN Y MOTIVACIÓN
// ============================================================================

= Introducción

== Historia
// Fuente: https://kotlinlang.org/lp/10yearsofkotlin/past/

- Lenguaje creado por *JetBrains*, empresa fundada en 2000 en Praga, conocida por desarrollar el IDE IntelliJ IDEA.

- El nombre viene de la *isla de Kotlin*, situada frente a San Petersburgo (Rusia).

- *Timeline:*
  - *2011:* Se hace público el proyecto Kotlin.
  - *2012:* Kotlin se libera como proyecto _open source_.
  - *2016:* Primera release estable: Kotlin 1.0.
  - *2017:* Google anuncia en la Google I/O que Kotlin será lenguaje oficial de Android.
  - *2019:* Google establece Kotlin como *lenguaje preferente* para Android.
  - *2020:* Kotlin 1.4 con interoperabilidad mejorada para iOS. Se lanza la Alpha del plugin _Kotlin Multiplatform Mobile_ (KMM).
  - *2024:* Kotlin 2.0 con nuevo compilador K2.

---

== ¿Por qué Kotlin?

- *Conciso:* Permite hacer más con menos código. Reduce el _boilerplate_ habitual en Java.

- *Seguro:* Sistema de tipos que previene errores de `null` en tiempo de compilación (_null safety_).

- *Interoperable con Java:* Se puede mezclar código Kotlin y Java en el mismo proyecto. Se pueden usar todas las librerías Java existentes.

- *Multiplataforma:* Kotlin se puede compilar para JVM, JavaScript y código nativo (iOS, Linux, Windows...).

- *Herramientas:* Integración total con Android Studio e IntelliJ IDEA.

== Ecosistema de Kotlin

- *Kotlin/JVM:* Compila a bytecode de la JVM. Uso principal: Android y backend.

- *Kotlin/JS:* Compila a JavaScript para ejecución en navegadores web.

- *Kotlin/Native:* Compila a código nativo sin necesidad de JVM. Permite crear aplicaciones para iOS, Linux, Windows, macOS...

- *Kotlin Multiplatform (KMP):* Permite compartir lógica de negocio entre plataformas (Android, iOS, web, escritorio) manteniendo UIs nativas.

- *Kotlin Script (`.kts`):* Versión simplificada para escribir ficheros de configuración Gradle (sustituyendo a Groovy).


// ============================================================================
// SECCIÓN 2: HELLO WORLD Y CONCEPTOS BÁSICOS
// ============================================================================

= Conceptos Básicos

== Hello World
// Fuente: https://kotlinlang.org/docs/kotlin-tour-hello-world.html

```kotlin
fun main() {
    println("¡Hola, mundo!")
}
```

- La función `main()` es el *punto de entrada* de una aplicación en Kotlin.
- `println()` escribe en la salida estándar (con salto de línea).
- *No se utilizan punto y coma* (`;`) al final de cada línea.
  - Si se utilizan, el IDE avisará con un _warning_.

---

== Paquetes, Imports y Comentarios
// Fuente: https://kotlinlang.org/docs/packages.html

```kotlin
package com.example.myapp  // Declaración de paquete

import kotlin.math.PI      // Import específico
import kotlin.math.*        // Import de todo el paquete
```

- Los *paquetes* organizan el código, como en Java.
- Si no se especifica paquete, el contenido irá al paquete por defecto.

#v(0.5em)

*Comentarios:*

```kotlin
// Comentario de una línea

/* Comentario
   de varias líneas */
```

== Recursos para Practicar

- Se puede probar código Kotlin directamente en el navegador, sin necesidad de instalar nada:

  #align(center)[
    #link("https://play.kotlinlang.org")[*Kotlin Playground* — play.kotlinlang.org]
  ]

- Ejercicios interactivos para aprender Kotlin paso a paso:

  #align(center)[
    #link("https://play.kotlinlang.org/koans/overview")[*Kotlin Koans* — play.kotlinlang.org/koans]
  ]

- Documentación oficial: #link("https://kotlinlang.org/docs/home.html")[kotlinlang.org/docs]

- Más recursos y referencias al final de las diapositivas.


// ============================================================================
// SECCIÓN 3: VARIABLES Y TIPOS
// ============================================================================

= Variables y Tipos

== Variables: `val` vs `var`
// Fuente: https://kotlinlang.org/docs/basic-syntax.html#variables

- En Kotlin, las variables se declaran con `val` o `var`:

```kotlin
val nombre = "Ana"    // Inmutable (no se puede reasignar)
var edad = 25         // Mutable (se puede reasignar)

edad = 26             // OK
nombre = "Luis"       // Error de compilación
```

- `val` = referencia inmutable (equivalente a `final` en Java). No se puede reasignar.
- `var` = referencia mutable. Se puede reasignar.

#v(0.5em)

#text(fill: rgb("#c0392b"), weight: "bold")[Se recomienda usar `val` siempre que sea posible.]

- Evita reasignaciones accidentales y hace el código más predecible.

---

== Objetos Inmutables vs Variables Inmutables
// Fuente: https://kotlinlang.org/docs/basic-syntax.html#variables

- #warning_symb `val` hace que la *referencia* sea inmutable, pero no el objeto en sí:

```kotlin
val persona = Persona(nombre = "Ana")
persona.nombre = "Luis"  // OK: se puede modificar la propiedad
persona = Persona(nombre = "Luis")  // Error: no se puede reasignar
```

- Esto es idéntico al comportamiento de `final` en Java.

== Inferencia de Tipos
// Fuente: https://kotlinlang.org/docs/basic-syntax.html#variables

- Kotlin tiene *inferencia de tipos*: el compilador deduce el tipo automáticamente.

```kotlin
val entero = 42           // Tipo inferido: Int
val texto = "Hola"        // Tipo inferido: String
val decimal = 3.14        // Tipo inferido: Double
```

- También se puede declarar el tipo explícitamente:

```kotlin
val entero: Int = 42
val texto: String = "Hola"
var sinValor: Int         // Error: debe inicializarse
```

- #warning_symb Las variables *siempre* deben inicializarse (con `val` o `var`).

== Tipos Básicos
// Fuente: https://kotlinlang.org/docs/types-overview.html

#v(0.5em)

Los tipos básicos en Kotlin son similares a Java, pero *siempre son objetos* (no hay tipos primitivos a nivel de lenguaje):

#v(0.5em)

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Tipo*], [*Tamaño*], [*Ejemplo*]),
    [`Int`], [32 bits], [`val x = 42`],
    [`Long`], [64 bits], [`val x = 42L`],
    [`Double`], [64 bits], [`val x = 3.14`],
    [`Float`], [32 bits], [`val x = 3.14F`],
    [`Boolean`], [---], [`val x = true`],
    [`Char`], [16 bits], [`val x = 'A'`],
    [`String`], [---], [`val x = "Hola"`],
  )
]

---

== Conversión de Tipos
// Fuente: https://kotlinlang.org/docs/numbers.html#explicit-number-conversions

- *No hay conversiones implícitas* entre tipos numéricos (a diferencia de Java):

```kotlin
val i: Int = 42
val d: Double = i          // Error de compilación
val d: Double = i.toDouble()  // Correcto
```

- Funciones de conversión disponibles: `toInt()`, `toLong()`, `toDouble()`, `toFloat()`, `toChar()`, `toString()`...

- Pistas al compilador para inferencia de tipos numéricos:

```kotlin
val entero = 42        // Int
val hexadecimal = 0x2A // Int (hexadecimal)
val largo = 42L        // Long
val decimal = 42.5     // Double
val flotante = 42.5F   // Float
```

== String Templates
// Fuente: https://kotlinlang.org/docs/strings.html#string-templates

- Kotlin permite *interpolar variables y expresiones* dentro de strings:

```kotlin
val nombre = "Kotlin"
val version = 2

println("Bienvenidos a $nombre")
// -> Bienvenidos a Kotlin

println("$nombre versión ${version * 1}")
// -> Kotlin versión 2

println("Longitud del nombre: ${nombre.length}")
// -> Longitud del nombre: 6
```

- `$variable` para variables simples.
- `${expresion}` para expresiones más complejas.
- Muy útil para debugging y generación dinámica de strings.


// ============================================================================
// SECCIÓN 4: COLECCIONES
// ============================================================================

= Colecciones

== Listas
// Fuente: https://kotlinlang.org/docs/collections-overview.html#list

- *Lista ordenada* de elementos. Permite duplicados.

```kotlin
// Lista de solo lectura
val frutas = listOf("manzana", "pera", "naranja")
println(frutas[0])          // manzana
println(frutas.size)        // 3
println("pera" in frutas)   // true

// Lista mutable
val numeros = mutableListOf(1, 2, 3)
numeros.add(4)
numeros.removeAt(0)
println(numeros)  // [2, 3, 4]
```

---

== Conjuntos (Sets)
// Fuente: https://kotlinlang.org/docs/collections-overview.html#set

- Colección de elementos *únicos* y sin orden garantizado.

```kotlin
// Set de solo lectura
val colores = setOf("rojo", "verde", "azul", "rojo")
println(colores)       // [rojo, verde, azul]
println(colores.size)  // 3

// Set mutable
val letras = mutableSetOf("a", "b")
letras.add("c")
letras.add("a")  // No se añade (ya existe)
println(letras)  // [a, b, c]
```

== Mapas
// Fuente: https://kotlinlang.org/docs/collections-overview.html#map

- Colección de *pares clave-valor*. Las claves son únicas.

```kotlin
// Mapa de solo lectura
val edades = mapOf("Ana" to 25, "Luis" to 30)
println(edades["Ana"])    // 25
println(edades.keys)      // [Ana, Luis]
println(edades.values)    // [25, 30]

// Mapa mutable
val notas = mutableMapOf("Ana" to 9.5)
notas["Luis"] = 8.0
notas.remove("Ana")
println(notas)  // {Luis=8.0}
```

== Colecciones: Read-Only vs Mutable
// Fuente: https://kotlinlang.org/docs/collections-overview.html#collection-types

- Kotlin distingue entre colecciones de *solo lectura* y *mutables*:

#align(center)[
  #table(
    columns: (auto, auto),
    inset: (x: 10pt),
    align: (left, left),
    table.header([*Solo lectura*], [*Mutable*]),
    [`listOf()`], [`mutableListOf()`],
    [`setOf()`], [`mutableSetOf()`],
    [`mapOf()`], [`mutableMapOf()`],
  )
]

- Siguiendo la filosofía de inmutabilidad de Kotlin, *se recomienda usar colecciones de solo lectura* siempre que sea posible.

- Las colecciones de solo lectura no tienen métodos como `add()`, `remove()`, etc.

- Las colecciones usan *genéricos* (como en Java): `List<String>`, `Map<String, Int>`, etc. Kotlin infiere el tipo genérico automáticamente:

```kotlin
val nombres = listOf("Ana", "Luis")  // List<String> (inferido)
val edades: Map<String, Int> = mapOf("Ana" to 25)  // explícito
```


// ============================================================================
// SECCIÓN 5: CONTROL DE FLUJO
// ============================================================================

= Control de Flujo

== `if` como Expresión
// Fuente: https://kotlinlang.org/docs/control-flow.html

- En Kotlin, `if` puede usarse como *expresión* que devuelve un valor:

```kotlin
// Uso clásico (como en Java)
if (x > 0) {
    println("Positivo")
} else if (x == 0) {
    println("Cero")
} else {
    println("Negativo")
}

// Como expresión (asignar resultado a una variable)
val resultado = if (x > 0) "Positivo" else "Negativo"
```

- Cuando se usa como expresión, la rama `else` es *obligatoria*.

== `when` --- Sustituto de `switch`
// Fuente: https://kotlinlang.org/docs/control-flow.html#when-expressions-and-statements

- `when` es mucho más potente que el `switch` de Java:

```kotlin
fun describe(obj: Any): String = when (obj) {
    1           -> "Uno"
    "Hello"     -> "Saludo"
    is Long     -> "Es un Long"
    !is String  -> "No es un String"
    else        -> "Desconocido"
}
```

- Soporta coincidencia con valores literales, comprobación de tipo (`is`), rangos (`in`), y más.
- Se puede usar como *expresión* (devuelve un valor).
- `else` es obligatorio cuando se usa como expresión.

---

== `when` sin Sujeto
// Fuente: https://kotlinlang.org/docs/control-flow.html#when-expressions-and-statements

- `when` también se puede usar *sin sujeto*, como alternativa a cadenas de `if-else`:

```kotlin
val temperatura = 35

val sensacion = when {
    temperatura < 0  -> "Helado"
    temperatura < 15 -> "Frío"
    temperatura < 25 -> "Agradable"
    temperatura < 35 -> "Calor"
    else             -> "Mucho calor"
}
```

== Rangos
// Fuente: https://kotlinlang.org/docs/ranges.html

- Kotlin tiene soporte nativo para *rangos*, que crean objetos `IntRange`, `LongRange`, `CharRange`, etc.:

```kotlin
val rango = 1..10       // IntRange: 1, 2, 3, ..., 10 (inclusive)
val rangoAbierto = 1..<10  // IntRange: 1, 2, ..., 9 (exclusive)

// Comprobar si un valor está en un rango
if (x in 1..100) {
    println("x está entre 1 y 100")
}

// Rangos descendentes y con paso
val desc = 10 downTo 1      // 10, 9, 8, ..., 1
val pares = 0..10 step 2    // 0, 2, 4, 6, 8, 10
```

== Bucles: `for`
// Fuente: https://kotlinlang.org/docs/control-flow.html#for-loops

- `for` itera sobre cualquier cosa que proporcione un iterador:

```kotlin
// Iterar sobre una colección
val frutas = listOf("manzana", "pera", "naranja")
for (fruta in frutas) {
    println("Me gusta la $fruta")
}

// Iterar sobre un rango
for (i in 1..5) {
    println(i)  // 1, 2, 3, 4, 5
}

// Con índice
for ((indice, fruta) in frutas.withIndex()) {
    println("$indice: $fruta")
}
```

---

== Bucles: `while` y `do-while`
// Fuente: https://kotlinlang.org/docs/control-flow.html#while-loops

- Funcionan igual que en Java:

```kotlin
var contador = 0

// while
while (contador < 5) {
    println(contador)
    contador++
}

// do-while (se ejecuta al menos una vez)
do {
    println(contador)
    contador--
} while (contador > 0)
```


// ============================================================================
// SECCIÓN 6: FUNCIONES
// ============================================================================

= Funciones

== Declaración de Funciones
// Fuente: https://kotlinlang.org/docs/functions.html

- Las funciones se declaran con la palabra clave `fun`:

```kotlin
fun saludar(nombre: String): String {
    return "Hola, $nombre!"
}
```

- Si una función no devuelve nada útil, su tipo de retorno es `Unit` (equivalente a `void` en Java), y se puede omitir:

```kotlin
fun imprimir(mensaje: String) {
    println(mensaje)
}

// Equivalente a:
fun imprimir(mensaje: String): Unit {
    println(mensaje)
}
```

== Funciones de una Sola Expresión
// Fuente: https://kotlinlang.org/docs/functions.html#single-expression-functions

- Si el cuerpo de una función es una sola expresión, se pueden omitir las llaves y el `return`:

```kotlin
fun cuadrado(x: Int): Int = x * x

// El tipo de retorno también se puede inferir:
fun cuadrado(x: Int) = x * x
```

#v(1em)

- Esto hace que las funciones simples sean muy concisas:

```kotlin
fun esPar(n: Int) = n % 2 == 0
fun maximo(a: Int, b: Int) = if (a > b) a else b
```

== Argumentos con Nombre y Valores por Defecto
// Fuente: https://kotlinlang.org/docs/functions.html#named-arguments
// Fuente: https://kotlinlang.org/docs/functions.html#parameters-with-default-values

- Se pueden especificar los *nombres de los argumentos* al llamar a una función:

```kotlin
fun crearUsuario(nombre: String, edad: Int, activo: Boolean) {
    // ...
}

crearUsuario(nombre = "Ana", edad = 25, activo = true)
crearUsuario(edad = 30, nombre = "Luis", activo = false)  // Otro orden
```

- Se pueden definir *valores por defecto* para los parámetros:

```kotlin
fun saludar(nombre: String, saludo: String = "Hola") {
    println("$saludo, $nombre!")
}

saludar("Ana")              // Hola, Ana!
saludar("Ana", "Buenos días")  // Buenos días, Ana!
```

---

== Varargs
// Fuente: https://kotlinlang.org/docs/functions.html#variable-number-of-arguments-varargs

- Con `vararg` se pueden pasar un *número variable de argumentos*:

```kotlin
fun imprimirTodo(vararg mensajes: String) {
    for (m in mensajes) println(m)
}

imprimirTodo("Hola", "Mundo", "!")

// Para pasar un array como vararg, se usa el operador *
val palabras = arrayOf("uno", "dos", "tres")
imprimirTodo(*palabras)
```

== Expresiones Lambda
// Fuente: https://kotlinlang.org/docs/lambdas.html

- Las *lambdas* son funciones anónimas que se pueden almacenar en variables y pasar como argumento:

```kotlin
// Lambda almacenada en una variable
val suma: (Int, Int) -> Int = { a, b -> a + b }
println(suma(3, 5))  // 8

// Lambda como argumento
val numeros = listOf(1, 2, 3, 4, 5)
val pares = numeros.filter { it % 2 == 0 }     // [2, 4]
val dobles = numeros.map { it * 2 }             // [2, 4, 6, 8, 10]
```

- `it` es el nombre implícito del parámetro cuando la lambda tiene un solo parámetro.

---

== Trailing Lambdas
// Fuente: https://kotlinlang.org/docs/lambdas.html#passing-trailing-lambdas

- Cuando el *último parámetro* de una función es una lambda, se puede sacar fuera de los paréntesis:

```kotlin
// Estas tres formas son equivalentes:
numeros.filter({ n -> n > 3 })
numeros.filter() { n -> n > 3 }
numeros.filter { n -> n > 3 }
```

---

*Comparación con Java*

Un listener en Java:
```java
view.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        Toast.makeText(v.getContext(), "Click", Toast.LENGTH_SHORT).show();
    }
});
```

En Kotlin, gracias a las lambdas:
```kotlin
view.setOnClickListener { toast("Click") }
```


// ============================================================================
// SECCIÓN 7: CLASES
// ============================================================================

= Clases

== Declaración de Clases
// Fuente: https://kotlinlang.org/docs/classes.html

- Una clase básica en Kotlin:

```kotlin
class Persona(val nombre: String, var edad: Int) {
    // Cuerpo de la clase

    fun presentarse() {
        println("Soy $nombre y tengo $edad años")
    }
}

val p = Persona("Ana", 25)
println(p.nombre)   // Ana (acceso directo a la propiedad)
p.edad = 26         // Modificable porque es var
p.presentarse()     // Soy Ana y tengo 26 años
```

- Las propiedades declaradas en el constructor (`val`/`var`) generan automáticamente _getters_ (y _setters_ si es `var`).
- No es necesario usar `new` para crear instancias.

---

== Contenido de una Clase
// Fuente: https://kotlinlang.org/docs/classes.html

```kotlin
class Persona(val nombre: String) {
    // Cuerpo de la clase
    var edad: Int = 0
}
```

El cuerpo de una clase `{ }` puede contener:

- *Propiedades* (`val`/`var`) y *funciones* miembro
- *Bloques `init`* --- inicialización del constructor primario
- *Constructores secundarios* (`constructor(...)`)
- *Clases anidadas* e *internas* (`inner class`)
- *`object` declarations* (singletons dentro de la clase)

---

== Constructor y Bloque `init`
// Fuente: https://kotlinlang.org/docs/classes.html#constructors-and-initializer-blocks

- El *constructor primario* se define en la cabecera de la clase.
- El bloque `init` es el *cuerpo del constructor primario* (se ejecuta *siempre* que se crea una instancia):

```kotlin
class Persona(val nombre: String, var edad: Int) {
    // Cuerpo de la clase con propiedad y bloque init
    val esMayorDeEdad: Boolean

    init {
        // Bloque de initialización -- se ejecuta cuando se crea una instancia
        require(edad >= 0) { "La edad no puede ser negativa" }
        esMayorDeEdad = edad >= 18
    }
}
```

---

== Constructores Secundarios
// Fuente: https://kotlinlang.org/docs/classes.html#constructors-and-initializer-blocks

#[
  #set text(size: 0.94em)
  - Los *constructores secundarios* deben delegar al primario con `this(...)`, y pueden tener su propio cuerpo:

  ```kotlin
  class Persona(val nombre: String, var edad: Int) {
      init { println("init: $nombre") }  // siempre se ejecuta

      constructor(nombre: String) : this(nombre, 0) {
          println("secundario")  // se ejecuta después del init
      }
  }

  Persona("Ana", 25)  // imprime: "init: Ana"
  Persona("Luis")      // imprime: "init: Luis" y luego "secundario"
  ```

  - En Kotlin idiomático, se prefiere usar *valores por defecto* en lugar de constructores secundarios:

  ```kotlin
  // Equivalente y más conciso:
  class Persona(val nombre: String, var edad: Int = 0)
  ```
]

== Propiedades: Custom Getters y Setters
// Fuente: https://kotlinlang.org/docs/properties.html

- Kotlin genera _getters_ y _setters_ automáticos, pero se pueden personalizar:

```kotlin
class Rectangulo(val ancho: Double, val alto: Double) {
    // Propiedad calculada (custom getter, sin backing field)
    val area: Double
        get() = ancho * alto
}

val r = Rectangulo(3.0, 4.0)
println(r.area)  // 12.0
```

---

== Propiedades: Custom Setters y `field`
// Fuente: https://kotlinlang.org/docs/properties.html#custom-getters-and-setters

- Para _setters_ personalizados se usa `field` para acceder al _backing field_ (el valor almacenado):

```kotlin
class Usuario(val nombre: String) {
    var email: String = ""
        set(value) {
            // field = el valor almacenado real de esta propiedad
            field = value.lowercase().trim()
        }
}

val u = Usuario("Ana")
u.email = "  ANA@Email.COM  "
println(u.email)  // ana@email.com
```

- #warning_symb Usar `this.email = ...` dentro del setter causaría recursión infinita. Por eso existe `field`.

== Data Classes
// Fuente: https://kotlinlang.org/docs/data-classes.html

- Las *data classes* generan automáticamente: `toString()`, `equals()`, `hashCode()`, `copy()`...

```kotlin
data class Persona(
    val nombre: String,
    var edad: Int
)

val p1 = Persona("Ana", 25)
val p2 = Persona("Ana", 25)
println(p1)           // Persona(nombre=Ana, edad=25)
println(p1 == p2)     // true (comparación por contenido)

val p3 = p1.copy(edad = 26)
println(p3)           // Persona(nombre=Ana, edad=26)
```


// == Data Class vs Java: Comparación

// *En Java* (o similar POJO), el equivalente requiere ~50 líneas:

// ```java
// public class Persona {
//     private String nombre;
//     private int edad;

//     public Persona(String nombre, int edad) { ... }
//     public String getNombre() { return nombre; }
//     public int getEdad() { return edad; }
//     public void setEdad(int edad) { this.edad = edad; }
//     @Override public String toString() { ... }
//     @Override public boolean equals(Object o) { ... }
//     @Override public int hashCode() { ... }
// }
// ```

// *En Kotlin*, una sola línea:
// ```kotlin
// data class Persona(val nombre: String, var edad: Int)
// ```

// Los _Java Records_ (Java 16+) se acercan, pero siguen siendo más limitados que las _data classes_ de Kotlin.


// ============================================================================
// SECCIÓN 8: HERENCIA DE CLASES
// ============================================================================

= Herencia e Interfaces

== Herencia de Clases
// Fuente: https://kotlinlang.org/docs/inheritance.html

#[
  #set text(size: 0.9em)

  - Por defecto, las clases en Kotlin son `final` (no se pueden extender).
  - Para permitir la herencia, hay que marcar la clase como `open`:

  ```kotlin
  open class Animal(val nombre: String) {
      open fun hablar() {
          println("...")
      }
  }

  class Perro(nombre: String) : Animal(nombre) {
      override fun hablar() {
          println("¡Guau!")
      }
  }

  val perro = Perro("Rex")
  perro.hablar()  // ¡Guau!
  ```

  - `open` en la clase y en los métodos que se quieran sobreescribir.
  - `override` es obligatorio al sobreescribir un método.
]

---

== Clases Abstractas
// Fuente: https://kotlinlang.org/docs/classes.html#abstract-classes

- Las clases abstractas no se pueden instanciar directamente:

```kotlin
abstract class Figura(val nombre: String) {
    abstract fun area(): Double   // Sin implementación

    fun describir() {             // Con implementación
        println("$nombre: área = ${area()}")
    }
}

class Circulo(val radio: Double) : Figura("Círculo") {
    override fun area() = Math.PI * radio * radio
}

val c = Circulo(5.0)
c.describir()  // Círculo: área = 78.53981633974483
```

== Interfaces
// Fuente: https://kotlinlang.org/docs/interfaces.html

- Las interfaces se declaran de forma similar a Java, pero pueden incluir *implementaciones por defecto*:

```kotlin
interface Dibujable {
    fun dibujar()               // Abstracto
    fun descripcion(): String {  // Con implementación por defecto
        return "Soy dibujable"
    }
}

class Cuadrado(val lado: Double) : Figura("Cuadrado"), Dibujable {
    override fun area() = lado * lado
    override fun dibujar() {
        println("Dibujando cuadrado de lado $lado")
    }
}
```

- Una clase puede implementar *múltiples interfaces* pero solo heredar de *una clase*.

== Modificadores de Visibilidad
// Fuente: https://kotlinlang.org/docs/visibility-modifiers.html

#v(0.5em)

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Modificador*], [*Kotlin*], [*Java equivalente*]),
    [`public`], [Visible en todas partes *(por defecto)*], [`public`],
    [`private`], [Visible solo en el fichero/clase], [`private`],
    [`protected`], [Visible en la clase y subclases], [`protected`],
    [`internal`], [Visible dentro del mismo módulo], [_(no existe)_],
  )
]

#v(0.5em)

- En Kotlin, el modificador por defecto es *`public`* (en Java es _package-private_).
- `internal` reemplaza al concepto de _package-private_ de Java, pero opera a nivel de *módulo* (e.g., un módulo Gradle).


// ============================================================================
// SECCIÓN 9: NULL SAFETY
// ============================================================================

= Null Safety

== El Problema del Null
// Fuente: https://kotlinlang.org/docs/null-safety.html

#v(0.5em)

#block(
  fill: luma(94%),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  _"I call it my billion-dollar mistake... I couldn't resist the temptation to put in a null reference, simply because it was so easy to implement. This has led to innumerable errors, vulnerabilities, and system crashes."_ \
  #h(1fr) --- *Tony Hoare*, inventor of ALGOL W
]

#v(0.5em)

- En Java, los `NullPointerException` son una fuente constante de errores.
- Kotlin aborda este problema con su *sistema de tipos null-safe*: el compilador detecta posibles errores de null en *tiempo de compilación*.

---

== Tipos Nullable vs Non-Nullable
// Fuente: https://kotlinlang.org/docs/null-safety.html#nullable-types-and-non-nullable-types

- Por defecto, las variables *no pueden ser null*:

```kotlin
var nombre: String = "Ana"
nombre = null  // Error de compilación
```

- Para permitir null, se usa el operador `?`:

```kotlin
var nombre: String? = "Ana"
nombre = null  // OK
```

- #warning_symb Al usar un tipo nullable, el compilador *obliga a manejar* el posible null antes de acceder a sus miembros:

```kotlin
var nombre: String? = null
println(nombre.length)  // Error: nombre puede ser null
```

== Safe Call (`?.`)
// Fuente: https://kotlinlang.org/docs/null-safety.html#safe-call-operator

- El operador *safe call* (`?.`) accede a un miembro solo si el objeto no es null. Si es null, devuelve null:

```kotlin
val nombre: String? = null

println(nombre?.length)      // null (no lanza excepción)
println(nombre?.uppercase()) // null
```

- Se puede encadenar:

```kotlin
val ciudad: String? = usuario?.direccion?.ciudad
```

== Operador Elvis (`?:`)
// Fuente: https://kotlinlang.org/docs/null-safety.html#elvis-operator

- El operador *Elvis* (`?:`) proporciona un *valor por defecto* cuando la expresión es null:

```kotlin
val nombre: String? = null
val longitud = nombre?.length ?: 0
println(longitud)  // 0

// Equivalente a:
val longitud = if (nombre != null) nombre.length else 0
```

- También se puede usar con `return` o `throw`:

```kotlin
fun obtenerNombre(usuario: Usuario?): String {
    return usuario?.nombre ?: throw IllegalArgumentException("Sin usuario")
}
```

---

== Non-Null Assertion (`!!`)
// Fuente: https://kotlinlang.org/docs/null-safety.html#not-null-assertion-operator

- El operador `!!` *fuerza* el acceso sin verificar null. Si el valor es null, lanza una excepción:

```kotlin
val nombre: String? = "Ana"
println(nombre!!.length)  // 3
```

#v(0.5em)

- #warning_symb *Usar con mucha precaución.* Si el valor es null, se lanzará un `NullPointerException`:

```kotlin
val nombre: String? = null
println(nombre!!.length)  // NullPointerException
```

- Se recomienda usar `?.` con `?:` en lugar de `!!` siempre que sea posible.

== Smart Casts
// Fuente: hthttps://kotlinlang.org/docs/typecasts.html#smart-casts

- Kotlin realiza *smart casts*: después de comprobar que un valor no es null, se puede usar directamente sin operadores especiales:

```kotlin
val nombre: String? = "Ana"

if (nombre != null) {
    // Aquí, nombre es automáticamente String (no String?)
    println(nombre.length)  // OK, sin necesidad de ?.
}
```

- También funciona con comprobaciones de tipo (`is`):

```kotlin
fun describir(x: Any): String = when (x) {
    is String -> "String de longitud ${x.length}"  // Smart cast a String
    is Int    -> "Entero con valor $x"
    else      -> "Otro tipo"
}
```


// ============================================================================
// SECCIÓN 10: OPERADORES DE IGUALDAD
// ============================================================================

== Operadores de Igualdad
// Fuente: https://kotlinlang.org/docs/equality.html

- Kotlin tiene *dos operadores de comparación*:

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Operador*], [*Significado*], [*Java equivalente*]),
    [`==`], [Igualdad *estructural* (contenido)], [`.equals()`],
    [`===`], [Igualdad *referencial* (misma instancia)], [`==`],
  )
]

```kotlin
val set1 = setOf("a", "b", "c")
val set2 = setOf("c", "b", "a")

println(set1 == set2)   // true  (mismos elementos)
println(set1 === set2)  // false (objetos distintos)
```

- #warning_symb Cuidado: en Java `==` compara referencias. En Kotlin `==` compara *contenido*.


// ============================================================================
// APÉNDICE
// ============================================================================

#show: ty.appendix

= Apéndice

== Clases Sealed
// Fuente: https://kotlinlang.org/docs/sealed-classes.html

- Las *sealed classes* restringen la jerarquía de herencia a un conjunto conocido de subtipos:

```kotlin
sealed class Resultado {
    data class Exito(val datos: String) : Resultado()
    data class Error(val mensaje: String) : Resultado()
    data object Cargando : Resultado()
}

fun manejar(r: Resultado) = when (r) {
    is Resultado.Exito    -> println("Datos: ${r.datos}")
    is Resultado.Error    -> println("Error: ${r.mensaje}")
    is Resultado.Cargando -> println("Cargando...")
    // No necesita 'else' porque el compilador sabe que
    // son todos los casos posibles
}
```

- Muy útil para modelar estados y resultados.

---

== Enum Classes
// Fuente: https://kotlinlang.org/docs/enum-classes.html

#[
  #set text(0.85em)

  - Las *enum classes* definen un conjunto fijo de constantes:
    ```kotlin
    enum class Color(val rgb: Int) {
        ROJO(0xFF0000),
        VERDE(0x00FF00),
        AZUL(0x0000FF);

        fun esCalido() = this == ROJO
    }

    val color = Color.ROJO
    println(color.rgb)         // 16711680
    println(color.esCalido())  // true
    ```

  - Con `when`, el compilador verifica que se cubran *todos* los valores (no necesita `else`):

    ```kotlin
    fun describir(color: Color) = when (color) {
        Color.ROJO  -> "Rojo"
        Color.VERDE -> "Verde"
        Color.AZUL  -> "Azul"
    }
    ```
]

== Object Declarations (Singleton)
// Fuente: https://kotlinlang.org/docs/object-declarations.html

- La palabra clave `object` crea un *singleton* (una clase con una única instancia, creada automáticamente).
- Se usa para configuración global, utilidades, o implementar interfaces con una sola instancia:

```kotlin
object Configuracion {
    var idioma = "es"
    var modoOscuro = false

    fun resumen() = "Idioma: $idioma, Oscuro: $modoOscuro"
}

Configuracion.idioma = "en"
println(Configuracion.resumen())  // Idioma: en, Oscuro: false
```

- En Java se implementaría manualmente con un constructor privado e instancia estática.

---

== Companion Objects
// Fuente: https://kotlinlang.org/docs/object-declarations.html#companion-objects

- Los *companion objects* definen miembros asociados a la clase, no a una instancia. Es lo más parecido a `static` en Java:

```kotlin
class Temperatura(val grados: Double) {

    companion object {
        fun desdeFahrenheit(f: Double): Temperatura {
            return Temperatura((f - 32) * 5 / 9)
        }
    }
}

val t = Temperatura.desdeFahrenheit(98.6)
println(t.grados)  // 37.0
```

- Se acceden a través del nombre de la clase, sin necesidad de crear una instancia.

== Genéricos
// Fuente: https://kotlinlang.org/docs/generics.html

- Kotlin soporta *genéricos*, similares a los de Java, para crear clases y funciones que operan sobre tipos parametrizados:

```kotlin
// Clase genérica
class Caja<T>(val contenido: T) {
    fun obtener(): T = contenido
}

val cajaString = Caja("Hola")   // Caja<String> (inferido)
val cajaInt = Caja(42)           // Caja<Int> (inferido)
println(cajaString.obtener())    // Hola
```

---

== Funciones Genéricas
// Fuente: https://kotlinlang.org/docs/generics.html

- Las funciones también pueden tener parámetros de tipo:

```kotlin
fun <T> intercambiar(a: T, b: T): Pair<T, T> {
    return Pair(b, a)
}

val resultado = intercambiar("Hola", "Mundo")
println(resultado)  // (Mundo, Hola)
```

- Se puede restringir el tipo con *upper bounds* (similar a `<T extends ...>` en Java):

```kotlin
fun <T : Comparable<T>> maximo(a: T, b: T): T {
    return if (a > b) a else b
}

println(maximo(3, 7))        // 7
println(maximo("abc", "xyz")) // xyz
```

---

== Varianza: `in` y `out`
// Fuente: https://kotlinlang.org/docs/generics.html#variance

- Kotlin hace explícita la *varianza* de los genéricos con `in` y `out`:

#align(center)[
  #table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, left, left),
    table.header([*Kotlin*], [*Java equivalente*], [*Uso*]),
    [`out T`], [`? extends T`], [Solo se produce/devuelve `T`],
    [`in T`], [`? super T`], [Solo se consume/recibe `T`],
  )
]

```kotlin
// out: la interfaz solo produce valores de tipo T
interface Fuente<out T> {
    fun obtener(): T
}

// in: la interfaz solo consume valores de tipo T
interface Destino<in T> {
    fun enviar(valor: T)
}
```

- Esto permite que `Fuente<String>` sea subtipo de `Fuente<Any>` (_covarianza_).

== Extension Functions
// Fuente: https://kotlinlang.org/docs/extensions.html

- Las *funciones de extensión* permiten añadir nuevas funciones a clases existentes sin modificar su código fuente:

```kotlin
fun String.palabras(): Int {
    return this.trim().split("\\s+".toRegex()).size
}

println("Hola mundo Kotlin".palabras())  // 3
```

- Equivalen a las clases _Util_ que se crean en Java, pero con una sintaxis más natural.

---

== Extension Properties
// Fuente: https://kotlinlang.org/docs/extensions.html#extension-properties

- De forma similar, se pueden añadir *propiedades de extensión*:

```kotlin
val String.primeraLetra: Char
    get() = this[0]

println("Kotlin".primeraLetra)  // K
```

- Las _extension properties_ no pueden tener _backing field_, solo _custom getters_.

== Scope Functions: `let`, `apply`, `run`, `also`, `with`
// Fuente: https://kotlinlang.org/docs/scope-functions.html

Las _scope functions_ crean un ámbito temporal para operar sobre un objeto:

#v(0.3em)

#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 6pt,
    align: (left, left, left, left),
    table.header([*Función*], [*Referencia*], [*Retorno*], [*Uso típico*]),
    [`let`], [`it`], [resultado lambda], [null checks, transformar],
    [`apply`], [`this`], [el objeto], [configurar objeto],
    [`run`], [`this`], [resultado lambda], [ejecutar bloque],
    [`also`], [`it`], [el objeto], [logging, side effects],
    [`with`], [`this`], [resultado lambda], [agrupar llamadas],
  )
]

---

== Scope Functions: Ejemplos
// Fuente: https://kotlinlang.org/docs/scope-functions.html

```kotlin
// let: comúnmente usado para null checks
val nombre: String? = "Ana"
nombre?.let {
    println("Nombre no nulo: $it")
}

// apply: configurar un objeto
val persona = Persona("Ana", 25).apply {
    edad = 26
}

// also: efectos secundarios (logging, debug)
val numeros = mutableListOf(1, 2, 3)
    .also { println("Lista antes: $it") }
    .apply { add(4) }
    .also { println("Lista después: $it") }
```

== Excepciones
// Fuente: https://kotlinlang.org/docs/exceptions.html

- Las excepciones en Kotlin funcionan de forma casi idéntica a Java:

```kotlin
throw IOException("Error de lectura")

try {
    // Código que puede lanzar excepción
} catch (e: IOException) {
    // Manejar excepción
} finally {
    // Se ejecuta siempre
}
```

- Diferencia importante: en Kotlin *no existen checked exceptions*. No es obligatorio declarar ni capturar excepciones.

---

== Recursos y Documentación

*Practicar Kotlin:*
- Kotlin Playground: #link("https://play.kotlinlang.org")
- Tour oficial de Kotlin: #link("https://kotlinlang.org/docs/kotlin-tour-welcome.html")
- Kotlin Koans (ejercicios interactivos): #link("https://play.kotlinlang.org/koans/overview")

*Documentación oficial:*
- Documentación de Kotlin: #link("https://kotlinlang.org/docs/home.html")
- Kotlin para Android: #link("https://developer.android.com/kotlin")
- Kotlin style guide: #link("https://developer.android.com/kotlin/style-guide")

---

*Video tutoriales:*
- "Kotlin Course - Tutorial for Beginners" (freeCodeCamp.org): #link("https://www.youtube.com/watch?v=F9UC9DY-vIU")
- "Learn Kotlin Programming - Full Course for Beginners" (freeCodeCamp.org): #link("https://www.youtube.com/watch?v=EExSSotojVI")

*IDEs:*
- Android Studio: #link("https://developer.android.com/studio")
- IntelliJ IDEA: #link("https://www.jetbrains.com/idea/")

== Ejercicios: Kotlin Koans

- *Kotlin Koans* es una serie de ejercicios interactivos para practicar Kotlin.

- Cada ejercicio es un test unitario que falla hasta que se resuelve correctamente.

- Se pueden hacer:
  - *Online:* #link("https://play.kotlinlang.org/koans/overview")
  - *En el IDE:* Instalando el plugin _JetBrains Academy_ en Android Studio o IntelliJ.

- Cubren desde los fundamentos hasta temas avanzados como generics, builders y operadores.
