---
name: touying-gtec-simple
description: Guide for creating presentation slides using the Touying GTEC-Simple theme in Typst. Use when working with Typst presentations, creating slides, or when the user mentions Touying, GTEC-Simple theme, or presentation slides.
---

# Touying GTEC-Simple Theme

A Typst Touying theme designed for the GTEC group at the University of A Coruña, based on the Metropolis theme with custom enhancements.

## Quick Start

Every presentation starts with theme initialization:

```typst
#import "@local/touying-gtec-simple:0.0.1": *

#show: gtec-simple-theme.with(
  aspect-ratio: "16-9",
  ty.config-info(
    title: [Your Presentation Title],
    author: [Your Name],
    date: datetime.today(),
  ),
)

#title-slide(
  header: [Your Degree \ Your Subject],
  footer: auto,  // auto (university logo), none, or custom content
)

// Your slides here
```

## Installation

**Local package:**

```typst
#import "@local/touying-gtec-simple:0.0.1": *
```

**Local import:**

```typst
#import "path/to/touying-gtec-simple/src/lib.typ": *
```

## Slide Types Reference

### Title Slide

```typst
#title-slide(
  header: [Degree in Computer Science \ Data Structures Course]
)
```

### Regular Content Slides

Use level 2 headings (`==`):

```typst
== My Slide Title

Content with:
- Bullet points
- *Bold text*
- _Italic text_
- #highlight[highlighted text]
```

### Section Slides

Use level 1 headings (`=`):

```typst
= Section Title

== First Slide in Section
Content here...
```

### Outline Slides

**Basic:**

```typst
#outline-slide()
```

**Customized:**

```typst
#outline-slide(
  title: [Contents],
  outline-args: (depth: 1),  // Only level 1 headings
  column: 2                  // Two-column layout
)
```

**With side image:**

```typst
#outline-image-slide(
  title: [Contents],
  image: image("path/to/image.png", height: 100%, fit: "cover"),
  side: left,             // left, right, top, or bottom
  image-width: 35%,
  outline-args: (depth: 1)
)
```

### Focus Slides

Large centered text for emphasis:

```typst
#focus-slide[
  Important Announcement!
  
  This grabs attention.
]
```

### Slides with Side Image

To place an image on the side of a slide, use a regular slide with a two-column grid.

**Example with image on the right:**

```typst
== My Slide Title

#grid(
  columns: (1fr, 35%),
  column-gutter: 1em,
  align: horizon,
  [
    Content here
  ],
  image("path/to/image.png", width: 100%),
)
```

Adjust the first value in `columns` to control the image width. Use `align: top` instead of `align: horizon` to align content to the top.

### Colored Highlight Blocks

Use `#block()` to visually highlight a quote or important information:

```typst
#block(
  fill: luma(95%),
  inset: 12pt,
  radius: 5pt,
  width: 100%,
)[
  _"I call it my billion-dollar mistake..."_ \
  #h(1fr) --- *Tony Hoare*, inventor of ALGOL W
]
```

Common fill colors:
- `luma(95%)` — light gray (neutral, general use)
- `#fff2df` — yellow/beige (warmer, good for quotes or warnings)

**Note:** Use sparingly — too many colored blocks make slides feel cluttered.

### Shaped Slides

Colored panel with optional decorative edge:

```typst
#side-shape-slide(
  shape-body: shape-title([Main Title], subtitle: [Subtitle Text]),
  shape-fill: rgb("#d4c5b0"),
  side: left,
  shape-width: 35%,
  edge: "wave",  // "wave", "zigzag", "round", or none
)[
  Content on the other side
]
```

#### Shape Body Options

The `shape-body` parameter accepts any Typst content.

**Using shape-title() helper:**

```typst
shape-body: shape-title(
  [Main Title],
  subtitle: [Subtitle],
  spacing: 2em,
  align: left + horizon,
  inset: (x: 1.5em, y: 2em),
)
```

**Custom content:**

```typst
// Just text
shape-body: [Any content here]

// An image
shape-body: image("logo.png", width: 80%)

// A styled block
shape-body: block(
  inset: 2em,
  align(center + horizon)[
    #text(size: 2em, weight: "bold")[Custom Content]
    #v(1em)
    #image("icon.png", width: 50%)
  ]
)
```

#### Custom Colors and Strokes

```typst
#side-shape-slide(
  shape-body: shape-title([Title]),
  shape-fill: rgb("#326e76"),
  shape-stroke: 3pt + black,
  config: ty.config-page(fill: aqua),
  edge: "wave",
)[
  Content here
]
```

## Advanced Customization

### Subtitles

Add subtitles using `#slide()`:

```typst
#slide(
  subtitle: [Additional Context],
)[
  == My Slide Title
  
  Content here
]
```

### Custom Alignment

```typst
#slide(
  align: left + top,
)[
  == Title
  
  Content aligned to top-left
]
```

## Appendix Slides

Slides after appendix show only current page numbers:

```typst
#show: ty.appendix

= Appendix

== Extra Information
This slide shows only its page number, not the total count.
```

## Best Practices

1. **Keep titles concise** - Short titles are more readable
2. **Use subtitles for context** - Provide additional information when needed
3. **Use edge decorations sparingly** - Shaped slides with decorative edges (wave, zigzag, round) are visually striking but can distract if overused. Reserve them for:
   - Key concept slides
   - Special emphasis moments
   - Use plain slides for regular content

## Complete Example

See [example.md](example.md) for a full presentation example.
