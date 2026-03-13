{#vapor-builder-methods-reference}

# Vapor Builder Methods — Complete Reference

#### Every chainable method on `ComponentBuilder`, organized by category.

---

{#overview}

## How the Builder Works

Every Vapor component returns a `ComponentBuilder` struct. Methods are chained to configure the element, and a terminal method (`.end()`, `.children()`, or `.style()`) finalizes it.

```zig
// Pattern: Constructor → Chainable methods → Terminator
Box()                          // Constructor
    .spacing(16)               // Chainable
    .padding(.all(20))         // Chainable
    .background(.palette(.bg)) // Chainable
    .children({ /* ... */ });  // Terminator
```

All chainable methods return a new `Self` (or `*const Self`) so order doesn't matter — but terminators must come last.

---

{#layout-and-sizing}

## Layout & Sizing

| Method          | Signature                  | Description                                                               |
| --------------- | -------------------------- | ------------------------------------------------------------------------- |
| `.layout(v)`    | `(types.Layout) → Self`    | Set flex alignment (`.center`, `.left_center`, `.x_between_center`, etc.) |
| `.direction(v)` | `(types.Direction) → Self` | Set flex direction (`.row` or `.column`)                                  |
| `.spacing(v)`   | `(u8) → Self`              | Gap between children in pixels                                            |
| `.wrap(v)`      | `(types.FlexWrap) → Self`  | Flex wrap (`.wrap`, `.nowrap`)                                            |
| `.center()`     | `() → Self`                | Shorthand for `.layout(.center)`                                          |
| `.columns(n)`   | `(u8) → *const Self`       | CSS multi-column count                                                    |

### Sizing

| Method            | Signature                             | Description               |
| ----------------- | ------------------------------------- | ------------------------- |
| `.size(dim)`      | `(types.Size) → Self`                 | Set both width and height |
| `.width(v)`       | `(types.Sizing) → Self`               | Set width only            |
| `.height(v)`      | `(types.Sizing) → Self`               | Set height only           |
| `.hw(h, w)`       | `(types.Sizing, types.Sizing) → Self` | Set height and width      |
| `.minWidth(v)`    | `(types.Sizing) → Self`               | Set minimum width         |
| `.maxWidth(v)`    | `(types.Sizing) → Self`               | Set maximum width         |
| `.minHeight(v)`   | `(types.Sizing) → Self`               | Set minimum height        |
| `.maxHeight(v)`   | `(types.Sizing) → Self`               | Set maximum height        |
| `.aspectRatio(v)` | `(types.AspectRatio) → Self`          | Lock aspect ratio         |

```zig
// Min/max constraints
Box()
    .minWidth(.px(200))
    .maxWidth(.px(800))
    .width(.percent(100))
    .children({ /* responsive container */ });

// Aspect ratio
Image(.{ .src = "/thumb.jpg" })
    .aspectRatio(.{ .width = 4, .height = 3 })
    .width(.percent(100))
    .end();
```

---

{#spacing-and-margin}

## Padding & Margin

### Padding

| Method        | Signature                | Description                                                             |
| ------------- | ------------------------ | ----------------------------------------------------------------------- |
| `.padding(v)` | `(types.Padding) → Self` | Set padding (`.all()`, `.horizontal()`, `.vertical()`, `.tblr()`, etc.) |
| `.pl(v)`      | `(u8) → Self`            | Padding left                                                            |
| `.pr(v)`      | `(u8) → Self`            | Padding right                                                           |
| `.pt(v)`      | `(u8) → Self`            | Padding top                                                             |
| `.pb(v)`      | `(u8) → Self`            | Padding bottom                                                          |

### Margin

| Method       | Signature               | Description   |
| ------------ | ----------------------- | ------------- |
| `.margin(v)` | `(types.Margin) → Self` | Set margin    |
| `.ml(v)`     | `(i16) → Self`          | Margin left   |
| `.mr(v)`     | `(i16) → Self`          | Margin right  |
| `.mt(v)`     | `(i16) → Self`          | Margin top    |
| `.mb(v)`     | `(i16) → Self`          | Margin bottom |

```zig
// Individual padding sides
Box()
    .pt(16).pb(16).pl(24).pr(24)
    .children({ /* ... */ });

// Negative margin (for bleed effects)
Box()
    .mt(-8)
    .children({ /* ... */ });
```

> **Note:** Margin values are `i16` (signed) allowing negative margins. Padding values are `u8` (unsigned).

---

{#visual-styling}

## Visual Styling

### Colors & Backgrounds

| Method           | Signature                   | Description                  |
| ---------------- | --------------------------- | ---------------------------- |
| `.background(v)` | `(types.Background) → Self` | Background color or gradient |
| `.textColor(c)`  | `(?Color) → Self`           | Text color                   |
| `.fill(c)`       | `(types.Color) → Self`      | SVG fill color               |
| `.stroke(c)`     | `(types.Color) → Self`      | SVG stroke color             |
| `.opacity(v)`    | `(f16) → Self`              | Opacity (0.0 – 1.0)          |
| `.gradient(v)`   | `(types.Background) → Self` | Alias for `.background()`    |

### Typography

| Method                       | Signature                       | Description                                              |
| ---------------------------- | ------------------------------- | -------------------------------------------------------- |
| `.font(size, weight, color)` | `(u8, ?u16, ?Color) → Self`     | Set font size, weight, and color                         |
| `.fontSize(v)`               | `(u8) → Self`                   | Font size only                                           |
| `.weight(v)`                 | `(u16) → Self`                  | Font weight only                                         |
| `.bold()`                    | `() → Self`                     | Shorthand for `.weight(700)`                             |
| `.fontFamily(v)`             | `([]const u8) → Self`           | Font family name                                         |
| `.fontStyle(v)`              | `(types.FontStyle) → Self`      | Font style (italic, normal)                              |
| `.textDecoration(v)`         | `(types.TextDecoration) → Self` | Text decoration (`.none`, `.underline`, `.line_through`) |
| `.noDecoration()`            | `() → Self`                     | Shorthand for `.textDecoration(.none)`                   |
| `.ellipsis(v)`               | `(types.Ellipsis) → Self`       | Text truncation (only on Text elements)                  |
| `.whiteSpace(v)`             | `(types.WhiteSpace) → Self`     | White space handling                                     |

### Borders

| Method            | Signature                      | Description                        |
| ----------------- | ------------------------------ | ---------------------------------- |
| `.border(v)`      | `(types.BorderGrouped) → Self` | Full border definition             |
| `.borderStyle(v)` | `(types.BorderStyle) → Self`   | Border style (solid, dashed, etc.) |
| `.radius(v)`      | `(types.BorderRadius) → Self`  | Border radius only                 |

### Effects

| Method          | Signature                                 | Description                                  |
| --------------- | ----------------------------------------- | -------------------------------------------- |
| `.shadow(v)`    | `(?types.Shadow) → Self`                  | Box shadow (or text shadow on Text elements) |
| `.newShadow(v)` | `(?Shadow) → Self`                        | New shadow system                            |
| `.blur(v)`      | `(?u8) → Self`                            | Backdrop blur                                |
| `.outline(v)`   | `(types.Outline) → Self`                  | Outline (focus rings)                        |
| `.layer(v)`     | `(?types.BackgroundLayer) → Self`         | Single background layer                      |
| `.layers(v)`    | `(?[]const types.BackgroundLayer) → Self` | Multiple background layers                   |

### Transform

| Method                | Signature                        | Description               |
| --------------------- | -------------------------------- | ------------------------- |
| `.transform(v)`       | `(?types.Transform) → Self`      | Arbitrary transform       |
| `.scale(v)`           | `(f16) → Self`                   | Scale transform shorthand |
| `.transformOrigin(v)` | `(types.TransformOrigin) → Self` | Transform origin point    |

---

{#positioning}

## Positioning

| Method       | Signature                 | Description                                    |
| ------------ | ------------------------- | ---------------------------------------------- |
| `.pos(v)`    | `(types.Position) → Self` | Full position (type, top, right, bottom, left) |
| `.zIndex(v)` | `(?i16) → Self`           | Z-index layer order                            |

```zig
// Absolute positioning with z-index
Box()
    .pos(.tl(.px(0), .px(0), .absolute))
    .zIndex(100)
    .children({ /* ... */ });

// Fixed full-screen overlay
Box()
    .pos(.full(.fixed))
    .zIndex(999)
    .children({ /* ... */ });

// Relative container
Box()
    .pos(.relative)
    .children({
        // Absolutely positioned child
        Box()
            .pos(.tr(.px(8), .px(8), .absolute))
            .children({ Text("Badge").end(); });
    });
```

---

{#interactivity}

## Interactivity & Hover

| Method                | Signature                    | Description                       |
| --------------------- | ---------------------------- | --------------------------------- |
| `.cursor(v)`          | `(types.Cursor) → Self`      | Cursor style                      |
| `.pointer()`          | `() → Self`                  | Shorthand for `.cursor(.pointer)` |
| `.hover(v)`           | `(types.Visual) → Self`      | Full hover visual override        |
| `.hoverBackground(c)` | `(types.Background) → Self`  | Hover background color            |
| `.hoverText(c)`       | `(Color) → Self`             | Hover text color                  |
| `.hoverScale()`       | `() → Self`                  | Hover scale-up effect             |
| `.interaction(v)`     | `(types.Interactive) → Self` | Full interactive style struct     |
| `.transition(v)`      | `(types.Transition) → Self`  | Transition settings               |
| `.duration(v)`        | `(u32) → Self`               | Transition duration in ms         |
| `.hidden(v)`          | `(bool) → Self`              | Conditionally hide element        |
| `.scroll(v)`          | `(types.Scroll) → Self`      | Scroll behavior                   |

```zig
// Complex hover state
Box()
    .hover(.{
        .background = .palette(.tint),
        .text_color = .white,
        .transform = .scaleDecimal(1.05),
        .shadow = .glow(20, .transparentize(.palette(.tint), 0.3)),
    })
    .duration(200)
    .cursor(.pointer)
    .children({ /* ... */ });
```

---

{#events}

## Event Handlers

| Method                         | Signature                                           | Description                              |
| ------------------------------ | --------------------------------------------------- | ---------------------------------------- |
| `.onChange(cb)`                | `(fn(*Vapor.Event) void) → Self`                    | Input change handler                     |
| `.onHover(cb)`                 | `(fn(*Vapor.Event) void) → Self`                    | Pointer enter handler                    |
| `.onLeave(cb)`                 | `(fn(*Vapor.Event) void) → Self`                    | Mouse leave handler                      |
| `.onFocus(cb)`                 | `(fn(*Vapor.Event) void) → Self`                    | Focus handler (requires `.bind()` first) |
| `.onBlur(cb)`                  | `(fn(*Vapor.Event) void) → Self`                    | Blur handler (requires `.bind()` first)  |
| `.onDragStart(cb)`             | `(fn(*Vapor.Event) void) → Self`                    | Pointer down / drag start                |
| `.onEvent(event, cb)`          | `(types.EventType, fn(*Vapor.Event) void) → Self`   | Generic event handler                    |
| `.onEventCtx(event, fn, args)` | `(types.EventType, anytype, anytype) → *const Self` | Event handler with context               |
| `.onHoverCtx(fn, args)`        | `(anytype, anytype) → Self`                         | Hover with context                       |
| `.onMountCtx(fn, args)`        | `(anytype, anytype) → Self`                         | Mount lifecycle with context             |

```zig
// Generic event
Box()
    .onEvent(.pointerdown, handlePointerDown)
    .children({ /* ... */ });

// Context event — passes data to handler
Box()
    .onEventCtx(.click, handleItemClick, .{ item.id, item.name })
    .children({ /* ... */ });

fn handleItemClick(id: u32, name: []const u8, evt: *Vapor.Event) void {
    _ = evt;
    selectItem(id, name);
}
```

---

{#element-binding}

## Element Binding & Refs

| Method                | Signature                    | Description                 |
| --------------------- | ---------------------------- | --------------------------- |
| `.ref(element)`       | `(*Element) → Self`          | Bind element for DOM access |
| `.bind(ptr)`          | `(*anyopaque) → Self`        | Bind value (TextField only) |
| `.createDraggable(d)` | `(*Draggable) → *const Self` | Attach draggable behavior   |
| `.getUUID()`          | `() → []const u8`            | Get the element's UUID      |

---

{#identity-and-styles}

## Identity & Style Application

| Method                    | Signature                               | Description                                                        |
| ------------------------- | --------------------------------------- | ------------------------------------------------------------------ |
| `.id(v)`                  | `([]const u8) → Self`                   | Set element ID                                                     |
| `.class(v)`               | `([]const u8) → Self`                   | Set CSS class name                                                 |
| `.classFmt(fmt, args)`    | `(comptime []const u8, anytype) → Self` | Dynamic class name                                                 |
| `.baseStyle(ptr)`         | `(*const Vapor.Style) → Self`           | Base style (can be overridden by chained methods)                  |
| `.style(ptr)`             | `(*const Vapor.Style) → Self`           | Apply style struct (terminal-ish: use `.children()` or loop after) |
| `.inlineStyle(fmt, args)` | `(comptime []const u8, anytype) → Self` | Raw inline CSS (formatted)                                         |
| `.inlineStyleStr(v)`      | `([]const u8) → Self`                   | Raw inline CSS (static)                                            |
| `.inherit(fields)`        | `([]const types.StyleFields) → Self`    | Inherit specific style fields from parent                          |
| `.inheritHover(fields)`   | `([]const types.StyleFields) → Self`    | Inherit hover style fields from parent                             |
| `.edges(tag)`             | `(?[]const u8) → Self`                  | Named edge style                                                   |

### baseStyle vs style

```zig
// baseStyle: chainable methods OVERRIDE the base
Box()
    .baseStyle(&card_style)          // Base: padding 16, background white
    .padding(.all(32))               // Overrides padding to 32
    .background(.palette(.surface))  // Overrides background
    .children({ /* ... */ });

// style: applies the struct directly, further chains don't override
Box()
    .style(&card_style)             // Applies everything from card_style
    .children({ /* ... */ });
```

---

{#animation}

## Animation

| Method                 | Signature              | Description                            |
| ---------------------- | ---------------------- | -------------------------------------- |
| `.animation(tag)`      | `(?[]const u8) → Self` | Set running animation                  |
| `.animationEnter(tag)` | `(?[]const u8) → Self` | Play animation when element enters DOM |
| `.animationExit(tag)`  | `(?[]const u8) → Self` | Play animation when element leaves DOM |

---

{#accessibility}

## Accessibility

| Method                     | Signature                     | Description                  |
| -------------------------- | ----------------------------- | ---------------------------- |
| `.a11y(v)`                 | `(Accessibility) → Self`      | Full accessibility struct    |
| `.ariaLabel(v)`            | `([]const u8) → Self`         | Accessible name              |
| `.role(v)`                 | `(Accessibility.Role) → Self` | ARIA role                    |
| `.ariaExpanded(v)`         | `(bool) → Self`               | Expanded state               |
| `.ariaSelected(v)`         | `(bool) → Self`               | Selected state               |
| `.ariaControls(v)`         | `([]const u8) → Self`         | ID of controlled element     |
| `.ariaActiveDescendant(v)` | `(?[]const u8) → Self`        | Active child ID              |
| `.ariaHidden(v)`           | `(bool) → Self`               | Hide from accessibility tree |
| `.tabIndex(v)`             | `(i16) → Self`                | Keyboard tab order           |

See the **Accessibility Reference** document for full patterns and examples.

---

{#anchor-methods}

## Anchor Positioning

| Method                | Signature                        | Description                      |
| --------------------- | -------------------------------- | -------------------------------- |
| `.anchorSource(name)` | `([]const u8) → Self`            | Mark element as an anchor source |
| `.anchorPlacement(v)` | `(types.AnchorPlacement) → Self` | Set anchor placement direction   |
| `.placement(v)`       | `(types.AnchorPlacement) → Self` | Alias for `.anchorPlacement()`   |

---

{#misc}

## Miscellaneous

| Method          | Signature                  | Description              |
| --------------- | -------------------------- | ------------------------ |
| `.fieldName(v)` | `([]const u8) → Self`      | Form field name          |
| `.unmanaged()`  | `() → Self`                | Disable text persistence |
| `.listStyle(v)` | `(types.ListStyle) → Self` | List bullet style        |
