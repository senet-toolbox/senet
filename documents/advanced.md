{#vapor-advanced-components}

# Vapor Advanced Components Reference

#### Deep-dive into Tables, Forms, Headings, Draggable, Anchors, and other components beyond the cheat sheet basics.

---

{#tables}

## Tables

Vapor provides a full set of semantic table components: `Table`, `TableHead`, `TableHeader`, `TableBody`, `TableRow`, and `TableCell`.

### Basic Table

```zig
const Table = Vapor.Table;
const TableHead = Vapor.TableHead;
const TableHeader = Vapor.TableHeader;
const TableBody = Vapor.TableBody;
const TableRow = Vapor.TableRow;
const TableCell = Vapor.TableCell;

fn render() void {
    Table().width(.percent(100)).children({
        // Table header row
        TableHead().children({
            TableRow().children({
                TableHeader().children({ Text("Name").bold().end(); });
                TableHeader().children({ Text("Email").bold().end(); });
                TableHeader().children({ Text("Role").bold().end(); });
            });
        });

        // Table body
        TableBody().children({
            for (users) |user| {
                TableRow().children({
                    TableCell().children({ Text(user.name).end(); });
                    TableCell().children({ Text(user.email).end(); });
                    TableCell().children({ Text(user.role).end(); });
                });
            }
        });
    });
}
```

### Styled Table

```zig
const table_style = Vapor.Style{
    .size = .{ .width = .percent(100) },
    .visual = .{
        .border = .simple(.palette(.border_color)),
    },
};

const header_cell_style = Vapor.Style{
    .padding = .tblr(12, 12, 16, 16),
    .visual = .{
        .background = .palette(.surface),
        .font_weight = 600,
        .font_size = 14,
        .text_color = .palette(.text_color),
        .border = .bottom(.palette(.border_color)),
    },
};

const body_cell_style = Vapor.Style{
    .padding = .tblr(10, 10, 16, 16),
    .visual = .{
        .border = .bottom(.palette(.border_color)),
        .font_size = 14,
    },
};

fn render() void {
    Table().style(&table_style).children({
        TableHead().children({
            TableRow().children({
                TableHeader().style(&header_cell_style).children({
                    Text("Name").end();
                });
                TableHeader().style(&header_cell_style).children({
                    Text("Status").end();
                });
            });
        });

        TableBody().children({
            for (items) |item| {
                TableRow()
                    .hoverBackground(.palette(.surface))
                    .duration(150)
                    .children({
                        TableCell().style(&body_cell_style).children({
                            Text(item.name).end();
                        });
                        TableCell().style(&body_cell_style).children({
                            Text(item.status).end();
                        });
                    });
            }
        });
    });
}
```

---

{#headings}

## Headings

The `Heading` component renders semantic HTML heading elements (`<h1>` through `<h6>`). Use these for document structure and accessibility — screen readers use heading levels for navigation.

```zig
const Heading = Vapor.Heading;

// Heading levels 1–6
Heading(1, "Page Title")
    .font(32, 700, .palette(.text_color))
    .end();

Heading(2, "Section Title")
    .font(24, 600, .palette(.text_color))
    .mb(16)
    .end();

Heading(3, "Subsection")
    .font(18, 600, .palette(.text_color))
    .end();

// With full styling chain
Heading(1, "Welcome")
    .fontFamily("Montserrat")
    .textColor(.palette(.tint))
    .padding(.bottom(12))
    .end();
```

> **Note:** There is also a legacy `Header` function with predefined sizes (XXLarge, XLarge, Large, Medium, Small). Prefer `Heading` for semantic correctness.

---

{#forms-advanced}

## Forms (Advanced)

The `Form` component provides submit handling. Unlike `Button`, `Form` takes both a handler and arguments at construction time.

### Form with Submit Handler

```zig
const Form = Vapor.Form;

var username: []const u8 = "";
var password: []const u8 = "";

fn handleSubmit(form_id: u32) void {
    // Validate and submit
    if (username.len == 0 or password.len == 0) return;
    Api.login(username, password);
}

fn render() void {
    Form(handleSubmit, .{@as(u32, 1)})
        .direction(.column)
        .spacing(12)
        .padding(.all(24))
        .children({
            TextField(.string)
                .bind(&username)
                .fieldName("username")
                .placeholder("Username")
                .width(.percent(100))
                .end();

            TextField(.password)
                .bind(&password)
                .fieldName("password")
                .placeholder("Password")
                .width(.percent(100))
                .end();

            Button(doNothing)
                .padding(.tblr(12, 12, 24, 24))
                .background(.palette(.tint))
                .children({
                    Text("Log In").font(16, 600, .white).end();
                });
        });
}
```

### Field Names

Use `.fieldName()` on TextFields within a Form to assign semantic field names:

```zig
TextField(.email)
    .bind(&email)
    .fieldName("email")
    .end();

TextField(.string)
    .bind(&phone)
    .fieldName("phone")
    .end();
```

---

{#code-component}

## Code

The `Code` component renders text with monospace/code styling. It accepts strings and numeric types.

```zig
const Code = Vapor.Code;

Code("const x = 42;").end();
Code(404).end();

// Styled
Code("npm install vapor")
    .padding(.tblr(4, 4, 8, 8))
    .background(.palette(.surface))
    .border(.round(.palette(.border_color), .all(4)))
    .fontSize(14)
    .end();
```

---

{#draggable}

## Draggable Elements

Vapor includes a `Draggable` system for building drag-and-drop interactions. You bind a `Draggable` instance to a component, and it handles pointer events and position tracking.

### Basic Draggable

```zig
const Draggable = Vapor.Draggable;

var drag_handle: Draggable = .{};

fn render() void {
    Box()
        .ref(&drag_handle.element)
        .createDraggable(&drag_handle)
        .width(.px(100))
        .height(.px(100))
        .background(.palette(.tint))
        .cursor(.grab)
        .children({
            Text("Drag me").end();
        });
}
```

### Drag Events

```zig
Box()
    .onDragStart(handleDragStart)
    .children({
        Text("Draggable item").end();
    });

fn handleDragStart(evt: *Vapor.Event) void {
    // Pointer down — drag initiated
    std.log.debug("Drag started", .{});
}
```

---

{#anchors-and-positioning}

## Anchors & Positioned Elements

Anchors allow you to position elements relative to other elements (tooltips, popovers, dropdowns). The system uses an anchor name to link a source element to a positioned target.

### Anchor Pattern

```zig
const anchor_name = "tooltip-anchor";

fn render() void {
    // The anchor target — positions itself relative to the source
    Anchor(anchor_name)
        .anchorPlacement(.top)
        .padding(.all(8))
        .background(.palette(.surface))
        .border(.round(.palette(.border_color), .all(8)))
        .shadow(.card(.transparentize(.black, 0.1)))
        .children({
            Text("Tooltip content here").fontSize(12).end();
        });

    // The anchor source — the element being "pointed at"
    Box()
        .anchorSource(anchor_name)
        .onEventCtx(.pointerenter, showTooltip, .{})
        .onEventCtx(.pointerleave, hideTooltip, .{})
        .children({
            Text("Hover me").end();
        });
}
```

### Anchor Placement Options

| Placement | Description                        |
| --------- | ---------------------------------- |
| `.top`    | Above the source element           |
| `.bottom` | Below the source element           |
| `.left`   | To the left of the source element  |
| `.right`  | To the right of the source element |

---

{#element-ids-and-classes}

## Element IDs & CSS Classes

### Custom IDs

Use `.id()` to assign a unique identifier to an element. This is used for `ariaControls`, `scrollIntoView`, and DOM queries.

```zig
Box()
    .id("main-content")
    .children({
        // ...
    });

// Later
Vapor.scrollIntoView("main-content", .{ .block = .start });
```

### CSS Classes

Use `.class()` or `.classFmt()` to assign CSS class names for external stylesheet integration or theme targeting.

```zig
Box()
    .class("card-container")
    .children({ /* ... */ });

// Dynamic class name
Box()
    .classFmt("item-{d}", .{index})
    .children({ /* ... */ });
```

---

{#inline-styles}

## Inline Styles

For cases where you need to emit raw CSS (e.g., CSS properties not yet in Vapor's type system), use `.inlineStyle()` or `.inlineStyleStr()`.

```zig
// Formatted inline style
Box()
    .inlineStyle("grid-template-columns: repeat({d}, 1fr)", .{column_count})
    .children({ /* ... */ });

// Static inline style string
Box()
    .inlineStyleStr("clip-path: circle(50%)")
    .children({ /* ... */ });
```

> **Note:** Prefer Vapor's typed style API when possible. Inline styles bypass the virtual DOM diffing and may have performance implications.

---

{#style-inheritance}

## Style Inheritance

### inherit

Use `.inherit()` to specify which style fields should be inherited from the parent's computed style.

```zig
Text("Inherited color")
    .inherit(&.{ .text_color, .font_size })
    .end();
```

### inheritHover

Same as `.inherit()` but applies to the element's hover state, pulling from the parent's hover styles.

```zig
Box()
    .inheritHover(&.{ .background, .text_color })
    .children({ /* ... */ });
```

---

{#visual-effects}

## Visual Effects

### Opacity

```zig
Box()
    .opacity(0.5)
    .children({ /* ... */ });

// Disabled state pattern
Button(action)
    .opacity(if (disabled) 0.4 else 1.0)
    .cursor(if (disabled) .default else .pointer)
    .children({
        Text("Submit").end();
    });
```

### Blur

```zig
// Frosted glass effect
Box()
    .blur(10)
    .background(.transparentize(.white, 0.2))
    .children({ /* ... */ });
```

### Transform & Scale

```zig
// Static scale
Icon(.arrow)
    .scale(1.5)
    .end();

// Arbitrary transform
Box()
    .transform(.scaleDecimal(0.95))
    .children({ /* ... */ });

// Transform origin for animations
Box()
    .transformOrigin(.{ .x = .center, .y = .top })
    .children({ /* ... */ });
```

### Outline

```zig
// Focus ring pattern
TextField(.string)
    .bind(&text)
    .outline(.{ .color = .palette(.tint), .width = 2, .offset = 2 })
    .end();
```

---

{#columns}

## Multi-Column Layout

Use `.columns()` to set a CSS multi-column layout on a container.

```zig
Box()
    .columns(3)
    .spacing(16)
    .children({
        for (articles) |article| {
            Box().padding(.all(12)).children({
                Text(article.title).bold().end();
                Text(article.excerpt).end();
            });
        }
    });
```

---

{#aspect-ratio}

## Aspect Ratio

Lock an element to a specific aspect ratio.

```zig
Image(.{ .src = "/hero.jpg" })
    .aspectRatio(.{ .width = 16, .height = 9 })
    .width(.percent(100))
    .end();

// Square
Box()
    .aspectRatio(.{ .width = 1, .height = 1 })
    .width(.px(200))
    .background(.palette(.surface))
    .children({ /* ... */ });
```

---

{#edges}

## Edges

The `.edges()` method applies a named edge style (defined in your theme or style system).

```zig
Box()
    .edges("card-edges")
    .children({ /* ... */ });
```

---

{#hidden-elements}

## Conditional Visibility

Use `.hidden()` to set `display: none` on an element based on a condition. Unlike conditional rendering with `if`, `.hidden()` keeps the element in the tree (preserving sibling IDs).

```zig
Box()
    .hidden(should_hide)
    .children({
        Text("This may be hidden").end();
    });
```

Compare with:

```zig
// Conditional rendering — removes element from tree
if (!should_hide) {
    Box().children({
        Text("Conditionally rendered").end();
    });
}
```

---

{#white-space}

## White Space Control

Control how whitespace is handled in text elements.

```zig
Text(code_snippet)
    .whiteSpace(.pre)
    .fontFamily("monospace")
    .end();

Text(long_paragraph)
    .whiteSpace(.normal)
    .end();
```

| Value      | Behavior                                         |
| ---------- | ------------------------------------------------ |
| `.normal`  | Collapses whitespace, wraps text (default)       |
| `.nowrap`  | Collapses whitespace, no wrapping                |
| `.pre`     | Preserves whitespace and line breaks             |
| `.pre_wrap`| Preserves whitespace, allows wrapping            |
| `.pre_line`| Collapses spaces, preserves line breaks, wraps   |

---

{#background-layers}

## Background Layers

For complex backgrounds with multiple visual layers (grids, dots, gradients stacked together):

### Single Layer

```zig
Box()
    .layer(.grid(14, 1, .palette(.grid_color)))
    .children({ /* ... */ });

Box()
    .layer(.dot(0.5, 20, .white))
    .children({ /* ... */ });
```

### Multiple Layers

```zig
Box()
    .layers(&.{
        .grid(14, 1, .palette(.grid_color)),
        .dot(0.5, 20, .transparentize(.white, 0.3)),
    })
    .background(.palette(.background))
    .children({ /* ... */ });
```

---

{#persisted-text-and-unmanaged}

## Text Persistence

By default, `Text()` with slice values persists the string across frames using an internal string table. This prevents dangling pointers when the source data changes.

### Unmanaged Text

If you know the text source is stable (e.g., a comptime string literal), you can opt out of persistence for performance:

```zig
Text("Static string that never changes")
    .unmanaged()
    .end();
```

> **Warning:** Only use `.unmanaged()` when you're certain the text pointer remains valid across render frames.

---

{#component-lifecycle-summary}

## Component Method Categories

### Constructors (Create a new component)

| Method           | Returns Children? | Description                     |
| ---------------- | ----------------- | ------------------------------- |
| `Box()`          | Yes               | Generic flex container          |
| `Stack()`        | Yes               | Vertical flex container         |
| `Center()`       | Yes               | Centered flex container         |
| `Text(value)`    | No                | Text display                    |
| `TextFmt(fmt, args)` | No           | Formatted text                  |
| `Number(value)`  | No                | Numeric display                 |
| `Label(text)`    | No                | Static label text               |
| `Code(value)`    | No                | Monospace code text             |
| `Html(text)`     | No                | Raw HTML insertion              |
| `Heading(level, text)` | No          | Semantic heading (h1–h6)        |
| `Image(opts)`    | No                | Image element                   |
| `Icon(token)`    | No                | Icon from icon token set        |
| `Svg(opts)`      | No                | Inline SVG                      |
| `Graphic(opts)`  | No                | Lazy-loaded SVG                 |
| `Spacer(val)`    | No                | Fixed-height spacer             |
| `Link(opts)`     | Yes               | Internal navigation link        |
| `RedirectLink(opts)` | Yes           | External redirect link          |
| `List()`         | Yes               | List container                  |
| `ListItem()`     | Yes               | List item                       |
| `Section()`      | Yes               | Intersection observer section   |
| `Form(fn, args)` | Yes               | Form with submit handler        |
| `Anchor(name)`   | Yes               | Anchor positioning target       |
| `Table()`        | Yes               | Table container                 |
| `TableHead()`    | Yes               | Table head section              |
| `TableHeader()`  | Yes               | Table header cell               |
| `TableBody()`    | Yes               | Table body section              |
| `TableRow()`     | Yes               | Table row                       |
| `TableCell()`    | Yes               | Table data cell                 |
| `Video(opts)`    | No                | Video element                   |
| `Null()`         | No                | Ghost placeholder element       |

### Terminators (Finalize the component)

| Method             | Description                                      |
| ------------------ | ------------------------------------------------ |
| `.end()`           | Finalize — required for all components           |
| `.children({ })` | Finalize with child block (containers only)        |
| `.style(&s)`       | Apply style struct, then use `.children()` or `.end()` |
| `.items(tuple)`    | Finalize with inline child tuple                 |
