{#what-is-vapor}

# What is Vapor?

#### Vapor is a Zig-powered WebAssembly UI framework/toolkit.

#### ⚡ Zero tooling. Zero JS build chain. Just Zig → WASM → UI.

**Vapor is a compiled instruction engine for the web.**

Traditional frameworks parse templates and manage heavy Javascript runtimes.
**Vapor** compiles native Zig functions into a compact binary of render commands.
Despite compiling to binary instructions, Vapor is fully inspectable.

This is because the engine maps instructions directly to native browser APIs
like `createElement` or `setAttribute` for Web, and UIKit for iOS.

Vapor treats the browser like a graphics driver, you create the UI with simple functions, and then
Vapor & Zig work together to compile your UI into a compact, optimized set of instructions.
These instructions are sent to the DOM only when necessary.
No strings, no parsing, just direct-to-metal UI performance.

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

