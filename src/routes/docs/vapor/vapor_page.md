{#what-is-vapor}

# What is Vapor?

#### A framework without all the ceremony.

```jsx
// JSX Frameworks
function Counter() {
  const [count, setCount] = useState(0);

  function increment() {
    setCount((c) => c + 1);
  }

  return <button onClick={increment}>{count}</button>;
}
```

```zig
// Vapor
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

#### The Two Endings: `.end()` vs `.children({})`

**Simple rule:** Does this element have children inside it?

| Element has children? | Use             |
| --------------------- | --------------- |
| No (leaf node)        | `.end()`        |
| Yes (container)       | `.children({})` |

```zig
// ❌ Text never has children - it IS the content
Text("Hello").children({});  // Wrong!

// ✅ Text is a leaf - close it
Text("Hello").end();

// ❌ Box needs to wrap something
Box().end();  // Wrong! (unless intentionally empty)

// ✅ Box contains children
Box().children({
    Text("I'm inside").end();
});
```

**The `{}` block is just Zig code.** It runs first, building children, then the parent closes:

```zig
Box().padding(.all(16)).children({
    // This code executes BEFORE Box closes
    Text("First").end();
    Text("Second").end();

    // You can use normal Zig here
    if (showThird) {
        Text("Third").end();
    }

    for (items) |item| {
        Text(item.name).end();
    }
});
// Box closes here, after all children are added
```

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
