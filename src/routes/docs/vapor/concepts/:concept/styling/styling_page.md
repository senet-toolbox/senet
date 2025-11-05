{#styling}

# Styling

{#quick-little-rant}

### Quick little rant

In typical web applications, the most common styling is CSS. Over the years CSS has been wrapped and abstracted, to the
end of the Earth. There is **SCSS, Tailwind, Sass, Less, Stylus, and more**. However, all of these abstraction take a thin layer approach
where the focus is less on the UI layout, and more on the reduction of syntax, ie Tailwind converts `margin-top to mt`.
This may reduce verbosity, and number of keys to press, but does not reduce the complexity required to center a div.

This is a website about how to **CENTER A DIV**.

Normal CSS: `style="display: flex; justify-content: center; align-items: center"`

Tailwind CSS: `class="flex justify-center items-center"`

The question is then, why can't we just do `style="center"`? I have found that in the few years of working in web development,
`Styling` has caused an enormity of abstraction layers, and more so pushed developers completely away from the frontend.

{#end-of-little-rant}

### End of little rant

{#new-approach}

## New Approach

Vapor has taken a completely new approach. In the very early stages of Vapor's creation, an entire UI layout algorithmn
was built from scratch. The aim of this was, to design an ergonmic, and usable simple styling system, for developers to work
with. Today, Vapor does not use this UI algo, due to the benefits of the browser's DOM engine, but still uses the same styling api interface.

To center any element in Vapor...

`.layout = .center` or `.layout(.center)`

Vapor, even exposes it own Center Component type, `Center` Component, which will Center any child elements within it.
No more `justify-content`, or `align-items`, or `text-align`. Now instead `.x = .start`, or
`.y = .center` or `.layout = .top_left`.

These are also direction independent, adding `direction = .row`
or `direction = .column`, will still layout elements in y and x axis, correctly, unlike justify-content, and align-items.

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

- Style structs

- Builder functions

{#builder-functions}

## Builder functions

For those coming from IOS development, builder functions will be familiar to you.

```zig
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Box = Static.Box;
pub fn render() void {
    Box.layout(.center).spacing(16).padding(.all(20)).body()({
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
Keep in mind, Vapor by default does not support duplicate styles, the above common styles while instantiated multiple times, during tree
rendering, deduplication will occur. Instead a reference will be kept for the common styles.

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

- `.body(fn (void) void)`

- `.close(void)`

{#style-structs}

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

`style="display: flex; justify-content: center, align-items: center,
border-radius: 8px; border: 1px solid rgb(var(--tint)); background: transparent;"`

While in Vapor we can do the following,

`Style{ .layout = .center, .visual = .{ .border = .round(.palette(.tint)) } }`

Or...

`Style{ .layout = .center, .visual = .border_round(palette(.tint)) }`

Or...

`.layout(.center).border(.round(.palette(.tint), .all(8)))`

{#structs-are-insanely-powerful}

### Structs are insanely powerful!

As you may have noticed, `Style` is a struct, and has fields, which means it also has methods.
When we create a new fabric project, we get the following default methods:

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

- and much more...

{#code-block}

### Code Block

```zig
const Vapor = @import("fabric");
const Static = Vapor.Static;
const Style = Vapor.Style;

fn StyledFlexBox(style: Style) fn (void) void {
    const elem_decl = Vapor.ElementDecl{
        .style = Style.override(style),
        .elem_type = .FlexBox,
    };
    Vapor.LifeCycle.open(elem_decl);
    Vapor.LifeCycle.configure(elem_decl);
    return Vapor.LifeCycle.close;
}

fn sample() void {
    // the Text UI node is centered
    Static.Button(.{ .onPress = clicked }, .{
        .display = .Center,
        .width = .fit,
        .height = .px(48),
        .border = .{ .radius = .all(4) },
        .padding = .all(8),
    })({
        // the text content is also centered
        Static.Text("Click Me", .{
            .font_size = 18,
            .display = .Center,
            .width = .px(200),
        });
    });

    // Here we create and set a default style we want to use
    Vapor.Style.setDefault(.{
        .display = .Center,
        .width = .percent(100),
        .height = .percent(100),
        .border = .{ .radius = .all(4), .thickness = .all(2) },
        .padding = .all(8),
    });

    // we then overide the default with width = .fit, and height = .px(48)
    const overided_default_style = Style.override(.{ .width = .fit, .height = .px(48) });

    // the Text UI node is centered, cause we are using a default
    Static.Button(
        .{ .onPress = clicked },
        overided_default_style,
    )({
        // the text content is also centered, here we are not using the default and instead
        // passing our own defined Style
        Static.Text("Click Me", .{
            .font_size = 18,
            .display = .Center,
            .width = .px(200),
        });
    });

    // Here we use the StyledFlexBox, instead of overidding within the UI node style argument
    StyledFlexBox(.{
        .width = .fit,
        .height = .px(48),
    })({
        // the text content is also centered, here we are not using the default and instead
        // passing our own defined Style
        Static.Text("Click Me", .{
            .font_size = 18,
            .display = .Center,
            .width = .px(200),
        });
    });
}
```
