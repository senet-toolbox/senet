{#what-is-vapor}

# What is Vapor?

#### A framework without all the ceremony.

```jsx
// JS Frameworks - what you may know
function Counter() {
  const [count, setCount] = useState(0);

  function increment() {
    setCount((c) => c + 1);
  }

  return <button onClick={increment}>{count}</button>;
}
```

```zig
// Vapor - almost the same, but simpler
var count: i32 = 0;

fn increment() void { count += 1; }

fn render() void {
    Button(.{ .on_press = increment }).children({
        Text(count).end();
    });
}
```

**A Note on Syntax**

- `.end()` closes leaf elements (no children)
- `.children({})` wraps elements that contain others
- The `{}` block runs first, adding children before the parent closes

### The Difference

#### Vapor is a Zig-powered WebAssembly UI framework/toolkit.

#### ⚡ Zero tooling. Zero JS build chain. Just Zig → WASM → UI.

**Vapor** is a UI framework where you write normal code and get a fast website.
No virtual DOM. No hooks. No build step headaches. Just functions that draw UI.

_"Vapor isn't trying to be React in Zig. It's showing what's possible when your framework disappears at compile time."_

This is because the engine maps instructions directly to native browser APIs
like `createElement` or `setAttribute` for Web, and UIKit for iOS.

**All in a simple, code based, declarative syntax.**

```zig
const Vapor = @import("vapor");
const Center = Vapor.Center;
const Button = Vapor.Button;
const Text = Vapor.Text;

// Initialize Vapor
export fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Home, null);
}
```

```zig
fn welcome() void {
    Vapor.alert("Welcome to Vapor!");
}

fn Home() void {
    Center().children({
        Button(.{ .on_press = welcome }).children({
            Text("Click Me").fontSize(18).end();
        });
    });
}
```

@alert

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

### The React Solution: useState

React solves this with `useState` to "rescue" variables from being reset:

```jsx
function Counter() {
  // ✅ useState preserves this between renders
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(count + 1)}>
        <p>{count}</p>
    </button>;
  );
}
```

### The Vapor Solution: Move State Outside

```zig
// This is static, it is created once.
var counter: usize = 0;

fn increment() void {
    counter += 1;
}

fn render() void {
    // ⚠️ This function body runs EVERY render

    Vapor.print("This runs on EVERY render!"); // Logs on every click
    Button(increment).children({
        Text(counter).end();
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

## Mental Model Comparison

#### React

![diagram](/assets/mental_model_react.svg)

#### Vapor

![diagram](/assets/mental_model_vapor.svg)

#### Key Takeaway

**React:** Your component is a function that runs repeatedly, so state needs special handling (`useState`)

**Vapor:** Your render function also runs repeatedly, but state lives **outside** the function, so it naturally persists

{#quickstart}

### Quickstart

%curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash

%metal create vapor my-app

%cd my-app && metal run web

**Visit** [localhost:5173](http://localhost:5173/)

{#vapor-is-simple}

## Vapor is simple by nature

- **Granular** - Automatic UI updates
- **Small bundle sizes** - _Hello World_ in only **28kb**, including router, hooks, reactivity, and more
- **No** - special framework syntax (macros, templating language), just normal programming
- **Only write** - `Zig`, even in the UI
- **Powerful Styling** - `.layout(.center)`, `.grid(16, 1, .palette(.grid_color))`
- **Simplified** - memory management

{#how-it-works}

## How it works

**Server-Side Pre-rendering**
Vapor compiles your Zig components into static HTML at build time. This is sent to the browser for an instant, SEO-friendly first paint.

**Client-Side Hydration**
The browser also receives your compact _`vapor.wasm`_ binary, and a thin JS glue bridge. This WASM binary runs and **hydrates** the static HTML,
seamlessly taking control of the page.

**Native Performance Runtime**
From that point on, all UI updates, routing, and logic are handled directly by high-performance WebAssembly, not JavaScript, giving you a smooth, native-like feel in the browser.

**You write Zig, it compiles to WASM, it runs in the browser. That's it.**

{#why-zig}

## Why Zig?

Zig compiles to tiny, fast WebAssembly binaries.
No garbage collector means predictable performance. And unlike Rust,
Zig's syntax is straightforward.

Just like some of you, I came from the Javascript world, 2 years ago I started writing Zig, and 1 years ago I started building Tether.

Don't be afraid of the syntax, or the dreaded **Memory Management**, all will be explained, and you'll come to find that
Vapor makes it easy to write performant, native-like UIs,
with _minimal to no memory management._

{#making-a-button}

## Making a button!

We will jump into depth on how Vapor works soon, but first we will make a **Button**.

** As you can see, we do not allocate or use any memory, just simple functions.**

```zig
// All normal Zig code
const Vapor = @import("vapor");

// Components
const Button = Vapor.Button;
const Text = Vapor.Text;

var counter: i32 = 0;
fn increment() void {
    counter += 1;
}

// Render
pub fn render() void {

    // ✨ No setState(), no hooks, no signals
    // Just mutate the variable. Vapor handles the rest.

    Text(counter).fontSize(18).end();

    Button(.{ .on_press = increment }).border(.simple(.black)).children({
        Text("Increment").fontSize(18).end();
    });
}
```

@counter

#### When state changes, Vapor performs two phases:

1. **Render Pass** - Your entire render() function executes in WebAssembly, generating a fresh virtual tree

2. **Reconciliation** - Vapor diffs the new tree against the previous one, identifying exactly which DOM elements need updates

Only the reconciliation results are applied to the actual DOM. This is what makes updates fine-grained. We determine all the changes that are needed
on the WASM side, and then bridge to the DOM side to apply all the updates.

Modern web frameworks, use signal based state management, due to performance issues of Javascript. Since we are using WASM, we do not have to worry about
performance issues, and can focus on the UI.

{#builder}

## Builder Pattern

Every Component follows the builder pattern. We start by creating a `Button` component, and then we can
call any set of **styling** functions such as `.border()`.

Each method returns itself, letting you chain calls fluently—just like SwiftUI or Tailwind's approach.

```zig
Center().height(.px(100)).layer(.dot(0.5, 20, .white)).background(.vapor_blue).children({
    Text("I like Dots!").font(48, 700, .white).fontFamily("Montserrat").end();
});
```

@builder

#### Or using the Style struct:

```zig
const box_style = Vapor.Style{
    .layout = .center,
    .spacing = 8,
    .size = .{ .height = .px(100) },
    .visual = .{
        .background = .vapor_blue,
        .layer = .dot(0.5, 20, .white),
    },
};

const text_style = Vapor.Style{
    .font_family = "Montserrat",
    .visual = .{
        .font_size = 48,
        .font_weight = 700,
        .text_color = .white
    },
};
```

#### This is the equivalent in CSS:

```css
.vapor-box {
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  height: 100px;

  background-color: rgb(33, 8, 255);
  background-image: radial-gradient(
    circle,
    rgb(255, 255, 255) 0.5px,
    transparent 0px
  );
  background-size: 20px 20px;
  background-position: center center;
  text-decoration: none;
}

.vapor-box-text {
  font-size: 48px;
  font-weight: 700;
  color: rgb(255, 255, 255);
  font-family: Montserrat;
}
```

#### This is the Tailwind equivalent:

```html
<div
  class="flex flex-row justify-center items-center h-[100px] bg-[rgb(33,8,255)] text-center"
  style="background-image: radial-gradient(circle, rgb(255, 255, 255) 0.5px, transparent 0px); background-size: 20px 20px; background-position: center center;"
>
  <span class="text-5xl font-bold text-white font-['Montserrat']">
    I like Dots!
  </span>
</div>
```
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

{#thats-ok}

# "I Don't Know Zig, That's OK"

**You don't need to know Zig to start building with Vapor.**

If you've written JavaScript, TypeScript, C, Java, or really any programming language, you already understand 90% of what you need. Zig just looks a little different.

This section will get you comfortable in about 10 minutes.

{#the-basics-variables}

### The Basics: Variables

```zig
// Mutable (can change)
var count = 0;
var name = "hello";

// Immutable (cannot change)
const max_size = 100;
const title = "My App";
```

`var` for things that change, `const` for things that don't.

**JavaScript equivalent:**

```js
let count = 0;
const maxSize = 100;
```

{#functions}

### Functions

```zig
fn sayHello() void {
    // do something
}

fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

- `void` means "returns nothing" (like `void` in TypeScript)
- `i32` means "32-bit integer" (just a number, that can be negative and positive)

**JavaScript equivalent:**

```js
function sayHello() {
  // do something
}

function add(a, b) {
  return a + b;
}
```

{#the-one-weird-type-strings}

### The One Weird Type: Strings

At first glance, this looks strange, in comparison to other languages, but it's actually incredibly handy.

```zig
var message: []const u8 = "Hello World";
```

What does `[]const u8` mean?

- `u8` = a byte (each character is a byte)
- `[]` = a bunch of them in a row (an array)
- `const` = the characters themselves can't be changed

**Translation:** "A string."

That's it. Whenever you see `[]const u8`, just think "string."

```zig
// These are all just strings
var greeting: []const u8 = "Hello";
var name: []const u8 = "Vapor";
const url: []const u8 = "/home";
```

⚠️ **Pro tip:** Zig often infers types, so you can frequently just write:

```zig
var greeting = "Hello";
```

#### Handiness

Since `[]const u8` is an array of bytes, you can index into it or pull out slices of it.

```zig
const hello_world: []const u8 = "Hello World";

// Index into the string
const first_letter = hello_world[0];

// Slice the string
const first_three_letters = hello_world[0..3];
```

This is a very handy feature, and is used throughout Vapor, for example with url paths.

{#if-statements}

### If Statements

```zig
if (count > 10) {
    // do something
} else {
    // do something else
}
```

Identical to JavaScript. No surprises here.

{#loops}

### Loops

```zig
// Loop through items
for (items) |item| {
    Text(item).end();
}

// With index
for (items, 0..) |item, index| {
    Text(item).end();
}

// While loop
while (count < 10) {
    count += 1;
}
```

**JavaScript equivalent:**

```js
for (const item of items) {
  // ...
}

items.forEach((item, index) => {
  // ...
});

while (count < 10) {
  count += 1;
}
```

The `|item|` syntax is called "capture" - it's just how Zig names the loop variable.

{#structs}

### Structs (Like Objects)

```zig
const User = struct {
    name: []const u8,
    age: u32,
};

var user = User{
    .name = "Alice",
    .age = 30,
};

// Access fields
const username = user.name;
```

**JavaScript equivalent:**

```js
const user = {
  name: "Alice",
  age: 30,
};

const username = user.name;
```

The only difference: Zig uses `.name = value` instead of `name: value`.

{#the-dot-brace-pattern}

### The Dot-Brace Pattern

You'll see this everywhere in Vapor:

```zig
Button(.{ .on_press = handleClick })
```

That `.{ }` is just an anonymous struct (like an inline object in JS):

```js
// JavaScript
Button({ onClick: handleClick })

// Zig
Button(.{ .on_press = handleClick })
```

Same concept, slightly different punctuation.

{#printing-debugging}

### Printing / Debugging

```zig
// Print to console
Vapor.print("Hello", .{});
Vapor.print("Count is: {d}", .{count});
Vapor.print("Name is: {s}", .{name});
```

The `{d}` means "digit" (number), `{s}` means "string". The `.{}` passes the values to insert.

**JavaScript equivalent:**

```js
console.log("Hello");
console.log(`Count is: ${count}`);
console.log(`Name is: ${name}`);
```

{#what-you-can-ignore}

### What You Can Ignore (For Now)

These Zig concepts exist but **you won't need them** to build UIs:

| Concept             | Why you can skip it                         |
| ------------------- | ------------------------------------------- |
| `comptime`          | Vapor uses it internally; you don't have to |
| Allocators / Arenas | Vapor manages memory for you                |
| Pointers (`*T`)     | Only needed for advanced patterns           |
| Error unions (`!T`) | Vapor handles errors internally             |
| Optionals (`?T`)    | You'll learn when you need it               |

{#a-complete-example}

### A Complete Example

Here's a real Vapor component. See if you can read it:

```zig
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;
const Box = Vapor.Box;

var count: i32 = 0;
var message: []const u8 = "Click the button!";

fn handleClick() void {
    count += 1;
    if (count == 1) {
        message = "You clicked once!";
    } else {
        message = "Keep going!";
    }
}

pub fn render() void {
    Box().layout(.center).spacing(16).children({
        Text(message).font(18, 400, .black).end();

        Button(.{ .on_press = handleClick }).children({
            Text("Click me").font(16, 700, .white).end();
        });

        Text(count).font(24, 700, .blue).end();
    });
}
```

If you understood that, **you're ready to build with Vapor.**

{#quick-reference-card}

### Quick Reference Card

Keep this handy for your first few hours:

| JavaScript             | Zig                              |
| ---------------------- | -------------------------------- |
| `let x = 0`            | `var x: i32 = 0`                 |
| `const x = 0`          | `const x: i32 = 0`               |
| `"hello"`              | `"hello"` (type is `[]const u8`) |
| `function fn() {}`     | `fn name() void {}`              |
| `console.log(x)`       | `Vapor.print("{d}", .{x})`       |
| `for (const x of arr)` | `for (arr) \|x\|`                |
| `{ key: value }`       | `.{ .key = value }`              |
| `obj.method()`         | `obj.method()`                   |
| `// comment`           | `// comment`                     |

{#next-steps}

### Next Steps

Now that you're comfortable with the basics, you're ready to build something real.

Head over to [Making a Button](#making-a-button) to create your first interactive Vapor component.
{#project-structure}

# Project Structure

Project structure in Vapor, is really up to you, by default Vapor, uses the routes directory to hold all the routes.
Vapor, as you know, renders to IOS, and Web, more are to come. By default, Vapor will render to Web. You can pull the IOS compilation tool via
metal. Then render to IOS.

![Diagram](/assets/project_structure.svg)

- The **/web** directory holds the wasm bridge files, for connecting JS to vapor.wasm.
- The **/src** directory hold `main` and `routes`, and anything else you want to use or create.
- The **/ios** directory holds the IOS bridge files, for connecting zig to native IOS objc code.

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
    vapor.print("i get called when you navigate away from this page", .{});
}

pub fn render() void {
    text("i get rendered when you navigate to this page");
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
    Text("i get rendered when you navigate to this page");
}
```

`Page()` is the entry point for your routes render and deinit functions, these are called when you navigate to and from routes.
it takes 3 arguments,

- either `@src()` or `"/..."`

- `renderfn`

- `deinitfn`

`@src()` is a builtin function that returns the current source location.

### remember

Vapor takes a function approach, you need to call `Vapor.Page()` to declare your routes. or the corresponding function within the `.zig` file.

With the above example, we call our `Page(...)` function, within the `init()` function of `main.zig`. like this:

#### routes/app/about/page.zig

```zig
// /routes/app/about/page.zig
const vapor = @import("vapor");
const page = vapor.page;

// page initialization
pub fn init() void {
    page(.{ .src = @src() }, render, deinit); // this will refer to "/app/about" since we are in /routes/app/about/page.zig
}
```

#### main.zig

```zig
// /routes/app/about/page.zig
const vapor = @import("vapor");
const aboutpage = @import("routes/app/about/page.zig");

// page initialization
export fn init() void {
    vapor.init(.{});
    aboutpage.init();
}
```

**note:** don't forget to mark functions as `pub` if you want to call them from other files.
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
    text = Vapor.fmtln("Current count: {d}", .{counter});
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
    Button(.{ .on_press = increment })
        .onHover(changeColor)
        .shadow(.card(color))
        .children({
            Text(text).font(22, 700, color).end();
    });
}
```

@counter

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
    Button(.{ .on_press = increment }).children({
        Text("Increment").end();
    });
    Text(counter).end();

}
```

![diagram](/assets/event_state_diagram.svg)

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
    Button(.{ .on_press = increment }).children({
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
    Button(.{ .on_press = increment }).children({
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
    Button(.{ .on_press = increment }).end()({
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

var counter: Signal(u32) = undefined;

fn init() void {
    counter.init(0);
}

fn increment() void {
    counter.increment();
}

fn render() void {
    Static.Button(.{ .on_press = increment }).end()({
        TextFmt("I am a counter: {d}", .{counter.get()}).end(); // This updates
    });
}
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

{#vaporize}

# Vaporize

#### Vaporize is a Component function that is unqiue to Vapor

Vaporize, or vaporization, is the process of converting Zig code, Markdown, or HTML files into native Vapor components.

Vaporize, works like a runtime compiler, when loaded in the browser, and a build time compiler when used in a Zig build.

The runtime version is best used for when you need dynamic UI, and the build time version is best used for when you need static UI.

Vaporize exposes the following set of functions:

- **Mardown(anytype)** - Returns a comptime Markdown Type, which can be used to generate UI
  - **compile(string)** - Takes a markdown string and compiles it into native Vapor components
  - **render()** - Renders the compiled markdown

- **Form(struct {...})** - Returns a comptime Form Type, which can be used to generate UI
  - **compile()** - Takes a form struct and compiles it into native Vapor components
  - **render()** - Renders the compiled form from a struct

#### For example, we can Vaporize a Markdown file:

```zig
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");


var vaporizer: Vaporize.Compiler = undefined;
var markdown: vaporizer.MarkDown(.{}) = .{};

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
    // Initialize the vaporize compiler
    vaporizer = Vaporize.init(Vapor.arena(.persist), .{}) catch |err| {
        Vapor.printErr("Failed to initialize vaporizer: {any}", .{err});
        return;
    };

    markdown.compile(markdown_text) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any}", .{err});
        return;
    };
}

fn render() void {
    markdown.render() catch |err| {
        Vapor.printErr("Failed to render markdown: {any}", .{err});
        return;
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
   markdown.compile(markdown_text) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any}", .{err});
        return;
    };
}

fn render() void {
    markdown.render();
}
```

#### However, you can also do this at runtime.

Vaporize is a runtime compiler, so we can fetch the markdown file, and then compile it at runtime. For example the TextArea below, is a live markdown editor,
that generates UI at runtime.

@text_area

@realtime_markdown

You could use this to create a live markdown editor, that exists in the browser, and then in your Zig code, add functionality and styling.

#### We can also do this with normal Zig code:

For example, we can Vaporize a struct, which has a `__valdiations` field that is used for validations, and defining element types.

Each field type maps to a element type, for example `i32` maps to number `TextField`, and `bool` maps to `Checkbox`.

- `[]const u8` maps to `TextField`
- `[]const []const u8` maps to `TextArea`
- `i32` maps to `TextField`
- `bool` maps to `Checkbox`
- `enum` maps to `Radio`

```zig
const Vapor = @import("vapor");
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
var new_form: vaporize.Form(Form) = undefined;

pub fn init() void {
    // Initialize the vaporize compiler
    vaporizer = Vaporize.init(Vapor.arena(.persist), .{}) catch |err| {
        Vapor.printErr("Failed to initialize vaporizer: {any}", .{err});
        return;
    };
    new_form.compile() catch |err| {
        Vapor.printErr("Failed to compile form: {any}", .{err});
        return;
    };
}

fn render() void {
    new_form.render() catch |err| {
        Vapor.printErr("Failed to render form: {any}", .{err});
        return;
    };
}
```

@form

### Validations

With the `Form(...)` comptime function, we automatically get validations for free, if, if you want to style the different elements, or includes a custom
component, or validation. You can do so by adding a `__validations` field to your struct. Or the components anonymous struct.

One thing to note, is that the validations are anonymous struct, the order of the fields, and the field names, must coincide with the order of the struct fields.

You can also use the type definitions themselves, as a validation or boudnary, for example the age field is currently a u6 type, this means that the maximum value is 120.

Instead of having to check via an `if` statement, like so: `if (form.age > 120) {}`, we can simply use the type definition to ensure that the value is within the range.

You can also do the same with the string fields, like so: `[16]u8` instead of `[]const u8`, this means that the field can only contain 16 characters.

{#complex-form}

### Complex Form

Below is a sample of a complex checkout form, with validation and custom components. This is a real-world example of a checkout form.
It includes, conditionals, sections, custom components, validation, dropdowns, and auto formatting.

<!-- @complex_form -->

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
    Box().animationEnter(&fadeIn).children({
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
        .animationEnter(&anim_enter)
        .animationExit(&anim_exit)
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
        Button(.{ .on_press = toggleModal })
            .hoverAnimation("buttonHover")
            .children({
                Text("toggle modal").end();
        });

        if (show_modal) {
            Box()
                .animationEnter(&modalIn)
                .animationExit(&modalOut)
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
        .animationEnter(&fadeIn)
        .animationExit(&fadeOut)
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

````zig
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
}```

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
````

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
{#memory}

# Memory

In Vapor, the majority of memory is handled by the Vapor's engine _Codex_. If you haven't been exposed to memory management yet, it is recommended to read through the 
New to Zig section first, and then come back here.

{#memory-is-not-scary}

### Memory is not Scary

I started writing Zig in 2024, and before that I was a web developer. Never touched memory or a low-level language. It took me just 1 week to start
writing Zig. Zig isn't C, C++ or Rust, it's **simple**, and **intutive**, all thanks to _Andrew Kelley_, and the core Zig team.

Rust prioritizes safety guarantees; **Zig prioritizes explicitness and simplicity**.

Zig makes memory management easy.

#### Vapor, takes it one step further.

Vapor exposes 4 memory arenas

#### `arena(memory_type)`

The `arena` function takes a **memory_type** argument, and returns the corresponding allocator, which is used for all memory allocations.

1. **.frame** the frame allocator, is used for memory that needs to be allocated and deallocated in a single render cycle. (Frames: are just a single render cycle, ie FPS)
2. **.view** the view allocator, is used for memory that needs to be allocated and deallocated per page.
3. **.persist** the persist allocator, is used for memory exists across your entire application, and is never freed.
4. **.scratch** the scratch allocator, is used for memory that can be freed by you the developer, at any time you want.

#### How they work in practice

```zig
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;

pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

pub fn render() void {
    const u32_number = Vapor.arena(.frame).create(u32) catch {};
    Text(u32_number).end();
}
```

In the above example, we use the **frame** arena, to allocate memory for a u32 number. Since we are creating a new number, inside the `render()` function, This creates a new u32 number
, every time the UI is updated. (Remember, Vapor is akin to a game engine, everytime the UI changes, it re-runs the `render()` function)

We use the **frame** arena type, here, since Vapor will automatically free any memory that is allocated in the frame arena, when we have finished rendering the UI.

![Diagram](/assets/vapor_arena_frame_example.svg)

#### Another example

Imagine, we have two pages, one for contacting support, and another for applying for a job.

On the contact page, we have a list of problems. The user can select the most relevent problem, and then click a button, to send the contact information to support.

On the job page, we have a list of jobs. The user can select the most relevent job, and then click a button, to send the contact information to the employer.

Each page, uses a different list. There is no point is having both lists in memory, at the same time. We aren't sharing the lists across pages.

In Vapor, we can use the **view** arena type, to allocate memory for the lists. This is because when we navigate to the job page, we want to create the jobs list,
and when we navigate away we want to free the memory that was allocated.

Vapor handles this automatically, it listens to the route changes, and frees all the memory from the **view** arena, when we navigate away.

```zig
// Contact page
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;

pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

pub fn mount() void {
    const view_allocator = Vapor.arena(.view);
    var problems = view_allocator.alloc([]const u8, 15) catch {};
    for (0..15) |i| {
        problems[i] = try std.fmt.allocPrint(view_allocator, "Problem {d}", .{i});
    }
    // ... Define the problems list
}

pub fn render() void {
    Hooks(.{ .mounted = mount })({
        Center().spacing(16).padding(.all(20)).children({
            Text("Contact").font(24, 700, .palette(.text_color)).end();
            List().direction(.column).layout(.{}).pos(.{}).children({
                for (problems) |problem| {
                    ListItem().children({
                        Text(problem).font(14, 700, .palette(.text_color)).end();
                    });
                }
            });
        });
    });
}
```

```zig
// Jobs page
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;

pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

pub fn mount() void {
    const view_allocator = Vapor.arena(.view);
    var jobs = view_allocator.alloc([]const u8, 10) catch {};
    for (0..10) |i| {
        jobs[i] = try std.fmt.allocPrint(view_allocator, "Job {d}", .{i});
    }
    // ... Define the jobs list
}

pub fn render() void {
    Hooks(.{ .mounted = mount })({
        Center().spacing(16).padding(.all(20)).children({
            Text("Jobs").font(24, 700, .palette(.text_color)).end();
            List().direction(.column).layout(.{}).pos(.{}).children({
                for (jobs) |job| {
                    ListItem().children({
                        Text(job).font(14, 700, .palette(.text_color)).end();
                    });
                }
            });
        });
    });
}
```

![Diagram](/assets/vapor_arena_view_example.svg)

### But that's not all!

Vapor includes a whole suite of memory management functions, that are used to allocate and free memory in a safe and efficient manner.
Some examples are shown below.

### `Array(T, memory_type)`

- A array allocated on the memory type specified.
  - This is useful, for creating arrays that live in a specific page, or frame, or should exist for the lifetime of the application.

```zig
// Allocated on the page, and deallocated when navigated away from
var array = Vapor.Array(u32, .view);
array.append(1);
array.append(2);
array.append(3);
```

### `fmtln(comptime fmt: type, args: anytype)`

- A function that is similar to `std.fmt.print`, but exists only for the frame.
  - This is useful, for creating strings within your UI.

```zig
pub fn SectionList() void {
    List().children({
        for (current.sections) |section| {
            // All normal Zig code in our UI!
            const title = section.title;

            // We create the url using fmtln, which is a function that is only available in the frame
            const url = Vapor.fmtln("#{s}", .{section.link});
            ListItem().children({
                Link(.{ .url = url, .aria_label = title }).children({
                    Text(title).end();
                });
            });
        }
    });
}
```
{#layouts}

# Layouts

Layouts are a powerful tool for building complex UIs.
They allow you to create a hierarchy of components that can be nested and positioned in a flexible way.
Components rendered within a layout, will render in every sub path of the origin route.

origin route: `/app`, then Navbar will render in `/app/about` and `/app/contact`.

```zig
fn registerLayouts() !void {
    try Vapor.registerLayout("/app", layout, .{});
    try Vapor.registerLayout("/docs", layoutDocs, .{ .reset = true });
}

pub fn layout(page: Vapor.PageFn) void {
    Navbar.render();
    page();
}

pub fn layoutDocs(page: Vapor.PageFn) void {
    DocsNavbar.render();
    page();
    Footer.render();
}
```

Every framework has its own way of defining layouts. Vapor uses a explicit functional approach, you can register a layout
anywhere in your codebase.

{#register-layout}

### registerLayout(string, LayoutFn, LayoutOptions)

`LayoutFn` is a function that takes a `page: PageFn` function as an argument, and renders the page within the layout.
`PageFn` is the same function that we use in `Page()` functions, it is nothing more than an alias for `*const fn () void`.

`.reset` is a field that is used to reset the layout hierarchy, this is useful for when you want to use a different layout in the same route path.

```zig
fn registerLayouts() !void {
    try Vapor.registerLayout("/app", layout, .{});
    try Vapor.registerLayout("/app/about", layoutAbout, .{ .reset = true });
}

pub fn layout(page: Vapor.PageFn) void {
    Navbar.render();
    page();
}

pub fn layoutAbout(page: Vapor.PageFn) void {
    About.render();
    page();
}
```

Now when we navigate to `/app/about`, the layout will be reset, and the About component will render. And the Navbar will not.
If we were to remove the `.reset` field, then the About component would render within the Navbar layout.

By default, Vapor will rerender and, mark all nodes as dirty when the route changes. This is not costly, there is no need to memoize.
This is because reloads should cause a full rerender and call to the server. State will persist, across all route changes, by default.

Reloads, will cause state to be reset, and Vapor will treat the route as fresh.
{#events-and-handlers}

# Events and Handlers

Events and Handlers in Fabric use a very similar approach to fetching.
We pass a callback which is called when an event is triggered.

![Diagram](/assets/event.svg)

There are element event listeners and global event lisenters.
Each takes a callback function and returns the callback id, which can then be used to unMount the listener.

{#basic-event-listener}

### Basic event listener

Here is a basic example of an global event listener. Which listens for the `keydown` event, and then checks if the key pressed is `k` and the meta key is pressed.

```zig
const Vapor = @import("vapor");

fn onKeyPress(evt: *Vapor.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "k") and evt.metaKey()) {
        evt.preventDefault();
        Vapor.println("Open dialog\n", .{});
    } else if (std.mem.eql(u8, key, "Escape")) {
        evt.preventDefault();
        Vapor.println("Close dialog\n", .{});
    }
}

fn mount() void {
    // Here we set globally and event listener for onKeyDown
    Vapor.eventListener(.keydown, onKeyPress);
}
```

All we have to do is call `Vapor.eventListener` and pass in the event type, and the callback function.
The event system is very similar to how native web events work, when rendering to IOS, the same system will be used.
There is no need to change or alter the syntax or code.

{#binded-event-listener}

### Binded event listener

Binded is a struct that contains functions and fields of a native element, we can attach event listeners and mutate the underlying element.
We first create a binded element width `Binded{}`, and then attach a listener to it. By default, Vapor will auto attach ids to the binded element,
and update the values. For example, there is no need to do the typical `getText` and `setText` implementation.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Binded = Vapor.Binded;
const Static = Vapor.Static;
const TextField = Static.TextField;
const Text = Static.Text;

var binded_textfield: Binded = Binded{};
fn onWrite(evt: *Vapor.Event) void {
    const input_text = evt.text(); // this is from the event itself
    Vapor.println("{s}", .{input_text});
}

var listener_id: ?u32 = null;
fn mount() void {
    // here we attache a listener to the element itself
    listener_id = Vapor.addListener(binded_textfield.element, .keydown, onKeyPress);
}

fn destroy() void {
    // Here we remove the listener
    if (listener_id) |id| {
        Vapor.removeListener(id);
    }
}

pub fn render() void {
    // Hooks calls to mount when all its children have been added to screen.
    Static.Hooks(.{ .mounted = mount, .destroy = destroy })({
        TextField(.string)
            .bind(&binded_textfield)
            .onChange(onWrite)
            .plain();
    });
    Text(binded_textfield.text).plain(); // binded_textfield.text is updated automatically
}
```

{#type-safety}

### Type safety

Since we are using Zig, Vapor is type safe, and will not allow for events to be called on the wrong element.
For example, a `click` event will not work on non-buttons, or non-links Components, similarly, an `onChange` event will not work on a non-textfield
component. Vapor will return an error if this occurs.

{#field-saftey}

### Field saftey

Similarly, Vapor will disallow specific fields from being set, or retrieved from the element. The `key` field is not allowed on a Box component,
or a Text component, ect.
{#hooks-overview}

# Hooks

There are two vairations of Hooks in Vapor, one is based on the router, and the other is based on the lifecycle of components or pages.

- Router Hooks

- Lifecycle Hooks

{#router-hooks}

## Router Hooks

Router Hooks are a powerful tool for handling complex route management. They work similarly to Layouts in Vapor.

Hooks allow you to create a hierarchy of routes that can be nested and called in a flexible way.
Each Hooks is a function call, that returns a HookContext struct, which contains the current route path, and the current route params.

```zig
const Vapor = @import("vapor");
pub fn registerHooks() !void {
    try Vapor.registerHook("/app", appHook, .before);
    try Vapor.registerHook("/app/about", aboutHookAfter, .after);
    try Vapor.registerHook("/app/about", aboutHookLeave, .leave);
}

pub fn appHook(ctx: Vapor.HookContext) !void {
    Vapor.print("App Hook called BEFORE page load ({s})", .{ctx.to_path});
}
pub fn aboutHookAfter(ctx: Vapor.HookContext) !void {
    Vapor.print("App About Hook called AFTER page load ({s})", .{ctx.to_path});
}
pub fn aboutHookLeave(ctx: Vapor.HookContext) !void {
    Vapor.print("App About Hook called on route LEAVE ({s})", .{ctx.to_path});
}
```

The above will be called in the following order:

![Hooks](/assets/hooks.svg)

{#hook-context}

### HookContext

`HookContext` is a struct that contains the current route path, and the current route params.

```zig
pub const HookContext = struct {
    from_path: []const u8,
    to_path: []const u8,
    params: std.StringHashMap([]const u8),
    query: std.StringHashMap([]const u8),
};
```

Every framework has its own way of defining layouts. Vapor uses a explicit functional approach, you can register a layout
anywhere in your codebase.

{#register-hook}

### registerHook([]const u8, HookFn, HookType)

`HookFn` is a function that takes a `ctx: HookContext` struct as an argument, and can be used within the hook call.
`HookType` is an enum type, that is used to determine when the hook should be called.

{#lifecycle-hooks}

## Lifecycle Hooks

Lifecycle Hooks are a powerful tool for handling lifecycle components or pages. They work similarly to other frameworks, but are more flexible.

{#component-hooks}

### Component Hooks

- **mounted** runs once the component is mounted after the entire DOM has been rendered.

- **created** runs every time the component is created, during the rendering of the DOM.

- **updated** runs every time the component is updated, during the rendering of the DOM.

- **destroyed** runs every time the component is destroyed, during the rendering of the DOM.

```zig
fn mount() void {
    Vapor.print("Mounted", .{});
}

fn render() void {
    Hooks(.{ .mounted = mount })({
        // ...
    });
}
```

{#tree-hooks}

### Tree Hooks

- onEnd

- onCommit

{#onend}

### OnEnd

`onEnd` is a function that takes a callback function as an argument, and will run the callback after the entire tree has been rendered.

onEnd is useful in scenarios in which you want to inject components, or mutate the DOM after the initial tree has been rendered. As you may
have noticed, every documentation page, has a set of Numbered Boxes on the right side. These are injected after generating the initial content page.

After the initial render, we query all the Heading components, by type, and then inject a Box component at the Heading positions, like so:

```zig
pub var boxes: []BoxNumber = undefined;
// var bounds: Vapor.lib.Bounds = undefined;
const BoxNumber = struct {
    id: []const u8,
    number: usize,
    bounds: Vapor.lib.Bounds = .{},
    active: bool = false,
};

pub fn initBoxes() void {
    boxes = Vapor.lib.frame_arena.getRouteAllocator().alloc(BoxNumber, 0) catch unreachable;
    const ids = Vapor.queryComponentIds(.Heading) catch unreachable;
    boxes = Vapor.lib.frame_arena.getRouteAllocator().alloc(BoxNumber, ids.len) catch unreachable;
    for (ids, 0..) |id, i| {
        const bounds = Vapor.getBoundingClientRect(id) orelse unreachable;
        const box_id = std.fmt.allocPrint(Vapor.lib.frame_arena.getRouteAllocator(), "box-{d}", .{i}) catch unreachable;
        boxes[i] = .{ .id = box_id, .number = i, .bounds = bounds };
    }
}

fn goto(url: []const u8) void {
    Vapor.onEnd(initBoxes); // This will triger at the end of the current cycle
    Vapor.Kit.navigate(url);
}

```

This is a very powerful feature, since now we can inject elements based on current context, this also occurs during reconciliation, so before
the DOM is committed to the browser, we are querying from the virtual tree directly. This is not allowed in traditional frameworks.

This also makes Vapor agnostic to the target renderer, instead of bridging to the DOM to query or to objc to query component information, we
can query the virtual tree that is generated by Vapor.

{#oncommit}

### OnCommit

`onCommit` is a function that takes a callback function as an argument, and will run the callback after the virtual DOM has been generated.

This is useful for when we want to parse the virtual tree, and perform some action based on the state of the tree.

The commit callbacks will only be called once, per render cycle, this means you cannot recursivley call `onCommit` from within the callback.

```zig
const Vapor = @import("vapor");

fn mount() void {
    Vapor.onCommit(addTextComponent);
}

fn addTextComponent() void {
    Text("Hello World").font(24, 700, .red).close();
    Vapor.cycle();
}
```

There are 4 stages of Vapor's lifecycle.

- Idle

- Generating

- Commiting

- Applying

During the commiting stage, the onCommit callbacks will be called in the order they were registered.
# Web-Dev to Vapor Cheat Sheet

This guide helps developers transition from **React**, **Vue**, or **Svelte** to the high-performance world of **Vapor**. While traditional frameworks manage heavy JavaScript runtimes, Vapor acts as a compiled instruction engine that treats the browser like a graphics driver.

## 1. Conceptual Mapping

| Feature | React / Vue / Svelte Habit | Vapor Paradigm | Mental Shift |
| :--- | :--- | :--- | :--- |
| **Component Body** | Re-runs on every change (React) or uses Observers (Vue/Svelte). | The `render()` function runs as a native instruction pass. | From "Component Instance" to "Render Loop Instruction". |
| **State Persistence** | `useState`, `ref`, or `$state`. | normal variables living **outside** `render()`. | Data and UI are separate; no "rescuing" variables is needed. |
| **Side Effects** | `useEffect`, `watch`, or `$effect`. | Procedural logic within Event Handlers or functional triggers. | Move away from implicit subscriptions to explicit Zig logic. |
| **Conditional UI** | `{cond && <UI />}`, `v-if`, or `{#if}`. | Standard Zig `if` or `switch` statements. | Use native programming control flow instead of template syntax. |
| **List Rendering** | `.map()`, `v-for`, or `{#each}`. | Standard Zig `for` and `while` loops iterating over arrays or slices. | Direct iteration over memory-contiguous data. |


## 2. Reactivity & State Logic

In JavaScript frameworks, state is often "reactive" via proxies or setters. In Vapor, the **UI is reactive**, not the variables.

| Task | React (useState) | Vue (ref) | Svelte ($state) | **Vapor (Zig)** |
| :--- | :--- | :--- | :--- | :--- |
| **Declare State** | `const [val, setVal] = useState(0);` | `const val = ref(0);` | `let val = $state(0);` | `var val: u32 = 0;` |
| **Update State** | `setVal(v => v + 1);` | `val.value++;` | `val += 1;` | `val += 1;` |
| **Derived State** | `useMemo(() => val * 2, [val])` | `computed(() => val.value * 2)` | `let double = $derived(val * 2)` | Zig function or variable. |

> **Note:** Vapor's **Atomic Mode** detects these direct mutations during events and performs fine-grained updates to the DOM only where necessary.

## 3. Lifecycle & Hooks

Vapor replaces the complex hook system with predictable Zig entry points.

| Lifecycle Event | React Hook | **Vapor Lifecycle / Hook** |
| :--- | :--- | :--- |
| **Initial Load** | `useEffect(fn, [])` | `pub fn init() { ... }` (Global) or `.mounted` (Component). |
| **Component Mount**| `useLayoutEffect` | `Hooks(.{ .mounted = func })`. |
| **Data Cleanup** | `return () => cleanup` | `.destroyed` hook or `deinit` function in Routing. |
| **Route Navigation**| `useNavigate` | `Vapor.Kit.navigate("/url")`. |

## 4. Memory Management: The "Web Dev Hack"

Because WASM has a fixed memory linear buffer, you must manage it. Vapor simplifies this using **Arenas**.

| Arena Type | Equivalent JS Concept | When to use it in Vapor |
| :--- | :--- | :--- |
| **`.frame`** | Local variables in a function. | Temporary data used only for the current render frame (e.g., formatting strings). |
| **`.view`** | Data scoped to a specific URL/Page. | Large datasets or lists specific to the current page (automatically freed on navigate). |
| **`.persist`** | Global variables / Redux store. | Core application state that must exist for the entire session. |


A good rule of thumb is to use `.persist` in anything within the `init()` function. `.view` for anything within the `mount` or `navigation functions`, 
and `.frame` for anything within the `render`. Feel free to create your own arenas if you need to, for example a `.scratch` arena for temporary data, 
that is tied to the Component itself, then call `destroy()` hook, and deinitialize the arena or reset its memory.

You can take a look at Opaque UI lib at [vapor-ui](https://vapor-ui) for examples of how to use arenas, that are tied to the Component itself.

## 5. Quick Syntax Reference

### Styling & Layout
If you are coming from a framework that requires wrapping everything in `<div>` or `<span>`, Vapor's builder pattern will feel much cleaner.

**React (Tailwind):**

```jsx
<div className="flex justify-center p-4">
  <p className="text-lg font-bold">Hello World</p>
</div>
```

**Vapor (Auto Complete and Type Safe):**

```zig
Box().layout(.center).padding(.all(16)).children({
    Text("Hello World").font(18, 700, .black).end();
});
```

{#codex-engine}

# Codex Engine

The Codex Engine refers to Vapor's core rendering engine, and is responsible for generating the render commands.

**Vapor is a compiled instruction engine for the web.**

Traditional frameworks parse templates and manage heavy Javascript runtimes.
**Vapor** compiles native Zig functions into a compact binary of render commands.
Despite compiling to binary instructions, Vapor is fully inspectable.

Vapor treats the browser like a graphics driver, you create the UI with simple functions, and then
Vapor & Zig work together to compile your UI into a compact, optimized set of instructions.
These instructions are sent to the DOM only when necessary.
No strings, no parsing, just direct-to-metal UI performance.

This gives Vapor the unique capability, of writing standard declarative UI code,
that compiles down to a high-performance runtime with a dramatically reduced memory footprint.

{#how-it-works}

## How it works

1. Write your UI.
2. Compile into optimized instruction function calls.
3. Generate a Virtual Tree by calling these instructions.
4. Reconcile the Virtual Tree against the old tree.
5. Generate a set of Render Commands:
   - Dirty Nodes
   - Added Nodes
   - Removed Nodes
6. Schedule a UI update.
7. Render the UI via native Web APIs.

We write our UI using the functions that Vapor exposes, like `Text`, `Button`, and `Box`.
These functions follow a unified builder pattern. This allows Zig and LLVM to generate identical machine code for the
internal logic of every builder, meaning we do not need to compile unique boilerplate for every component. We use one shared function for all builders.

This is further optimized by how Vapor handles tree generation. In a typical React environment, the runtime must transpile and read every specific element (e.g.,
`<p>Hello</p>`) to generate a DOM element (`document.createElement("p").textContent = "Hello"`). This compilation overhead occurs for every unique element in your application.

Vapor, conversely, uses the UI logic itself to generate the tree via a `LifeCycle` struct.

```zig
/// The LifeCycle struct
/// Allows control over a UI node in the tree.
/// Exposes open, configure, and close, which must be called in order.
pub const LifeCycle = struct {
    /// open takes an element decl and returns a *UINode
    /// This opens the element to allow for children.
    /// Within the tree, this newly opened node becomes the top of the stack;
    /// any subsequent children will reference this node as their parent.
    pub fn open(elem_decl: ElementDecl) ?*UINode {
        const ui_node = current_ctx.open(elem_decl) catch |err| {
            println("{any}\n", .{err});
            return null;
        };
        return ui_node;
    }
    /// close closes the current UINode
    pub fn close(_: void) void {
        _ = current_ctx.close();
        return;
    }
    /// configure is used internally to configure the UINode (e.g., adding text or hover props).
    /// We check if the node has an ID (using it if so, or generating one later).
    /// Any manipulation of the node after this point is considered undefined behavior.
    pub fn configure(elem_decl: ElementDecl) void {
        _ = current_ctx.configure(elem_decl);
    }
};
```

{#example}

## An Example

#### The Core Concept: Stack-Based Tree Building

Vapor does not build a virtual tree by allocating objects and linking them manually., instead it builds it via **side effects**
on a global stack.

This process relies on three functions: `open`, `configure`, and `close`.

1. `open` Pushes a node onto the global stack.
2. `configure` Applies styles and attributes to the current node.
3. `close` Pops the node off the stack.

### Step by Step Execution

```zig
Box().center().children({
    Text("Hello");
});
```

#### Box() The Constructor

Box() is called to, which in turn calls the `open` function, this pushes the Box Node onto the global stack.
This Node is now the "Current Parent".

The returned `Self` struct is the Builder struct itself, and now contains a pointer to the open `ui_node`.

```zig
pub fn Box(value: anytype) Self {
    ///... implementation details

   const elem_decl = ElementDecl{
        .state_type = _state_type,
        .elem_type = .Box,
    };

    const ui_node = LifeCycle.open(elem_decl) orelse {
        Vapor.printlnSrcErr("Could not add component Link to lifecycle {any}\n", .{error.CouldNotAllocate}, @src());
        unreachable;
    };

    return Self{
        ._elem_type = .Box,
        ._ui_node = ui_node,
    };
}
```

#### center() The Style Function

The builder method .center() is called on the result of Box().
**Engine State**: No change. This is purely a local Zig memory operation.
It copies the Builder struct, modifies the \_layout field, and returns the new struct. The UI tree is untouched.

```zig
pub fn center(self: *const Self) Self {
    var new_self: Self = self.*;
    new_self._layout = .center;
    return new_self;
}
```

#### Argument phase { Text("Hello") }

This is the most critical part. In Zig, function arguments are evaluated before the function is called.
Therefore, the block passed to .children(...) runs before .children executes.

Inside the block, we call Text("Hello"). This calls the `open` function, which pushes the Text Node onto the global stack.

#### Engine State:

1. The engine looks at the stack.
2. It sees the Box (from Step 1) is at the top.
3. It attaches Text as a child of Box.
4. It pushes Text onto the stack.
5. Since Text is a leaf, we immediately call close, popping itself off the stack.

The returned `Self` struct is the Builder struct itself, and now contains a pointer to the open `ui_node` which is the Text Node.

#### The Function Body: .children(...)

Now that the block (the argument `_: void`) has finished executing, the children function body finally runs.

The children function executes using the Self struct from Step 2 (which contains the .center() style of the Box Node).

1. **Aggregation:** It gathers all the styles (layout, padding, visuals) from the Self struct into a Style object .
2. **Configuration:** It calls Vapor.LifeCycle.configure(elem_decl). This applies the "center" layout to the Box node (which is still sitting open on the stack).
3. **Closure:** It calls Vapor.LifeCycle.close({}).

The Box() node is popped off the stack, and we can now continue to the next function call.

```zig
pub fn children(self: *const Self, _: void) void {
    ///... implementation details
    Vapor.LifeCycle.configure(elem_decl);
    return Vapor.LifeCycle.close({});
}
```

#### \_: void

The Syntax: \_: void means the function expects an argument of type void.

The Trick: A block in Zig { ... } evaluates to the value of its last statement. If the last statement is a semicolon or empty, it returns void.

The Purpose: It forces the developer to write a code block that executes prior to the configuration of the parent.

This architecture allows Vapor to be incredibly memory efficient.
It only allocates the lightweight Self structs temporarily on the stack to gather configuration data,
and then discards them immediately after the node is closed.

Above `_: void` is a special trick in Zig, (some call it **cursed**). This allows us to call the inner function first, but only return after the void argument has run.

{#comparison-to-typical-frameworks}

## Comparison to Typical Frameworks

### Compiler stage

The compiler stage is illustrated in the diagram below.
This is a simplified version of how compilers work, but since we use Zig, we inherit all its optimization and compilation benefits.
We also use LLVM to generate WebAssembly and wasm-opt to optimize the binary.

This results in an average 40x reduction in size. For example, the debug version of this documentation site is 7MB, while the release version is only 180KB.

@compiler_image

### Binary Deduplication

In the example below, we create 3 text elements in Svelte:

```svelte
<script>
	let step1 = 1;
	let step2 = 2;
	let step3 = 3;
</script>

<p>{step1}. Svelte</p>
<p>{step2}. Output</p>
<p>{step3}. Example</p>
```

#### Svelte Compiled result

When looking at the resulting compiled code,
we can see that multiple versions of the same elements are created.
Each is essentially the exact same code but with different arguments.
While the state management is compiled away, we are left with duplicated source code sent to the browser.

```js
import "svelte/internal/disclose-version";
import "svelte/internal/flags/legacy";
import "svelte/internal/flags/async";
import * as $ from "svelte/internal/client";

var root = $.from_html(`<p></p> <p></p> <p></p>`, 1);

export default function App($$anchor) {
  let step1 = 1;
  let step2 = 2;
  let step3 = 3;
  var fragment = root();
  var p = $.first_child(fragment);

  p.textContent = "1. Svelte";

  var p_1 = $.sibling(p, 2);

  p_1.textContent = "2. Output";

  var p_2 = $.sibling(p_1, 2);

  p_2.textContent = "3. Example";
  $.append($$anchor, fragment);
}
```

{#vapor-difference}

### Vapor Difference

You might argue that in Svelte you would use an {#each} loop to remove duplication.
However, not every element exists in a loop. Vapor dedupes all common elements at the core level, even across different pages.

In Svelte or React, you must manually extract common HTML elements into components to prevent code duplication.
In Vapor, there is only one single function call for each element type (like Text or Box) across the entire application.

This is why Vapor achieves such a small footprint.
For context, a single server-side rendered documentation page on [Next.js](https://nextjs.org/docs) is approximately 800KB of JavaScript.
Vapor's entire documentation site, with client-side rendering, is only 180KB.

#### The "Stamp" vs. "Sketch" Analogy

To understand why Vapor is so small, we have to look at how the machine code is generated.

In typical JavaScript frameworks, compiling a UI often acts like a Sketch. If you need three buttons, the compiler often writes
out the instructions to create Button A, then writes out the instructions to create Button B, and then Button C.
Even though they are similar, the specific "setup" code is repeated for every element in your application. As your app grows, your bundle size grows linearly.

Vapor acts like a Rubber Stamp. Because we compile to a native binary (WASM) using LLVM, the logic for how to create a
Button exists in memory at exactly one address.

Compared to other frameworks, Vapor gains the benefit of running like a game engine. Svelte, React,
and others may differentiate in how they handle and reconcile state changes, but they implement similar concepts regarding UI creation.

When you write:

```zig
Box().children({
    Text("Step 1");
    Text("Step 2");
    Text("Step 3");
});
```

The compiler does not generate the code for `Text` three times.
Instead, it generates the `Text` function **once** in the binary's "Text Section" (executable instructions).
The application then simply makes three lightweight function calls (jumps) to that same memory address, passing different arguments
("Step 1", "Step 2", etc.) each time.

{#instructions-vs-information}

### Instructions vs Information

**Instructions (The Logic):** The machine code that knows how to build the DOM, handle styles, and manage layout. This is constant.

**Information (The Arguments):** The strings, colors, and integers you pass in.

In the Svelte example previously shown, the compiler generated unique setup lines for every paragraph `(p.textContent = ..., p_1.textContent = ...)`.

In Vapor, adding 1,000 more text elements to your page adds almost zero overhead
to the logic size of your binary. It only adds the tiny footprint of the strings themselves and the function call instructions.
This is why Vapor scales like a game engine rather than a web page.

{#performance}

# Performance

Performance, is a major concern in all of Tether. It is one of the core reasons why I chose Zig, and why I built Tether.

{#memory-speed-runtime}

## Memory, Speed, Runtime

{#memory}

### Memory

Vapor, is highley optimized for memory usage. While A Hello World example in debug mode is 2.2MB, in release mode
this drops down to 28kb of memory.

**For context:**

- React + ReactDOM (minified): ~130KB

- Vue 3 (minified): ~110KB

- Svelte runtime: ~5KB

- **Vapor Hello World: 28KB** ✨

This documentation site, is originally 7MB, in release mode, it drops down to 150kb. a 40x reduction in memory usage.

The compression ratio improves with larger applications,
plateauing around 40x for production sites. Larger apps
benefit more from dead code elimination and deduplication.

{#speed-runtime}

### Speed, Runtime

> ⚠️ All tests are run on a 2021 M1 MacBook M1 Pro.

Out the gate, Vapor handles rendering **1,000 rows** in (~50-58ms), and updating in (2-3ms).
With **10,000 rows**, (~400ms), for rendering and (2-3ms) updating.

Compare this to traditional frameworks:

- React: ~1000 rows **create** (~60ms), **update** (20ms).

- React: ~10000 rows **create** (544ms), **update** (94ms).

- Svelte: ~1000 rows **create** (50ms), **update** (17ms).

- Svelte: ~10000 rows **create** (347ms), **update** (108ms).

This is possible because Vapor's reconciliation runs in WASM
with linear memory, then sends a compact diff to the DOM
rather than traversing JavaScript objects. Moreover, Vapor at runtime, compacts styles, and removes dead css.
Resulting in a lower memory footprint, and faster rendering.

{#default-mode}

## Default Mode

By default, Vapor, will dedupe styles, reconcile pure nodes that are dirty, remove, update, and add nodes. Without the need for
any state management, external dependencies, configuration or build flags. The point of Vapor and Tether as a whole, is to focus on your
application, and not build systems or configuation.

{#full-stack}

## The Full Stack

Tether isn't just a frontend framework. Running a single
command spins up:

**Frontend (Vapor):**

- 10,000+ node updates at 60fps

- 20KB total bundle size

- Zero-config reactivity

**Backend (Reverb):**

- 220K requests/second (M1 MacBook Pro)

- HTTP/WebSocket support

- Zero external dependencies

**Database (Canopy):**

- SQL and RESP protocol support

- In-memory hashmap performance

- Embedded or standalone modes

All from one `metal release` command. No Docker, no config
files, no dependency hell.
{#vapor-tictactoe-tutorial}

# Building Tic-Tac-Toe with Vapor

#### Learn Vapor's core concepts by building a classic game.

In this tutorial, we'll build a fully functional Tic-Tac-Toe game using Vapor. Along the way, you'll learn:

- How to structure a Vapor application
- State management without hooks or signals
- Event handling and user interaction
- Conditional rendering and loops
- Styling with the builder pattern

By the end, you'll have a working game and a solid understanding of Vapor's fundamentals.

{#prerequisites}

## Prerequisites

Before starting, make sure you have Vapor installed:

%curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash

%metal create vapor tictactoe

%cd tictactoe && metal run web

Visit [localhost:5173](http://localhost:5173/) to see your app running.

{#project-setup}

## Project Setup

Our Tic-Tac-Toe game will have a simple structure:

```
tictactoe/
├── src/
│   ├── main.zig          # Entry point
│   └── routes/
│       └── home/
│           └── Page.zig   # Our game lives here
└── web/
    └── index.html
```

{#game-state}

## Step 1: Define the Game State

First, let's think about what state our game needs:

- A 3x3 board to track X's and O's
- Whose turn it is (X or O)
- Whether the game is over
- Who won (if anyone)

In Vapor, state lives **outside** the render function. This is different from React where you'd use `useState`. Let's define our state:

```zig
// src/routes/home/Page.zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const Center = Vapor.Center;
const ButtonCtx = Vapor.CtxButton;

// Game state - lives OUTSIDE render()
var board: [9]?bool = .{ null, null, null, null, null, null, null, null, null };
var is_x_turn: bool = true;
var game_over: bool = false;
var winner: ?bool = null; // null = draw, true = X wins, false = O wins

pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}
```

**Key Insight:** In Vapor, `null` represents an empty cell. `true` represents X, and `false` represents O. This is idiomatic Zig - using optionals (`?bool`) to represent "maybe a value".

{#render-board}

## Step 2: Render the Game Board

Now let's create the visual board. We'll use a grid of 9 cells:

```zig
fn render() void {
    Center()
        .height(.percent(100))
        .background(.hex("#ecf0f1"))
        .children({
            Box()
                .direction(.column)
                .layout(.center)
                .spacing(16)
                .children({
                    // Title
                    Text("Tic-Tac-Toe")
                        .style(&title_style);

                    // Status message
                    renderStatus();

                    // Game board
                    Box()
                        .style(&board_container_style)({
                            renderBoard();
                    });

                    // Reset button
                    Button(.{ .on_press = resetGame })
                        .style(&reset_button_style)({
                            Text("New Game").end();
                    });
            });
    });
}
```

Notice how we break the UI into smaller functions: `renderStatus()` and `renderBoard()`. This keeps our code organized and readable.

Also note that `.style(&some_style)` doesn't need `.children({})` - it directly takes the block with `({})`.

{#board-grid}

## Step 3: Create the Board Grid

The board is a 3x3 grid. We'll use Vapor's `Box` component with a `wrap` modifier:

```zig
fn renderBoard() void {
    Box()
        .width(.px(306))
        .wrap(.wrap)
        .children({
            for (0..9) |i| {
                renderCell(i);
            }
    });
}

fn renderCell(index: usize) void {
    const cell_value = board[index];
    const is_clickable = !game_over and cell_value == null;
    const is_winning = isWinningCell(index);

    // Dynamic background color
    const bg_color: Vapor.Types.Background = if (is_winning)
        if (winner.?) .hex("#fadbd8") else .hex("#d4e6f1")
    else if (is_clickable)
        .hex("#ffffff")
    else
        .hex("#f5f5f5");

    var cell = ButtonCtx(makeMove, .{index})
        .baseStyle(&cell_base)
        .background(bg_color);

    if (is_clickable) {
        cell = cell.hoverBackground(.hex("#e8e8e8")).cursor(.pointer);
    }

    if (is_winning) {
        cell = cell.animation(&win_animation);
    }

    cell.children({
        if (cell_value) |is_x| {
            Text(if (is_x) "X" else "O")
                .font(44, 700, if (is_x) .hex("#e74c3c") else .hex("#3498db"))
                .animationEnter(&place_animation)
                .end();
        }
    });
}
```

**Important Concepts:**

1. **Loops in Vapor:** We use standard Zig `for` loops directly in our UI code
2. **Conditional Rendering:** Standard `if` statements work naturally
3. **ButtonCtx:** `ButtonCtx(makeMove, .{index})` lets us pass context data to our click handler
4. **Vapor.Types.Background:** Use this type for background colors (not `Vapor.Types.Color`)

{#game-logic}

## Step 4: Implement Game Logic

Now for the heart of our game - the logic that handles moves and determines winners:

```zig
fn makeMove(index: usize) void {
    // Ignore clicks if game is over or cell is taken
    if (game_over) return;
    if (board[index] != null) return;

    // Make the move
    board[index] = is_x_turn;

    // Check for winner
    if (checkWinner()) |result| {
        game_over = true;
        winner = result.winner;
        winning_line = result.line;
        return;
    }

    // Check for draw
    if (isBoardFull()) {
        game_over = true;
        winner = null;
        return;
    }

    // Switch turns
    is_x_turn = !is_x_turn;
}

const WinResult = struct {
    winner: bool,
    line: [3]usize,
};

fn checkWinner() ?WinResult {
    const patterns = [_][3]usize{
        .{ 0, 1, 2 }, .{ 3, 4, 5 }, .{ 6, 7, 8 }, // Rows
        .{ 0, 3, 6 }, .{ 1, 4, 7 }, .{ 2, 5, 8 }, // Columns
        .{ 0, 4, 8 }, .{ 2, 4, 6 },               // Diagonals
    };

    for (patterns) |pattern| {
        const a = board[pattern[0]];
        const b = board[pattern[1]];
        const c = board[pattern[2]];

        if (a != null and a == b and b == c) {
            return WinResult{
                .winner = a.?,
                .line = pattern,
            };
        }
    }
    return null;
}

fn isBoardFull() bool {
    for (board) |cell| {
        if (cell == null) return false;
    }
    return true;
}

fn isWinningCell(index: usize) bool {
    if (winning_line) |line| {
        return index == line[0] or index == line[1] or index == line[2];
    }
    return false;
}

fn resetGame() void {
    board = .{ null, null, null, null, null, null, null, null, null };
    is_x_turn = true;
    game_over = false;
    winner = null;
    winning_line = null;
}
```

**Zig Pattern:** The `checkWinner()` function returns `?WinResult` - an optional struct containing both the winner and the winning line. This lets us track which cells to highlight.

{#status-display}

## Step 5: Display Game Status

Let's add a status message that shows whose turn it is or who won:

```zig
fn renderStatus() void {
    const message: []const u8 = if (game_over)
        if (winner) |is_x|
            if (is_x) "🎉 X Wins!" else "🎉 O Wins!"
        else
            "🤝 It's a Draw!"
    else if (is_x_turn)
        "X's Turn"
    else
        "O's Turn";

    const color: Vapor.Types.Color = if (game_over and winner != null)
        if (winner.?) .hex("#e74c3c") else .hex("#3498db")
    else
        .hex("#7f8c8d");

    Text(message)
        .font(22, 600, color)
        .margin(.b(8))
        .end();
}
```

**Note:** For text colors, use `Vapor.Types.Color`. For backgrounds, use `Vapor.Types.Background`. Margin shorthand uses `.b()` for bottom, `.t()` for top, etc.

{#styling}

## Step 6: Polish with Styling

Let's define our reusable styles using Vapor's Style struct:

```zig
const title_style = Vapor.Style{
    .visual = .{
        .font_size = 42,
        .font_weight = 700,
        .text_color = .hex("#2c3e50"),
    },
    .margin = .b(10),
};

const board_container_style = Vapor.Style{
    .visual = .{
        .background = .hex("#34495e"),
        .border = .solid(.all(4), .hex("#2c3e50"), .all(12)),
        .shadow = .card(.hex("#00000033")),
    },
    .padding = .all(8),
};

const cell_base = Vapor.Style{
    .size = .square_px(90),
    .margin = .all(4),
    .visual = .{
        .border = .solid(.all(1), .hex("#ecf0f1"), .all(4)),
    },
    .layout = .center,
    .transition = .{ .duration = 100 },
};

const reset_button_style = Vapor.Style{
    .padding = .tblr(14, 14, 28, 28),
    .visual = .{
        .background = .hex("#27ae60"),
        .font_size = 16,
        .font_weight = 600,
        .text_color = .white,
        .border_radius = .all(8),
    },
    .interactive = .hover_scale(),
    .margin = .t(20),
};
```

**Style API Notes:**

- `.margin = .b(10)` - shorthand for bottom margin (also `.t()`, `.l()`, `.r()`)
- `.size = .square_px(90)` - creates a 90x90 pixel square
- `.border = .solid(.all(4), .hex("#color"), .all(12))` - thickness, color, radius
- When using `.style(&some_style)`, you don't chain `.children({})` - use `({})` directly

{#winning-animation}

## Step 7: Add Animations

Let's add animations for placing pieces and highlighting wins:

```zig
const Animation = Vapor.Animation;

// Define animations at file scope
const win_animation = Animation.init("winPulse")
    .prop(.scale, 1, 1.05)
    .duration(400)
    .easing(.easeInOut)
    .iterations(0) // infinite
    .dir(.alternate);

const place_animation = Animation.init("place")
    .prop(.scale, 0.5, 1)
    .prop(.opacity, 0, 1)
    .duration(150)
    .easing(.easeOutBack)
    .fill(.forwards);

pub fn init() void {
    // Build animations after Vapor initialization
    win_animation.build();
    place_animation.build();
    Vapor.Page(.{ .src = @src() }, render, null);
}
```

Apply animations in your render code:

```zig
// For winning cells
if (is_winning) {
    cell = cell.animation(&win_animation);
}

// For newly placed pieces
Text(if (is_x) "X" else "O")
    .font(44, 700, if (is_x) .hex("#e74c3c") else .hex("#3498db"))
    .animationEnter(&place_animation)
    .end();
```

{#complete-code}

## Complete Code

Here's the full implementation:

```zig
// src/routes/home/Page.zig
const std = @import("std");
const Vapor = @import("vapor");
const Animation = Vapor.Animation;
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const Center = Vapor.Center;
const ButtonCtx = Vapor.CtxButton;

// ============================================
// GAME STATE
// ============================================
var board: [9]?bool = .{ null, null, null, null, null, null, null, null, null };
var is_x_turn: bool = true;
var game_over: bool = false;
var winner: ?bool = null;
var winning_line: ?[3]usize = null;

// ============================================
// ANIMATIONS
// ============================================
const win_animation = Animation.init("winPulse")
    .prop(.scale, 1, 1.05)
    .duration(400)
    .easing(.easeInOut)
    .iterations(0) // infinite
    .dir(.alternate);

const place_animation = Animation.init("place")
    .prop(.scale, 0.5, 1)
    .prop(.opacity, 0, 1)
    .duration(150)
    .easing(.easeOutBack)
    .fill(.forwards);

// ============================================
// STYLES
// ============================================
const title_style = Vapor.Style{
    .visual = .{
        .font_size = 42,
        .font_weight = 700,
        .text_color = .hex("#2c3e50"),
    },
    .margin = .b(10),
};

const board_container_style = Vapor.Style{
    .visual = .{
        .background = .hex("#34495e"),
        .border = .solid(.all(4), .hex("#2c3e50"), .all(12)),
        .shadow = .card(.hex("#00000033")),
    },
    .padding = .all(8),
};

const cell_base = Vapor.Style{
    .size = .square_px(90),
    .margin = .all(4),
    .visual = .{
        .border = .solid(.all(1), .hex("#ecf0f1"), .all(4)),
    },
    .layout = .center,
    .transition = .{ .duration = 100 },
};

const reset_button_style = Vapor.Style{
    .padding = .tblr(14, 14, 28, 28),
    .visual = .{
        .background = .hex("#27ae60"),
        .font_size = 16,
        .font_weight = 600,
        .text_color = .white,
        .border_radius = .all(8),
    },
    .interactive = .hover_scale(),
    .margin = .t(20),
};

// ============================================
// INITIALIZATION
// ============================================
pub fn init() void {
    win_animation.build();
    place_animation.build();
    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================
// RENDER FUNCTIONS
// ============================================
fn render() void {
    Center()
        .height(.percent(100))
        .background(.hex("#ecf0f1"))
        .children({
            Box()
                .direction(.column)
                .layout(.center)
                .spacing(16)
                .children({
                    // Title
                    Text("Tic-Tac-Toe")
                        .style(&title_style);

                    // Status
                    renderStatus();

                    // Board
                    Box()
                        .style(&board_container_style)({
                            renderBoard();
                    });

                    // Reset Button
                    Button(.{ .on_press = resetGame })
                        .style(&reset_button_style)({
                            Text("New Game").end();
                    });
            });
    });
}

fn renderStatus() void {
    const message: []const u8 = if (game_over)
        if (winner) |is_x|
            if (is_x) "🎉 X Wins!" else "🎉 O Wins!"
        else
            "🤝 It's a Draw!"
    else if (is_x_turn)
        "X's Turn"
    else
        "O's Turn";

    const color: Vapor.Types.Color = if (game_over and winner != null)
        if (winner.?) .hex("#e74c3c") else .hex("#3498db")
    else
        .hex("#7f8c8d");

    Text(message)
        .font(22, 600, color)
        .margin(.b(8))
        .end();
}

fn renderBoard() void {
    Box()
        .width(.px(306))
        .wrap(.wrap)
        .children({
            for (0..9) |i| {
                renderCell(i);
            }
    });
}

fn renderCell(index: usize) void {
    const cell_value = board[index];
    const is_clickable = !game_over and cell_value == null;
    const is_winning = isWinningCell(index);

    // Dynamic background color
    const bg_color: Vapor.Types.Background = if (is_winning)
        if (winner.?) .hex("#fadbd8") else .hex("#d4e6f1")
    else if (is_clickable)
        .hex("#ffffff")
    else
        .hex("#f5f5f5");

    var cell = ButtonCtx(makeMove, .{index})
        .baseStyle(&cell_base)
        .background(bg_color);

    if (is_clickable) {
        cell = cell.hoverBackground(.hex("#e8e8e8")).cursor(.pointer);
    }

    if (is_winning) {
        cell = cell.animation(&win_animation);
    }

    cell.children({
        if (cell_value) |is_x| {
            Text(if (is_x) "X" else "O")
                .font(44, 700, if (is_x) .hex("#e74c3c") else .hex("#3498db"))
                .animationEnter(&place_animation)
                .end();
        }
    });
}

// ============================================
// GAME LOGIC
// ============================================
fn makeMove(index: usize) void {
    if (game_over) return;
    if (board[index] != null) return;

    board[index] = is_x_turn;

    if (checkWinner()) |result| {
        game_over = true;
        winner = result.winner;
        winning_line = result.line;
        return;
    }

    if (isBoardFull()) {
        game_over = true;
        winner = null;
        return;
    }

    is_x_turn = !is_x_turn;
}

const WinResult = struct {
    winner: bool,
    line: [3]usize,
};

fn checkWinner() ?WinResult {
    const patterns = [_][3]usize{
        .{ 0, 1, 2 }, .{ 3, 4, 5 }, .{ 6, 7, 8 }, // Rows
        .{ 0, 3, 6 }, .{ 1, 4, 7 }, .{ 2, 5, 8 }, // Columns
        .{ 0, 4, 8 }, .{ 2, 4, 6 },               // Diagonals
    };

    for (patterns) |pattern| {
        const a = board[pattern[0]];
        const b = board[pattern[1]];
        const c = board[pattern[2]];

        if (a != null and a == b and b == c) {
            return WinResult{
                .winner = a.?,
                .line = pattern,
            };
        }
    }
    return null;
}

fn isBoardFull() bool {
    for (board) |cell| {
        if (cell == null) return false;
    }
    return true;
}

fn isWinningCell(index: usize) bool {
    if (winning_line) |line| {
        return index == line[0] or index == line[1] or index == line[2];
    }
    return false;
}

fn resetGame() void {
    board = .{ null, null, null, null, null, null, null, null, null };
    is_x_turn = true;
    game_over = false;
    winner = null;
    winning_line = null;
}
```

{#whats-next}

## What You've Learned

Congratulations! You've built a complete Tic-Tac-Toe game and learned:

| Concept                   | What You Did                                                |
| ------------------------- | ----------------------------------------------------------- |
| **State Management**      | Variables outside `render()` persist between updates        |
| **Event Handling**        | `Button(.{ .on_press = fn })` and `ButtonCtx(fn, .{args})`  |
| **Conditional Rendering** | Standard Zig `if` statements in UI code                     |
| **Loops**                 | Zig `for` loops to generate repeated UI elements            |
| **Styling**               | Builder pattern and Style structs with `.style(&style)({})` |
| **Animations**            | Declarative animations with `Animation.init()`              |

{#api-quick-reference}

## API Quick Reference

| Pattern                                      | Usage                                                 |
| -------------------------------------------- | ----------------------------------------------------- |
| `ButtonCtx(fn, .{args})`                     | Button with context passed to handler                 |
| `.style(&style_struct)({})`                  | Apply style and children (no `.children()`)           |
| `.margin(.b(10))`                            | Bottom margin shorthand (also `.t()`, `.l()`, `.r()`) |
| `.size = .square_px(90)`                     | 90x90 pixel square                                    |
| `Vapor.Types.Background`                     | Type for background colors                            |
| `Vapor.Types.Color`                          | Type for text colors                                  |
| `.border = .solid(.all(4), color, .all(12))` | Border with thickness, color, radius                  |

{#challenges}

## Challenges

Ready to level up? Try these extensions:

1. **Add a Score Tracker** - Track wins for X and O across multiple games
2. **Implement AI** - Add a simple computer opponent using minimax algorithm
3. **Add Sound Effects** - Play sounds on moves and wins
4. **Create Themes** - Let players switch between light/dark or custom color themes
5. **Add Online Multiplayer** - Use Reverb (Vapor's backend) for real-time games

{#key-takeaways}

## Key Takeaways

**Vapor vs React/Vue/Svelte:**

| React                     | Vapor                       |
| ------------------------- | --------------------------- |
| `useState(0)`             | `var count: i32 = 0;`       |
| `setCount(c => c + 1)`    | `count += 1;`               |
| `{items.map(i => ...)}`   | `for (items) \|i\| { ... }` |
| `{cond && <UI />}`        | `if (cond) { UI(); }`       |
| `onClick={() => fn(arg)}` | `ButtonCtx(fn, .{arg})`     |

**Remember:** In Vapor, the UI is reactive, not the variables. Just mutate your state directly, and Vapor handles the rest.

Happy coding with Vapor! 🚀
{#ui-components}

## UI Components

Vapor includes a comprehensive component library for building production applications.

@ui_showcase_image

### Available Components

| Component     | Description                                             |
| ------------- | ------------------------------------------------------- |
| **DataTable** | Sortable, filterable, paginated tables with JSON export |
| **Chart**     | Bar, line, and combo charts                             |
| **Calendar**  | Date picker with month/year navigation                  |
| **Select**    | Searchable dropdowns with type-safe options             |
| **Tabs**      | Tabbed content navigation                               |
| **Dialog**    | Modal dialogs with animations                           |
| **Drawer**    | Slide-in panels                                         |
| **Toast**     | Stackable notifications                                 |
| **Command**   | Command palette (⌘K) with search                        |
| **Form**      | Auto-generated forms from structs                       |
| **Upload**    | File upload with drag-and-drop                          |
| **Slider**    | Range input controls                                    |

### Usage

Components are available via the Opaque UI library:

%metal add opaque-ui

```zig
const Opaque = @import("opaque");
const Select = Opaque.Select;
const DataTable = Opaque.DataTable;
const Calendar = Opaque.Calendar;
```

For full documentation, see [Opaque UI Docs](https://opaque.vapor.dev).

{#form-generation}

### Form Generation

Define a struct, get a complete form with validation:

```zig
const CheckoutForm = struct {
    account: struct {
        email: []const u8 = "",
        password: []const u8 = "",
    } = .{},

    pub const __validations = .{
        .email = Validation{ .field_type = .email },
        .password = Validation{ .field_type = .password },
    };
};

var form = Vaporize.Form(CheckoutForm){};
form.compile();
```

@checkout_form_image

Nested structs become form sections. Validation errors display inline. Custom components can override any field via `__components`.

---

## Quick Observations

### Strengths of the UI

| Aspect | Assessment |
|--------|------------|
| Visual consistency | Excellent - cohesive design language |
| Spacing/typography | Professional - proper hierarchy |
| Interactive states | Visible hover/focus states |
| Error handling | Clear inline validation |
| Accessibility | Appears to have proper labels |
| Dark mode ready | The chart suggests dark theme support |

### The Form Generation is the Killer Feature

Image 3 shows the exact struct from your code rendered as a real form:

```zig
Account
├── Email | Password (side-by-side)
├── Confirm password
└── Contact
    └── Phone

Payment
├── Payment Method (custom Select)
├── Expiry | CVV (side-by-side)
└── Billing address | Card number

Shipping details
└── Shipping same as billing [toggle]

[Submit]
````

