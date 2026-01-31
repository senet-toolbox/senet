# Vapor Framework - Complete LLM Reference

# Last updated: 2025-01-24 | Estimated tokens: ~18,000

<overview>
Vapor is a Zig-based WebAssembly UI framework for building web applications.

KEY DIFFERENCES FROM REACT/VUE/SVELTE:

- No virtual DOM in JavaScript - runs in WebAssembly
- No hooks or signals required for basic reactivity
- No JSX transpilation - pure Zig syntax
- State is just variables declared outside render functions
- Compiles to ~28KB for Hello World (including router)
  </overview>

<critical_rules>

## RULES YOU MUST FOLLOW

### 1. STATE LOCATION

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

### 2. STRING COPYING

Strings are copied to a string table internally. There is no need to manage the memory yourself.

```zig
// ✅ CORRECT - copy to persistent memory
fn saveCorrect() void {
    const copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;
    saved_items[item_count] = copy;
    item_count += 1;
    input_text = "";
}
```

### 3. SYNTAX PATTERNS

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

### 4. BUTTON HANDLERS

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

### 5. LOOP SYNTAX

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

### 6. REQUIRED IMPORTS

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
```

</critical_rules>

<application_setup>

## Application Setup

### main.zig - Entry Point

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;

// Initialize Vapor
export fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Home, null);
    Vapor.Page(.{ .route = "/about" }, About, aboutDeinit);
}

// State lives OUTSIDE render
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

</application_setup>

<components>
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
// Simple button - handler has no parameters
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
// Handler receives the arguments
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

fn submitForm() void {
    if (input_text.len == 0) return;
    // Process input...
    input_text = "";
}

TextField(.string)
    .bind(&input_text)
    .onEvent(.keydown, handleKeyDown)
    .placeholder("Press Enter to submit")
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
```

### Icon

```zig
Icon(.search).end();
Icon(.plus).font(24, 300, .hex("#4299e1")).end();
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

</components>

<styling>
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
```

### Sizing

```zig
.width(.px(200))              // Fixed pixels
.width(.percent(100))         // Percentage
.width(.fit)                  // Fit content
.width(.grow)                 // Flex grow
.height(.px(100))
.height(.auto)

// Shorthand
.hw(.px(100), .px(200))       // height, width
.size(.square_px(100))        // 100x100 square
```

### Spacing & Padding

```zig
.spacing(16)                      // Gap between children
.padding(.all(20))                // All sides
.padding(.horizontal(16))         // Left & right
.padding(.vertical(12))           // Top & bottom
.padding(.tblr(10, 10, 20, 20))   // top, bottom, left, right
.margin(.all(8))
.margin(.b(16))                   // Bottom only
.margin(.t(16))                   // Top only
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

// Backgrounds
.background(.hex("#ffffff"))
.background(.transparent)
```

### Borders

```zig
.border(.none)
.border(.simple(.hex("#e2e8f0")))
.border(.round(.hex("#e2e8f0"), .all(8)))       // color, radius
.border(.solid(.all(2), .hex("#4299e1"), .all(8)))  // thickness, color, radius
```

### Typography

```zig
.font(16, 400, .hex("#333333"))   // size, weight, color
.font(24, 700, null)              // size, weight, inherit color
.fontSize(18)
.fontWeight(700)
.fontFamily("Montserrat")
.textDecoration(.none)
.textDecoration(.underline)
.textDecoration(.line_through)
```

### Interactivity

```zig
.cursor(.pointer)
.hoverScale()
.hoverBackground(.hex("#4299e1"))
.hoverText(.white)
.duration(200)                    // Transition duration (ms)
```

</styling>

<state_management>

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
const TodoItem = struct {
    text: []const u8,
    completed: bool = false,
};

// Initialize in init(), not at declaration
var todos: Vapor.Array(TodoItem) = undefined;

pub fn init() void {
    todos = Vapor.array(TodoItem, .persist);
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn addTodo(text: []const u8) void {
    // Copy string to same arena as array
    const text_copy = Vapor.arena(.persist).dupe(u8, text) catch return;
    todos.append(.{ .text = text_copy }) catch return;
}

fn deleteTodo(index: usize) void {
    if (index >= todos.items.len) return;
    _ = todos.orderedRemove(index);
}

fn toggleTodo(index: usize) void {
    if (index >= todos.items.len) return;
    todos.items[index].completed = !todos.items[index].completed;
}

fn render() void {
    for (todos.items, 0..) |todo, i| {
        Box().children({
            Text(todo.text).end();
            ButtonCtx(deleteTodo, .{i}).children({
                Text("Delete").end();
            });
        });
    }
}
```

### Memory Arenas

```zig
// .persist - Lives entire session (user data, app state)
const persist_copy = Vapor.arena(.persist).dupe(u8, text) catch return;
var todos = Vapor.array(TodoItem, .persist);

// .view - Lives until route change (page-specific data)
var search_results = Vapor.array(Result, .view);

// .frame - Lives only during render (temporary formatting)
const display_text = Vapor.fmtln("Count: {d}", .{count});
```

### Arena Decision

```
Is data needed after render?
├── No → .frame
└── Yes → Is data needed after leaving page?
    ├── No → .view
    └── Yes → .persist
```

</state_management>

<events>
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

| Pattern                        | Handler Signature            |
| ------------------------------ | ---------------------------- |
| `Button(fn)`                   | `fn() void`                  |
| `ButtonCtx(fn, .{a, b})`       | `fn(A, B) void`              |
| `.onChange(fn)`                | `fn(*Vapor.Event) void`      |
| `.onEvent(.event, fn)`         | `fn(*Vapor.Event) void`      |
| `.onEventCtx(.event, fn, ctx)` | `fn(Ctx, *Vapor.Event) void` |

</events>

<complete_todo_example>

## Complete Example: Todo List

This is a fully working todo list with add, delete, and toggle functionality.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const TextField = Vapor.TextField;
const ButtonCtx = Vapor.ButtonCtx;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const TextFmt = Vapor.TextFmt;

// ============================================
// DATA STRUCTURES
// ============================================
const TodoItem = struct {
    text: []const u8,
    completed: bool = false,
};

// ============================================
// STATE (outside render!)
// ============================================
var todos: Vapor.Array(TodoItem) = undefined;
var input_text: []const u8 = "";

// ============================================
// STYLES
// ============================================
const container_style = Vapor.Style{
    .size = .{ .width = .px(400) },
    .padding = .all(24),
    .visual = .{
        .background = .white,
        .border = .round(.hex("#e2e8f0"), .all(12)),
        .shadow = .card(.hex("#00000011")),
    },
};

const todo_item_style = Vapor.Style{
    .layout = .x_between_center,
    .padding = .tblr(12, 12, 16, 16),
    .margin = .b(8),
    .visual = .{
        .background = .hex("#f7fafc"),
        .border = .round(.hex("#e2e8f0"), .all(8)),
    },
};

const add_btn_style = Vapor.Style{
    .padding = .tblr(10, 10, 16, 16),
    .visual = .{
        .background = .hex("#4299e1"),
        .text_color = .white,
        .font_weight = 600,
        .border = .round(.transparent, .all(8)),
    },
    .interactive = .hover_scale(),
};

const delete_btn_style = Vapor.Style{
    .padding = .tblr(6, 6, 12, 12),
    .visual = .{
        .background = .transparent,
        .text_color = .hex("#e53e3e"),
        .font_size = 14,
    },
    .interactive = .hover_scale(),
};

// ============================================
// INITIALIZATION
// ============================================
pub fn init() void {
    todos = Vapor.array(TodoItem, .persist);
    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================
// ACTIONS
// ============================================
fn addTodo() void {
    if (input_text.len == 0) return;

    // CRITICAL: Copy text to persistent memory!
    const text_copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;

    todos.append(.{
        .text = text_copy,
        .completed = false,
    }) catch return;

    input_text = "";
}

fn toggleTodo(index: usize) void {
    if (index >= todos.items.len) return;
    todos.items[index].completed = !todos.items[index].completed;
}

fn deleteTodo(index: usize) void {
    if (index >= todos.items.len) return;
    _ = todos.orderedRemove(index);
}

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        addTodo();
    }
}

// ============================================
// RENDER
// ============================================
fn render() void {
    Center().height(.percent(100)).background(.hex("#edf2f7")).children({
        Box().style(&container_style)({
            // Header
            Text("My Todos")
                .font(28, 700, .hex("#2d3748"))
                .margin(.b(20))
                .end();

            // Input row
            Box().layout(.left_center).spacing(8).margin(.b(16)).children({
                TextField(.string)
                    .bind(&input_text)
                    .placeholder("What needs to be done?")
                    .width(.grow)
                    .padding(.all(12))
                    .border(.round(.hex("#e2e8f0"), .all(8)))
                    .onEvent(.keydown, handleKeyDown)
                    .end();

                Button(addTodo).style(&add_btn_style)({
                    Text("Add").end();
                });
            });

            // Todo list
            Stack().spacing(0).children({
                if (todos.items.len == 0) {
                    Text("No todos yet!")
                        .font(14, 400, .hex("#a0aec0"))
                        .padding(.all(20))
                        .end();
                } else {
                    for (todos.items, 0..) |todo, i| {
                        renderTodoItem(todo, i);
                    }
                }
            });

            // Footer
            if (todos.items.len > 0) {
                TextFmt("{d} item{s}", .{
                    todos.items.len,
                    if (todos.items.len == 1) "" else "s",
                })
                    .font(12, 400, .hex("#a0aec0"))
                    .margin(.t(16))
                    .end();
            }
        });
    });
}

fn renderTodoItem(todo: TodoItem, index: usize) void {
    Box().style(&todo_item_style)({
        // Left side: checkbox + text
        Box().layout(.left_center).children({
            // Checkbox
            ButtonCtx(toggleTodo, .{index})
                .width(.px(24))
                .height(.px(24))
                .layout(.center)
                .border(.round(.hex("#cbd5e0"), .all(4)))
                .margin(.r(12))
                .background(if (todo.completed) .hex("#48bb78") else .white)
                .hoverScale()
                .children({
                    if (todo.completed) {
                        Text("✓").font(14, 700, .white).end();
                    }
                });

            // Todo text
            Text(todo.text)
                .font(16, if (todo.completed) 400 else 500,
                    if (todo.completed) .hex("#a0aec0") else .hex("#2d3748"))
                .textDecoration(if (todo.completed) .line_through else .none)
                .end();
        });

        // Delete button
        ButtonCtx(deleteTodo, .{index}).style(&delete_btn_style)({
            Text("Delete").end();
        });
    });
}
```

</complete_todo_example>

<common_patterns>

## Common Patterns

### Conditional Rendering

```zig
fn render() void {
    if (is_loading) {
        Text("Loading...").end();
    } else {
        Text("Content loaded").end();
    }

    // Conditional styling
    Text("Status")
        .font(16, 400, if (is_active) .hex("#48bb78") else .hex("#a0aec0"))
        .end();

    Box()
        .background(if (is_hovered) .hex("#4299e1") else .transparent)
        .children({ });
}
```

### Looping

```zig
// Just values
for (items) |item| {
    Text(item.name).end();
}

// With index (for delete/toggle operations)
for (items, 0..) |item, i| {
    Box().children({
        Text(item.name).end();
        ButtonCtx(deleteItem, .{i}).children({
            Text("Delete").end();
        });
    });
}

// Range
for (0..5) |i| {
    TextFmt("Item {d}", .{i}).end();
}
```

### Modal/Overlay

```zig
var show_modal: bool = false;

fn openModal() void { show_modal = true; }
fn closeModal() void { show_modal = false; }

fn render() void {
    Button(openModal).children({
        Text("Open Modal").end();
    });

    if (show_modal) {
        // Backdrop
        Box()
            .pos(.full(.fixed))
            .zIndex(999)
            .background(.transparentize(.black, 0.5))
            .children({
                Button(closeModal).size(.full).end();
            });

        // Modal
        Center()
            .pos(.full(.fixed))
            .zIndex(1000)
            .children({
                Box()
                    .width(.px(400))
                    .padding(.all(24))
                    .background(.white)
                    .border(.round(.hex("#e2e8f0"), .all(12)))
                    .children({
                        Text("Modal Content").end();
                        Button(closeModal).children({
                            Text("Close").end();
                        });
                    });
            });
    }
}
```

### Form with Validation

```zig
var email: []const u8 = "";
var error_msg: ?[]const u8 = null;

fn validateAndSubmit() void {
    if (email.len == 0) {
        error_msg = "Email is required";
        return;
    }
    if (std.mem.indexOf(u8, email, "@") == null) {
        error_msg = "Invalid email";
        return;
    }
    error_msg = null;
    // Submit...
}

fn render() void {
    Stack().spacing(8).children({
        TextField(.email)
            .bind(&email)
            .placeholder("Email")
            .border(.round(
                if (error_msg != null) .hex("#e53e3e") else .hex("#e2e8f0"),
                .all(8)
            ))
            .end();

        if (error_msg) |err| {
            Text(err).font(12, 400, .hex("#e53e3e")).end();
        }

        Button(validateAndSubmit).children({
            Text("Submit").end();
        });
    });
}
```

</common_patterns>

<gotchas>
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
const text = Vapor.arena(.frame).dupe(u8, input) catch return;  // WRONG!
todos.append(.{ .text = text }) catch return;  // Dangling pointer!
```

✅ Fix: Use same arena: `Vapor.arena(.persist).dupe(...)`
</gotchas>

<quick_reference>

## Quick Reference

### Syntax Patterns

| Element Type                        | Builder Chain   | Style Struct     |
| ----------------------------------- | --------------- | ---------------- |
| Container (Box, Stack, Center)      | `.children({})` | `.style(&s)({})` |
| Button                              | `.children({})` | `.style(&s)({})` |
| Leaf (Text, TextField, Icon, Image) | `.end()`        | `.end()`         |

### Handler Signatures

| Pattern                        | Signature                    |
| ------------------------------ | ---------------------------- |
| `Button(fn)`                   | `fn() void`                  |
| `ButtonCtx(fn, .{a, b})`       | `fn(A, B) void`              |
| `.onEvent(.event, fn)`         | `fn(*Vapor.Event) void`      |
| `.onEventCtx(.event, fn, ctx)` | `fn(Ctx, *Vapor.Event) void` |

### Arena Selection

| Arena      | Lifetime           | Use For                |
| ---------- | ------------------ | ---------------------- |
| `.persist` | Session            | User data, saved items |
| `.view`    | Until route change | Page-specific data     |
| `.frame`   | Single render      | Formatted strings      |

### Common Imports

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
```

</quick_reference>
