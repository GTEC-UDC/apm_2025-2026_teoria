# Complete Presentation Example

This example demonstrates a full presentation using the Touying GTEC-Simple theme.

````typst
#import "@local/touying-gtec-simple:0.0.1": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Introduction to Algorithms],
    author: [Professor Smith],
    date: datetime.today(),
  ),
)

#title-slide(
  header: [Computer Science \ 101: Algorithms and Data Structures]
)

#outline-slide()

= Introduction

== What are Algorithms?

An algorithm is a step-by-step procedure for solving a problem.

*Key properties:*
- Finite steps
- Well-defined inputs and outputs
- Deterministic
- Can be implemented in any programming language

= Sorting Algorithms

#side-shape-slide(
  shape-body: shape-title([Bubble Sort], subtitle: [Simple but slow]),
  edge: "wave",
)[
  Basic approach:
  - Compare adjacent elements
  - Swap if in wrong order
  - Repeat until sorted

  Time complexity: $O(n^2)$
]

== Implementation

```python
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n-i-1):
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
```

#focus-slide[
  Practice Time!
]

#show: ty.appendix

= References

== Additional Resources

- Textbook: "Introduction to Algorithms"
- Online: algorithm visualizations
````
