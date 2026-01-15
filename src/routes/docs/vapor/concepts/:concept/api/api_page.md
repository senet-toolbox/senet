
{#vapor-api-cheatsheet}

# Vapor API Cheat Sheet

#### Quick reference for building UIs with Vapor's Zig-powered WebAssembly framework.

---

{#imports-and-setup}

## Imports & Setup

```zig
const std = @import("std");
const Vapor = @import("vapor");

// Core Components
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const TextField = Vapor.TextField;
const TextArea = Vapor.TextArea;
const Label = Vapor.Label;
const Link = Vapor.Link;
const Image = Vapor.Image;
const List = Vapor.List;
const ListItem = Vapor.ListItem;

// Context Components
const ButtonCtx = Vapor.CtxButton;
const TextFmt = Vapor.TextFmt;

// Static Components (never update)
const Static = Vapor.Static;

// Hooks
const HooksCtx = Vapor.Static.HooksCtx;

// Utilities
const Binded = Vapor.Binded;
const Animation = Vapor.Animation;
```

---

{#application-initialization}

## Application Initialization

```zig
// main.zig
export fn init() void {
    Vapor.init(.{});
    
    // Register routes
    Vapor.Page(.{ .route = "/" }, Home, null);
    Vapor.Page(.{ .route = "/about" }, About, deinit);
    
    // Or use @src() for file-based routing
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn Home() void {
    Text("Hello Vapor!").end();
}

fn About() void {
    Text("About Page").end();
}

fn deinit() void {
    // Called when navigating away
}
```

---

{#state-management}

## State Management

### Basic State (Outside Render)

```zig
// State lives OUTSIDE render function
var counter: i32 = 0;
var text: []const u8 = "Hello";
var items: []Item = &.{};

fn increment() void {
    counter += 1;
}

fn render() void {
    // UI declaration runs every update
    Text(counter).end();
    Button(.{ .on_press = increment }).children({
        Text("Click").end();
    });
}
```

### Signal-Based State (Explicit Reactivity)

```zig
const Signal = Vapor.Signal;

var counter: Signal(u32) = undefined;

fn init() void {
    counter.init(0);
}

fn increment() void {
    counter.increment();  // Auto-triggers UI update
}

fn render() void {
    Text(counter.get()).end();
}
```

### Signal Methods

| Method | Description |
|--------|-------------|
| `.init(value)` | Initialize with value |
| `.get()` | Get current value |
| `.set(value)` | Set new value |
| `.increment()` | Increment numeric value |
| `.decrement()` | Decrement numeric value |
| `.toggle()` | Toggle boolean value |
| `.append(item)` | Append to array |

---

{#component-patterns}

## Component Patterns

### Global Component (Shared State)

```zig
// components/Counter.zig
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;

var count: i32 = 0;

fn increment() void { count += 1; }
fn decrement() void { count -= 1; }

pub fn render() void {
    Box().layout(.center).spacing(16).children({
        Button(.{ .on_press = decrement }).children({ Text("-").end(); });
        Text(count).font(24, 700, .palette(.text_color)).end();
        Button(.{ .on_press = increment }).children({ Text("+").end(); });
    });
}
```

### Instance Component (Independent State)

```zig
// components/Counter.zig
const Counter = @This();
count: i32 = 0,

fn increment(counter: *Counter) void {
    counter.count += 1;
}

fn decrement(counter: *Counter) void {
    counter.count -= 1;
}

pub fn render(counter: *Counter) void {
    Box().layout(.center).spacing(16).children({
        ButtonCtx(decrement, .{counter}).children({ Text("-").end(); });
        Text(counter.count).font(24, 700, .palette(.text_color)).end();
        ButtonCtx(increment, .{counter}).children({ Text("+").end(); });
    });
}

// Usage
var my_counter: Counter = .{};
fn render() void {
    my_counter.render();
}
```

### Function Component (Generic/Comptime)

```zig
pub fn Counter(comptime T: type, initial_value: T) type {
    return struct {
        var count: T = initial_value;

        fn increment() void { count += 1; }
        fn decrement() void { count -= 1; }

        pub fn render() void {
            Box().layout(.center).spacing(16).children({
                Button(.{ .on_press = decrement }).children({ Text("-").end(); });
                Text(count).font(24, 700, .palette(.text_color)).end();
                Button(.{ .on_press = increment }).children({ Text("+").end(); });
            });
        }
    };
}

// Usage
const i32_counter = Counter(i32, 0);
const u64_counter = Counter(u64, 100);
```

---

{#core-components}

## Core Components

### Text

```zig
Text("Hello World").end();
Text(counter).end();                           // Numbers
Text(enum_value).end();                        // Enums
Text(text_variable).end();                     // Strings

// Styled
Text("Styled")
    .font(18, 700, .palette(.text_color))      // size, weight, color
    .fontFamily("Montserrat")
    .ellipsis(.dot)                            // Truncation
    .end();
```

### TextFmt (Formatted Text)

```zig
TextFmt("Count: {d}", .{counter}).end();
TextFmt("Hello {s}!", .{name}).end();
TextFmt("Page {d}/{d}", .{current, total}).end();
```

### Box (Container)

```zig
Box().children({
    Text("Child 1").end();
    Text("Child 2").end();
});

// Styled Box
Box()
    .layout(.center)
    .direction(.column)
    .spacing(16)
    .padding(.all(20))
    .background(.palette(.background))
    .border(.round(.palette(.border_color), .all(8)))
    .children({ /* children */ });
```

### Stack (Vertical Container)

```zig
Stack()
    .spacing(8)
    .width(.percent(100))
    .children({
        Text("Item 1").end();
        Text("Item 2").end();
    });
```

### Center

```zig
Center()
    .height(.percent(100))
    .children({
        Text("Centered Content").end();
    });
```

### Button

```zig
// Simple button
Button(.{ .on_press = handleClick }).children({
    Text("Click Me").end();
});

// Button with context (pass data to handler)
ButtonCtx(handleAction, .{ item, index }).children({
    Text("Action").end();
});

// Styled button
Button(.{ .on_press = submit })
    .padding(.tblr(12, 12, 24, 24))
    .background(.palette(.tint))
    .border(.round(.transparent, .all(8)))
    .cursor(.pointer)
    .hoverScale()
    .children({
        Text("Submit").font(16, 600, .white).end();
    });
```

### TextField

```zig
var input_text: []const u8 = "";

TextField(.string)
    .bind(&input_text)
    .placeholder("Enter text...")
    .width(.percent(100))
    .padding(.all(12))
    .border(.round(.palette(.border_color), .all(8)))
    .end();

// Input types
TextField(.string)     // Text
TextField(.int)        // Numbers
TextField(.password)   // Password
TextField(.email)      // Email
```

### TextArea

```zig
TextArea()
    .width(.percent(100))
    .height(.px(200))
    .padding(.all(12))
    .border(.round(.palette(.border_color), .all(8)))
    .resize(.none)
    .end();
```

### Link

```zig
Link(.{ .url = "/about", .aria_label = "About Page" }).children({
    Text("Go to About").end();
});

// External link
Link(.{ .url = "https://vapor.dev", .aria_label = "Vapor Website" })
    .textDecoration(.none)
    .children({
        Text("Visit Vapor").end();
    });
```

### Image

```zig
Image(.{ .src = "/images/logo.png" })
    .width(.px(200))
    .height(.px(100))
    .border(.round(.transparent, .all(8)))
    .end();
```

### Icon

```zig
Icon(.search).end();
Icon(.plus).font(24, 300, .palette(.tint)).end();
Icon(.chevron_right).font(16, 700, .white).end();
```

### List & ListItem

```zig
List()
    .direction(.column)
    .spacing(8)
    .children({
        for (items) |item| {
            ListItem().children({
                Text(item.name).end();
            });
        }
    });
```

---

{#styling-reference}

## Styling Reference

### Layout

```zig
.layout(.center)              // Center both axes
.layout(.left_center)         // Left horizontal, center vertical
.layout(.right_center)        // Right horizontal, center vertical
.layout(.top_left)            // Top left corner
.layout(.top_right)           // Top right corner
.layout(.top_center)          // Top center
.layout(.bottom_left)         // Bottom left corner
.layout(.bottom_right)        // Bottom right corner
.layout(.bottom_center)       // Bottom center
.layout(.x_between_center)    // Space between, center vertical
.layout(.x_even_center)       // Space evenly, center vertical
.layout(.y_between)           // Vertical space between
```

### Sizing

```zig
.width(.px(200))              // Fixed pixels
.width(.percent(100))         // Percentage
.width(.fit)                  // Fit content
.width(.grow)                 // Flex grow
.width(.full)                 // 100%
.height(.px(100))
.height(.percent(50))
.height(.auto)

// Shorthand
.hw(.px(100), .px(200))       // height, width
.size(.full)                  // width & height 100%
.size(.square_px(100))        // Square 100x100
```

### Spacing & Padding

```zig
.spacing(16)                  // Gap between children
.padding(.all(20))            // All sides
.padding(.horizontal(16))     // Left & right
.padding(.vertical(12))       // Top & bottom
.padding(.tblr(10, 10, 20, 20)) // top, bottom, left, right
.padding(.tb(12, 12))         // top, bottom
.margin(.all(8))
.margin(.b(16))               // Bottom only
.margin(.t(16))               // Top only
.margin(.l(8))                // Left only
.margin(.r(8))                // Right only
```

### Direction & Wrapping

```zig
.direction(.row)              // Horizontal (default)
.direction(.column)           // Vertical
.wrap(.wrap)                  // Allow wrapping
.wrap(.nowrap)                // No wrapping
```

### Colors & Backgrounds

```zig
// Colors
.palette(.text_color)         // Theme color
.palette(.tint)
.palette(.background)
.palette(.border_color)
.hex("#FF5733")               // Hex color
.rgba(255, 87, 51, 255)       // RGBA
.white
.black
.transparent
.transparentizeHex(.palette(.tint), 0.5)  // Semi-transparent

// Backgrounds
.background(.palette(.background))
.background(.hex("#F5F5F5"))
.background(.transparent)
.layer(.grid(14, 1, .palette(.grid_color)))
.layer(.dot(0.5, 20, .white))
```

### Borders

```zig
.border(.none)
.border(.simple(.palette(.border_color)))
.border(.round(.palette(.border_color), .all(8)))
.border(.solid(.all(2), .palette(.tint), .all(12)))
.border(.bottom(.palette(.border_color)))
.border(.top(.palette(.border_color)))
```

### Shadows

```zig
.shadow(.card(.hex("#00000033")))
.shadow(.glow(30, .transparentizeHex(.black, 0.1)))
.shadow(.{
    .top = 4,
    .spread = 2,
    .blur = 6,
    .color = .transparentizeHex(.black, 0.05),
})
```

### Typography

```zig
.font(16, 400, .palette(.text_color))  // size, weight, color
.font(24, 700, null)                   // Inherit color
.fontSize(18)
.fontWeight(700)
.fontFamily("Montserrat")
.textDecoration(.none)
.textDecoration(.underline)
```

### Positioning

```zig
.pos(.relative)
.pos(.absolute)
.pos(.fixed)
.pos(.tl(.px(0), .px(0), .absolute))   // top, left, position
.pos(.tr(.px(0), .px(0), .absolute))   // top, right, position
.zIndex(100)
```

### Interactivity

```zig
.cursor(.pointer)
.cursor(.default)
.hoverScale()
.hoverBackground(.palette(.tint))
.hoverText(.white)
.hover(.{
    .background = .palette(.tint),
    .text_color = .white,
    .transform = .scaleDecimal(1.1),
})
.duration(200)                         // Transition duration (ms)
```

### Scroll

```zig
.scroll(.scroll_y())                   // Vertical scroll
.scroll(.scroll_x())                   // Horizontal scroll
```

---

{#style-structs}

## Style Structs

```zig
const button_style = Vapor.Style{
    .layout = .center,
    .size = .hw(.px(48), .px(160)),
    .padding = .tblr(12, 12, 24, 24),
    .visual = .{
        .background = .palette(.tint),
        .border = .round(.transparent, .all(8)),
        .font_size = 16,
        .font_weight = 600,
        .text_color = .white,
    },
    .transition = .{ .duration = 200 },
    .interactive = .hover_scale(),
};

// Apply with .style()
Button(.{ .on_press = action }).style(&button_style)({
    Text("Click").end();
});

// Or with .baseStyle() to allow overrides
Box().baseStyle(&card_style).padding(.all(32)).children({
    // children
});

// Merge styles
fn mergedStyle() Vapor.Style {
    var base = button_style;
    return base.merge(Vapor.Style{
        .visual = .{ .background = .hex("#FF0000") },
    });
}
```

---

{#events-and-handlers}

## Events & Handlers

### Element Events

```zig
// On change (TextField)
TextField(.string)
    .onChange(handleChange)
    .end();

fn handleChange(evt: *Vapor.Event) void {
    const text = evt.text();
    // Handle text change
}

// Hover events
Box()
    .onHover(handleHover)
    .onLeave(handleLeave)
    .children({ /* ... */ });

fn handleHover(_: *Vapor.Event) void {
    hovered = true;
}

fn handleLeave(_: *Vapor.Event) void {
    hovered = false;
}

// Context events
Box()
    .onHoverCtx(handleHoverItem, item)
    .children({ /* ... */ });

fn handleHoverItem(item: *Item, _: *Vapor.Event) void {
    current_item = item;
}

// Focus/Blur
TextField(.string)
    .onEventCtx(.focus, handleFocus, id)
    .onEventCtx(.blur, handleBlur, id)
    .end();
```

### Global Events

```zig
fn mount() void {
    Vapor.eventListener(.keydown, handleKeyPress);
}

fn handleKeyPress(evt: *Vapor.Event) void {
    const key = evt.key();
    
    if (std.mem.eql(u8, key, "Escape")) {
        evt.preventDefault();
        close();
    }
    
    if (std.mem.eql(u8, key, "k") and evt.metaKey()) {
        evt.preventDefault();
        openSearch();
    }
}
```

### Event Methods

| Method | Description |
|--------|-------------|
| `evt.key()` | Get pressed key name |
| `evt.text()` | Get input text value |
| `evt.number()` | Get numeric input value |
| `evt.metaKey()` | Check if meta/cmd pressed |
| `evt.shiftKey()` | Check if shift pressed |
| `evt.ctrlKey()` | Check if ctrl pressed |
| `evt.preventDefault()` | Prevent default action |

---

{#lifecycle-hooks}

## Lifecycle Hooks

### Component Hooks

```zig
fn mount() void {
    // Called after component is mounted
    Vapor.print("Mounted", .{});
}

fn destroy() void {
    // Called when component is removed
    Vapor.print("Destroyed", .{});
}

fn render() void {
    Vapor.Static.HooksCtx(.mounted, mount, .{})({
        Vapor.Static.HooksCtx(.destroy, destroy, .{})({
            // Component content
            Text("Hello").end();
        });
    });
}
```

### Tree Hooks

```zig
// Called after entire tree is rendered
Vapor.onEnd(callback);

// Called after virtual DOM is generated
Vapor.onCommit(callback);

// Manual update cycle
Vapor.cycle();
```

---

{#memory-arenas}

## Memory Arenas

```zig
// Frame arena - freed each render cycle
const frame_alloc = Vapor.arena(.frame);
const temp_string = Vapor.fmtln("Count: {d}", .{counter});

// View arena - freed on route change
const view_alloc = Vapor.arena(.view);
var page_items = view_alloc.alloc(Item, 100) catch unreachable;

// Persist arena - lives entire session
const persist_alloc = Vapor.arena(.persist);
var app_state = persist_alloc.create(AppState) catch unreachable;

// Scratch arena - manually managed
const scratch_alloc = Vapor.arena(.scratch);
// Free when done: scratch_alloc.free(ptr);

// Dynamic arrays
var items = Vapor.array(Item, .persist);
items.append(item) catch unreachable;
items.clearRetainingCapacity();
```

---

{#routing}

## Routing

### Route Registration

```zig
export fn init() void {
    Vapor.init(.{});
    
    // Static routes
    Vapor.Page(.{ .route = "/" }, Home, null);
    Vapor.Page(.{ .route = "/about" }, About, aboutDeinit);
    
    // Dynamic routes
    Vapor.Page(.{ .route = "/user/:id" }, UserPage, null);
    
    // File-based routing
    Vapor.Page(.{ .src = @src() }, render, deinit);
}
```

### Navigation

```zig
fn navigate(url: []const u8) void {
    Vapor.Kit.navigate(url);
}

// Usage
Button(.{ .on_press = goHome }).children({ Text("Home").end(); });

fn goHome() void {
    Vapor.Kit.navigate("/");
}
```

### Layouts

```zig
fn registerLayouts() !void {
    try Vapor.registerLayout("/app", appLayout, .{});
    try Vapor.registerLayout("/docs", docsLayout, .{ .reset = true });
}

fn appLayout(page: Vapor.PageFn) void {
    Navbar.render();
    page();
    Footer.render();
}
```

---

{#animations}

## Animations

### Define Animation

```zig
const Animation = Vapor.Animation;

const fadeIn = Animation.init("fadeIn")
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const slideIn = Animation.init("slideIn")
    .prop(.translateY, -20, 0)
    .prop(.opacity, 0, 1)
    .duration(200)
    .easing(.easeOutBack);

const spin = Animation.init("spin")
    .prop(.rotate, 0, 360)
    .duration(1000)
    .easing(.linear)
    .infinite();

// Build in init
fn init() void {
    fadeIn.build();
    slideIn.build();
    spin.build();
}
```

### Apply Animation

```zig
Box()
    .animationEnter(&fadeIn)
    .animationExit(&slideOut)
    .children({ /* ... */ });

// Hover animation
Button(.{ .on_press = action })
    .hover(.{ .animation = &pulse })
    .children({ /* ... */ });

// Conditional
Text("Loading")
    .animation(if (loading) &spin else null)
    .end();
```

### Animation Properties

| Property | Description |
|----------|-------------|
| `.translateX`, `.translateY` | Position |
| `.scale`, `.scaleX`, `.scaleY` | Scaling |
| `.rotate` | Rotation |
| `.opacity` | Transparency |
| `.blur` | Blur filter |
| `.backgroundColor` | Color |

### Easing Functions

| Function | Description |
|----------|-------------|
| `.linear` | Constant speed |
| `.ease` | Default |
| `.easeIn` | Start slow |
| `.easeOut` | End slow |
| `.easeInOut` | Slow start and end |
| `.easeOutBack` | Overshoot |
| `.easeOutBounce` | Bounce |

---

{#binded-elements}

## Binded Elements

```zig
var binded_box: Vapor.Binded = .{};
var search_box: Vapor.Binded = .{};

fn mount() void {
    search_box.focus();
}

fn render() void {
    Box()
        .ref(&binded_box)
        .children({ /* ... */ });
    
    TextField(.string)
        .ref(&search_box)
        .val(&search_box.text)
        .end();
}

// Get bounds
fn getPosition() void {
    if (binded_box.getBoundingClientRect()) |bounds| {
        const x = bounds.left;
        const y = bounds.top;
        const w = bounds.width;
        const h = bounds.height;
    }
}

// Scroll
binded_box.scrollToTop(100);
binded_box.scrollIntoView(.{ .block = .nearest });
```

---

{#conditionals-and-loops}

## Conditionals & Loops

### Conditionals

```zig
fn render() void {
    if (show_modal) {
        Modal.render();
    }
    
    // Ternary in styles
    Text("Status")
        .font(16, 400, if (active) .palette(.tint) else .palette(.text_color))
        .end();
    
    // Conditional rendering
    Box()
        .background(if (hovered) .palette(.tint) else .transparent)
        .children({
            if (loading) {
                Spinner.render();
            } else {
                Text("Content").end();
            }
        });
}
```

### Loops

```zig
fn render() void {
    Stack().children({
        for (items) |item| {
            Text(item.name).end();
        }
    });
    
    // With index
    List().children({
        for (items, 0..) |item, i| {
            ListItem().children({
                TextFmt("{d}. {s}", .{i + 1, item.name}).end();
            });
        }
    });
    
    // Range
    Box().children({
        for (0..5) |i| {
            Text(i).end();
        }
    });
}
```

---

{#utility-functions}

## Utility Functions

### Formatting

```zig
// Frame-scoped formatted string
const text = Vapor.fmtln("Count: {d}", .{counter});

// Print to console
Vapor.print("Debug: {s}", .{message});
Vapor.printErr("Error: {any}", .{err});
```

### DOM Utilities

```zig
// Alert
Vapor.alert("Message");

// Scroll into view
Vapor.scrollIntoView(element_id, .{ .block = .nearest });

// Get bounds
if (Vapor.getBoundingClientRect(element_id)) |bounds| {
    // Use bounds
}

// Query components
const heading_ids = Vapor.queryComponentIds(.Heading) catch &.{};
```

### File Operations

```zig
const File = Vapor.FileReader;

// Download file
File.downloadFile("data.json", json_content, .@"application/json");
```

---

{#quick-syntax-reference}

## Quick Syntax Reference

| Pattern | Description |
|---------|-------------|
| `Component().children({ ... });` | Container with children |
| `Component().end();` | Leaf element (no children) |
| `Component().style(&style)({ ... });` | Apply style struct with children |
| `.children({ ... })` | Block for child elements |
| `ButtonCtx(fn, .{args})` | Button with context arguments |
| `.onEventCtx(.event, fn, ctx)` | Event handler with context |
| `Vapor.Static.HooksCtx(.mounted, fn, .{})({ ... });` | Lifecycle hook |
| `for (items) \|item\| { ... }` | Loop over items |
| `if (cond) { ... }` | Conditional render |

---

{#common-patterns}

## Common Patterns

### Modal/Overlay

```zig
if (show_modal) {
    // Backdrop
    Box()
        .pos(.full(.fixed))
        .zIndex(999)
        .background(.transparentizeHex(.black, 0.5))
        .children({
            Button(.{ .on_press = closeModal }).size(.full).end();
        });
    
    // Modal content
    Center()
        .pos(.full(.fixed))
        .zIndex(1000)
        .children({
            Box()
                .width(.px(400))
                .padding(.all(24))
                .background(.palette(.background))
                .border(.round(.palette(.border_color), .all(12)))
                .children({
                    Text("Modal Content").end();
                });
        });
}
```

### Dropdown/Select

```zig
var show_dropdown: bool = false;

fn toggleDropdown() void {
    show_dropdown = !show_dropdown;
}

fn render() void {
    Box().pos(.relative).children({
        Button(.{ .on_press = toggleDropdown }).children({
            Text("Select Option").end();
        });
        
        if (show_dropdown) {
            Stack()
                .pos(.tl(.px(0), .percent(100), .absolute))
                .zIndex(100)
                .background(.palette(.background))
                .border(.round(.palette(.border_color), .all(8)))
                .shadow(.card(.transparentizeHex(.black, 0.1)))
                .children({
                    for (options) |option| {
                        ButtonCtx(selectOption, .{option}).children({
                            Text(option.label).end();
                        });
                    }
                });
        }
    });
}
```

### Form with Validation

```zig
var email: []const u8 = "";
var error_message: ?[]const u8 = null;

fn validateEmail() bool {
    if (email.len == 0) {
        error_message = "Email is required";
        return false;
    }
    if (std.mem.indexOf(u8, email, "@") == null) {
        error_message = "Invalid email format";
        return false;
    }
    error_message = null;
    return true;
}

fn submit() void {
    if (validateEmail()) {
        // Submit form
    }
}

fn render() void {
    Stack().spacing(8).children({
        Label("Email").end();
        TextField(.email)
            .bind(&email)
            .border(.round(
                if (error_message != null) .hex("#FF0000") else .palette(.border_color),
                .all(8)
            ))
            .end();
        if (error_message) |err| {
            Text(err).font(12, 400, .hex("#FF0000")).end();
        }
        Button(.{ .on_press = submit }).children({
            Text("Submit").end();
        });
    });
}
```

