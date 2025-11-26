{#routing}

# Routing

Routing in Vapor works off of the directory structure of your project using `@src()`, or hardcoded strings `/app/about`.
To use dynamic routes, you have to either set the directory to `:slug` or use a static string, like `/app/about/:slug`.

When using the `@src()` union tag, the `.zig` file must be located within `routes/` directory, for example `routes/app/about/Page.zig`.

![Diagram](/src/assets/routes.svg)

{#page-sample}

## Using Page()

Routes should be declared once, it is common convention to either put them in the `init()` function of main.zig, or in an `init()` function within the
`....zig` file, you are working on.
By using the `Page` function, you can easily define your routes.

```zig
// /main.zig
const Vapor = @import("vapor");
const Page = Vapor.Page;

// Page Initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, deinit); // this will refer to "/" since we are in main.zig
    // or
    Page(.{ .route = "/app/about" }, render, deinit); // this will refer to "/app/about"
}

// Page Deinitialization
pub fn deinit() void {
    Vapor.print("I get called when you navigate away from this page", .{});
}

pub fn render() void {
    Text("I get rendered when you navigate to this page");
}
```

Or within the `.zig` file level _("/routes/app/about/Page.zig")_

```zig
// /routes/app/about/Page.zig
const Vapor = @import("vapor");
const Page = Vapor.Page;

// Page Initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, deinit); // this will refer to "/app/about" since we are in /routes/app/about/Page.zig
}

// Page Deinitialization
pub fn deinit() void {
    Vapor.print("I get called when you navigate away from this page", .{});
}

pub fn render() void {
    Text("I get rendered when you navigate to this page");
}
```

`Page()` is the entry point for your routes render and deinit functions, these are called when you navigate to and from routes.
It takes 3 arguments,

- Either `@src()` or `"/..."`

- `RenderFn`

- `DeinitFn`

`@src()` is a builtin function that returns the current source location.

### Remember

Vapor takes a function approach, you need to call `Vapor.Page()` to declare your routes. or the corresponding function within the `.zig` file.

With the above example, we call our `Page(...)` function, within the `init()` function of `main.zig`. Like this:

#### routes/app/about/Page.zig

```zig
// /routes/app/about/Page.zig
const Vapor = @import("vapor");
const Page = Vapor.Page;

// Page Initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, deinit); // this will refer to "/app/about" since we are in /routes/app/about/Page.zig
}
```

#### main.zig

```zig
// /routes/app/about/Page.zig
const Vapor = @import("vapor");
const AboutPage = @import("routes/app/about/Page.zig");

// Page Initialization
export fn init() void {
    Vapor.init(.{});
    AboutPage.init();
}
```

**Note:** Don't forget to mark functions as `pub` if you want to call them from other files.
