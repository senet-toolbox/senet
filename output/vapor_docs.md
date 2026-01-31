{#what-is-vapor}

# What is Vapor?

#### A framework without all the ceremony.

_"Vapor isn't trying to be React in Zig. It's showing what's possible when your framework disappears at compile time."_

```jsx
// JSX Frameworks
function Counter() {
  // useState hooks, batching, and magic
  const [count, setCount] = useState(0);

  function increment() {
    setCount((c) => c + 1);
  }

  return <button onClick={increment}>{count}</button>;
}
```

#### Vapor manages state for you

Vapor keeps state throughout the entire lifecycle—navigation, re-renders, everything. No _context_, no _stores_, no _prop drilling_. Just **functions** and **simple** programming.

```zig
// Vapor
var count: i32 = 0;
fn increment() void { count += 1; }

fn Counter() void {
    Button(increment).children({
        Text(count).end();
    });
}
```

@counter

{#quickstart}

## Quickstart

#### Build small blogs, to full-blown production apps, without installing a single dependency.

@video

%curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash

%metal create vapor my-app

%cd my-app && metal run web

{#vapor-is-simple}

## Vapor is simple by nature

- **Small bundle sizes** - _Hello World_ in only **28kb**, including router, hooks, reactivity, and more
- **No special syntax** - just normal programming
- **Powerful Styling** - `.layout(.center)`, `.grid(16, 1, .palette(.grid_color))`

{#how-it-works}

### How it works

**Server-Side Pre-rendering**
Vapor compiles your Zig components into static HTML at build time. This is sent to the browser for an instant, SEO-friendly first paint.

**Client-Side Hydration**
The browser also receives your compact _`vapor.wasm`_ binary, and a thin JS glue bridge. This WASM binary runs and **hydrates** the static HTML,
seamlessly taking control of the page.

**Native Performance Runtime**
From that point on, all UI updates, routing, and logic are handled directly by high-performance WebAssembly, not JavaScript, giving you a smooth, native-like feel in the browser.

**You write Zig, it compiles to WASM, it runs in the browser. That's it.**

{#why-zig}

### Why Zig?

Zig compiles to tiny, fast WebAssembly binaries.
No garbage collector means predictable performance. And unlike Rust,
Zig's syntax is straightforward.

Just like some of you, I came from the Javascript world, 2 years ago I started writing Zig, and 1 year ago I started building Senet.

Don't be afraid of the syntax, or the dreaded **Memory Management**, all will be explained, and you'll come to find that
Vapor makes it easy to write performant, native-like UIs,
with _minimal to no memory management._

**A Note on Syntax**

- `.end()` closes leaf elements (no children)
- `.children({})` wraps elements that contain others
- The `{}` block runs first, adding children before the parent closes


{#basics}

# Basics

#### The main.zig file is the root entry point for your Vapor application

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
fn increment() void {  counter += 1;  }

fn Home() void {
    Button(increment).children({
        Text("Increment").end();
    });
    Text(counter).end();
}
```

{#instantiate}

### Init and Export

The `init` function is called once when the vapor.wasm file is loaded. It initializes the Vapor framework and sets up the application environment.
We add our routes here, these routes are the pages that we can navigate to and from.

```zig
export fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Home, null);
}
```

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

### How it works

We create our route via the `Page()` function. `Page()`, takes a render function, which will be called when we navigate to the route.
In the scenario above, we pass in `Home()`.
Then when we navigate to the "/", Vapor internally calls `Home()`, then reconciles the UI, and updates the DOM.

### The Render Loop: A Key Concept

It is common convention to use the `render()` and `init()` naming convention when creating Components, and use the
name of route like "Home" or "About" for the page render function, as this explicitly reads as "render the UI", and "initialize the Data".

The function passed to `Page(...)` is called every time Vapor needs to update the UI. Just like any function, variables **inside** `render()` are reset each call:

```zig
fn render() void {
    var counter: usize = 0; // ⚠️ Reset to 0 every render!
    // ... rest of your UI
}

fn renderCycle() void {
    while (true) {
        render();
    }
}
```

⚠️ Note: This is a conceptual model. In practice, Vapor only calls render()
when state changes are detected, not in an infinite loop. Think of it as
"render() gets called fresh each time we need to update the UI."

#### State is reset within render functions, so doing the following will not work:

```zig
// ❌ WRONG - resets every render
pub fn render() void {
    var count: usize = 0;  // Always 0!
}
```

#### Instead, move the state outside the render function:

```zig
// ✅ CORRECT - persists between renders
var count: usize = 0;  // Outside render

pub fn render() void {
    // Use count here
}
```

### State

```zig
var counter: usize = 0;  // ✅ Persists

fn increment() void { counter += 1; }

fn render() void {
    var temp: usize = 0;  // ❌ Resets every render
    Button(increment).children({
        Text(counter).end();
        Text(temp).end();
    });
}
```

In Vapor we seperate data, from UI. Everything inside the render function is UI, and gets called every time we want to update the UI. This is why, in all the examples
you will see, we have a `init()` function for initialization of data, and a `render()` function for rendering the UI.

Vapor treats, data and UI as two seperate things, This drastically improves readability, and debugging, since the lifecycle of the entire application is predictable, and deterministic.

- Everything inside `render()` is called every time we want to update the UI.
- Everything declared outside `render()` persists between renders. Functions outside `render()` can be called multiple times (like event handlers), but variables outside `render()` maintain their values.

In both frameworks, the UI declaration runs repeatedly. The difference is **where state lives**:

This is why you'll see two functions in Vapor apps:

- `init()` - Initialize state (runs once)
- `render()` - Declare UI (runs on every update)

```zig
// 📁 main.zig
const Home = @import("routes/home/Page.zig");
export fn init() void {
    Vapor.init(.{});
    Home.init();
}
```

```zig
// 📁 routes/home/Page.zig
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;

var text: []const u8 = "";
pub fn init() void {
    text = "Welcome to Vapor!";
    Page(.{ .route = "/home" }, render, null);
}

fn render() void {
    Box().children({
        Text(text).end();
    });
}
```

{#structuring-your-application}

## Structuring your application

Every element type `(Box, Text, Link, Image, Svg, Button, TextField, ListItem, etc...)`. Is nothing more than a function call to add
a node to the UI tree.

1. **Elements** - Like `Box()`, can take arguments, and various builder functions.
2. **Style Builder** - These are functions operate on the component itself, and mutate the style of the component, like `layout(.center)`.
3. **Event Callbacks** - These functions are called based on events, for example, `on_press`, or `onHover`, or `onChange`.

![Diagram](/src/assets/tree.svg)


{#components}

# Components

Components are reusable pieces of UI. In Vapor, a component is just a Zig file with a `render()` function—no special syntax, no decorators, no magic.

```zig
// components/Greeting.zig
const Vapor = @import("vapor");
const Text = Vapor.Text;

pub fn render() void {
    Text("Hello from a component!").end();
}
```

```zig
// Use it anywhere
const Greeting = @import("components/Greeting.zig");

fn render() void {
    Greeting.render();
}
```

| Pattern  | Use When                                 |
| -------- | ---------------------------------------- |
| Global   | Single instance, simple state            |
| Instance | Multiple instances, each needs own state |
| Function | Multiple instances with different types  |

Most of the time, you'll use Global components. Start there and reach for the others when you need independent state or type generics.

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
                Button(decrement).children({
                    Text("-").fontSize(18).end();
                });

                Text(count).font(24, 700, .palette(.text_color)).end();

                Button(increment).children({
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

{#passing-props}

## Passing Props

#### We can also pass props to the different components

```zig
const Vapor = @import("vapor");
const Box = Vapor.Box;
const ButtonCtx = Vapor.ButtonCtx;

pub fn Counter(comptime T: type, initial_value: T, multiplier: T) type {
    return struct {
        var count: T = initial_value;

        fn multiPos(multi: T) void {
            count = count * multi;
        }

        fn multiNeg(multi: T) void {
            count = -1 * count * multi;
        }

        pub fn render() void {
            Box().layout(.center).spacing(16).padding(.all(20)).children({
                // Again here we use ButtonCtx, not Button
                ButtonCtx(multiNeg, .{multiplier}).children({
                    Text("-").fontSize(18).end();
                });

                Text(count).font(24, 700, .palette(.text_color)).end();

                // We use ButtonCtx here so that we can pass the multiplier
                ButtonCtx(multiPos, .{multiplier}).children({
                    Text("+").fontSize(18).end();
                });
            });
        }
    };
}
```

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


{#thats-ok}

# "I don't know zig, that's ok"

**You don't need to know zig to start building with vapor.**

If you've written javascript, typescript, c, java, or really any programming language, you already understand 90% of what you need. Zig just looks a little different.

This section will get you comfortable in about 10 minutes.

{#the-basics-variables}

### The basics: variables

```zig
// mutable (can change)
var count = 0;
var name = "hello";

// immutable (cannot change)
const max_size = 100;
const title = "my app";
```

`var` for things that change, `const` for things that don't.

**javascript equivalent:**

```js
let count = 0;
const maxsize = 100;
```

{#functions}

### functions

```zig
fn sayhello() void {
    // do something
}

fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

- `void` means "returns nothing" (like `void` in typescript)
- `i32` means "32-bit integer" (just a number, that can be negative and positive)

**javascript equivalent:**

```js
function sayhello() {
  // do something
}

function add(a, b) {
  return a + b;
}
```

{#the-one-weird-type-strings}

### The one weird type: strings

at first glance, this looks strange, in comparison to other languages, but it's actually incredibly handy.

```zig
var message: []const u8 = "hello world";
```

what does `[]const u8` mean?

- `u8` = a byte (each character is a byte)
- `[]` = a bunch of them in a row (an array)
- `const` = the characters themselves can't be changed

**translation:** "a string."

that's it. whenever you see `[]const u8`, just think "string."

```zig
// these are all just strings
var greeting: []const u8 = "hello";
var name: []const u8 = "vapor";
const url: []const u8 = "/home";
```

⚠️ **pro tip:** zig often infers types, so you can frequently just write:

```zig
var greeting = "hello";
```

#### handiness

since `[]const u8` is an array of bytes, you can index into it or pull out slices of it.

```zig
const hello_world: []const u8 = "hello world";

// index into the string
const first_letter = hello_world[0];

// slice the string
const first_three_letters = hello_world[0..3];
```

this is a very handy feature, and is used throughout vapor, for example with url paths.

{#if-statements}

### if statements

zig has no concept of ternary statements, but we can use if statements to achieve the same effect.

```zig
if (count > 10) {
    // do something
} else {
    // do something else
}

const flag = if (is_active) "America" else "Denmark";
const flag = is_active ? "America" : "Denmark" ❌ // Error: ternary operator is not allowed;
```

`if else if else` statement are identical to javascript. no surprises here.

{#loops}

### loops

```zig
// loop through items
for (items) |item| {
    Text(item).end();
}

// with index
for (items, 0..) |item, index| {
    Text(item).end();
}

// while loop
while (count < 10) {
    count += 1;
}

// ✅ Value only
for (items) |item| { }

// ✅ Index only
for (0..items.len) |i| { }

// ✅ Both value AND index (note the 0..)
for (items, 0..) |item, i| { }

// ❌ Wrong - can't use |_, i| without 0..
for (items) |_, i| { }  // Won't compile!
```

**javascript equivalent:**

```js
for (const item of items) {
  // ...
}

items.foreach((item, index) => {
  // ...
});

while (count < 10) {
  count += 1;
}
```

the `|item|` syntax is called "capture" - it's just how zig names the loop variable.

{#structs}

### Structs (like objects)

```zig
const user = struct {
    name: []const u8,
    age: u32,
};

var user = user{
    .name = "alice",
    .age = 30,
};

// access fields
const username = user.name;
```

**javascript equivalent:**

```js
const user = {
  name: "alice",
  age: 30,
};

const username = user.name;
```

the only difference: zig uses `.name = value` instead of `name: value`.

{#the-dot-brace-pattern}

### The dot-brace pattern

you'll see this everywhere in vapor:

```zig
// The left side is the function, the right side are the args
printCount(.{ .count = 12 })

fn printCount(args: struct { count: i32 }) void {
    std.log.info(("Count: {d}", .{args.count});
}
```

that `.{ }` is just an anonymous struct (like an inline object in js):

```js
// javascript
printCount({ count: 12 });

function printCount({ count }) {
  console.log(`Count: ${count}`);
}
```

same concept, slightly different punctuation.

{#printing-debugging}

### printing / debugging

```zig
// print to console
std.log.info("hello", .{}); // info
std.log.debug("count is: {d}", .{count}); // debug
std.log.err("name is: {s}", .{name}); // error
```

the `{d}` means "digit" (number), `{s}` means "string". the `.{}` passes the values to insert.

**javascript equivalent:**

```js
console.log("hello");
console.log(`count is: ${count}`);
console.log(`name is: ${name}`);
```

{#what-you-can-ignore}

### What you can ignore (for now)

these zig concepts exist but **you won't need them** to build uis:

| concept             | why you can skip it                         |
| ------------------- | ------------------------------------------- |
| `comptime`          | vapor uses it internally; you don't have to |
| allocators / arenas | vapor manages memory for you                |
| pointers (`*t`)     | only needed for advanced patterns           |
| error unions (`!t`) | vapor handles errors internally             |
| optionals (`?t`)    | you'll learn when you need it               |

{#a-complete-example}

### A complete example

Here's a real Vapor component. See if you can read it:

```zig
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;
const Box = Vapor.Box;

var count: i32 = 0;
var message: []const u8 = "click the button!";

fn handleclick() void {
    count += 1;
    if (count == 1) {
        message = "you clicked once!";
    } else {
        message = "keep going!";
    }
}

pub fn render() void {
    Box().layout(.center).spacing(16).children({
        Text(message).font(18, 400, .black).end();

        Button(handleclick).children({
            Text("click me").font(16, 700, .white).end();
        });

        Text(count).font(24, 700, .blue).end();
    });
}
```

If you understood that, **you're ready to build with Vapor.**

{#quick-reference-card}

### Quick reference card

Keep this handy for your first few hours:

| javascript             | zig                              |
| ---------------------- | -------------------------------- |
| `let x = 0`            | `var x: i32 = 0`                 |
| `const x = 0`          | `const x: i32 = 0`               |
| `"hello"`              | `"hello"` (type is `[]const u8`) |
| `function fn() {}`     | `fn name() void {}`              |
| `console.log(x)`       | `std.log.info("{d}", .{x})`      |
| `for (const x of arr)` | `for (arr) \|x\|`                |
| `{ key: value }`       | `.{ .key = value }`              |
| `obj.method()`         | `obj.method()`                   |
| `// comment`           | `// comment`                     |

{#next-steps}

### Next steps

Now that you're comfortable with the basics, you're ready to build something real.

Head over to [making a button](#making-a-button) to create your first interactive vapor component.


{#project-structure}

# Project Structure

Project structure in Vapor, is really up to you, by default Vapor, uses the routes directory to hold all the routes.
Vapor, as you know, Web, and more are to come. Other than that, you can create any folder, and import whatever you want, the routes directory is just
used for when we make use of the `@src()` function.

![Diagram](/assets/project_structure.svg)

- The **/web** directory holds the wasm bridge files, for connecting JS to vapor.wasm.
- The **/src** directory hold `main` and `routes`, and anything else you want to use or create.

```zig
// 📁 main.zig
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Docs = @import("routes/docs/Docs.zig");
const Home = @import("routes/users/DateUsersPage.zig");
const Home = @import("routes/home/Page.zig");

// Page initialization
pub fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Home, null);
    Vapor.Page(.{ .route = "/docs" }, Docs, null);
    Vapor.Page(.{ .route = "/app/data/:users" }, Users, null);

    // Or use @src() for file-based routing
    Home.init();
}
```

```zig
// 📁 /routes/home/Page.zig
const Vapor = @import("vapor");
pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}
```


{#routing}

# Routing

Routing in vapor works off of the directory structure of your project using `@src()`, or hardcoded strings `/app/about`.
to use dynamic routes, you have to either set the directory to `:slug` or use a static string, like `/app/about/:slug`.

When using the `@src()` union tag, the `.zig` file must be located within `routes/` directory, for example `routes/app/about/page.zig`.

![diagram](/src/assets/routes.svg)

{#page-sample}

## Using Page()

Routes should be declared once, it is common convention to either put them in the `init()` function of main.zig, or in an `init()` function within the
`....zig` file, you are working on.
by using the `Page` function, you can easily define your routes.

```zig
// /main.zig
const Vapor = @import("vapor");
const Page = Vapor.Page;

// Page initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, deinit); // this will refer to "/" since we are in main.zig
    // or
    Page(.{ .route = "/app/about" }, render, deinit); // this will refer to "/app/about"
}

// page deinitialization
pub fn deinit() void {
    Vapor.print("i get called when you navigate away from this page", .{});
}

pub fn render() void {
    Text("i get rendered when you navigate to this page").end();
}
```

Or within the `.zig` file level _("/routes/app/about/page.zig")_

```zig
// /routes/app/about/page.zig
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Text = Vapor.Text;

// page initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, deinit); // this will refer to "/app/about" since we are in /routes/app/about/page.zig
}

// page deinitialization
pub fn deinit() void {
    Vapor.print("i get called when you navigate away from this page", .{});
}

pub fn render() void {
    Text("i get rendered when you navigate to this page").end();
}
```

`Page()` is the entry point for your routes render and deinit functions, these are called when you navigate to and from routes.
it takes 3 arguments,

- either `@src()` or `"/..."`

- `renderfn`

- `deinitfn`

`@src()` is a builtin function that returns the current source location.

Vapor takes a function approach, you need to call `Vapor.Page()` to declare your routes. or the corresponding functions within the `.zig` file.

With the above example, we call our `Page(...)` function, within the `init()` function of `main.zig`. like this:

#### routes/app/about/page.zig

```zig
// /routes/app/about/page.zig
const Vapor = @import("vapor");
const Page = Vapor.Page;

// page initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, deinit); // this will refer to "/app/about" since we are in /routes/app/about/page.zig
}
```

#### main.zig

```zig
// /routes/app/about/page.zig
const Vapor = @import("vapor");
const AboutPage = @import("routes/app/about/page.zig");

// page initialization
export fn init() void {
    Vapor.init(.{});
    AboutPage.init();
}
```

**Note:** Don't forget to mark functions as `pub` if you want to call them from other files.


{#styling}

# Styling

Vapor treats styling, like Zig itself, there is no scoping, namespacing, css classes, ect. Just pure Zig code.

In Vapor, we reconcile the styles, and so not only is everything deduped, but also consolidated. A typical 50kb CSS file, is reduced to a single 10kb CSS file, when using Vapor.

### Three approaches to styling

1. Builder Pattern
2. Style Structs
3. Inline String Styles

{#new-approach}

## New approach

Vapor has taken a completely new approach. In the very early stages of Vapor's creation, an entire ui layout algorithmn
was built from scratch. The aim of this was, to design an ergonmic, and usable simple styling system, for developers to work
with. Today, Vapor does not use this ui algo, due to the benefits of the browser's dom engine, but still uses the same styling api interface.

To center any element in Vapor (including "text")

`.layout = .center` or `.layout(.center)`

Vapor, even exposes it own center element type, `Center()`, which will center any child elements within it.

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

### 3 types of styling in vapor

- **Builder Pattern**

- **Style Structs**

- **Inline String Styles**

{#builder-functions}

## Builder Pattern

For those coming from ios development, builder functions will be familiar to you.

```zig
const Vapor = @import("vapor");
const Box = Vapor.Box;
pub fn render() void {
    Box().layout(.center).spacing(16).padding(.all(20)).children({
        Text("hello there!")
            .hoverScale()
            .font(24, 700, .blue)
            .close();
        Text("...")
            .font(18, 700, .black)
            .close();
        Text("general kenobi")
            .fontStyle(.italic)
            .font(24, 700, .red)
            .close();
    });
}
```

Builder functions are a powerful tool, for creating quick styles, that do not need to be shared across the application.
Keep in mind, Vapor by default does **not support duplicate styles**, the above common styles while instantiated multiple times, during tree
rendering. Will be deduplicated. Instead a reference will be kept for the common styles.

_Think of it as a set of css classes, all being combined optimally, into multiple smaller classes, which are shared across each component._

{#builder-patterns}

### Builder Patterns

- `.layout(Layout)`

- `.spacing(u8)`

- `.padding(Padding)`

- `.direction(Direction)`

- `.font(u16, ?u16, ?Color)`

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

- `.fontStyle(FontStyle)`

- `.resize(Resize)`

- `.hw(Sizing, Sizing)`

- `ariaLabel([]const u8)`

- `ect...`

{#style-struct}

## const Style = struct { ... }

The second type of styling in Vapor is the `Style` struct. This is contains all the styling properties, and is passed to the
components, via the `style(*const Style)` function. This is handy when we have a common style, shared across the application.

### what about .style(&style)?

when using a Style struct, the syntax changes slightly:

```zig
// builder chain → .children({})
Button(click).padding(.all(8)).children({
    Text("click").end();
});

// style struct → direct block ({})
Button(click).style(&button_style)({
    Text("click").end();
});

const button_style = Vapor.Style{
    .layout = .center,
    .size = .hw(.px(48), .px(160)),
    .padding = .all(8),
    .visual = .{ .border = .simple(.black), .background = .white },
};
```

we are taking a reference to the `button_style` variable, and passing it to the `.style()` function.

#### note on style vs children

**why?** `.style()` returns a different type that takes the children block directly. just remember:

- `.children({...})` after builder chains
- `({...})` after `.style(&style)`

```zig
ButtonCtx(clicked, .{12}).style(&button_style)({ // ✅ Correct
    Text("click").end();
});

ButtonCtx(clicked, .{12}).style(&button_style).children({ // ❌ Incorrect, cannot use children after style
    Text("click").end();
});
```

### quick reference

```zig
// leaf elements - use .end()
Text("hello").end();
Text(35).end();
Icon(.search).end();
Image(.{ .src = "photo.jpg" }).end();
TextField(.string).bind(&text).end();

// containers - use .children({})
Box().children({ ... });
Center().children({ ... });
Stack().children({ ... });
List().children({ ... });
Button(fn).children({ ... });
Link(.{ .url = "/" }).children({ ... });

// with style struct - use ({})
// ❌ Cannot use children({}) after style
Box().style(&my_style)({ ... });
ButtonCtx(fn, .{}).style(&btn_style)({ ... });
```

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
        Text("hello there!").style(text_style);
        Text("...").style(&.{
            .visual = .{
                .font_size = 18,
                .font_weight = 700,
                .text_color = .black,
            },
        });
        Text("general kenobi").style(text_style);
    });
}
```

{#inline-style}

## .inlineStyle(fmt, .{})

The `.inlineStyle()` function allows you to pass a string of CSS, and apply it to the element.

```zig
var font_size: u32 = 24;
var font_weight: u32 = 700;
var theme: []const u8 = "--tint";
var text_style: []const u8 = "font-size: {d}; font-weight: {d}; color: rgb(var({s}));";

Box().inlineStyle("display: flex; justify-content: center, align-items: center, border-radius: 8px; border: 1px solid rgb(var(--tint)); background: transparent;", .{})
    .children({
    Text("hello there!").end();
});

Box().inlineStyle(text_style, .{font_size, font_weight, theme})
    .children({
    Text("hello there!").end();
});
```

{#taking-it-even-further}

### Taking it even further

A Typical CSS styled button requires the following styling

```css
style="display: flex; justify-content: center, align-items: center, border-radius: 8px; border: 1px solid rgb(var(--tint)); background: transparent;"
```

While in Vapor we can do the following,

```zig
Style{ .layout = .center, .visual = .{ .border = .round(.palette(.tint)) } }
```

or...

```zig
.layout(.center).border(.round(.palette(.tint), .all(8)))
```

{#structs-are-insanely-powerful}

### Structs are insanely powerful!

As you may have noticed, `Style` is a struct, and has fields, which means it also has methods.
when we create a new Vapor project, we get the following default methods:

- visual `.font(size: u32, weight: ?u32, color: ?color)`

- when `.pill(color: color)`

- bg `.hex(hex_str: []const u8)`

- interactive `.hover_scale()`

- style `.extend(base: *style, extension: style)`

- padding `.tblr(top: u32, bottom: u32, left: u32, right: u32)`

- size `.hw(height: sizing, width: sizing)`

- size `.square_percent(size: f32)`

- width `.mobile_desktop_percent(mobile: f32, desktop: f32)`

- background `.grid(size: f32, thickness: i32, color: color)`

- background `.hex(hex_str: []const u8)`

- background `.linear_gradient(start: color, end: color)`

- border `.simple(color: color)`

- border `.round(color: color)`

- border `.solid(color: color, thickness: i32)`

- border `.dashed(color: color, thickness: i32)`

- merge `.merge(style: style)`

- extend `.extend(style: style)`

- and much more...

{#code-block}

### code block

below is a sample code block of various styling options.

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

fn mergedstyle() style {
    var base = pill_button_base;
    return base.merge(style{
        .visual = .{ .border = .simple(.hex("#e1e1e1")) },
    });
}

fn clicked() void {
    Vapor.alert("you clicked me!");
}

fn samples() void {
    Box()
        .layer(.dot(0.5, 20, .white))
        .background(.vapor_blue)
        .width(.percent(100))
        .height(.auto)
        .layout(.center)
        .children({
        Text("i like dots!")
            .font(48, 700, .white).fontFamily("montserrat").end();
    });

    Box().style(&common_style)({
        Text("top right text").fontSize(14).end();
    });

    // here we use the basestyle, now we can override the default style
    Box().baseStyle(&common_style).layout(.top_left).children({
        Text("top left text").fontSize(14).end();
    });

    Button(clicked).style(&pill_button_base)({
        Text("click me").fontSize(18).end();
    });

    // here we merge the pill style,
    Button(clicked).style(&mergedStyle())({
        Text("click me").fontSize(18).end();
    });
}
```

@styling_samples

#### extend

The extend function allows you to extend a style with another style. It mutates the original style, and returns the mutated style.

#### merge

The merge function allows you to merge a style with another style. This creates an entirely new style, and returns the new style.


{#reactivity}

# Reactivity

#### Most frameworks make variables reactive. Vapor makes the UI reactive.

This simple inversion eliminates useState, useEffect,
and dependency arrays entirely.

If you're new to application development, reactivity, is the concept of being able to update your application in real time, without having to refresh the page.

Vapor is an even more simplified version of Svelte, just create variables, and mutate them, and the UI updates, THAT'S IT!

By default, every element is treated as a reactive. If it's state changes, the element will update in the UI **granularly**.

The following example shows a simple counter, that increments, and changes color when hovered.

Feel free to inspect the html elements, and see that only the text and color classes are updated.

```zig
const Vapor = @import("vapor");
var counter: usize = 0;
var text: []const u8 = "Current count: 0";

pub fn increment() void {
    counter += 1;
    text = std.log.debug("Current count: {d}", .{counter});
}

fn multiply(multiplier: usize) void {
    counter *= 2;
    text = std.log.debug("Current count: {d}", .{counter});
}

var color: Vapor.Types.Color = .palette(.text_color);
var changed_color: bool = false;
fn changeColor(_: *Vapor.Event) void {
    changed_color = !changed_color;
    if (changed_color) {
        color = .palette(.tint);
        return;
    }
    color = .palette(.text_color);
}

pub fn render() void {
    Button(increment)
        .onHover(changeColor)
        .shadow(.card(color))
        .children({
            Text(text).font(22, 700, color).end();
    });

    const multiplier = if (counter % 2 == 0) 2 else 3;

    ButtonCtx(multiply, .{multiplier})
        .onHover(changeColor)
        .shadow(.card(color))
        .children({
            Text("*").font(22, 700, color).end();
    });
}
```

@counter

### State is not reset

By default, Vapor will persist the state of the application, if you navigate away from the page, and return, the state will not be reset.
Feel free to increment the counter, and come back another time, the counter will still be incremented.

This also works for forms, modals, and other components, everything is considered stateful, it is up to the developer to decide how they want to handle it.

{#ui-as-reactivity}

## UI as reactivity

Vapor, is a toolkit, this means that the developer can decide how they want their application's reactivity to work.

- **Atomic Mode** ⚛️ (Default)

- **Static Mode**

- **Immediate Mode**

- **Retained Mode**

Vapor, has taken the concept of reactivity, and _Inversed It!_
Instead of defining a reactive variable like `let counter = $state(0);`
we define our UI as reactive.

There are two types of **State Elements** in Vapor,

- **Static Elements:** will never update!

- **Vapor Elements:** will only update if their styles or props change.

Static Element are best used for either readability, or improving performance.

```zig
const Vapor = @import("vapor");
const Static = Vapor.Static;
const TextField = Vapor.TextField;
var text: []const u8 = "Inital Text";

pub fn render() void {
    TextField(.string)
        .bind(&text)
        .end();

    Static.Text(text).end(); // This will never update
    Text(text).end(); // This will update
}
```

{#atomic-mode}

### Atomic Mode

Atomic mode is the default mode of Vapor. It is the simplest mode, if a **User interacts with the UI**, or an **Event is triggered**, like
`timeout`, `onChange`, `onPress`, `onHover`, `fetch` ect.
Vapor will check what is changed and only update the changed elements, ie their props or styles.

**The overhead cost of doing this is minimal, since we are working in WASM.**

Atomic mode acts a event engine, where each event into and out of Vapor's engine results in a call to check what is changed, and only update the changed elements.

This accomplishes the majority of the work needed to update and render the UI without any explicit state management. The remaining is handled through
Explicit State Containers called `Signal(T)` or manually calling `cycle()`.

**Just** because Vapor offers these features, doesn't mean they are needed, both this _Documentation_ site, and _Acorn_, are built using atomic mode, and use no
`Signal(T)` containers or `cycle()` calls.

The **Solution** to state management, isn't to solve it all, but to solve **+90%** of the problem.

The remaining **%** is when you want to use a state management system. Because now the user is not interacting and you are not receiving events.

```zig
const Vapor = @import("vapor");
const TextField = Vapor.TextField;
const Button = Vapor.Button;
const Text = Vapor.Text;
var text: []const u8 = "Inital Text";

var counter: usize = 0;
pub fn increment() void {
    counter += 1;
}

pub fn render() void {
    // The user interacts with the UI, via a text field
    TextField(.string).bind(&text).end();
    Text(text).end(); // This will update

    // The user interacts with the UI, via a button press
    Button(increment).children({
        Text("Increment").end();
    });
    Text(counter).end();

}
```

@graphics

Since the user interacts with the UI, an event is triggered, Vapor sees this, and then checks what is changed, added, or removed. And updates the UI accordingly.
Since Vapor runs in WASM, this process is extremely fast, and uses very little memory.

#### The remaining %

As long as there is an input into Vapor, then the UI will update, only small edge cases are not handled, for example, if you write your own external functionality.

Another scenario is, as you probably have noticed the numbered boxes on the right. These are generated after the Markdown file is compiled and the UI is rendered. After this
we query to see how many Section Elements were created, and then create a bunch of Numbered Boxes. But since no event happened, the UI does not update.
Thus we must call `cycle()` to trigger the UI update.

Querying elements is not an event, it is a function call, and thus not considered.

{#immediate-mode}

### Immediate Mode

Immediate mode works like GUIs where the entire render tree is ran, every frame. But unlike GUIs, Vapor only updates the elements that are affected.

Immediate mode is extremely fast.
In a worst case scenario, with a list of 10,000 nodes, no stable
keys, in which the first node is order removed,
the entire render
cycle from removal to UI update takes 12ms on a 2021 M1 MacBook Pro.

Immediate mode requires no state management, if a variable changes the UI will change, only the elements that are affected will be updated. **100%** of the work is done by Vapor.

```zig
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;
const TextField = Vapor.TextField;

// Initialize Vapor
export fn init() void {
    Vapor.init(.{ .mode = .immediate });
    Vapor.Page(.{ .route = "/" }, Home, null);
}


var text: []const u8 = "Inital Text";
var counter: usize = 0;

pub fn increment() void {
    counter += 1;
}

pub fn Home() void {
    // The user interacts with the UI, via a text field
    TextField(.string).bind(&text).end();
    Text(text).end(); // This will update

    // The user interacts with the UI, via a button press
    Button(increment).children({
        Text("Increment").end();
    });
    Text(counter).end();

}
```

{#80-content-is-static}

### 80% of content in an application is static

Most UI elements never change after initial render.
Vapor optimizes for this reality by exposing `Static`
elements.

In practice, the only difference between a `Static` `Text` and a `Text` is the import.
This site, never uses `Static` elements, while Acorn does, this is mainly for readability and maintainability.
Since most of the documentation site, is made up of Mardown files.

```zig
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Text = Static.Text;
const Button = Static.Button;
```

{#retained-mode}

### Retained Mode

As stated before, Vapor is a toolkit, and so you can decide how you want your application to work.
Retained mode is the most restrictive mode, you must define when a variable changes, or manually call `cycle()`, to ask Vapor to reconcile and update the UI.

There are two types of state functions in Vapor,

- **Signal(T)**

- **cycle()**

{#using-cycle}

### Using cycle()

The `cycle()` function tells Vapor, to update the UI, this is agnostic to the variables. It will update all UI elements that have changed, not just
the `counter` variable. For example the following will udpate both the
`counter` and the `text` variables.

```zig
const Vapor = @import("vapor");
const TextFmt = Vapor.TextFmt;

const Static = Vapor.Static;
const Text = Static.Text;
const Button = Static.Button;

var counter: usize = 0;

pub fn increment() void {
    counter += 1;
    Vapor.cycle(); // Here we call cycle, to ask Vapor to update the UI
}

pub fn render() void {
    Button(increment).children({
        Text("Increment").end();
    });
    TextFmt("I am a counter: {d}", .{counter}).end(); // Only this updates
}
```

```zig
const Vapor = @import("vapor");
const TextFmt = Vapor.TextFmt;
const Text = Vapor.Text; // We changed this to a Vapor element

const Static = Vapor.Static;
const Button = Static.Button;

var counter: usize = 0;
var text: []const u8 = "Increment";

pub fn increment() void {
    counter += 1;
    text = "Increment again";
    Vapor.cycle();
}

pub fn render() void {
    Button(increment).end()({
        Text(text).end(); // This now updates
    });
    TextFmt("{d}", .{counter}).end(); // This still updates
}
```

@cycle_example

{#zig-is-meant-to-be-explicit}

### Zig is meant to be Explicit!

Developers and Zig users alike, will most likely want to have explicit control over the UI at times, and not depend on the framework.
Svelte came to this realization, and implemented _Runes_, which are explicit UI state variables.

Vapor, has the same concept. When need be developers, can define their own UI variables through the `Signal(T)` type.

{#signalT}

### Signal(T)

`Signal(T)` is a type that is used to define UI state variables.
It is a wrapper around a `cycle()`.

```zig
const Vapor = @import("vapor");
const Signal = Vapor.Signal; // The Signal type
const Static = Vapor.Static;
const TextFmt = Vapor.TextFmt;

const Counter = struct {
    count: Signal(u32) = undefined,

    pub fn init() Counter {
        return .{ .count = count.init(0) };
    }

    pub fn increment(counter: *Counter) void {
        counter.count.increment();
    }

    pub fn render(counter: *Counter) void {
        Static.ButtonCtx(increment, .{counter}).end()({
            TextFmt("I am a counter: {d}", .{counter.count.get()}).end(); // This updates
        });
    }
};

```

`Signal(T)` has a number of methods, that can be used to change or update the state variable.

- `get()`

- `set()`

- `increment()`

- `decrement()`

- `toggle()`

- `append()`

- `getElement()`

- `compare()`

- and much more...

{#effects}

### Effects

Vapor, has decided to completely remove the concept of useEffect, useMemo, and subscriptions, entirely.
Instead, a functional approach should be used.

{#with-the-concept-of-effects}

### With the concept of effects

```zig
const Vapor = @import("vapor");
const Signal = Vapor.Signal;

var counter: Signal(u32) = undefined;
var text: Signal([]const u8) = undefined;
fn init() void {
    counter.init(0);
    text.init("Is 0");
++    counter.effect(updateText);
}

fn updateText(count: u32) void {
++    text.set(Vapor.fmtln("Is {d}", .{count}));
}

fn increment() void {
    counter.increment();
}
```

{#without-the-concept-of-effects}

### Without the concept of effects

```zig
const Vapor = @import("vapor");
const Signal = Vapor.Signal;

var counter: Signal(u32) = undefined;
var text: Signal([]const u8) = undefined;
fn init() void {
    counter.init(0);
    text.init("Is 0");
}

fn increment() void {
    counter.increment();
++    text.set(Vapor.fmtln("Is {d}", .{counter.get()}));
}
```

While Vapor, takes a strong stance against the use of effects, subscriptions, and such, it does not mean you cannot build your own effect system.
I did this originally, to determine if Vapor needed an effect system, however with the complexity and history of issues
with effects, I removed it.
If you truly want one, then you are going to have to build it yourself.

{#its-just-zig}

### Its just Zig

Since Vapor is not transpiled, and is just Zig, this means the variables can be passed from file to file.
Instead of defining `const [counter, setCounter] = useState(0);` variables,
and then passing them down the tree, to use in a child component.

We can just import the variable where needed. `const Parent = @import("parent.zig");`
`Parent.counter += 1;`

This also means that we can pass variables from parent to child, or child to parent.
This shows the immense power of Zig, and keeping the framework away from transpilation!

```zig
// GlobalCounter.zig
const std = @import("std");
const Vapor = @import("vapor");

pub var count: u32 = 0;

pub fn init() void {
    Page(.{ .src = "/global-counter" }, render, null);
}

fn render() void {
    TextFmt("I am a counter: {d}", .{count}).end();
}
```

```zig
// Parent.zig or Child.zig or Anywhere.zig
const Vapor = @import("vapor");
const GlobalCounter = @import("GlobalCounter.zig");

pub fn increment() void {
    GlobalCounter.count += 1;
}

pub fn render() void {
    Button(increment).children({
        Text("Increment the Global Counter").end();
    });
}
```


{#common-patterns}

# Common Patterns

#### Practical patterns you'll use in real applications.

{#form-handling}

## Form Handling & User Input

When capturing user input from `TextField`, the text slice points to an internal buffer that gets reused.
If you need to store the input (like adding items to a list), you must copy it to persistent memory.

### The Problem

```zig
var input_text: []const u8 = "";
var saved_items: [100][]const u8 = undefined;
var item_count: usize = 0;

fn saveItem() void {
    // ❌ WRONG - input_text points to TextField's buffer
    // It will be overwritten when user types again!
    saved_items[item_count] = input_text;
    item_count += 1;
}
```

### The Solution

```zig
var input_text: []const u8 = "";
var saved_items: [100][]const u8 = undefined;
var item_count: usize = 0;

fn saveItem() void {
    if (input_text.len == 0) return;

    // ✅ CORRECT - copy to persistent arena
    const persisted = Vapor.arena(.persist).dupe(u8, input_text) catch return;
    saved_items[item_count] = persisted;
    item_count += 1;
    input_text = ""; // Clear the input
}

fn render() void {
    TextField(.string)
        .bind(&input_text)
        .placeholder("Enter item...")
        .end();

    Button(saveItem).children({
        Text("Add").end();
    });

    // Display saved items
    for (saved_items[0..item_count]) |item| {
        Text(item).end();
    }
}
```

### Arena Quick Reference for Forms

| Arena      | Use When                           | Example                              |
| ---------- | ---------------------------------- | ------------------------------------ |
| `.persist` | Data that lives for entire session | User's todo items, saved preferences |
| `.view`    | Data that lives until route change | Current page's form state            |
| `.frame`   | Temporary formatting within render | `Vapor.fmtln("Count: {d}", .{n})`    |

{#keyboard-events-in-forms}

## Keyboard Events in Forms

Handle enter key to submit forms without a button:

```zig
var input_text: []const u8 = "";

fn handleKeyDown(evt: *Vapor.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "Enter")) {
        evt.preventDefault();
        submitForm();
    }
}

fn submitForm() void {
    if (input_text.len == 0) return;
    // Process the input...
    input_text = "";
}

fn render() void {
    TextField(.string)
        .bind(&input_text)
        .onEvent(.keydown, handleKeyDown)
        .placeholder("Press Enter to submit")
        .end();
}
```

### With Context Data

```zig
fn handleKeyDownCtx(form_id: u32, evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        submitFormById(form_id);
    }
}

fn render() void {
    TextField(.string)
        .bind(&input_text)
        .onEventCtx(.keydown, handleKeyDownCtx, 1)
        .end();
}
```

### Using Dynamic Arrays

```zig
var items: []Item = undefined;
var dynamic_list: Vapor.Array(Item) = undefined;

fn init() void {
    // We want to use the persist arena for items
    // We use the persist arena when we want to store data that lives for the entire session
    items = Vapor.arena(.persist).alloc(Item, 100) catch return;
    dynamic_list = Vapor.array(Item, .persist);

    // We only use the numbers inside the init function so we can use frame arena
    var numbers = std.array_list.Managed(i32).init(Vapor.arena(.frame));
    for (0..4) |i| {
        try numbers.append(i);
    }

    for (4..20) |i| {
        try numbers.append(i);
    }
    numbers.append(100) catch {};
    numbers.append(200) catch {};

    for (numbers.items) |item| {
        std.debug.print("{d}\n", .{item});
    }

}

fn addItem() void {
    if (input_text.len == 0) return;
    if (item_count >= items.len) return;

    // Copy text to persistent memory
    const text_copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;

    items[item_count] = .{
        .text = text_copy,
        .completed = false,
    };
    item_count += 1;
    input_text = "";
}

fn addDynamicItem() void {
    if (input_text.len == 0) return;

    // Copy text to persistent memory
    const text_copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;

    dynamic_list.append(.{
        .text = text_copy,
        .completed = false,
    }) catch return;
    input_text = "";
}
```

{#todo-list-example}

## Complete Example: Todo List

Here's a full todo list implementation demonstrating form handling, state management, and list operations:

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

// ============================================
// DATA STRUCTURES
// ============================================
const TodoItem = struct {
    id: u32,
    text: []const u8,
    completed: bool,
};

// ============================================
// STATE
// ============================================
var todos: [100]?TodoItem = .{null} ** 100;
var todo_count: usize = 0;
var next_id: u32 = 0;
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

const input_container_style = Vapor.Style{
    .layout = .left_center,
    .child_gap = 8,
    .margin = .b(16),
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

const checkbox_base = Vapor.Style{
    .size = .square_px(24),
    .layout = .center,
    .visual = .{
        .border = .round(.hex("#cbd5e0"), .all(4)),
    },
    .margin = .r(12),
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

// ============================================
// INITIALIZATION
// ============================================
pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================
// ACTIONS
// ============================================
fn addTodo() void {
    if (input_text.len == 0) return;
    if (todo_count >= todos.len) return;

    // Copy text to persistent memory
    const text_copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;

    todos[todo_count] = TodoItem{
        .id = next_id,
        .text = text_copy,
        .completed = false,
    };
    todo_count += 1;
    next_id += 1;
    input_text = "";
}

fn toggleTodo(index: usize) void {
    if (todos[index]) |*todo| {
        todo.completed = !todo.completed;
    }
}

fn deleteTodo(index: usize) void {
    if (index >= todo_count) return;

    // Shift remaining todos down
    var i = index;
    while (i < todo_count - 1) : (i += 1) {
        todos[i] = todos[i + 1];
    }
    todos[todo_count - 1] = null;
    todo_count -= 1;
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
            Box().style(&input_container_style)({
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
                if (todo_count == 0) {
                    Text("No todos yet. Add one above!")
                        .font(14, 400, .hex("#a0aec0"))
                        .padding(.all(20))
                        .end();
                } else {
                    for (0..todo_count) |i| {
                        if (todos[i]) |todo| {
                            renderTodoItem(todo, i);
                        }
                    }
                }
            });

            // Footer
            if (todo_count > 0) {
                Text(Vapor.fmtln("{d} item{s}", .{
                    todo_count,
                    if (todo_count == 1) "" else "s",
                }))
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
                .baseStyle(&checkbox_base)
                .background(if (todo.completed) .hex("#48bb78") else .white)
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

@todo_demo

### Key Takeaways

1. **Copy user input** with `Vapor.arena(.persist).dupe(u8, text)` before storing
2. **Use `ButtonCtx`** to pass index/id to handlers for list operations
3. **Handle keyboard events** with `.onEvent(.keydown, handler)` on TextField
4. **Conditional styling** with inline `if` expressions in builder chains
5. **Array shifting** for delete operations in fixed-size arrays


{#gotchas}

# Gotchas & Common Mistakes

#### Avoid these pitfalls when building with Vapor.

{#string-slice-gotcha}

## String Slices Are References, Not Copies

**The Problem:** String slices (`[]const u8`) in Zig are just a pointer and length—they don't own the data.

```zig
var user_input: []const u8 = "";

fn saveInput() void {
    // ❌ This stores a reference to TextField's internal buffer
    // When the user types again, this reference points to new data!
    my_saved_data = user_input;
}
```

**The Fix:** Copy strings that need to outlive their source.

```zig
fn saveInput() void {
    // ✅ Copy to persistent memory
    my_saved_data = Vapor.arena(.persist).dupe(u8, user_input) catch return;
}
```

{#style-syntax-gotcha}

## Style Struct vs Builder Chain Syntax

**The Problem:** Mixing up `.children({})` and direct block `({})` syntax.

```zig
// ❌ WRONG - can't use .children() after .style()
Box().style(&my_style).children({
    Text("Hello").end();
});

// ❌ WRONG - forgetting to close leaf elements
Text("Hello");  // Missing .end()!

// ❌ WRONG - using ({}) without .style()
Box()({  // This won't compile
    Text("Hello").end();
});
```

**The Fix:** Follow these rules:

```zig
// ✅ With style struct: use direct block
Box().style(&my_style)({
    Text("Hello").end();
});

// ✅ With builder chain: use .children({})
Box().padding(.all(20)).children({
    Text("Hello").end();
});

// ✅ Leaf elements always use .end()
Text("Hello").end();
Icon(.search).end();
Image(.{ .src = "/img.png" }).end();
TextField(.string).bind(&text).end();
```

**Quick Reference:**

| Element Type                        | With Builder Chain | With Style Struct |
| ----------------------------------- | ------------------ | ----------------- |
| Container (Box, Stack, Center)      | `.children({})`    | `.style(&s)({})`  |
| Button                              | `.children({})`    | `.style(&s)({})`  |
| Leaf (Text, Icon, Image, TextField) | `.end()`           | `.end()`          |

{#event-handler-gotcha}

## Event Handler Signatures

**The Problem:** Wrong function signatures for event handlers.

```zig
// ❌ WRONG - Button handler shouldn't take Event
fn handleClick(evt: *Vapor.Event) void {
    // ...
}
Button(handleClick)  // Won't compile!

// ❌ WRONG - ButtonCtx handler has wrong parameter order
fn handleDelete(evt: *Vapor.Event, id: u32) void {
    // ...
}
ButtonCtx(handleDelete, .{42})  // Won't compile!
```

**The Fix:** Match the expected signatures:

```zig
// ✅ Button - no parameters
fn handleClick() void {
    // ...
}
Button(handleClick)

// ✅ ButtonCtx - context params only (no Event)
fn handleDelete(id: u32) void {
    // ...
}
ButtonCtx(handleDelete, .{42})

// ✅ onEvent - Event pointer
fn handleKeyDown(evt: *Vapor.Event) void {
    const key = evt.key();
    // ...
}
TextField(.string).onEvent(.keydown, handleKeyDown)

// ✅ onEventCtx - context first, then Event
fn handleHover(item_id: u32, evt: *Vapor.Event) void {
    // ...
}
Box().onEventCtx(.pointerenter, handleHover, item_id)
```

**Handler Signature Reference:**

| Pattern                        | Signature                    |
| ------------------------------ | ---------------------------- |
| `Button(fn)`                   | `fn() void`                  |
| `ButtonCtx(fn, .{a, b})`       | `fn(A, B) void`              |
| `.onEvent(.event, fn)`         | `fn(*Vapor.Event) void`      |
| `.onEventCtx(.event, fn, ctx)` | `fn(Ctx, *Vapor.Event) void` |

{#state-in-render-gotcha}

## State Inside Render Functions

**The Problem:** Declaring state inside `render()` resets it every frame.

```zig
fn render() void {
    var count: u32 = 0;  // ❌ Always 0!

    Button(increment).children({
        Text(count).end();
    });
}

fn increment() void {
    count += 1;  // ❌ Won't compile - count not in scope
}
```

**The Fix:** State lives outside render functions.

```zig
var count: u32 = 0;  // ✅ Persists between renders

fn render() void {
    Button(increment).children({
        Text(count).end();
    });
}

fn increment() void {
    count += 1;  // ✅ Works!
}
```

{#color-type-gotcha}

## Color vs Background Types

**The Problem:** Using the wrong color type for styling.

```zig
// ❌ WRONG - background expects Background type
.font(16, 400, .hex("#ffffff"))  // This is Color, correct for font
.background(.hex("#ffffff"))     // ⚠️ Works but semantically it's Background

// Explicit types help catch errors:
const my_color: Vapor.Types.Color = .hex("#ffffff");
const my_bg: Vapor.Types.Background = .hex("#ffffff");
```

**The Fix:** Be aware of context:

```zig
// ✅ Font color uses Color
Text("Hello").font(16, 400, .hex("#333333")).end();

// ✅ Background uses Background (same syntax, different type)
Box().background(.hex("#ffffff")).children({});

// ✅ In Style structs, fields have correct types
const style = Vapor.Style{
    .visual = .{
        .text_color = .hex("#333333"),     // Color
        .background = .hex("#ffffff"),      // Background
    },
};
```

{#loop-index-gotcha}

## Loop Index vs Value

**The Problem:** Confusing loop syntax when you need both index and value.

```zig
// ❌ WRONG - this only gives you the value
for (items) |item| {
    ButtonCtx(deleteItem, .{item})  // Can't identify which item!
}

// ❌ WRONG - range doesn't give you the item
for (0..items.len) |i| {
    Text(i).end();  // Just prints index, not item data
}
```

**The Fix:** Use the full loop syntax when needed.

```zig
// ✅ When you need just the value
for (items) |item| {
    Text(item.name).end();
}

// ✅ When you need just the index
for (0..10) |i| {
    Text(i).end();
}

// ✅ When you need both value AND index
for (items, 0..) |item, i| {
    Box().children({
        Text(item.name).end();
        ButtonCtx(deleteItem, .{i}).children({
            Text("Delete").end();
        });
    });
}
```


{#vaporize}

# Vaporize

#### Vaporize is a Component function that is unqiue to Vapor

Vaporize, or vaporization, is the process of converting Zig code, Markdown, or HTML files into native Vapor components.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");

const log = std.log;

// Global vaporize compiler
var vaporizer: Vaporize.Compiler = undefined;

// markdown type which can take Vapor components as arguments
var markdown: vaporizer.MarkDown(.{}) = .{};

// Mardkown file
const markdown_text = "# Main Heading";

export fn init() void {
    // Initialize the vaporize compiler
    vaporize = Vaporize.init(Vapor.arena(.persist), .{}) catch |err| {
        log.err("Failed to initialize vaporizer: {any}", .{err});
        return;
    };

    // Compile the markdown file
    markdown.compile(markdown_text) catch |err| {
        log.err("Failed to compile markdown: {any}", .{err});
        return;
    };
}
```

Vaporize, works like a runtime compiler, when loaded in the browser, and a build time compiler when used in a Zig build.

The runtime version is best used for when you need dynamic UI, and the build time version is best used for when you need static UI.

Vaporize exposes the following set of functions:

- **Mardown(anytype)** - Returns a comptime Markdown Type, which can be used to generate UI
  - **compile(string)** - Takes a markdown string and compiles it into native Vapor components
  - **render()** - Renders the compiled markdown

- **Form(struct {...})** - Returns a comptime Form Type, which can be used to generate UI
  - **compile()** - Takes a form struct and compiles it into native Vapor components
  - **render()** - Renders the compiled form from a struct

#### Vaporizing a Markdown file:

```zig
// ... initialization

// Mardkown file
const markdown_text =
    \\# Main Heading
    \\
    \\- Item 1
    \\  - Nested item 1
    \\  - Nested item 2
    \\- Item 2
    \\  - Nested item 3
    \\
    \\This is the second paragraph.
;

fn render() void {
    // Render the markdown file
    markdown.render() catch |err| {
        TextFmt("Failed to render markdown: {any}", .{err}).end();
    };
}
```

One major benefit as discussed in the Codex Engine section, is that since we compile our entire UI tree to a single WASM binary, vaporizing multiple files,
scales memory usage logarithmically, since the markdown files uses the same function calls for each `Text`, `Link`, `ListItem`, ect.

### One Vaporization Instance

We only need to init and create one instance of the Vaporize compiler, and then we can use it anywhere in our application.
For this website, we have a single instance intialized in the `init` function within the `instances.zig` file.

```zig
pub var vaporizer: Vaporize.Compiler = undefined;

pub fn init() void {
    Vapor.init(.{});
    vaporizer = Vaporize.init(Vapor.arena(.persist), style_config) catch ...;
}
```

Afterwards, we can just import the vaporizer and use it anywhere in our application, like so:

```zig
// 📁 /routes/docs/vapor
const Vapor = @import("vapor");
const Instances = @import("instances.zig");

var markdown: Instances.vaporizer.MarkDown(.{}) = .{};

// Mardkown file
const markdown_text =
    \\# Main Heading
    \\
    \\- Item 1
    \\  - Nested item 1
    \\  - Nested item 2
    \\- Item 2
    \\  - Nested item 3
    \\
    \\This is the second paragraph.
;

pub fn init() void {
   Vapor.Page(.{ .src = @src() }, render, null);
   markdown.compile(markdown_text) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any}", .{err});
        return;
    };
}

fn render() void {
    // Render the markdown file
    markdown.render() catch |err| {
        TextFmt("Failed to render markdown: {any}", .{err}).end();
    };
}
```

#### However, you can also do this at runtime.

Vaporize is a runtime compiler, so we can fetch the markdown file, and then compile it at runtime. For example the TextArea below, is a live markdown editor,
that generates UI at runtime.

@text_area

@realtime_markdown

You could use this to create a live markdown editor, that exists in the browser, and then in your Zig code, add functionality and styling.

{#components-as-args}

### Components as Arguments

#### We can also pass Vapor components as arguments that are then rendered in the markdown

We pass the component we want to render, as well as a tag `[]const u8`, we then reference this tag in the markdown file, with the `@` symbol.

```zig
// 📁 /routes/docs/vapor
const Vapor = @import("vapor");
const Instances = @import("instances.zig");

var markdown: Instances.vaporizer.MarkDown(.{
    .{ .tag = "counter", .function = counter },
}) = .{};

// Mardkown file
const markdown_text =
    \\# Main Counter
    \\
    \\@counter
    \\
    \\This is the second paragraph.
;

pub fn init() void {
   Vapor.Page(.{ .src = @src() }, render, null);
   markdown.compile(markdown_text) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any}", .{err});
        return;
    };
}

fn render() void {
    // Render the markdown file
    markdown.render() catch |err| {
        TextFmt("Failed to render markdown: {any}", .{err}).end();
    };
}
```

This is how all the pages in the docs make use of dynamic interactive components.

{#vaporizing-normal-zig-code}

## Generating Forms

#### We can also vaporize normal Zig code:

Below is an example of vaporizing a struct, which in turns generates a form.

```zig
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");

const TextFmt = Vapor.TextFmt;
const Validation = Vaporize.Validation;
const Compiler = Vaporize.Compiler;

const Form = struct {
    email: []const u8 = "",
    password: []const u8 = "",
};

var vaporizer: Compiler = undefined;
var form: vaporize.Form(Form) = .{};

pub fn init() void {
    // Initialize the vaporize compiler
    // ...

    form.compile() catch |err| {
        Vapor.printErr("Failed to compile form: {any}", .{err});
        return;
    };
}

fn render() void {
    form.render() catch |err| {
        TextFmt("Failed to render form: {any}", .{err}).end();
        return;
    };
}
```

@simple_form

### Complex Form

We can also Vaporize complex structs with custom components and validations.
The `__valdiations` field that is used for validations, and defining element types. While the `__components` field defines custom components.

Each field type maps to a element type, for example `i32` maps to number `TextField`, and `bool` maps to `Checkbox`.

- `[]const u8` maps to `TextField`
- `[]const []const u8` maps to `TextArea`
- `i32` maps to `TextField`
- `bool` maps to `Checkbox`
- `enum` maps to `Radio`

```zig
const Vapor = @import("vapor");
const TextFmt = Vapor.TextFmt;
const Vaporize = @import("vaporize");
const Validation = Vaporize.Validation;
const Compiler = Vaporize.Compiler;

const Form = struct {
    username: []const u8 = "",
    email: []const u8 = "",
    phonenumber: []const u8 = "",
    password: []const u8 = "",
    age: u6 = 0,
    pub var __validations = .{
        .username = Validation{ .min = 3, .max = 10, .err = "Username must be between 3 and 10 characters" },
        .email = Validation{ .field_type = .email },
        .phonenumber = Validation{ .field_type = .telephone },
        .password = Validation{ .field_type = .password },
        .age = Validation{
            .min_value = 18,
            .max_value = 120,
            .err = "Age must be between 18 and 120",
        },
    };
};

var vaporizer: Compiler = undefined;
var new_form: vaporize.Form(Form) = .{
    .on_submit = onSubmit,
};

fn onSubmit(form: Form) void {
    Vapor.alert("Form submitted {s}", .{form.email});
}

pub fn init() void {
    // Initialize the vaporize compiler
    // ...

    new_form.compile() catch |err| {
        Vapor.printErr("Failed to compile form: {any}", .{err});
        return;
    };
}

fn render() void {
    new_form.render() catch |err| {
        TextFmt("Failed to render form: {any}", .{err}).end();
        return;
    };
}
```

@form

### Validations

With the `Form(...)` comptime function, we automatically get validations for free, if, if you want to style the different elements, or include a custom
component, or validation. You can do so by adding a `__validations` field to your struct. Or the `__components` field for custom components.

One thing to note, is that the validations are anonymous struct, the order of the fields, and the field names, must coincide with the order of the struct fields.

You can also use the type definitions themselves, as a validation or boudnary, for example the age field is currently a u6 type, this means that the maximum value is 120.

Instead of having to check via an `if` statement, like so: `if (form.age > 120) {}`, we can simply use the type definition to ensure that the value is within the range.

You can also do the same with the string fields, like so: `[16]u8` instead of `[]const u8`, this means that the field can only contain 16 characters.

{#complex-form}

### Complex Form

Below is a sample of a complex checkout form, with validation and custom components. This is a real-world example of a checkout form.
It includes, conditionals, sections, custom components, validation, dropdowns, and auto formatting.

The output of this example can be found at the bottom of the root page [here](/).

#### Code

```zig
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Validation = Vaporize.Validation;
const ValidationError = Vaporize.ValidationError;

const Box = Vapor.Box;
const Text = Vapor.Text;
const Compiler = @import("../main.zig");
const Select = @import("../components/Opaque.zig").Select;
const new = @import("../components/Select.zig").new;
const Field = @import("../components/Opaque.zig").Field;

const Currency = enum { usd, eur };

const Country = enum { US, CA, UK };

const PaymentMethod = enum { card, paypal };

const CheckoutForm = struct {
    // Account
    account: struct {
        email: []const u8 = "",
        password: []const u8 = "",
        confirm_password: []const u8 = "",
        contact: struct {
            phone: []const u8 = "",
        } = .{},
    } = .{},

    payment: struct {
        method: []const u8 = "",
        expiry: []const u8 = "",
        cvv: []const u8 = "",
        billing_address: []const u8 = "",
        card_number: []const u8 = "",
    } = .{},

    shipping_details: struct {
        shipping_same_as_billing: Vaporize.Condition(CheckoutForm) = .{
            .callback = sameAsBilling,
            .target_field = "shipping",
        },
    } = .{},

    shipping: struct {
        address: []const u8 = "",
        country: []const u8 = "",
        state: []const u8 = "",
        city: []const u8 = "",
        postal_code: []const u8 = "",
    } = .{},

    pub const __validations = .{
        .email = Validation{ .field_type = .email },
        .password = Validation{ .field_type = .password },
        .confirm_password = Validation{ .field_type = .password, .target_field = "password", .match = true },
        .phone = Validation{ .field_type = .telephone, .depends_on = "country" },
        .card_number = Validation{ .field_type = .credit_card },
        .expiry = Validation{ .field_type = .expiry, .placeholder = "MM/YY" },
        .cvv = Validation{ .field_type = .cvv, .placeholder = "123", .err = "CVV is required" },
        .address = Validation{ .field_type = .string, .required = true },
        .city = Validation{ .field_type = .string, .required = true },
        .state = Validation{ .field_type = .string, .required = true },
        .postal_code = Validation{ .field_type = .string, .required = true },
    };

    pub const __components = .{
        .method = PaymentMethodComponent,
        .country = CountryComponent,
    };
};
fn PaymentMethodComponent(_: *CheckoutForm, _: ?ValidationError) void {
    payment_method.render();
}

fn CountryComponent(_: *CheckoutForm, _: ?ValidationError) void {
    country.render();
}

fn sameAsBilling(form: *CheckoutForm) void {
    Vapor.print("sameAsBilling {any}", .{form.shipping_details.shipping_same_as_billing.value});
}

fn onSubmit(form: CheckoutForm) void {
    Vapor.print("Submitted {any}", .{form});
}

const FormCheckout = Compiler.vaporize.Form(CheckoutForm);
var login_form: FormCheckout = undefined;
var country: Select(Country) = undefined;
var payment_method: Select(PaymentMethod) = undefined;

pub fn init() void {
    Field.new();
    new();
    // compile the struct into a UI form
    login_form.compile() catch unreachable;
    login_form.inner_form.on_submit = onSubmit;

    payment_method = .fromItems(&.{
        .{ .value = PaymentMethod.card, .label = "Card" },
        .{ .value = PaymentMethod.paypal, .label = "PayPal" },
    });

    payment_method.trigger = "Payment Method";

    country = .fromItems(&.{
        .{ .value = Country.US, .label = "United States" },
        .{ .value = Country.CA, .label = "Canada" },
        .{ .value = Country.UK, .label = "United Kingdom" },
    });

    country.trigger = "Country";
}

pub fn LoginComponent() void {
    login_form.render();
}
```


{#animation}

# Animation

#### Vapor's animation system lets you create smooth, performant css animations entirely in Zig.

**Vapor treats animations like everything else: data.**

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;

const bounce_animation = Animation.init("bounce")
        .prop(.translateY, 0, -20)
        .prop(.scale, 1, 1.1)
        .duration(300)
        .easing(.easeOutBack)
        .iterations(2)
        .build();


fn init() void {
    bounce_animation.build();
}
```

{#quick-start}

### Quickstart

Animations in Vapor are created using the `Animation` struct. you define properties to animate,
timing, and easing, then call `.build()` to register it.

⚠️ **important:** `.build()` stores the animation in an internal hashmap.
This means you **must** call `.build()` within and init function ie runtime, you cannot call it during compilation.

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;
const Box = Vapor.Box;
const Text = Vapor.Text;

const fadeIn = Animation.init("fadeIn")
        .prop(.opacity, 0, 1)
        .duration(500)
        .fill(.forwards);

fn init() void {
    // now we can build animations
    fadeIn.build();
}

fn render() void {
    // use it on any element
    Box().animationEnter("fadeIn").children({
        Text("hello world!").end();
    });
}
```

{#core-concepts}

## Core Concepts

Animations in Vapor work through three main concepts:

1. **properties** - what values change (opacity, position, scale, etc.)
2. **timing** - duration, delay, easing, iterations
3. **keyframes** - for complex multi-step animations

### Defining Animations as Constants

You can define animations as compile-time constants, then call `.build()` in your init function:

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;

// define at comptime
const spinner: Animation = Animation.init("spin")
    .easing(.easeInOut)
    .duration(100)
    .prop(.rotate, 0, 180);

const fadeIn: Animation = Animation.init("fadeIn")
    .prop(.opacity, 0, 1)
    .duration(300)
    .fill(.forwards);

fn init() void {
    // build at runtime
    spinner.build();
    fadeIn.build();

    Vapor.Page(.{ .route = "/" }, render, null);
}
```

{#property-types}

### Property Types

Vapor supports a wide range of animatable properties through the `AnimationType` enum:

#### transforms

1. `.translateX`, `.translateY`, `.translateZ` - position movement
2. `.scale`, `.scaleX`, `.scaleY` - scaling
3. `.rotate`, `.rotateX`, `.rotateY`, `.rotateZ` - rotation
4. `.skewX`, `.skewY` - skewing

#### visual

1. `.opacity` - transparency
2. `.blur`, `.brightness`, `.saturate` - filters
3. `.backgroundColor` - color transitions

#### layout

1. `.width`, `.height` - size
2. `.top`, `.bottom`, `.left`, `.right` - positioning
3. `.marginTop`, `.marginBottom`, `.marginLeft`, `.marginRight` - margins
4. `.paddingTop`, `.paddingBottom`, `.paddingLeft`, `.paddingRight` - padding
5. `.borderRadius`, `.borderWidth` - borders

{#basic-animations}

## Basic Animations

The simplest way to create an animation is with the `.prop()` method.
it takes a property type, a starting value, and an ending value.

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;

// fade from invisible to visible
const fadeIn = Animation.init("fadeIn")
        .prop(.opacity, 0, 1);

const slideIn = Animation.init("slideIn")
        .prop(.translateX, -100, 0);

const growIn = Animation.init("growIn")
        .prop(.scale, 0.5, 1)
        .prop(.opacity, 0, 1);


export fn init() void {
    fadeIn.build();
    slideIn.build();
    growIn.build();
}
```

You can chain multiple `.prop()` calls to animate several properties simultaneously.

{#timing-controls}

## Timing Controls

Vapor provides full control over animation timing:

```zig
Animation.init("customTiming")
    .prop(.translateY, 0, 50)
    .duration(1000)      // 1 second
    .delay(200)          // wait 200ms before starting
    .easing(.easeInOut)  // smooth start and end
    .fill(.forwards)     // keep final state
    .build();
```

### duration and delay

Both `.duration()` and `.delay()` accept milliseconds:

```zig
.duration(500)  // animation takes 500ms
.delay(100)     // wait 100ms before starting
```

### iteration count

Control how many times the animation plays:

```zig
.iterations(3)  // play 3 times
.infinite()     // loop forever
```

### direction

Control the playback direction:

```zig
.dir(.normal)           // play forward
.dir(.reverse)          // play backward
.dir(.alternate)        // forward then backward
.dir(.alternateReverse) // backward then forward
```

### fill mode

Control what happens before and after the animation:

```zig
.fill(.none)      // return to initial state
.fill(.forwards)  // keep final state
.fill(.backwards) // apply initial state during delay
.fill(.both)      // both forwards and backwards
```

{#easing-functions}

## Easing Functions

Vapor includes a comprehensive set of easing functions:

#### basic

- `.linear` - constant speed
- `.ease` - default browser easing
- `.easeIn` - start slow
- `.easeOut` - end slow
- `.easeInOut` - slow start and end

#### quad (power of 2)

- `.easeInQuad`
- `.easeOutQuad`
- `.easeInOutQuad`

#### cubic (power of 3)

- `.easeInCubic`
- `.easeOutCubic`
- `.easeInOutCubic`

#### back (overshoot)

- `.easeInBack` - pull back before animating
- `.easeOutBack` - overshoot then settle
- `.easeInOutBack` - both effects

#### bounce

- `.easeOutBounce` - bouncy landing effect

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;

// bouncy button press
_ = Animation.init("buttonPress")
    .prop(.scale, 1, 0.95)
    .duration(100)
    .easing(.easeOutBack);
```

{#keyframe-animations}

## Keyframe Animations

For complex, multi-step animations, use the keyframe api with `.at()` and `.set()`:

```zig
const glitch = Animation.init("glitch")
    .at(0)
        .set(.translateX, 0)
        .set(.opacity, 1)
    .at(20)
        .set(.translateX, -5)
        .set(.opacity, 0.8)
    .at(40)
        .set(.translateX, 5)
        .set(.opacity, 1)
    .at(60)
        .set(.translateX, -3)
        .set(.opacity, 0.9)
    .at(80)
        .set(.translateX, 3)
        .set(.opacity, 1)
    .at(100)
        .set(.translateX, 0)
        .set(.opacity, 1)
    .duration(200)
    .infinite();

fn init() void {
    glitch.build();
}
```

### keyframe methods

#### `.at(percent)`

Sets the current keyframe position (0-100):

```zig
.at(0)    // start of animation (0%)
.at(50)   // middle of animation (50%)
.at(100)  // end of animation (100%)
```

#### `.set(property, value)`

Adds a property value at the current keyframe:

```zig
.at(0).set(.opacity, 0).set(.scale, 0.5)
.at(100).set(.opacity, 1).set(.scale, 1)
```

#### `.setUnit(property, value, unit)`

Adds a property with a specific unit:

```zig
.at(50).setUnit(.translateX, 50, .percent)  // 50%
.at(100).setUnit(.rotate, 180, .deg)        // 180deg
```

#### `.setColor(property, color)`

Adds a color property at the current keyframe:

```zig
.at(0).setColor(.backgroundColor, .red)
.at(100).setColor(.backgroundColor, .blue)
```

{#units}

## Units

Vapor supports multiple units for different property types:

- `.px` - pixels (default for most properties)
- `.percent` - percentage
- `.em` - relative to font size
- `.rem` - relative to root font size
- `.vw` - viewport width
- `.vh` - viewport height
- `.deg` - degrees (default for rotation)
- `.none` - unitless (default for opacity, scale)

```zig
// explicit unit control
_ = Animation.init("slidePercent")
    .propUnit(.translateX, 0, 100, .percent);
```

{#presets}

## Presets

Vapor includes common animation presets you can use directly:

#### fade animations

```zig
Animation.fadeIn("myFadeIn")
Animation.fadeOut("myFadeOut")
```

#### slide animations

```zig
Animation.slideInLeft("slideL", 100)   // slide from 100px left
Animation.slideInRight("slideR", 100)  // slide from 100px right
Animation.slideInUp("slideU", 100)     // slide from 100px below
Animation.slideInDown("slideD", 100)   // slide from 100px above

Animation.slideOutLeft("outL", 100)
Animation.slideOutRight("outR", 100)
Animation.slideOutUp("outU", 100)
Animation.slideOutDown("outD", 100)
```

#### zoom animations

```zig
Animation.zoomIn("zoomIn")
Animation.zoomOut("zoomOut")
```

#### continuous animations

```zig
Animation.spin("spinner")   // 360° rotation, infinite
Animation.pulse("pulse")    // subtle scale pulse, infinite
```

### using presets

Presets return an `Animation` struct, so you can further customize them:

```zig
// customize a preset
_ = Animation.fadeIn("customFade")
    .duration(800)
    .easing(.easeOutCubic);
```

{#exit-animations}

## Exit Animations

Vapor supports exit animations for elements being removed from the dom.
when an element with an exit animation is removed, Vapor automatically:

1. plays the exit animation
2. waits for it to complete
3. removes the element from the dom

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;
const Box = Vapor.Box;
const Text = Vapor.Text;

// define as constants
const anim_enter = Animation.init("toast-enter")
    .prop(.translateY, -20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const anim_exit = Animation.init("toast-exit")
    .prop(.opacity, 1, 0)
    .prop(.scale, 1, 0.95)
    .duration(200)
    .easing(.easeIn)
    .fill(.forwards);

export fn init() void {
    anim_enter.build();
    anim_exit.build();
    Vapor.page(.{ .route = "/" }, render, null);
}

fn render() void {
    // use animation pointers for enter/exit
    Box()
        .animationEnter("toast-enter")
        .animationExit("toast-exit")
        .children({
            Text("i will animate in and out!").end();
    });
}
```

{#transitions}

## Transitions

In addition to keyframe animations, Vapor supports css transitions for smooth property changes.
use the `.transition()` builder method to define which properties should animate when changed:

```zig
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;

fn render() void {
    Box()
        .transition(.{
            .properties = &.{ .top, .scale, .opacity, .transform },
            .duration = 200,
            .timing = .easeInOut,
        })
        .scale(scale_value)
        .pos(.tr(.px(top_offset), .px(0), .absolute))
        .children({
            Text("smooth transitions!").end();
    });
}
```

Transitions are ideal for:

- hover effects
- state-driven position/size changes
- interactive ui feedback

Use keyframe animations for:

- complex multi-step sequences
- entrance/exit animations
- continuous loops (spinners, pulses)

{#complete-example}

## Complete Example

Here's a complete example showing various animation techniques:

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const Center = Vapor.Center;
const Icon = Vapor.Icon;

var show_modal: bool = false;

// define animations as constants (no allocation yet)
const modalIn = Animation.init("modalIn")
    .prop(.scale, 0.8, 1)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOutBack)
    .fill(.forwards);

const modalOut = Animation.init("modalOut")
    .prop(.scale, 1, 0.8)
    .prop(.opacity, 1, 0)
    .duration(200)
    .easing(.easeIn)
    .fill(.forwards);

const spinner = Animation.init("spin")
    .prop(.rotate, 0, 360)
    .duration(1000)
    .easing(.linear)
    .infinite();

const buttonHover = Animation.init("buttonHover")
    .prop(.scale, 1, 1.05)
    .prop(.translateY, 0, -2)
    .duration(150)
    .easing(.easeOut);

export fn init() void {
    // register all animations (requires allocator from Vapor.init)
    modalIn.build();
    modalOut.build();
    spinner.build();
    buttonHover.build();

    Vapor.page(.{ .route = "/" }, render, null);
}

fn toggleModal() void {
    show_modal = !show_modal;
}

fn render() void {
    Center().children({
        Button(toggleModal)
            .hoverAnimation("buttonHover")
            .children({
                Text("toggle modal").end();
        });

        if (show_modal) {
            Box()
                .animationEnter("modalIn")
                .animationExit("modalOut")
                .background(.white)
                .padding(.all(24))
                .radius(.all(12))
                .shadow(.card(.black))
                .children({
                    Text("hello from modal!").font(18, 600, .black).end();
            });
        }
    });
}
```

{#api-reference}

## Api Reference

### Animation struct

| method                           | description                                |
| -------------------------------- | ------------------------------------------ |
| `init(name)`                     | create a new animation with the given name |
| `prop(type, from, to)`           | add a property to animate                  |
| `propUnit(type, from, to, unit)` | add a property with custom unit            |
| `at(percent)`                    | set keyframe position (0-100)              |
| `set(type, value)`               | set property at current keyframe           |
| `setUnit(type, value, unit)`     | set property with unit at keyframe         |
| `setColor(type, color)`          | set color property at keyframe             |
| `duration(ms)`                   | set animation duration in milliseconds     |
| `delay(ms)`                      | set animation delay in milliseconds        |
| `easing(fn)`                     | set easing function                        |
| `fill(mode)`                     | set fill mode                              |
| `dir(direction)`                 | set animation direction                    |
| `iterations(count)`              | set iteration count                        |
| `infinite()`                     | loop animation forever                     |
| `build()`                        | register the animation                     |

### presets

| preset                          | description                 |
| ------------------------------- | --------------------------- |
| `fadeIn(name)`                  | fade from 0 to 1 opacity    |
| `fadeOut(name)`                 | fade from 1 to 0 opacity    |
| `slideInLeft(name, distance)`   | slide in from left          |
| `slideInRight(name, distance)`  | slide in from right         |
| `slideInUp(name, distance)`     | slide in from bottom        |
| `slideInDown(name, distance)`   | slide in from top           |
| `slideOutLeft(name, distance)`  | slide out to left           |
| `slideOutRight(name, distance)` | slide out to right          |
| `slideOutUp(name, distance)`    | slide out to top            |
| `slideOutDown(name, distance)`  | slide out to bottom         |
| `zoomIn(name)`                  | scale from 0 to 1           |
| `zoomOut(name)`                 | scale from 1 to 0           |
| `spin(name)`                    | 360° infinite rotation      |
| `pulse(name)`                   | subtle infinite scale pulse |

{#best-practices}

## Best Practices

1. **call Vapor.init() first** - `.build()` requires the internal allocator, so always initialize Vapor before building animations

2. **define animations as constants** - declare animations at file scope, then call `.build()` in your init function

3. **use meaningful names** - animations are registered globally, so use descriptive names like `"modalFadeIn"` instead of `"fade"`

4. **set fill mode** - use `.fill(.forwards)` to keep the final state, otherwise elements snap back

5. **prefer transforms** - `translateX/Y`, `scale`, and `rotate` are gpu-accelerated and perform better than animating `width/height`

6. **keep durations short** - animations over 500ms often feel sluggish. 150-300ms is usually ideal

7. **use appropriate easing** - `.easeOut` for entrances, `.easeIn` for exits, `.easeInOut` for state changes

8. **use animation pointers for enter/exit** - pass `&animation` to `.animationEnter()` and `.animationExit()`

```zig
const Vapor = @import("vapor");
const Animation = Vapor.Animation;
const Box = Vapor.Box;
const Text = Vapor.Text;

// ✅ good - define as constants at file scope
const fadeIn = Animation.init("fadeIn")
    .prop(.opacity, 0, 1)
    .duration(300)
    .fill(.forwards);

const fadeOut = Animation.init("fadeOut")
    .prop(.opacity, 1, 0)
    .duration(200)
    .fill(.forwards);

fn init() void {
    // ✅ build after Vapor.init
    fadeIn.build();
    fadeOut.build();

    Vapor.page(.{ .route = "/" }, render, null);
}

fn render() void {
    // ✅ use pointer for animationEnter/Exit
    Box()
        .animationEnter("fadeIn")
        .animationExit("fadeOut")
        .children({
            Text("animated content").end();
    });
}
```

```zig
const Animation = Vapor.Animation;

// ❌ bad - could forget to set the animation, leading to undefined behavior
var animation: Animation = undefined;
fn init() void {
    animation = Animation.init("fade").prop(.opacity, 0, 1).build(); // crash! no allocator yet
}

// ❌ bad - building inside render
fn render() void {
    Animation.init("fade").build(); // don't do this! builds every frame
    Box().animation("fade").children({ ... });
}
```


{#new-to-zig}

# New to Zig

The following will be a small introduction to Zig, focused on the basics. This is not a comprehensive guide, but a starting point for those who are new to Zig.
The goal is to get you up and running with Vapor, not make you a master of Zig.

⚠️ **NOTE:** This is directed to those who have some experience in programming, whether that is python, javascript, or other languages. It
also helps if you have some basic understanding of types, control flow, and functions.

If you want to learn more about Zig, you can check out the

1. [Zig Book](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html). A book that teaches you Zig by example. 🌟
2. [Zig Documentation](https://ziglang.org/documentation/master/). The official Zig website.

## Zig Basics

Zig is a general-purpose programming language, designed for robustness, optimality, and maintainability.
It is a compiled language, which means that it is compiled to native machine code, and then executed.

Zig is a statically typed language, which is incredibly helpful in catching bugs at compile time.

We will explore the following concepts:

1. **Zig Types**
2. **Zig Memory**
3. **Basic Zig Control Flow**

### Zig Types

In Zig, there are several types of data, these are all similar to other languages.

A common type or synbol set you will see in Zig is the '[]' this is called an array. An array is a collection of items of the same type.
for example, an array of integers is `[]i32`. We define an array with the number of items it contains, and the type of the items.

```zig
const numbers = [4]i32{ 1, 2, 3, 4 };
```

Above we have an array of 4 integers, the first item is 1, the second is 2, the third is 3, and the fourth is 4.

We index into an array with the square brackets, the index starts at 0, so the first item is at index 0, the second is at index 1, and so on.

```zig
const first_number = numbers[0]; // 1
const second_number = numbers[1]; // 2
const third_number = numbers[2]; // 3
const fourth_number = numbers[3]; // 4
```

Zig is smart, and so we can interpret the number of items in the array, with the '\_' symbol, like so:

```zig
const numbers = [_]i32{ 1, 2, 3, 4 };
```

At compile time, Zig will determine the number of items in the array.

The above is a constant array, meaning we cannot modify or the values it contains. To do that, we need to use the `var` keyword.

```zig
var numbers = [4]i32{ 1, 2, 3, 4 };
// or
var numbers = [_]i32{ 1, 2, 3, 4 };
```

Now we can modify the values in the array.

```zig
numbers[0] = 5;
numbers[1] = 6;
numbers[2] = 7;
numbers[3] = 8;
```

#### Slices

A slice is like a sub-array, is a reference to a part of an array. We can create a slice with the `[number..number]` syntax.

```zig
const numbers = [4]i32{ 1, 2, 3, 4 };
const first_three_numbers = numbers[0..3];
```

Just like arrays, we can index into a slice.

```zig
const first_number = first_three_numbers[0]; // 1
const second_number = first_three_numbers[1]; // 2
const third_number = first_three_numbers[2]; // 3
```

A slice is a reference to a part of an array, and it's length.

```zig
const numbers = [4]i32{ 1, 2, 3, 4 };
const first_three_numbers = numbers[0..3];

std.debug.print("Ptr of first_three_numbers: {*}\n", .{first_three_numbers.ptr}); // ...
std.debug.print("Length of first_three_numbers: {d}\n", .{first_three_numbers.len}); // 3

```

The `ptr` is like an address, to a house in a neighborhood.

Let's say we wanted to count the total number of houses on a street.

1. We first need to define the starting house.
2. Then we count from the starting house to the end of the street.

In our example above, we have a total of 4 houses, and our first house is at index 0, then we only want to record the first 3 houses.
so we cut or 'slice' the array, to only include the first 3 houses.

- The `ptr` refers to the starting elment of the slice.
- The `len` refers to the length of the slice.

In another example, let's say we had 100 houses, and house 1-10 are red, houses 11-20 are blue, houses 21-30 are green, and so on.

We can use a slice to only include the red houses, and then count the number of red houses.

```zig
const houses = [100]House{
     // ... a bunch of houses ...
};

const red_houses = houses[0..10]; // slice of 10 red houses
const blue_houses = houses[10..20]; // slice of 10 blue houses
const green_houses = houses[20..30]; // slice of 10 green houses
```

The ptr field in the slice `blue_houses.ptr` is the first address of the blue houses. the len field is the length of the slice, or number of houses.

We do this in Zig because then we are not copying the data around everywhere. Instead we just grab out the pointer to the start of the slice, and the length of the slice.
Now we can index into the slice.

```zig
const third_blue_house = blue_houses[2]; // the third blue house
// or with the big array
const third_blue_house = houses[12]; // the third blue house
```

#### Strings

In Zig, a string is a sequence of characters. We define a string literal as `[]const u8`.

```zig
// JS style string
const hello_world = "Hello World!";

// Zig style string
const hello_world: []const u8 = "Hello World!";
```

The type `[]const u8` is an array of characters. Essentially, u8 is a byte, it can be any number between 0 and 255. In computer science, we represent the alphabet as a set of numbers,
for example, 'A' is 65, 'B' is 66, 'n' is 110, and so on.

So the above string literal is techinically an array of numbers that represent the characters in the string.

- 'H' is 72
- 'e' is 101
- 'l' is 108
- 'l' is 108
- 'o' is 111

- 'W' is 87
- 'o' is 111
- 'r' is 114
- 'l' is 108
- 'd' is 100
- '!' is 33

Just like arrays, we can slice a string literal, and then index into the slice.

```zig
const hello_world: []const u8 = "Hello World!";
const first_letter = hello_world[0]; // 'H'
const second_letter = hello_world[1]; // 'e'
const third_letter = hello_world[2]; // 'l'
const fourth_letter = hello_world[3]; // 'l'
const fifth_letter = hello_world[4]; // 'o'

// Slice of the string literal
const world = hello_world[6..11]; // 'World'
const w = world[0]; // 'W'
```

And again, since they are just arrays, we can grab our the pointer and length of the string.

```zig
const hello_world: []const u8 = "Hello World!";
const hello_world_ptr = hello_world.ptr; // starting address of the string literal
const hello_world_len = hello_world.len; // 12
```

You probably noticed that for strings, we are `const`, instead of `[]u8`. This is because we do not want to modify the string's individual characters.
If you want to create a string, where you can modify the characters, you need to use the `var` keyword.

```zig
var string = [_]u8{ 'H', 'e', 'l', 'l', 'o' };
string[0] = 'H';
string[1] = 'E';
string[2] = 'L';
string[3] = 'L';
string[4] = '!';
```

If you just want to modify the entire string itself, you can do the following:

```zig
var string: []const u8  = "Hello";
string = "Hello World!";
```

#### Structs

A struct is a collection of fields and methods. Just like a class in other languages.

```zig
const House = struct {
    color: []const u8,
    number: i32,

    pub fn forSale(self: *House) bool {
        if (std.mem.eql(u8, self.color, "red")) {
            return true;
        }
        return false;
    }
};
```

Above we have a struct called `House`, it has two fields, a `color` field, and a `number` field.
It also has a method called `forSale`, which returns a boolean value.

Within the method, we have a special standard library function called `std.mem.eql`, which is used to compare two types.
In this case, we are comparing two strings. We define the type we are comparing as `u8` since underneath the hood, `std.mem.eql` compares each character in the string.

The `pub` keyword makes a variable or function public. This means we can access said function outside of the struct. This is useful when calling a function in a different file.
or methods, or anywhere other than the struct itself.

#### We can create a new House instance with the following:

```zig
var house = House{
    .color = "red",
    .number = 1234,
};
```

Then we can call the `forSale` method on the instance:

```zig
if (house.forSale()) {
    std.debug.print("House is for sale!\n", .{});
}
```

Structs are handy for encapsulating data and methods. In the Lego City tutroial, we will use structs to create a set of different types of Lego bricks, buildings, and other objects.

`std.debug.print` is a function that prints a string to the console, the first part is the format string, and the second part is the arguments to be formatted.

```zig
std.debug.print("Hello {s}!\n", .{"world"});
```

### To Summerize:

1. _[]const u8_ is a string literal, it is essentially an array of characters, like so &.{'h', 'e', 'l', 'l', 'o'}
2. _[]i32_ is an array of integers, like so [4]i32{1, 2, 3, 4}
3. _struct_ is like a class or object in other languages, it is a collection of fields and methods.
4. _fn_ is a function.
5. _pub_ makes a function or variable public.
6. _var_ is like a variable in other languages, it is a named value that can be changed.
7. _const_ is like a constant in other languages, it is a named value that cannot be changed.

{#memory}

# Memory

Memory, is a popular topic in programming, some argue it should be compiled away, completely avoided, handled by the programmer, or handled by the program.

In Zig, memory is typically handled with Arenas.

### What is an Arena?

Imagine, you work at a construction site. If you want to build a house, you need to first have a plot of land. This is where the arena comes in.

The arena is like a large piece of land, that is used for building the house. First we add the plumbing, and electrical wiring, this is like allocating memory for an array.
The we add the foundations, and walls, this is like allocating memory for a string.

Then we finally put the roof on, together all of these pieces make up the house. Just how the struct below is made up of the strings, and the arrays we allocated.

```zig
const House = struct {
    plumbing: [16]u32,
    electrical_wiring: [16]u32,
    foundations: []const u8,
    walls: []const u8,
    roof: bool,
};

pub fn init() void {
    const arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    const plumbing = allocator.alloc(u32, 16) catch {};
    const electrical_wiring = allocator.alloc(u32, 16) catch {};
    const foundations = "foundations";
    const walls = "walls";
    const roof = true;

    const house = House{
        .plumbing = plumbing,
        .electrical_wiring = electrical_wiring,
        .foundations = foundations,
        .walls = walls,
        .roof = roof,
    };
}
```

The arena, is a large piece of memory, that we can use slices of. Just like how a large piece of land can be used to build multiple houses.

The usefulness of the arena, is that we can grab various slices of memory, and use them as we please, then when we are done with all of them, we just call `deinit` on the arena.
This will automatically free all the memory that was allocated. We do not need to track what memory we allocated, or how we used it, or when we freed it.

Vapor makes use of this arena pattern, by allocating memory for each render cycle, creating all the UI, and reconciling it. Then finally when we have made all the DOM changes, we call `deinit` on the arena.

This means that internally, Vapor never needs to be concerned with memory tracking, or deallocation.

### alloc and dynamic arrays

In the above example, we use the `alloc` memory to allocate memory for our arrays. This means that the arrays now live on the heap, and will live forever.
The `alloc` method returns an array of type `T` ie `[]T`. For example:

```zig
pub fn init() void {
    const arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    var numbers: []i32 = allocator.alloc(i32, 4) catch {}; // Allocate 4 numbers []i32
    for (0..4) |i| {
        numbers[i] = i;
    }
}
```

We can also create dynamic arrays, by using the standard library's `std.array_list.Managed`

```zig
const std = @import("std");
const Vapor = @import("vapor");

pub fn init() void {
    const arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    var numbers = std.array_list.Managed(i32).init(allocator);
    for (0..4) |i| {
        try numbers.append(i);
    }

    for (4..20) |i| {
        try numbers.append(i);
    }
    numbers.append(100) catch {};
    numbers.append(200) catch {};

    for (numbers.items) |item| {
        std.debug.print("{d}\n", .{item});
    }
}
```

### \* is a pointer

```zig
const House = struct {
    plumbing: [16]u32,
    electrical_wiring: [16]u32,
    foundations: []const u8,
    walls: []const u8,
    roof: bool,
};

pub fn init() void {
    const arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    const plumbing = allocator.alloc(u32, 16) catch {};
    const electrical_wiring = allocator.alloc(u32, 16) catch {};
    const foundations = "foundations";
    const walls = "walls";
    const roof = true;

    const house = allocator.create(House) catch {};
    house.* = House{
        .plumbing = plumbing,
        .electrical_wiring = electrical_wiring,
        .foundations = foundations,
        .walls = walls,
        .roof = roof,
    };
}
```

In the above example, we use the `*` to refer to the actual memory that is allocated. This is called a pointer, just like how in real life, we have an address to a house, we have
an address to our memory slices. In the case above, we have an address to a slice memory, that is a string ([]const u8), and a bool (\*bool).

The reason, that the arena returns a pointer, is the same reason we use adresses in real life. If we wanted to go over to our friend's birthday party, it would be strange to ask her
to move her entire house to our place, so we can attend it. Imagine, if multiple people were attending the party, she would have to move the entire house contstantly.

Instead, she gives us an adress to the party, so that we can attend it.

Similarly, the arena returns a pointer, so that we don't copy all the memory over to our structure, we just take an adress to the memory, and we "go to it", with `.*`.

### .\* is a dereference

`.*` is a dereference operator, it takes a pointer, and returns the actual memory that is allocated. This is the same as and address in real life, we take an address to a
house, and we go to it, by car or by foot. In Zig, we can do the same thing, by using `.*`.

```zig
pub fn init() void {
    const address: *House = Vapor.arena(.persist).create(House) catch {};
    const house = address.*;
}
```

### Error Handling

In the above examples, we have used the `catch` keyword to handle errors. In Zig, errors are values, meaning they can be returned, and they can be handled.

#### Catching Errors

```zig
const result = someFunction() catch |err| {
    std.debug.print("Error: {s}\n", .{err});
    // Handle the error
    return err;
};

// Or ignore the error (not recommended in real code)
const result = someFunction() catch {};

// Or use `try` to propagate the error up
const result = try someFunction();
```

#### Optionals

Values can be optional (might be null):

```zig
var maybe_house: ?House = null;

// Check if it exists
if (maybe_house) |house| {
    // Use house here
}

// Or provide a default
const house = maybe_house orelse default_house;
```

### Basic Control Flow

#### If statements

```zig
if (house.number > 100) {
    std.debug.print("High number!\n", .{});
} else {
    std.debug.print("Low number!\n", .{});
}
```

#### For loops

```zig
for (numbers, 0..) |num, i| {
    std.debug.print("{d}\n", .{num});
}
```

#### While loops

```zig
var i: i32 = 0;
while (i < 10) : (i += 1) {
    std.debug.print("{d}\n", .{i});
}
```


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
const TextFmt = Vapor.TextFmt;
const Spacer = Vapor.Spacer;

// Context Components
const ButtonCtx = Vapor.ButtonCtx;
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
var items: []const Item = &.{};

fn multiply(multiplier: i32) void {
    counter = counter * multiplier;
}

fn render() void {
    // UI declaration runs every update
    Text(counter).end();
    Button(multiply, .{2}).children({
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

| Method          | Description             |
| --------------- | ----------------------- |
| `.init(value)`  | Initialize with value   |
| `.get()`        | Get current value       |
| `.set(value)`   | Set new value           |
| `.increment()`  | Increment numeric value |
| `.decrement()`  | Decrement numeric value |
| `.toggle()`     | Toggle boolean value    |
| `.append(item)` | Append to array         |

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
        Button(decrement).children({ Text("-").end(); });
        Text(count).font(24, 700, .palette(.text_color)).end();
        Button(increment).children({ Text("+").end(); });
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
                Button(decrement).children({ Text("-").end(); });
                Text(count).font(24, 700, .palette(.text_color)).end();
                Button(increment).children({ Text("+").end(); });
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

// Styled Box with style struct
Box()
    .style(&.{
        .visual = .{
            .background = .palette(.background),
            .border = .simple(.palette(.border_color)),
        },
    })({ /* children */ });
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
Button(handleClick).children({
    Text("Click Me").end();
});

// Button with context (pass data to handler)
ButtonCtx(handleAction, .{ item, index }).children({
    Text("Action").end();
});

// Styled button
Button(submit)
    .padding(.tblr(12, 12, 24, 24))
    .background(.palette(.tint))
    .border(.round(.transparent, .all(8)))
    .cursor(.pointer)
    .hoverScale()
    .children({
        Text("Submit").font(16, 600, .white).end();
    });
```

Button(handler)
→ Handler takes no arguments

ButtonCtx(handler, .{args})
→ Handler receives args
→ Example: ButtonCtx(deleteTodo, .{item.id})

```zig

// Button - no arguments to handler
Vapor.Button(doSomething)

// ButtonCtx - pass arguments to handler
Vapor.ButtonCtx(doSomething, .{arg1, arg2})

// ❌ This doesn't exist:
Vapor.Button(handler, .{args})
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

### TextField Events

```zig
var text: []const u8 = "";

// Basic binding
TextField(.string)
    .bind(&text)
    .end();

// With change handler
TextField(.string)
    .bind(&text)
    .onChange(handleChange)
    .end();

fn handleChange(evt: *Vapor.Event) void {
    const new_text = evt.text();
    std.log.debug("Text changed to: {s}", .{new_text});
}

// With keyboard events (e.g., submit on Enter)
TextField(.string)
    .bind(&text)
    .onEvent(.keydown, handleKeyDown)
    .end();

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        submitForm();
    }
}

// With context
TextField(.string)
    .bind(&text)
    .onEventCtx(.keydown, handleKeyDownCtx, form_id)
    .end();

fn handleKeyDownCtx(id: u32, evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        submitFormById(id);
    }
}
```

### Common TextField Events

| Event                    | Trigger              | Use Case                   |
| ------------------------ | -------------------- | -------------------------- |
| `.onChange`              | Text content changes | Validation, live search    |
| `.onEvent(.keydown, fn)` | Key pressed          | Submit on Enter, shortcuts |
| `.onEvent(.focus, fn)`   | Field gains focus    | Show suggestions           |
| `.onEvent(.blur, fn)`    | Field loses focus    | Validate on blur           |

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
Link(.{ .url = "/about" }).children({
    Text("Go to About").end();
});

// External link
Link(.{ .url = "https://vapor.dev" })
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
.rgb(255, 87, 51)             // RGB
.white
.black
.transparent
.transparentize(.palette(.tint), 0.5)  // Semi-transparent

// Backgrounds
.background(.palette(.background))
.background(.hex("#F5F5F5"))
.background(.transparent)
.background(.transparentize(.palette(.tint), 0.5))  // Semi-transparent
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
.shadow(.glow(30, .transparentize(.black, 0.1)))
.shadow(.{
    .top = 4,
    .spread = 2,
    .blur = 6,
    .color = .transparentize(.black, 0.05),
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
.scroll(.none())                       // No scroll
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
Button(action).style(&button_style)({
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
    .onEventCtx(.pointerenter, handleHoverItem, item)
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

| Method                 | Description               |
| ---------------------- | ------------------------- |
| `evt.key()`            | Get pressed key name      |
| `evt.text()`           | Get input text value      |
| `evt.number()`         | Get numeric input value   |
| `evt.metaKey()`        | Check if meta/cmd pressed |
| `evt.shiftKey()`       | Check if shift pressed    |
| `evt.ctrlKey()`        | Check if ctrl pressed     |
| `evt.preventDefault()` | Prevent default action    |

---

{#lifecycle-hooks}

## Lifecycle Hooks

### Component Hooks

```zig
fn mount() void {
    // Called after component is mounted
    std.log.debug("Mounted", .{});
}

fn destroy() void {
    // Called when component is removed
    std.log.debug("Destroyed", .{});
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

{#dynamic-arrays}

## Dynamic Arrays

Vapor provides a convenient wrapper around Zig's `std.array_list.Managed` that automatically uses the correct arena allocator.

### Creating Arrays
```zig
const Vapor = @import("vapor");

// Create a dynamic array with a specific arena lifetime
var todos = Vapor.array(TodoItem, .persist);    // Lives entire session
var search_results = Vapor.array(Result, .view); // Lives until route change
var temp_items = Vapor.array(Item, .frame);      // Lives only this render

// The type annotation (optional but helpful)
var todos: Vapor.Array(TodoItem) = Vapor.array(TodoItem, .persist);
```

### Array Methods

`Vapor.Array(T)` is an alias for `std.array_list.Managed(T)`, so you get all standard ArrayList methods:
```zig
var items = Vapor.array(Item, .persist);

// Adding items
items.append(item) catch return;                    // Add single item
items.appendSlice(&.{ item1, item2 }) catch return; // Add multiple items

// Accessing items
const first = items.items[0];           // Direct index access
const all = items.items;                // Get underlying slice
const count = items.items.len;          // Get count

// Removing items
_ = items.orderedRemove(index);         // Remove at index, preserve order
_ = items.swapRemove(index);            // Remove at index, swap with last (faster)
items.clearRetainingCapacity();         // Remove all, keep memory allocated
items.clearAndFree();                   // Remove all, free memory

// Iteration
for (items.items) |item| {
    // Use item
}

for (items.items, 0..) |item, i| {
    // Use item and index
}
```

### Choosing the Right Arena

| Arena | Array Lifetime | Use Case |
|-------|----------------|----------|
| `.persist` | Entire session | User data, app state, settings |
| `.view` | Until route change | Page-specific lists, search results |
| `.frame` | Single render | Temporary filtering, sorting for display |
| `.scratch` | Manual control | Advanced use cases |

### Complete Example: Todo List with Dynamic Array
```zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.ButtonCtx;
const TextField = Vapor.TextField;

const TodoItem = struct {
    text: []const u8,
    completed: bool = false,
};

// Dynamic array that persists across navigations
var todos: Vapor.Array(TodoItem) = undefined;
var input_text: []const u8 = "";

pub fn init() void {
    // Initialize with persist arena - todos survive page navigation
    todos = Vapor.array(TodoItem, .persist);
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn addTodo() void {
    if (input_text.len == 0) return;
    
    // Copy text to same arena as the array
    const text_copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;
    
    todos.append(.{
        .text = text_copy,
        .completed = false,
    }) catch return;
    
    input_text = "";
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
    Box().direction(.column).spacing(16).padding(.all(20)).children({
        // Input
        TextField(.string)
            .bind(&input_text)
            .placeholder("New todo...")
            .end();
        
        Button(addTodo).children({
            Text("Add").end();
        });
        
        // List - iterate with index for delete/toggle operations
        for (todos.items, 0..) |todo, i| {
            Box().layout(.x_between_center).children({
                Text(todo.text)
                    .textDecoration(if (todo.completed) .line_through else .none)
                    .end();
                
                ButtonCtx(toggleTodo, .{i}).children({
                    Text(if (todo.completed) "Undo" else "Done").end();
                });
                
                ButtonCtx(deleteTodo, .{i}).children({
                    Text("Delete").end();
                });
            });
        }
        
        // Count display
        Text(Vapor.fmtln("{d} items", .{todos.items.len})).end();
    });
}
```

### Why Use Vapor.array() Instead of std.ArrayList Directly?

1. **Automatic allocator selection** - No need to manually get the allocator
2. **Consistent lifetime semantics** - Arena type clearly indicates data lifetime
3. **Less boilerplate** - One line instead of three
```zig
// Without Vapor.array()
const allocator = Vapor.arena(.persist);
var todos = std.array_list.Managed(TodoItem).init(allocator);

// With Vapor.array()
var todos = Vapor.array(TodoItem, .persist);
```

### Common Patterns

**Filtering for display (use .frame):**
```zig
fn render() void {
    // Create temporary filtered list just for this render
    var active_todos = Vapor.array(TodoItem, .frame);
    
    for (todos.items) |todo| {
        if (!todo.completed) {
            active_todos.append(todo) catch continue;
        }
    }
    
    // Render only active todos
    for (active_todos.items) |todo| {
        Text(todo.text).end();
    }
    // active_todos is automatically freed after render
}
```

**Page-specific data (use .view):**
```zig
var search_results: Vapor.Array(SearchResult) = undefined;

pub fn init() void {
    // Results cleared when user navigates away
    search_results = Vapor.array(SearchResult, .view);
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn performSearch(query: []const u8) void {
    search_results.clearRetainingCapacity();
    // ... populate with new results
}
```

**Persistent app state (use .persist):**
```zig
var user_favorites: Vapor.Array(FavoriteItem) = undefined;
var cart_items: Vapor.Array(CartItem) = undefined;

pub fn init() void {
    // These survive the entire session
    user_favorites = Vapor.array(FavoriteItem, .persist);
    cart_items = Vapor.array(CartItem, .persist);
}
```

### ⚠️ Important: Match Array and Item Arenas

When storing strings or allocated data in an array, use the **same arena** for both:
```zig
// ✅ Correct - both use .persist
var todos = Vapor.array(TodoItem, .persist);
const text = Vapor.arena(.persist).dupe(u8, input) catch return;
todos.append(.{ .text = text }) catch return;

// ❌ Wrong - mismatched lifetimes
var todos = Vapor.array(TodoItem, .persist);  // Lives forever
const text = Vapor.arena(.frame).dupe(u8, input) catch return;  // Freed after render!
todos.append(.{ .text = text }) catch return;  // Dangling pointer!
```


### Practical Example: When to Use Each Arena
```zig
const std = @import("std");
const Vapor = @import("vapor");

// ============================================
// PERSIST ARENA - Lives entire session
// ============================================
// Use for: User data, app state, anything that survives navigation

var user_todos: [100][]const u8 = undefined;
var todo_count: usize = 0;

fn addTodo(input: []const u8) void {
    // Copy string to persistent memory
    const copied = Vapor.arena(.persist).dupe(u8, input) catch return;
    user_todos[todo_count] = copied;
    todo_count += 1;
}

// ============================================
// VIEW ARENA - Lives until route change  
// ============================================
// Use for: Page-specific state, form data, temporary lists

var page_search_results: []SearchResult = &.{};

fn loadPageData() void {
    const view_alloc = Vapor.arena(.view);
    page_search_results = view_alloc.alloc(SearchResult, 50) catch return;
    // This memory is freed when user navigates away
}

// ============================================
// FRAME ARENA - Lives only during this render
// ============================================
// Use for: Formatted strings, temporary display values

fn render() void {
    // fmtln uses frame arena internally - perfect for display
    Text(Vapor.fmtln("You have {d} todos", .{todo_count})).end();
    
    // This string only needs to exist during render
    const status = Vapor.fmtln("Page {d} of {d}", .{current_page, total_pages});
    Text(status).end();
}
```

### Arena Decision Flowchart
```
Is this data needed after render completes?
├── No → Use .frame (or Vapor.fmtln)
└── Yes → Is this data needed after leaving the page?
    ├── No → Use .view
    └── Yes → Use .persist
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
Button(goHome).children({ Text("Home").end(); });

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
    .animationEnter("fadeIn")
    .animationExit("slideOut")
    .children({ /* ... */ });

// Hover animation
Button(action)
    .hover(.{ .animation = "pulse" })
    .children({ /* ... */ });

// Conditional
Text("Loading")
    .animation(if (loading) "spin" else null)
    .end();
```

### Animation Properties

| Property                       | Description  |
| ------------------------------ | ------------ |
| `.translateX`, `.translateY`   | Position     |
| `.scale`, `.scaleX`, `.scaleY` | Scaling      |
| `.rotate`                      | Rotation     |
| `.opacity`                     | Transparency |
| `.blur`                        | Blur filter  |
| `.backgroundColor`             | Color        |

### Easing Functions

| Function         | Description        |
| ---------------- | ------------------ |
| `.linear`        | Constant speed     |
| `.ease`          | Default            |
| `.easeIn`        | Start slow         |
| `.easeOut`       | End slow           |
| `.easeInOut`     | Slow start and end |
| `.easeOutBack`   | Overshoot          |
| `.easeOutBounce` | Bounce             |

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
std.log.debug("Debug: {s}", .{message});
std.log.err("Error: {any}", .{err});
```

### DOM Utilities

```zig
// Alert
Vapor.alert("Say {s}", .{"Hi"});

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

| Pattern                                              | Description                      |
| ---------------------------------------------------- | -------------------------------- |
| `Component().children({ ... });`                     | Container with children          |
| `Component().end();`                                 | Leaf element (no children)       |
| `Component().style(&style)({ ... });`                | Apply style struct with children |
| `.children({ ... })`                                 | Block for child elements         |
| `ButtonCtx(fn, .{args})`                             | Button with context arguments    |
| `.onEventCtx(.event, fn, ctx)`                       | Event handler with context       |
| `Vapor.Static.HooksCtx(.mounted, fn, .{})({ ... });` | Lifecycle hook                   |
| `for (items) \|item\| { ... }`                       | Loop over items                  |
| `if (cond) { ... }`                                  | Conditional render               |

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
        .background(.transparentize(.black, 0.5))
        .children({
            Button(closeModal).size(.full).end();
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
        Button(toggleDropdown).children({
            Text("Select Option").end();
        });

        if (show_dropdown) {
            Stack()
                .pos(.tl(.px(0), .percent(100), .absolute))
                .zIndex(100)
                .background(.palette(.background))
                .border(.round(.palette(.border_color), .all(8)))
                .shadow(.card(.transparentize(.black, 0.1)))
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
        Button(submit).children({
            Text("Submit").end();
        });
    });
}
```
