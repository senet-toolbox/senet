{#styling}

# Styling

Vapor treats styling, like Zig itself, there is no scoping, namespacing, CSS classes, ect. Just pure Zig code.

While in typical CSS, application we need to specify classes, and then scope them so that they are tagged with the correct element, and we can use multiple classes with the same naming.

In Vapor, we reconcile the styles, and so not only is everything deduped, but also consolidated. A typical 50kb CSS file, is reduced to a single 10kb CSS file, when using Vapor.

{#new-approach}

## New Approach

Vapor has taken a completely new approach. In the very early stages of Vapor's creation, an entire UI layout algorithmn
was built from scratch. The aim of this was, to design an ergonmic, and usable simple styling system, for developers to work
with. Today, Vapor does not use this UI algo, due to the benefits of the browser's DOM engine, but still uses the same styling api interface.

To center any element in Vapor (including "text")

`.layout = .center` or `.layout(.center)`

Vapor, even exposes it own Center Element type, `Center()`, which will Center any child elements within it.

No more justify-content, or align-items, or text-align. Now instead _.x = .start_,
_.y = .center_ or _.layout = .top_left_.

These are also direction independent, adding _direction = .row_
or _direction = .column_, will still layout elements in y and x axis, correctly, unlike justify-content, and align-items.

{#layout}

### Layout:

- `.center`

- `.left_center`

- `.right_center`

- `.top_left`

- `.top_right`

- `.bottom_left`

- `.bottom_right`

- `.top_center`

- `.bottom_center`

- `.x_even_center`

- `.y_between`

- `.and much more...`

{#two-types-of-styling}

## Two types of styling in Vapor

- **Builder Pattern**

- **Style Structs**

{#builder-functions}

## Builder Pattern

For those coming from IOS development, builder functions will be familiar to you.

```zig
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Box = Static.Box;
pub fn render() void {
    Box.layout(.center).spacing(16).padding(.all(20)).children({
        Text("Hello there!")
            .font(24, 700, .blue)
            .close();
        Text("...")
            .font(18, 700, .black)
            .close();
        Text("General Kenobi")
            .font(24, 700, .red)
            .close();
    });
}
```

Builder functions are a powerful tool, for creating quick styles, that do not need to be shared across the application.
Keep in mind, Vapor by default does **not support duplicate styles**, the above common styles while instantiated multiple times, during tree
rendering. Will be deduplicated. Instead a reference will be kept for the common styles.

{#builder-patterns}

### Builder patterns

- `.layout(Layout)`

- `.spacing(Spacing)`

- `.padding(Padding)`

- `.direction(Direction)`

- `.font(u32, ?u32, ?Color)`

- `.pos(Position)`

- `.size(Sizing)`

- `.width(Sizing)`

- `.height(Sizing)`

- `.zIndex(i16)`

- `.blur(u8)`

- `.background(Background)`

- `.border(Border)`

- `.wrap(Wrap)`

- `.cursor(Cursor)`

- `.hoverScale()`

- `.hoverText(Color)`

- `.margin(Margin)`

- `.radius(Radius)`

- `.duration(Duration)`

- `.listStyle(ListStyle)`

- `.outline(Outline)`

- `.onHover(EventHandler)`

- `.onLeave(EventHandler)`

- `.onChange(EventHandler)`

- `.onFocus(EventHandler)`

- `.onBlur(EventHandler)`

- `ect...`

{#style-struct}

## const Style = struct { ... }

The second type of styling in Vapor is the `Style` struct. This is contains all the styling properties, and is passed to the
components, via the `style(*const Style)` fucntion. This is handy when we have a common style, shared across the application.

```zig
pub fn render() void {
    const text_style: *const Vapor.Style = &.{
        .visual = .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .red,
        },
    };

    Box.style(text_style)({
        Text("Hello there!").style(text_style);
        Text("...").style(&.{
            .visual = .{
                .font_size = 18,
                .font_weight = 700,
                .text_color = .black,
            },
        });
        Text("General Kenobi").style(text_style);
    });
}
```

{#taking-it-even-further}

### Taking it even further

A typical CSS styled Button requires the following styling

```css
style="display: flex; justify-content: center, align-items: center, border-radius: 8px; border: 1px solid rgb(var(--tint)); background: transparent;"
```

While in Vapor we can do the following,

```zig
Style{ .layout = .center, .visual = .{ .border = .round(.palette(.tint)) } }
```

Or...

```zig
.layout(.center).border(.round(.palette(.tint), .all(8)))
```

{#structs-are-insanely-powerful}

### Structs are insanely powerful!

As you may have noticed, `Style` is a struct, and has fields, which means it also has methods.
When we create a new Vapor project, we get the following default methods:

- visual `.font(size: u32, weight: ?u32, color: ?Color)`

- when `.pill(color: Color)`

- bg `.hex(hex_str: []const u8)`

- interactive `.hover_scale()`

- style `.extend(base: *Style, extension: Style)`

- padding `.tblr(top: u32, bottom: u32, left: u32, right: u32)`

- size `.hw(height: Sizing, width: Sizing)`

- size `.square_percent(size: f32)`

- width `.mobile_desktop_percent(mobile: f32, desktop: f32)`

- background `.grid(size: f32, thickness: i32, color: Color)`

- background `.hex(hex_str: []const u8)`

- background `.linear_gradient(start: Color, end: Color)`

- border `.simple(color: Color)`

- border `.round(color: Color)`

- border `.solid(color: Color, thickness: i32)`

- border `.dashed(color: Color, thickness: i32)`

- merge `.merge(style: Style)`

- extend `.extend(style: Style)`

- and much more...

{#code-block}

### Code Block

Below is a sample code block of various styling options.

```zig

const Vapor = @import("vapor");
const Box = Vapor.Box;

pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

const common_style = Style{
    .layout = .top_right,
    .size = .{
        .height = .px(120),
    },
    .visual = .{
        .border = .round(.vapor_blue, .all(4)),
    },
    .padding = .all(8),
};

pub const pill_button_base = Style{
    .layout = .center,
    .size = .hw(.px(45), .px(160)),
    .visual = .pill(.hex("#000000")),
    .transition = .{ .duration = 100 },
    .interactive = .hover_scale(),
    .child_gap = 8,
};

fn mergedStyle() Style {
    var base = pill_button_base;
    return base.merge(Style{
        .visual = .{ .border = .simple(.hex("#E1E1E1")) },
    });
}

fn clicked() void {
    Vapor.alert("You clicked me!");
}

fn samples() void {
    Box()
        .layer(.dot(0.5, 20, .white))
        .background(.vapor_blue)
        .width(.percent(100))
        .height(.auto)
        .layout(.center)
        .children({
        Text("I like Dots!")
            .font(48, 700, .white).fontFamily("Montserrat").end();
    });

    Box().style(&common_style)({
        Text("Top right Text").fontSize(14).end();
    });

    // Here we use the baseStyle, now we can override the default style
    Box().baseStyle(&common_style).layout(.top_left).children({
        Text("Top left Text").fontSize(14).end();
    });

    Button(.{ .on_press = clicked }).style(&pill_button_base)({
        Text("Click Me").fontSize(18).end();
    });

    // Here we merge the pill style,
    Button(.{ .on_press = clicked }).style(&mergedStyle())({
        Text("Click Me").fontSize(18).end();
    });
}
```

@styling_samples

#### extend

The extend function allows you to extend a style with another style. It mutates the original style, and returns the mutated style.

#### merge

The merge function allows you to merge a style with another style. This creates an entirely new style, and returns the new style.

