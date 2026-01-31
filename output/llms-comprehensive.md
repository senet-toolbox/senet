# Vapor Framework - Complete Development Guide

## Overview

Vapor is a Zig-based WebAssembly UI framework for building web applications. It compiles to approximately 28KB for a basic application including routing, making it extremely lightweight compared to JavaScript frameworks.

### Key Differences from React/Vue/Svelte

- No virtual DOM in JavaScript - runs in WebAssembly
- No hooks or signals required for basic reactivity
- No JSX transpilation - pure Zig syntax
- State is just variables declared outside render functions
- Direct compilation to WebAssembly

---

## Critical Rules

### 1. State Location

Variables MUST be declared OUTSIDE render functions. Variables inside render() reset every frame.

```zig
// ❌ WRONG - resets every render
fn render() void {
    var count: u32 = 0;  // Always 0!
}

// ✅ CORRECT - persists between renders
var count: u32 = 0;

fn render() void {
    Text(count).end();
}
```

### 2. String Copying

User input from TextField points to a reusable buffer. You MUST copy it before storing.

```zig
var input_text: []const u8 = "";
var saved_items: [100][]const u8 = undefined;
var item_count: usize = 0;

// ❌ WRONG - input_text will be overwritten
fn saveWrong() void {
    saved_items[item_count] = input_text;
}

// ✅ CORRECT - copy to persistent memory
fn saveCorrect() void {
    const copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;
    saved_items[item_count] = copy;
    item_count += 1;
    input_text = "";
}
```

### 3. Syntax Patterns

```zig
// Containers with builder chain → .children({})
Box().padding(.all(20)).children({
    Text("Hello").end();
});

// Containers with style struct → direct block ({})
Box().style(&my_style)({
    Text("Hello").end();
});

// ❌ WRONG - cannot use .children() after .style()
Box().style(&my_style).children({ });

// Leaf elements → always .end()
Text("Hello").end();
TextField(.string).bind(&text).end();
Icon(.search).end();
```

### 4. Button Handlers

```zig
// Button - handler takes NO parameters
fn handleClick() void { }
Button(handleClick)

// ButtonCtx - handler receives the args
fn handleDelete(index: usize) void { }
ButtonCtx(handleDelete, .{index})

// ❌ WRONG - Button doesn't pass args
Button(handleDelete, .{index})  // This doesn't exist!
```

### 5. Loop Syntax

```zig
// Value only
for (items) |item| { }

// Index only
for (0..items.len) |i| { }

// Both value AND index (note the 0..)
for (items, 0..) |item, i| { }

// ❌ WRONG - invalid syntax
for (items) |_, i| { }  // Won't compile!
```

### 6. Required Imports

Always include these at the top of your file:

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.ButtonCtx;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const TextFmt = Vapor.TextFmt;
const Icon = Vapor.Icon;
const Animation = Vapor.Animation;
```

---

## Application Setup

### main.zig - Entry Point

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;

export fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Home, null);
    Vapor.Page(.{ .route = "/about" }, About, aboutDeinit);
}

var counter: u32 = 0;

fn increment() void {
    counter += 1;
}

fn Home() void {
    Button(increment).children({
        Text("Increment").end();
    });
    Text(counter).end();
}

fn About() void {
    Text("About Page").end();
}

fn aboutDeinit() void {
    // Called when navigating away from /about
}
```

### Page in Separate File

```zig
// routes/home/Page.zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;

var message: []const u8 = "Welcome!";

pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn render() void {
    Box().children({
        Text(message).end();
    });
}
```

```zig
// main.zig
const Vapor = @import("vapor");
const HomePage = @import("routes/home/Page.zig");

export fn init() void {
    Vapor.init(.{});
    HomePage.init();
}
```

---

## Core Components

### Text

```zig
Text("Hello World").end();
Text(counter).end();                              // Numbers
Text(my_string_variable).end();                   // Strings

// Styled
Text("Styled")
    .font(18, 700, .hex("#333333"))               // size, weight, color
    .fontFamily("Montserrat")
    .end();
```

### TextFmt - Formatted Text

```zig
TextFmt("Count: {d}", .{counter}).end();
TextFmt("Hello {s}!", .{name}).end();
TextFmt("Page {d} of {d}", .{current, total}).end();
TextFmt("${d}.00", .{price}).end();  // For prices
```

### Box - Container

```zig
Box().children({
    Text("Child 1").end();
    Text("Child 2").end();
});

// Styled
Box()
    .layout(.center)
    .direction(.column)
    .spacing(16)
    .padding(.all(20))
    .background(.hex("#ffffff"))
    .children({
        Text("Content").end();
    });
```

### Stack - Vertical Container

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
        Text("Centered").end();
    });
```

### Button

```zig
fn handleClick() void {
    // do something
}

Button(handleClick).children({
    Text("Click Me").end();
});

// Styled button
Button(submit)
    .padding(.tblr(12, 12, 24, 24))
    .background(.hex("#4299e1"))
    .border(.round(.transparent, .all(8)))
    .hoverScale()
    .children({
        Text("Submit").font(16, 600, .white).end();
    });
```

### ButtonCtx - Button with Context

```zig
fn deleteItem(index: usize) void {
    // delete item at index
}

fn toggleItem(id: u32, completed: bool) void {
    // toggle item
}

// Pass single argument
ButtonCtx(deleteItem, .{index}).children({
    Text("Delete").end();
});

// Pass multiple arguments
ButtonCtx(toggleItem, .{item.id, item.completed}).children({
    Text("Toggle").end();
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
    .border(.round(.hex("#e2e8f0"), .all(8)))
    .end();

// Input types
TextField(.string)     // Text
TextField(.int)        // Numbers  
TextField(.password)   // Password
TextField(.email)      // Email
```

### TextField with Enter Key Handler

```zig
var input_text: []const u8 = "";

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        submitForm();
    }
}

TextField(.string)
    .bind(&input_text)
    .onEvent(.keydown, handleKeyDown)
    .placeholder("Press Enter to submit")
    .end();
```

### TextArea

```zig
var description: []const u8 = "";

Vapor.TextArea()
    .background(.palette(.background))
    .bind(&description)
    .ariaLabel("Description")
    .width(.percent(100))
    .height(.px(100))
    .outline(.none)
    .border(.solid(.tblr(1, 3, 1, 1), .palette(.border_color_light), .all(6)))
    .padding(.all(8))
    .font(16, 300, .palette(.text_color))
    .fontFamily("IBM Plex Sans,monospace")
    .resize(.none)
    .end();
```

### Link

```zig
Link(.{ .url = "/about" }).children({
    Text("Go to About").end();
});

Link(.{ .url = "https://example.com" })
    .textDecoration(.none)
    .children({
        Text("External Link").end();
    });
```

### Image

```zig
Image(.{ .src = "/images/logo.png" })
    .width(.px(200))
    .height(.px(100))
    .end();

// With radius for avatars
Vapor.Image(.{ .src = "/assets/avatar.webp" })
    .width(.px(40))
    .height(.px(40))
    .radius(.all(999))
    .end();
```

### Icon

```zig
Icon(.search).end();
Icon(.plus).font(24, 300, .hex("#4299e1")).end();
Icon(.cart).font(18, 400, .palette(.text_color)).end();

// Common icons: .search, .plus, .minus, .cart, .heart, .star, .trash,
// .edit, .eye, .check, .x_lg, .arrow_left, .arrow_right, .chevron_down
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

## Styling

### Builder Pattern

```zig
Box()
    .layout(.center)
    .direction(.column)
    .spacing(16)
    .padding(.all(20))
    .background(.hex("#f7fafc"))
    .border(.round(.hex("#e2e8f0"), .all(8)))
    .children({
        Text("Content").end();
    });
```

### Style Struct

```zig
const card_style = Vapor.Style{
    .layout = .center,
    .padding = .all(24),
    .visual = .{
        .background = .white,
        .border = .round(.hex("#e2e8f0"), .all(12)),
        .shadow = .card(.hex("#00000011")),
    },
};

// Apply with direct block - NOT .children()
Box().style(&card_style)({
    Text("Card Content").end();
});
```

### Layout Values

```zig
.layout(.center)              // Center both axes
.layout(.left_center)         // Left horizontal, center vertical
.layout(.right_center)        // Right horizontal, center vertical
.layout(.top_left)            // Top left
.layout(.top_center)          // Top center
.layout(.top_right)           // Top right
.layout(.bottom_left)         // Bottom left
.layout(.bottom_center)       // Bottom center
.layout(.bottom_right)        // Bottom right
.layout(.x_between_center)    // Space between horizontal, center vertical
.layout(.x_even_center)       // Evenly distributed horizontal, center vertical
```

### Sizing

```zig
.width(.px(200))              // Fixed pixels
.width(.percent(100))         // Percentage
.width(.fit)                  // Fit content
.width(.grow)                 // Flex grow
.height(.px(100))
.height(.auto)
.height(.percent(100))

// Shorthand
.hw(.px(100), .px(200))       // height, width
.size(.square_px(100))        // 100x100 square
.size(.full)                  // 100% width and height
```

### Spacing & Padding

```zig
.spacing(16)                      // Gap between children
.padding(.all(20))                // All sides
.padding(.horizontal(16))         // Left & right (alias: .xy(16, 0))
.padding(.vertical(12))           // Top & bottom
.padding(.tblr(10, 10, 20, 20))   // top, bottom, left, right
.padding(.xy(16, 12))             // horizontal, vertical
.margin(.all(8))
.margin(.b(16))                   // Bottom only
.margin(.t(16))                   // Top only
.margin(.r(12))                   // Right only
.margin(.l(12))                   // Left only
```

### Colors & Backgrounds

```zig
.hex("#FF5733")                   // Hex color
.white
.black
.transparent
.palette(.text_color)             // Theme color
.palette(.tint)
.palette(.background)
.palette(.border_color_light)
.palette(.highlight_color)
.palette(.danger)

// Backgrounds
.background(.hex("#ffffff"))
.background(.transparent)
.background(.palette(.background))
.background(.transparentizeHex(.palette(.tint), 0.2))  // With opacity
```

### Borders

```zig
.border(.none)
.border(.simple(.hex("#e2e8f0")))
.border(.round(.hex("#e2e8f0"), .all(8)))       // color, radius
.border(.round(.transparent, .all(99)))         // Fully rounded (pills, avatars)
.border(.solid(.all(2), .hex("#4299e1"), .all(8)))  // thickness, color, radius
.border(.top(1, .palette(.border_color_light)))
.border(.bottom(1, .palette(.border_color_light)))
.border(.right(1, .palette(.border_color_light)))
```

### Typography

```zig
.font(16, 400, .hex("#333333"))   // size, weight, color
.font(24, 700, null)              // size, weight, inherit color
.fontSize(18)
.fontWeight(700)
.fontFamily("Montserrat")
.fontFamily("IBM Plex Mono,monospace")
.textDecoration(.none)
.textDecoration(.underline)
.textDecoration(.line_through)
.ellipsis(.dot)                   // Text overflow with ellipsis
```

### Shadows

```zig
.newShadow(Vapor.Types.NewShadow.init()
    .drop(4, 4, 4, .transparentizeHex(.black, 0.1)))

.newShadow(Vapor.Types.NewShadow.init()
    .inset(0, -2, .transparentizeHex(.black, 0.2))
    .drop(0, 1, 3, .transparentizeHex(.black, 0.1)))
```

### Interactivity

```zig
.cursor(.pointer)
.pointer()                        // Shorthand for pointer cursor
.hoverScale()
.hoverBackground(.hex("#4299e1"))
.hoverText(.white)
.duration(200)                    // Transition duration (ms)
.duration(150)

// Hover state object
.hover(.{
    .background = .palette(.highlight_color),
    .text_color = .palette(.tint),
    .transform = .scaleDecimal(1.1),
})
```

### Positioning

```zig
.pos(.relative)
.pos(.absolute)
.pos(.fixed)
.pos(.full(.fixed))               // Full screen fixed
.pos(.tr(.px(44), .px(0), .absolute))  // Top-right absolute
.pos(.br(.px(0), .px(0), .absolute))   // Bottom-right absolute
.pos(.bl(.px(-8), .px(48), .absolute)) // Bottom-left absolute
.zIndex(100)
.zIndex(999)
.zIndex(1000)
```

### Scrolling

```zig
.scroll(.scroll_y())              // Vertical scroll
.scroll(.scroll_x())              // Horizontal scroll
```

### Layers and Decorations

```zig
.layer(.line(1, 4, .diagonal_down, .palette(.grid_color)))
.layer(.line(2, 4, .diagonal_up, .palette(.grid_color)))
.layer(.grid(14, 1, .transparentizeHex(.black, 0.05)))
.layer(.dot(0.5, 6, .transparentizeHex(.palette(.tint), 0.3)))
```

---

## State Management

### Basic State

```zig
// State declared OUTSIDE render
var count: i32 = 0;
var message: []const u8 = "Hello";
var is_loading: bool = false;

fn increment() void {
    count += 1;
}

fn setMessage(new_message: []const u8) void {
    message = new_message;
}

fn render() void {
    Text(count).end();
    Text(message).end();
    
    Button(increment).children({
        Text("Add").end();
    });
}
```

### Dynamic Arrays

```zig
const Product = struct {
    id: usize,
    name: []const u8,
    price: i32,
    quantity: u32 = 1,
};

// Initialize in init(), not at declaration
var products: Vapor.Array(Product) = undefined;
var cart: Vapor.Array(Product) = undefined;

pub fn init() void {
    products = Vapor.array(Product, .persist);
    cart = Vapor.array(Product, .persist);
    initSampleData();
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn addToCart(product: *const Product) void {
    // Check if already in cart
    for (cart.items) |*item| {
        if (item.id == product.id) {
            item.quantity += 1;
            return;
        }
    }
    
    // Copy strings to same arena as array
    const name_copy = Vapor.arena(.persist).dupe(u8, product.name) catch return;
    cart.append(.{ 
        .id = product.id,
        .name = name_copy,
        .price = product.price,
        .quantity = 1,
    }) catch return;
}

fn removeFromCart(index: usize) void {
    if (index >= cart.items.len) return;
    _ = cart.orderedRemove(index);
}

fn updateQuantity(index: usize, delta: i32) void {
    if (index >= cart.items.len) return;
    const new_qty = @as(i32, @intCast(cart.items[index].quantity)) + delta;
    if (new_qty <= 0) {
        _ = cart.orderedRemove(index);
    } else {
        cart.items[index].quantity = @intCast(new_qty);
    }
}
```

### Memory Arenas

```zig
// .persist - Lives entire session (user data, app state, cart)
const persist_copy = Vapor.arena(.persist).dupe(u8, text) catch return;
var cart = Vapor.array(Product, .persist);

// .view - Lives until route change (page-specific data)
var search_results = Vapor.array(Result, .view);

// .frame - Lives only during render (temporary formatting)
const display_text = Vapor.fmtln("Count: {d}", .{count});
const formatted_price = Vapor.fmtln("${d}.{d:0>2}", .{dollars, cents});
```

### Arena Decision

```
Is data needed after render?
├── No → .frame
└── Yes → Is data needed after leaving page?
    ├── No → .view
    └── Yes → .persist
```

---

## Event Handling

### Button Events

```zig
// No parameters
fn handleClick() void {
    count += 1;
}
Button(handleClick)

// With parameters via ButtonCtx
fn handleDelete(index: usize) void {
    _ = items.orderedRemove(index);
}
ButtonCtx(handleDelete, .{i})

// Multiple parameters
fn handleQuantityChange(index: usize, delta: i32) void {
    // Update quantity
}
ButtonCtx(handleQuantityChange, .{i, 1})   // Increment
ButtonCtx(handleQuantityChange, .{i, -1})  // Decrement
```

### TextField Events

```zig
fn handleChange(evt: *Vapor.Event) void {
    const new_text = evt.text();
    // Handle change
}

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        submit();
    }
}

TextField(.string)
    .bind(&input_text)
    .onChange(handleChange)
    .onEvent(.keydown, handleKeyDown)
    .end();
```

### Hover Events

```zig
fn handleHover(_: *Vapor.Event) void {
    is_hovered = true;
}

fn handleLeave(_: *Vapor.Event) void {
    is_hovered = false;
}

Box()
    .onHover(handleHover)
    .onLeave(handleLeave)
    .children({ });
```

### Event with Context

```zig
fn handleItemHover(item_id: u32, _: *Vapor.Event) void {
    selected_id = item_id;
}

Box()
    .onEventCtx(.pointerenter, handleItemHover, item.id)
    .children({ });
```

### Handler Signature Reference

| Pattern | Handler Signature |
|---------|------------------|
| `Button(fn)` | `fn() void` |
| `ButtonCtx(fn, .{a, b})` | `fn(A, B) void` |
| `.onChange(fn)` | `fn(*Vapor.Event) void` |
| `.onEvent(.event, fn)` | `fn(*Vapor.Event) void` |
| `.onEventCtx(.event, fn, ctx)` | `fn(Ctx, *Vapor.Event) void` |

---

## Animations

### Defining Animations

```zig
const fade_in = Animation.init("fade-in")
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const slide_up = Animation.init("slide-up")
    .prop(.translateY, 20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const pulse_glow = Animation.init("pulse-glow")
    .prop(.opacity, 1, 0.5)
    .duration(2000)
    .dir(.alternate)
    .infinite();

const hover_scale = Animation.init("hover-scale")
    .prop(.scale, 1, 1.05)
    .duration(200)
    .easing(.easeOut);
```

### Building and Using Animations

```zig
pub fn init() void {
    // Build animations at startup
    fade_in.build();
    slide_up.build();
    pulse_glow.build();
    
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn render() void {
    Box()
        .animationEnter("slide-up")
        .children({
            Text("Animated Content").end();
        });
    
    // Continuous animation
    Box()
        .animation("pulse-glow")
        .children({
            Icon(.circle).end();
        });
}
```

---

## UI Component Patterns

### Theme Configuration

```zig
const Theme = struct {
    const bg_base = Vapor.Types.Background.palette(.background);
    const bg_card = Vapor.Types.Background.palette(.background);
    const bg_elevated = Vapor.Types.Background.palette(.background);
    const bg_hover = Vapor.Types.Background.hex("#3f3f46");
    
    const border = Vapor.Types.Color.hex("#27272a");
    const border_light = Vapor.Types.Color.hex("#3f3f46");
    
    const text = Vapor.Types.Color.palette(.text_color);
    const text_secondary = Vapor.Types.Color.hex("#a1a1aa");
    const text_muted = Vapor.Types.Color.hex("#71717a");
    
    const accent = Vapor.Types.Color.hex("#6366f1");
    const success = Vapor.Types.Color.hex("#10b981");
    const warning = Vapor.Types.Color.hex("#f59e0b");
    const danger = Vapor.Types.Color.palette(.danger);
};
```

### Card Component

```zig
fn renderProductCard(product: *const Product) void {
    Box()
        .width(.px(280))
        .padding(.all(16))
        .background(Theme.bg_card)
        .border(.round(.palette(.border_color_light), .all(12)))
        .direction(.column)
        .spacing(12)
        .pointer()
        .duration(150)
        .hover(.{
            .background = .palette(.highlight_color),
        })
        .children({
        // Image
        Vapor.Image(.{ .src = product.image })
            .width(.percent(100))
            .height(.px(180))
            .radius(.all(8))
            .end();
        
        // Title
        Text(product.name)
            .font(16, 600, Theme.text)
            .fontFamily("Montserrat")
            .end();
        
        // Price
        TextFmt("${d}.00", .{product.price})
            .font(20, 700, Theme.accent)
            .fontFamily("Montserrat")
            .end();
        
        // Add to cart button
        ButtonCtx(addToCart, .{product})
            .width(.percent(100))
            .padding(.xy(16, 10))
            .background(.palette(.tint))
            .border(.round(.transparent, .all(8)))
            .layout(.center)
            .spacing(8)
            .children({
            Icon(.cart).font(16, 400, .palette(.background)).end();
            Text("Add to Cart")
                .font(14, 500, .palette(.background))
                .fontFamily("Montserrat")
                .end();
        });
    });
}
```

### Navigation Bar

```zig
fn renderNavBar() void {
    Box()
        .width(.percent(100))
        .height(.px(72))
        .padding(.horizontal(24))
        .background(Theme.bg_base)
        .border(.bottom(1, .palette(.border_color_light)))
        .layout(.x_between_center)
        .children({
        // Logo
        Box()
            .layout(.left_center)
            .spacing(12)
            .children({
            Icon(.shop).font(24, 700, .palette(.tint)).end();
            Text("My Store")
                .font(20, 700, Theme.text)
                .fontFamily("Montserrat")
                .end();
        });
        
        // Nav links
        Box()
            .layout(.center)
            .spacing(32)
            .children({
            renderNavLink("Home", true);
            renderNavLink("Products", false);
            renderNavLink("About", false);
            renderNavLink("Contact", false);
        });
        
        // Actions
        Box()
            .layout(.right_center)
            .spacing(16)
            .children({
            // Search
            Button(toggleSearch, .{})
                .width(.px(40))
                .height(.px(40))
                .layout(.center)
                .children({
                Icon(.search).font(18, 400, Theme.text_secondary).end();
            });
            
            // Cart
            Button(openCart, .{})
                .width(.px(40))
                .height(.px(40))
                .layout(.center)
                .pos(.relative)
                .children({
                Icon(.cart).font(18, 400, Theme.text_secondary).end();
                if (cart.items.len > 0) {
                    Box()
                        .pos(.tr(.px(-4), .px(-4), .absolute))
                        .width(.px(18))
                        .height(.px(18))
                        .background(.palette(.danger))
                        .border(.round(.palette(.danger), .all(99)))
                        .layout(.center)
                        .children({
                        TextFmt("{d}", .{cart.items.len})
                            .font(10, 600, .white)
                            .end();
                    });
                }
            });
        });
    });
}

fn renderNavLink(label: []const u8, is_active: bool) void {
    Box()
        .padding(.xy(12, 8))
        .pointer()
        .children({
        Text(label)
            .font(14, if (is_active) 600 else 400, 
                if (is_active) .palette(.tint) else Theme.text_secondary)
            .fontFamily("Montserrat")
            .end();
    });
}
```

### Sidebar Navigation

```zig
fn renderSidebar() void {
    Stack()
        .width(.px(240))
        .height(.percent(100))
        .padding(.all(20))
        .spacing(24)
        .border(.right(1, .palette(.border_color_light)))
        .children({
        // Logo section
        Box()
            .layout(.left_center)
            .spacing(12)
            .children({
            Box()
                .width(.px(40))
                .height(.px(40))
                .background(.black)
                .border(.round(.black, .all(8)))
                .layout(.center)
                .children({
                Icon(.grid_3x3).font(20, 700, .white).end();
            });
            Text("Dashboard")
                .font(20, 700, Theme.text)
                .fontFamily("Montserrat")
                .end();
        });
        
        // Menu items
        Stack()
            .width(.percent(100))
            .spacing(4)
            .children({
            Text("MENU")
                .font(10, 600, Theme.text_muted)
                .fontFamily("Montserrat")
                .margin(.b(8))
                .end();
            
            for (nav_items) |nav_item| {
                renderSidebarItem(nav_item);
            }
        });
        
        // Spacer
        Box().height(.grow).children({});
        
        // User profile
        Box()
            .width(.percent(100))
            .padding(.all(8))
            .layout(.left_center)
            .spacing(12)
            .children({
            Vapor.Image(.{ .src = "/assets/avatar.webp" })
                .width(.px(32))
                .height(.px(32))
                .radius(.all(999))
                .end();
            Stack()
                .spacing(0)
                .width(.grow)
                .children({
                Text("John Doe")
                    .font(14, 500, Theme.text)
                    .fontFamily("Montserrat")
                    .end();
                Text("Admin")
                    .font(12, 400, Theme.text_muted)
                    .fontFamily("Montserrat")
                    .end();
            });
        });
    });
}

fn renderSidebarItem(item: NavItem) void {
    const is_active = selected_nav == item;
    
    ButtonCtx(selectNav, .{item})
        .width(.percent(100))
        .padding(.xy(14, 10))
        .background(if (is_active) .transparentizeHex(.palette(.tint), 0.1) else .transparent)
        .border(.round(.transparent, .all(8)))
        .layout(.left_center)
        .spacing(12)
        .pointer()
        .duration(150)
        .hover(.{
            .background = .palette(.highlight_color),
        })
        .children({
        Icon(item.icon())
            .font(16, 400, if (is_active) .palette(.tint) else Theme.text_secondary)
            .end();
        Text(item.label())
            .font(14, if (is_active) 500 else 400, 
                if (is_active) .palette(.tint) else Theme.text_secondary)
            .fontFamily("Montserrat")
            .end();
    });
}
```

### Modal/Alert

```zig
const Alert = @import("components/Opaque.zig").Alert;

var modal: Alert = undefined;

pub fn init() void {
    modal = .init(renderModalContent);
    // ...
}

fn openModal() void {
    modal.open();
}

fn closeModal() void {
    modal.close();
}

fn renderModalContent(_: *Alert) void {
    Box()
        .width(.px(400))
        .padding(.all(24))
        .background(Theme.bg_card)
        .border(.round(.palette(.border_color_light), .all(16)))
        .direction(.column)
        .spacing(20)
        .children({
        // Header
        Box()
            .layout(.x_between_center)
            .children({
            Text("Modal Title")
                .font(20, 700, Theme.text)
                .fontFamily("Montserrat")
                .end();
            Button(closeModal, .{})
                .width(.px(36))
                .height(.px(36))
                .layout(.center)
                .children({
                Icon(.x_lg).font(16, 400, Theme.text_secondary).end();
            });
        });
        
        // Content
        Text("Modal content goes here...")
            .font(14, 400, Theme.text_secondary)
            .fontFamily("Montserrat")
            .end();
        
        // Actions
        Box()
            .layout(.right_center)
            .spacing(12)
            .children({
            Button(closeModal, .{})
                .padding(.xy(16, 10))
                .border(.round(.palette(.border_color_light), .all(8)))
                .children({
                Text("Cancel")
                    .font(14, 500, Theme.text_secondary)
                    .fontFamily("Montserrat")
                    .end();
            });
            Button(confirmAction, .{})
                .padding(.xy(16, 10))
                .background(.palette(.tint))
                .border(.round(.transparent, .all(8)))
                .children({
                Text("Confirm")
                    .font(14, 500, .palette(.background))
                    .fontFamily("Montserrat")
                    .end();
            });
        });
    });
}

fn render() void {
    // ... main content ...
    
    // Render modal overlay
    modal.render();
}
```

### Sheet (Slide-in Panel)

```zig
const Sheet = @import("components/Sheet.zig");

var cart_sheet: Sheet = undefined;

pub fn init() void {
    cart_sheet = Sheet.init(.right);  // .right, .left, .top, .bottom
    cart_sheet.content = renderCartContent;
    // ...
}

fn openCart() void {
    cart_sheet.open();
}

fn closeCart() void {
    cart_sheet.close();
}

fn renderCartContent(_: *Sheet) void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(24))
        .spacing(24)
        .children({
        // Header
        Box()
            .layout(.x_between_center)
            .children({
            Text("Shopping Cart")
                .font(20, 700, Theme.text)
                .fontFamily("Montserrat")
                .end();
            Button(closeCart, .{})
                .width(.px(36))
                .height(.px(36))
                .layout(.center)
                .children({
                Icon(.x_lg).font(16, 400, Theme.text_secondary).end();
            });
        });
        
        // Cart items
        Stack()
            .width(.percent(100))
            .height(.grow)
            .spacing(16)
            .scroll(.scroll_y())
            .children({
            for (cart.items, 0..) |item, i| {
                renderCartItem(&item, i);
            }
        });
        
        // Total and checkout
        Box()
            .width(.percent(100))
            .padding(.t(16))
            .border(.top(1, .palette(.border_color_light)))
            .direction(.column)
            .spacing(16)
            .children({
            Box()
                .layout(.x_between_center)
                .children({
                Text("Total")
                    .font(18, 600, Theme.text)
                    .fontFamily("Montserrat")
                    .end();
                TextFmt("${d}.00", .{calculateTotal()})
                    .font(24, 700, Theme.accent)
                    .fontFamily("Montserrat")
                    .end();
            });
            
            Button(checkout, .{})
                .width(.percent(100))
                .padding(.xy(20, 14))
                .background(.palette(.tint))
                .border(.round(.transparent, .all(8)))
                .layout(.center)
                .children({
                Text("Checkout")
                    .font(16, 600, .palette(.background))
                    .fontFamily("Montserrat")
                    .end();
            });
        });
    });
}

fn render() void {
    // ... main content ...
    
    // Render sheet
    cart_sheet.render();
}
```

### Toast Notifications

```zig
const Toast = @import("components/Toast.zig");

pub fn init() void {
    Toast.new();
    // ...
}

fn addToCart(product: *const Product) void {
    // ... add logic ...
    Toast.success(.{ 
        .title = "Added to Cart", 
        .description = "Item has been added to your cart" 
    });
}

fn removeFromCart(index: usize) void {
    // ... remove logic ...
    Toast.warning(.{ 
        .title = "Item Removed", 
        .description = "Item has been removed from your cart" 
    });
}

fn showError() void {
    Toast.err(.{ 
        .title = "Error", 
        .description = "Something went wrong" 
    });
}

fn showInfo() void {
    Toast.info(.{ 
        .title = "Info", 
        .description = "Here's some information" 
    });
}
```

### Select/Dropdown

```zig
const SelectStruct = @import("components/Select.zig");
const Select = SelectStruct.Select;

const SortOption = enum {
    price_low,
    price_high,
    newest,
    popular,
    
    pub fn label(self: SortOption) []const u8 {
        return switch (self) {
            .price_low => "Price: Low to High",
            .price_high => "Price: High to Low",
            .newest => "Newest First",
            .popular => "Most Popular",
        };
    }
};

var sort_select: Select(SortOption) = undefined;
var current_sort: SortOption = .newest;

var sort_options = [_]Select(SortOption).Item{
    .{ .value = .price_low, .label = "Price: Low to High" },
    .{ .value = .price_high, .label = "Price: High to Low" },
    .{ .value = .newest, .label = "Newest First" },
    .{ .value = .popular, .label = "Most Popular" },
};

pub fn init() void {
    SelectStruct.new();
    
    sort_select = .fromItems(&sort_options);
    sort_select.trigger = "Sort By";
    sort_select.on_select = handleSortChange;
    // ...
}

fn handleSortChange(_: *Select(SortOption), item: *Select(SortOption).Item) void {
    current_sort = item.value;
    // Re-sort products
}

fn render() void {
    Box()
        .width(.px(180))
        .children({
        sort_select.renderPos(.bottom);  // .bottom, .top
    });
}
```

### Tooltip

```zig
const Tooltip = @import("components/Tooltip.zig");

pub fn init() void {
    Tooltip.new();
    // ...
}

fn TooltipTrigger(label: []const u8) void {
    Icon(.info_circle)
        .font(14, 400, Theme.text_muted)
        .end();
}

fn TooltipContent(message: []const u8) void {
    Box()
        .width(.px(200))
        .padding(.all(12))
        .background(Theme.bg_card)
        .border(.round(.palette(.border_color_light), .all(8)))
        .children({
        Text(message)
            .font(12, 400, Theme.text_secondary)
            .fontFamily("Montserrat")
            .end();
    });
}

fn render() void {
    Tooltip.create(.{
        .background = .palette(.background),
        .stroke_color = .palette(.border_color_light),
    })
        .Trigger(TooltipTrigger, .{"Help"})
        .Component(TooltipContent, .{"This is helpful information"})
        .end();
}
```

### Progress Bar

```zig
const ProgressBar = @import("components/Opaque.zig").ProgressBar;

var progress_bar: ProgressBar = undefined;

pub fn init() void {
    progress_bar = ProgressBar.init(Vapor.arena(.persist), .{
        .width = 200,
        .height = 8,
        .color = .palette(.tint),
        .background = .transparentize(.palette(.text_color), 0.1),
    });
    progress_bar.setProgress(0.75);  // 75%
    // ...
}

fn render() void {
    Box()
        .layout(.left_center)
        .spacing(12)
        .children({
        progress_bar.render();
        TextFmt("{d}%", .{75})
            .font(14, 500, Theme.text)
            .fontFamily("Montserrat")
            .end();
    });
}
```

---

## Common Patterns

### Conditional Rendering

```zig
fn render() void {
    if (is_loading) {
        Center().height(.percent(100)).children({
            Text("Loading...").end();
        });
    } else if (products.items.len == 0) {
        Center().height(.percent(100)).children({
            Stack().layout(.center).spacing(16).children({
                Icon(.inbox).font(48, 400, Theme.text_muted).end();
                Text("No products found")
                    .font(18, 400, Theme.text_muted)
                    .fontFamily("Montserrat")
                    .end();
            });
        });
    } else {
        // Render products
        for (products.items) |*product| {
            renderProductCard(product);
        }
    }
    
    // Conditional styling
    Box()
        .background(if (is_selected) .palette(.tint) else .transparent)
        .children({ });
}
```

### Grid Layout

```zig
fn renderProductGrid() void {
    Box()
        .width(.percent(100))
        .layout(.top_left)
        .wrap(.wrap)
        .spacing(24)
        .children({
        for (products.items) |*product| {
            renderProductCard(product);
        }
    });
}
```

### Search and Filter

```zig
var search_query: []const u8 = "";
var selected_category: ?Category = null;
var price_filter: PriceRange = .all;

fn matchesFilter(product: *const Product) bool {
    // Search filter
    if (search_query.len > 0) {
        const name_lower = std.ascii.allocLowerString(Vapor.arena(.frame), product.name) catch return true;
        const query_lower = std.ascii.allocLowerString(Vapor.arena(.frame), search_query) catch return true;
        if (std.mem.indexOf(u8, name_lower, query_lower) == null) return false;
    }
    
    // Category filter
    if (selected_category) |cat| {
        if (product.category != cat) return false;
    }
    
    // Price filter
    switch (price_filter) {
        .all => {},
        .under_50 => if (product.price >= 50) return false,
        .range_50_100 => if (product.price < 50 or product.price > 100) return false,
        .over_100 => if (product.price <= 100) return false,
    }
    
    return true;
}

fn render() void {
    for (products.items) |*product| {
        if (!matchesFilter(product)) continue;
        renderProductCard(product);
    }
}
```

### Pagination

```zig
const ITEMS_PER_PAGE: usize = 12;
var current_page: usize = 0;

fn getTotalPages() usize {
    return (products.items.len + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE;
}

fn getPageItems() []Product {
    const start = current_page * ITEMS_PER_PAGE;
    const end = @min(start + ITEMS_PER_PAGE, products.items.len);
    return products.items[start..end];
}

fn nextPage() void {
    if (current_page < getTotalPages() - 1) {
        current_page += 1;
    }
}

fn prevPage() void {
    if (current_page > 0) {
        current_page -= 1;
    }
}

fn goToPage(page: usize) void {
    current_page = page;
}

fn renderPagination() void {
    const total_pages = getTotalPages();
    
    Box()
        .layout(.center)
        .spacing(8)
        .children({
        // Previous button
        Button(prevPage, .{})
            .padding(.xy(12, 8))
            .background(if (current_page == 0) .palette(.highlight_color) else .palette(.tint))
            .border(.round(.transparent, .all(6)))
            .children({
            Icon(.chevron_left)
                .font(14, 400, if (current_page == 0) Theme.text_muted else .palette(.background))
                .end();
        });
        
        // Page numbers
        for (0..total_pages) |i| {
            ButtonCtx(goToPage, .{i})
                .width(.px(36))
                .height(.px(36))
                .layout(.center)
                .background(if (i == current_page) .palette(.tint) else .transparent)
                .border(.round(.palette(.border_color_light), .all(6)))
                .children({
                TextFmt("{d}", .{i + 1})
                    .font(14, 500, if (i == current_page) .palette(.background) else Theme.text)
                    .end();
            });
        }
        
        // Next button
        Button(nextPage, .{})
            .padding(.xy(12, 8))
            .background(if (current_page >= total_pages - 1) .palette(.highlight_color) else .palette(.tint))
            .border(.round(.transparent, .all(6)))
            .children({
            Icon(.chevron_right)
                .font(14, 400, if (current_page >= total_pages - 1) Theme.text_muted else .palette(.background))
                .end();
        });
    });
}
```

### Form Handling

```zig
var form_name: []const u8 = "";
var form_email: []const u8 = "";
var form_message: []const u8 = "";
var form_errors: FormErrors = .{};

const FormErrors = struct {
    name: ?[]const u8 = null,
    email: ?[]const u8 = null,
    message: ?[]const u8 = null,
};

fn validateForm() bool {
    form_errors = .{};
    var is_valid = true;
    
    if (form_name.len == 0) {
        form_errors.name = "Name is required";
        is_valid = false;
    }
    
    if (form_email.len == 0) {
        form_errors.email = "Email is required";
        is_valid = false;
    } else if (std.mem.indexOf(u8, form_email, "@") == null) {
        form_errors.email = "Invalid email address";
        is_valid = false;
    }
    
    if (form_message.len == 0) {
        form_errors.message = "Message is required";
        is_valid = false;
    }
    
    return is_valid;
}

fn submitForm() void {
    if (!validateForm()) return;
    
    // Process form...
    Toast.success(.{ .title = "Success", .description = "Form submitted successfully" });
    
    // Clear form
    form_name = "";
    form_email = "";
    form_message = "";
}

fn renderFormField(
    label: []const u8, 
    value: *[]const u8, 
    error_msg: ?[]const u8,
    field_type: enum { text, email }
) void {
    Stack()
        .spacing(6)
        .children({
        Text(label)
            .font(14, 500, Theme.text)
            .fontFamily("Montserrat")
            .end();
        
        TextField(if (field_type == .email) .email else .string)
            .bind(value)
            .width(.percent(100))
            .padding(.all(12))
            .border(.round(
                if (error_msg != null) Theme.danger else .palette(.border_color_light), 
                .all(8)
            ))
            .end();
        
        if (error_msg) |err| {
            Text(err)
                .font(12, 400, Theme.danger)
                .fontFamily("Montserrat")
                .end();
        }
    });
}
```

---

## Quick Reference

### Syntax Patterns

| Element Type | Builder Chain | Style Struct |
|--------------|---------------|--------------|
| Container (Box, Stack, Center) | `.children({})` | `.style(&s)({})` |
| Button | `.children({})` | `.style(&s)({})` |
| Leaf (Text, TextField, Icon, Image) | `.end()` | `.end()` |

### Handler Signatures

| Pattern | Signature |
|---------|-----------|
| `Button(fn)` | `fn() void` |
| `ButtonCtx(fn, .{a, b})` | `fn(A, B) void` |
| `.onEvent(.event, fn)` | `fn(*Vapor.Event) void` |
| `.onEventCtx(.event, fn, ctx)` | `fn(Ctx, *Vapor.Event) void` |

### Arena Selection

| Arena | Lifetime | Use For |
|-------|----------|---------|
| `.persist` | Session | User data, cart, saved items |
| `.view` | Until route change | Page-specific data |
| `.frame` | Single render | Formatted strings, temporary data |

### Common Layout Patterns

```zig
// Full-width centered content
Center().width(.percent(100)).children({});

// Horizontal space between
Box().layout(.x_between_center).children({});

// Vertical stack with gap
Stack().spacing(16).children({});

// Grid wrap
Box().wrap(.wrap).spacing(24).children({});

// Fixed sidebar + fluid content
Box().layout(.top_left).children({
    Stack().width(.px(240)).children({});  // Sidebar
    Stack().width(.grow).children({});      // Content
});
```

### Common Styling

```zig
// Card
.padding(.all(20))
.background(.palette(.background))
.border(.round(.palette(.border_color_light), .all(12)))

// Button primary
.padding(.xy(16, 10))
.background(.palette(.tint))
.border(.round(.transparent, .all(8)))
.hoverScale()

// Button secondary
.padding(.xy(16, 10))
.background(.transparent)
.border(.round(.palette(.border_color_light), .all(8)))

// Avatar
.width(.px(40))
.height(.px(40))
.border(.round(.transparent, .all(99)))

// Badge
.padding(.xy(8, 4))
.background(.transparentizeHex(.palette(.tint), 0.2))
.border(.round(.palette(.tint), .all(4)))
```

---

## Common Mistakes to Avoid

### ❌ State inside render
```zig
fn render() void {
    var count: u32 = 0;  // WRONG! Always 0
}
```
✅ Fix: Declare outside render

### ❌ Not copying user input
```zig
fn save() void {
    saved = input_text;  // WRONG! Points to reusable buffer
}
```
✅ Fix: `saved = Vapor.arena(.persist).dupe(u8, input_text) catch return;`

### ❌ .children() after .style()
```zig
Box().style(&s).children({ })  // WRONG!
```
✅ Fix: `Box().style(&s)({ })`

### ❌ Wrong loop syntax
```zig
for (items) |_, i| { }  // WRONG!
```
✅ Fix: `for (items, 0..) |item, i| { }`

### ❌ Forgetting .end() on leaf elements
```zig
Text("Hello")  // WRONG! Missing .end()
```
✅ Fix: `Text("Hello").end()`

### ❌ Using Button with args
```zig
Button(handler, .{arg})  // WRONG! Doesn't exist
```
✅ Fix: `ButtonCtx(handler, .{arg})`

### ❌ Missing imports
```zig
Box().children({ })  // WRONG! Box not imported
```
✅ Fix: Add `const Box = Vapor.Box;`

### ❌ Mismatched arena lifetimes
```zig
var todos = Vapor.array(TodoItem, .persist);
const text = Vapor.arena(.frame).dupe(u8, input) catch return;
todos.append(.{ .text = text }) catch return;  // Dangling pointer!
```
✅ Fix: Use same arena: `Vapor.arena(.persist).dupe(...)`
