{#basics}

# Basics

The main.zig file is the root entry point for your Vapor application

Vapor is compiled into wasm, and reverb handles the request, response connection with the client.
Once vapor.wasm is loaded on to the client browser, then we generate the dom. This is known as Client Side Rendering (CSR).

![Diagram](/assets/client-server.webp)

{#csr-vs-ssr}

## CSR VS SSR

CSR is the default mode of Vapor. It is the simplest mode, and is the very performant, this site runs in CSR mode.

SSR will not be supported in the future, Tether takes a very strict approach to application architecture, and will never support SSR.
You can read more about why here: [ssr-vs-csr](/docs/vapor/concepts/csr_vs_ssr)

{#creating-a-vapor-app}

### app.zig

The app.zig file is the root entry point for your Vapor application. Here we intialize Vapor, set up our routes, and layouts, as well as our global style variables.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const RootPage = @import("routes/Page.zig");
pub fn instantiate(window_width: f32, window_height: f32, allocator: std.mem.Allocator) void {
    // InitializeVapor
    Vapor.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = allocator,
        .page_node_count = 10 * 1024,
    });

    // Global style variables
    Vapor.setGlobalStyleVariables(.{ // Adds 11kb
        .themes = &[_]Vapor.ThemeDefinition{
            Vapor.ThemeDefinition{ .name = "light", .theme = Theme.Light, .default = true },
            Vapor.ThemeDefinition{ .name = "dark", .theme = Theme.Dark },
        },
    });

    RootPage.init();
}

export fn renderUI(route: [*:0]u8) void {
    Vapor.renderCycle(route);
}
```

{#core-functions}

## Core Functions

{#instantiate}

### Instantiate

The `instantiate` function is called once when the wasm file is loaded. It initializes the Vapor framework and sets up the application environment.

```zig
export fn instantiate(window_width: f32, window_height: f32, allocator: std.mem.Allocator) void {
    // Init vapor.
    Vapor.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = allocator,
    });
}
```

{#renderUI}

### RenderUI

The `renderUI` function is calls the entire render function tree. It is called once per render cycle.
By default, Vapor will call renderUI once per frame, as the default mode of Vapor is immediate mode.

```zig
export fn renderUI(route: [*:0]u8) void {
    Vapor.renderCycle(route);
}
```

{#export}

### export

The `export` keyword gives the wasm bridge access to the zig functions.

```zig
export fn renderUI(route: [*:0]u8) void {
    Vapor.renderCycle(route);
}
```

{#virtual-dom-and-reconciliation}

## Virtual Dom & Reconciliation

The rendering system uses a virtual DOM approach with the following features:

- `Tree Construction`: Builds a UI tree representation in memory

- `Diffing Algorithm`: Compares current and new tree states

- `Dirty Tracking`: Marks nodes that require updates

- `Additions`: Marks nodes that need to be added

- `Removals`: Marks nodes that need to be removed

- `Selective Updates`: Only updates nodes that have changed

Vapor exports a a virtual tree, an array of nodes that are dirty, an array of nodes that need to be added, and an array of nodes that need to be removed.

We can access these via the following commands:

```zig
const dirty_nodes = Vapor.dirty_nodes;
const added_nodes = Vapor.removed_nodes;
const removed_nodes = Vapor.added_nodes;

for (dirty_nodes.items) |node| {
    // Do something with the dirty node
}

```

`Note these are globals and are cleared on every frame`

{#performance}

## Performance

Instead of traversing the entire tree in the JS or native code side, we loop through the arrays of nodes and update those only.

This gives us both the power and control of reconcilation, and virtualization, but also the speed of native code, and simple looping mechanics.

Vapor is extremely fast, and can render thousands of nodes in a single frame, in a worst case sceanrio, with a list of 10,000 nodes, no stable
keys, in which the first node is order removed, the entire render cycle from removal to UI update takes 15ms on a 2021 M1 MacBook Pro.

{#structuring-your-application}

## Structuring your application

Every component type `(Box, Text, Link, Image, Svg, Button, ButtonCycle, ButtonCtx, etc...)` Is nothing more than a function call to add
a node to the UI tree.

![Diagram](/src/assets/tree.svg)

```zig
pub inline fn Node() NodeBody {
    const elem_decl = ElementDefinition{
        .state_type = .static,
        .element_type = .Box,
    };

    LifeCycle.open(elem_decl);
    LifeCycle.configure(elem_decl);
    return LifeCycle.body;
}
```

`LifeCycle` is a struct that handles configuring Nodes, and adding them to the UI tree.
`.open` adds the node to the tree and sets it as the current open node
or parent node.
We return `body` which is a function that allows
for child nodes to be added to the current node.

{#global-components}

### Global Components

Standard Global components, which take no reference to themselves, and instead just operate on global variables contained in their file.
If this Component is rendered in different areas of the codebase they will all use the same global set of variables.

```zig
const std = @import("std");
const Vapor = @import("fabric");
const Static = Vapor.Static;
const Pure = Vapor.Pure;

// Global state
var count: i32 = 0;

fn increment() void {
    count += 1;
}

fn decrement() void {
    count -= 1;
}

pub fn render() void {
    Static.Box.layout(.center).spacing(16).padding(.all(20)).body()({
        Pure.Button(.{ .on_press = decrement })
            .padding(.all(8))
            .borderRadius(.all(4))
            .body()({
            Static.Text("-").font(18, null, .palette(.text_color)).close();
        });

        Pure.TextFmt("{d}", .{count}).font(24, 700, .palette(.text_color)).close();

        Pure.Button(.{ .on_press = increment })
            .padding(.all(8))
            .borderRadius(.all(4))
            .body()({
            Static.Text("+").font(18, null, .palette(.text_color)).close();
        });
    });
}
```

@global_sample.zig

@global_sample.zig

{#instance-components}

### Instance Components

Instance components, which do reference to themselves, and hence can be instantiated multiple times and use their own set of local variables

```zig
const std = @import("std");
const Vapor = @import("fabric");
const Allocator = std.mem.Allocator;
const Signal = Vapor.Signal;
const Static = Vapor.Static;
const Pure = Vapor.Pure;

/// Counter component
const Counter = @This();

initial_value: i32 = 0,
count: Signal(i32) = undefined,

fn increment(counter: *Counter) void {
    counter.count.increment();
}

fn decrement(counter: *Counter) void {
    counter.count.decrement();
}

/// The init function instantiates the local allocator and component signals for the counter
/// The counter.initial_value field is used as the starting value
pub fn init(counter: *Counter) void {
    counter.count.init(counter.initial_value);
}

pub fn deinit(counter: *Counter) void {
    counter.count.deinit();
}

pub fn render(counter: *Counter) void {
    Static.Box.layout(.center).spacing(16).padding(.all(20)).body()({
        Static.CtxButton(decrement, .{counter})
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .body()({
            Static.Text("-").font(18, null, .palette(.text_color)).close();
        });

        Static.TextFmt("Instance State: {d}", .{counter.count.get()}).font(24, 700, .palette(.text_color)).close();

        Static.CtxButton(increment, .{counter})
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .body()({
            Static.Text("+").font(18, null, .palette(.text_color)).close();
        });
    });
}
```

@instance_sample.zig

@instance_sample2.zig

{#its-just-zig}

## Its just Zig

Vapor is just zig, so you can structure the application however you want, there is no magic transpilation,
`comptime` is an incredibly powerful tool, that is part of the language, and can be used to generate various components of different types.

For example, we can use `comptime` to generate a `Counter` with various values types, the `comptime` system is used for the `DataTable` component
in Vapor.

```zig
const Vapor = @import("fabric");
const Signal = Vapor.Signal;
const Static = Vapor.Static;

pub fn Counter(comptime T: type) type {
    return struct {
        var count: T = 0;

        fn increment() void {
            count += 1;
        }

        fn decrement() void {
            count -= 1;
        }

        pub fn render() void {
            Static.Box.layout(.center).spacing(16).padding(.all(20)).body()({
                Static.Button(.{ .on_press = decrement })
                    .padding(.all(8))
                    .border(.simple(.palette(.border_color_light)))
                    .cursor(.pointer)
                    .body()({
                    Static.Text("-").font(18, null, .palette(.text_color)).close();
                });

                Static.TextFmt("Global State: {d}", .{count}).font(24, 700, .palette(.text_color)).close();

                Static.Button(.{ .on_press = increment })
                    .padding(.all(8))
                    .border(.simple(.palette(.border_color_light)))
                    .cursor(.pointer)
                    .body()({
                    Static.Text("+").font(18, null, .palette(.text_color)).close();
                });
            });
        }
    };
}
```
