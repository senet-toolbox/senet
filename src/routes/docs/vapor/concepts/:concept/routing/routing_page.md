{#routing}

# Routing

Routing in Vapor works off of the directory structure of your project `@src()`, or hardcoded strings `/app/about`.
To use dynamic routes, yoy have to either set the directory to `:slug` or use a static string, like `/app/about/:concept`.

When using the `@src()` union tag, the `.zig` file must be located in the same directory as `routes/`.

![Diagram](/src/assets/routes.svg)

{#page-sample}

## Using Page()

Every Route is declared in the `init()` function of the `.zig` file.
By using the `Page` function, you can easily define your routes.

```zig
// /routes/app/about/Page.zig
const Vapor = @import("fabric");
const Page = Vapor.Page;

// Page Initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, deinit);
    // or
    Page(.{ .route = "/app/about" }, render, deinit);
}

// Page Deinitialization
pub fn deinit() void {
    Vapor.print("I get called when you navigate away from this page", .{});
}

pub fn render() void {
    Vapor.print("I get rendered when you navigate to this page", .{});
}
```

`Page()` is the entry point for your routes render and deinit functions, these are called when you navigate to and from routes.
It takes 3 arguments,

- `SourceLocation`

- `render_fn`

- `deinit_fn`

`SourceLocation` is a struct that contains the path to the file, and the line number.
`@src()` is a builtin function that returns the current source location.
