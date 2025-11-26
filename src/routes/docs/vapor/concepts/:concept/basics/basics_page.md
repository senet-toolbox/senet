{#basics}

# Basics

#### The main.zig file is the root entry point for your Vapor application

![Diagram](/assets/client-server.webp)

{#creating-a-vapor-app}

### main.zig

In main.zig we intialize Vapor, set up our routes, and whatever else we need.
It's simple to set up a Vapor app, all we have to do is import Vapor with `const Vapor = @import("vapor");` and then
call `Vapor.init(.{});` to initialize Vapor within the `init()` function.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;

// Initialize Vapor
export fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Home, null);
}

var counter: u32 = 0;
fn increment() void {
    counter += 1;
}

fn Home() void {
    Button(.{ .on_press = increment }).children({
        Text("Increment").end();
    });
    Text(counter).end();
}
```

{#instantiate}

### Init

The `init` function is called once when the vapor.wasm file is loaded. It initializes the Vapor framework and sets up the application environment.
We add our routes here, these routes are the pages that we can navigate to and from.

```zig
export fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Home, null);
}
```

{#export}

### export

The `export` keyword gives the wasm bridge access to the zig functions.

```zig
export fn init() void {
    // ... init code
}
```

You can create other export functions to interact with JS, from Zig, or vice versa with `extern` functions.
This is useful when you want to integrate various JS libraries into your Vapor app.

⚠️ NOTE: Vapor comes with a plethora of UI components, and libraries.
You can add these via the metal CLI tool. Acorn, is built with **0** dependencies.

{#engine}

## Engine

Vapor is akin to modern game engines, where the entire rendering is handled by the engine.

The rendering system uses a virtual DOM approach with the following features:

1. **Tree Construction**: Builds a UI tree representation in memory

2. **Diffing Algorithm**: Compares current and new tree states

3. **Dirty Tracking**: Marks nodes that require updates

4. **Additions**: Marks nodes that need to be added

5. **Removals**: Marks nodes that need to be removed

6. **Selective Updates**: Only updates nodes that have changed

![Diagram](/src/assets/tree.svg)

Vapor runs the entire render cycle, on every state change. Vapor generates a Virtual Tree (DOM),
and then reconciles the differences between the old and new tree.

This is done in a single pass, and is extremely fast, even with large trees. Vapor can rerender a total of **10,000 nodes** in just **12ms** on a 2021 M1 MacBook Pro.
**At 80FPS.** This includes the time to update the DOM, and the time to render the UI.

##### After reconciliation, Vapor spits out an array of nodes:

1. An array of nodes that need to be **removed**

2. An array of nodes that need to be **added**

3. An array of nodes that need to be **updated**

These are then applied to the DOM **granularly** for minimal overhead.

We can access these via the following commands:

```zig
const dirty_nodes = Vapor.dirty_nodes;
const added_nodes = Vapor.added_nodes;
const removed_nodes = Vapor.removed_nodes;

for (dirty_nodes.items) |node| {
    // Do something with the dirty node
}
```

#### How it's different

This is different from React, where changing a parent's state triggers
re-renders of all children—even if their props didn't change. Vapor's
reconciliation is component-agnostic: it doesn't matter where the state lives,
only which elements display it.

{#performance}

## Performance

Instead of traversing the entire tree in the JS or native code side, we loop through the arrays of nodes and update those only.

This gives us both the power and control of reconcilation, and virtualization, but also the speed of native code, and simple looping mechanics.

{#structuring-your-application}

## Structuring your application

Every element type `(Box, Text, Link, Image, Svg, Button, TextField, ListItem, etc...)`. Is nothing more than a function call to add
a node to the UI tree.

1. **Elements** - Like `Box()`, can take arguments, and various builder functions.
2. **Style Builder** - These are functions operate on the component itself, and mutate the style of the component, like `layout(.center)`.
3. **Event Callbacks** - These functions are called based on events, for example, `on_press`, or `onHover`, or `onChange`.

![Diagram](/src/assets/tree.svg)

{#global-components}

### Global Components

These are the most common component type you will use in your applications. They declare there variables globally, but are only available within the file they are declared in.

Global Components take no reference to themselves, and instead just operate on their local variables.

⚠️ All instances of a Global Component share the same variables. If you need independent state, use Instance or Function components instead.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;

// Global state
var count: i32 = 0;

fn increment() void {
    count += 1;
}

fn decrement() void {
    count -= 1;
}

pub fn render() void {
    Box().layout(.center).spacing(16).padding(.all(20)).children({
        Button(.{ .on_press = decrement }).children({
            Text("-").fontSize(18).end();
        });

        Text(count).font(24, 700, .palette(.text_color)).end();

        Button(.{ .on_press = increment }).children({
            Text("+").fontSize(18).end();
        });
    });
}
```

```zig
// Render in /routes/about/Page.zig
const Vapor = @import("vapor");
const Counter = @import("components/Counter.zig");

pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

fn render() void {
    Counter.render();
}
```

```zig
// Render in /routes/contact/Page.zig
const Vapor = @import("vapor");
const Counter = @import("components/Counter.zig");

pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

fn render() void {
    Counter.render();
}
```

Below we can see that both instances of `Counter` use the same local set of variables, and share the same `count` variable. Just like in a normal programming language, if you
call the same function in two different files, they will share the same variables.

@global_sample

@global_sample

{#instance-components}

### Instance Components

Instance components, do reference themselves, they are akin to classes in other languages. They have their own set of local variables. That are bound to the struct.

We use these when we want to create multiple instances of the same component, with different data. For example a counter component that has the same styling, but we want
to have seperate `count` data.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Allocator = std.mem.Allocator;
const Box = Vapor.Box;
const Text = Vapor.Text;
const ButtonCtx = Vapor.ButtonCtx;

/// Counter component
const Counter = @This();
count: i32 = 0,

fn increment(counter: *Counter) void {
    counter.count += 1;
}

fn decrement(counter: *Counter) void {
    counter.count -= 1;
}

pub fn render(counter: *Counter) void {
    Box().layout(.center).spacing(16).padding(.all(20)).children({

        // ButtonCtx lets us pass a context to the button, which is the Counter struct
        ButtonCtx(decrement, .{counter}).children({
            Text("-").fontSize(18).end();
        });

        Text(counter.count).font(24, 700, .palette(.text_color)).end();

        ButtonCtx(increment, .{counter}).children({
            Text("+").fontSize(18).end();
        });
    });
}
```

```zig
// Render in /routes/about/Page.zig
const Vapor = @import("vapor");
const Counter = @import("components/Counter.zig");

var i32_counter: Counter = .{};
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

fn render() void {
    i32_counter.render();
}
```

```zig
// Render in /routes/contact/Page.zig
const Vapor = @import("vapor");
const Counter = @import("components/Counter.zig");

var i32_counter: Counter = .{};
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

fn render() void {
    i32_counter.render();
}
```

@instance_sample

@instance_sample2

##### Now they are different instances of the same component, with different data.

Incrementing one, will not affect the other.

{#function-components}

### Function Components

Vapor is just Zig, so you can structure the application however you want. There is no magic transpilation. What you see is what you get.

Zig has a special keyword called `comptime`.

`comptime `is an incredibly powerful tool, that is part of the language, and can be used to generate various components of different types.

`comptime`: Code Generation at Compile Time
The comptime keyword tells Zig: "Run this function during compilation, not at runtime."

For example, we can use `comptime` to generate a `Counter` with various values types, the `comptime` system is used for the `DataTable` component
in Vapor.

##### This is like function components in React, Solid, or other such frameworks.

##### These can be created multiple times, and have their own local variables.

```zig
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Button = Vapor.Button;

pub fn Counter(comptime T: type, initial_value: T) type {
    return struct {
        var count: T = initial_value;

        fn increment() void {
            count += 1;
        }

        fn decrement() void {
            count -= 1;
        }

        pub fn render() void {
            Box().layout(.center).spacing(16).padding(.all(20)).children({
                Button(.{ .on_press = decrement }).children({
                    Text("-").fontSize(18).end();
                });

                Text(count).font(24, 700, .palette(.text_color)).end();

                Button(.{ .on_press = increment }).children({
                    Text("+").fontSize(18).end();
                });
            });
        }
    };
}
```

```zig
// Render in /routes/about/Page.zig
const Vapor = @import("vapor");
const Counter = @import("components/Counter.zig");

const i32_counter = Counter(i32, -1);
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

fn render() void {
    i32_counter.render();
}
```

```zig
// Render in /routes/contact/Page.zig
const Vapor = @import("vapor");
const Counter = @import("components/Counter.zig");

const u32_counter = Counter(u32, 1);
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

fn render() void {
    u32_counter.render();
}
```

@i32_sample

@u32_sample

#### Typescript Comparison

In typescript, you would need to use generics, and this would all occur at runtime. We also need to create a new class for each type, and therefore need to reference the class
inside all our functions. In the Zig version, above we can just treat the varaible as a normal, akin to the global component, but with all the benefits of local bounded variables.

```ts
class Counter<T extends number> {
  private count: T;

  constructor(initialValue: T) {
    this.count = initialValue;
  }

  increment = () => {
    this.count += 1;
  }

  decrement = () => {
    this.count -= 1;
  }

  render() {
    return (
      <Box layout="center" spacing={16} padding={20}>
        <Button onPress={this.decrement}>
          <Text fontSize={18}>-</Text>
        </Button>
        <Text fontSize={24} fontWeight={700}>
          {this.count}
        </Text>
        <Button onPress={this.increment}>
          <Text fontSize={18}>+</Text>
        </Button>
      </Box>
    );
  }
}
```

