{#what-is-vapor}

# What is Vapor?

#### Vapor is a Zig-powered WebAssembly UI framework.

#### ⚡ Zero tooling. Zero JS build chain. Just Zig → WASM → UI.

Vapor generates a set of render commands, that bind to native apis, like `createElement` or `setAttribute` for the browser or UIKit for iOS.
Giving you the power of the native rendering, but with the speed of Zig. This very website is built with Vapor, and is only ~180kb total.

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

pub fn Home() void {
    Center().children({
        Button(.{ .on_press = welcome }).children({
            Text("Click Me").fontSize(18).end();
        });
    });
}
```

@alert

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

- **Only write** - `Zig`

- **Powerful Styling** - `.layout(.center)`

- **Simplified** - memory management

{#how-it-works}

## How it works

**Server-Side Pre-rendering**
Vapor compiles your Zig components into static HTML at build time. This is sent to the browser for an instant, SEO-friendly first paint.

**Client-Side Hydration**
The browser also receives your compact vapor.wasm binary, and a thin JS glue bridge. This WASM binary runs and "hydrates" the static HTML, seamlessly taking control of the page.

**Native Performance Runtime**
From that point on, all UI updates, routing, and logic are handled directly by high-performance WebAssembly, not JavaScript, giving you a smooth, native-like feel in the browser.

**You write Zig, it compiles to WASM, it runs in the browser. That's it.**

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
    Button(.{ .on_press = increment })
    .border(.simple(.black)).children({
        Text("Increment").fontSize(18).end();
    });
    Text(counter).fontSize(18).end(); // state is updated automatically
}
```

@counter

{#builder}

## Builder Pattern

Every Component follows the builder pattern. We start by creating a `Button` component, and then we can
call any set of **styling** functions such as `.border()`.

We attach a `on_press` handler to the button, and pass the increment function to it.

Within the `increment` function, we increment the counter, this will automatically result in the `Text(counter)` being updated.

There is no need to use _Signals_, _Hooks_, or _State Management_ in Vapor.

#### When state changes, Vapor performs two phases:

1. **Render Pass** - Your entire render() function executes in WebAssembly, generating a fresh virtual tree

2. **Reconciliation** - Vapor diffs the new tree against the previous one, identifying exactly which DOM elements need updates

Only the reconciliation results are applied to the actual DOM—this is what
makes updates fine-grained.
