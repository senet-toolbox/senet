{#hooks-overview}

# Hooks

There are two variations of Hooks in Vapor, one is based on the router, and the other is based on the lifecycle of components or pages.

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

pub fn appHook(ctx: Vapor.lib.HookContext) !void {
    std.log.info("App Hook called BEFORE page load ({s})", .{ctx.to_path});
}
pub fn aboutHookAfter(ctx: Vapor.lib.HookContext) !void {
    std.log.info("App About Hook called AFTER page load ({s})", .{ctx.to_path});
}
pub fn aboutHookLeave(ctx: Vapor.lib.HookContext) !void {
    std.log.info("App About Hook called on route LEAVE ({s})", .{ctx.to_path});
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
    std.log.info("Mounted", .{});
}

fn destroy() void {
    std.log.info("Destroy", .{});
}

fn create() void {
    std.log.info("Create", .{});
}

fn update() void {
    std.log.info("Mounted", .{});
}

fn render() void {
    Row()
        .onMount(mount, .{})
        .onCreate(create, .{})
        .onDestroy(destroy, .{})
        .onUpdate(update, .{})
        .children({
        // ...
    });
}
```

{#tree-hooks}

### Tree Hooks

- onLayout

- onCommit

{#onend}

### OnLayout

`onLayout` is a function that runs after the DOM has been full rendered, this is useful for querying and performing computation after render.

onLayout is useful in scenarios in which you want to inject components, or mutate the DOM after the initial tree has been rendered. As you may
have noticed, every documentation page, has a set of Numbered Boxes on the right side. These are injected after generating the initial content page.

After the initial render, we query all the Intersection components, by type, and then inject a Box component at the Heading positions, like so:

```zig
pub var boxes: []Box = undefined;
const Box = struct {
    id: []const u8,
    number: usize,
    bounds: Vapor.lib.Bounds = .{},
    active: bool = false,
};

pub fn reinitBoxes() void {
    const ids = Vapor.queryComponentIds(.Intersection) orelse return;
    var count: usize = 0;
    for (ids) |id| {
        if (std.mem.startsWith(u8, id, "Inte_")) continue;
        count += 1;
    }
    boxes = Vapor.arena(.view).alloc(Box, count) catch |err| {
        std.log.err("{any}", .{err});
        return;
    };
    var i: usize = 0;
    for (ids) |id| {
        if (std.mem.startsWith(u8, id, "Inte_")) continue;
        const bounds = Vapor.getComponentBounds(id) orelse continue;
        const box_id = Vapor.view.fmt("box-{d}", .{i});
        boxes[i] = .{ .id = box_id, .number = i, .bounds = bounds };
        i += 1;
    }
    if (ids.len == 0) {
        std.log.warn("No Sections", .{});
    }
}


fn goto(url: []const u8) void {
    Vapor.Kit.navigate(url);
    Vapor.onLayout(reinitBoxes); // This will triger at the end of the current cycle
}
```
{#oncommit}

### OnCommit

`onCommit` is a function that runs before the DOM has been fully rendered, this is useful for querying and performing computation before final render.

This is useful for when we want to parse the virtual tree, and perform some action based on the state of the tree.

⚠️ Note: In the future, Vapor will use it's own layout system, and so offsets, positions and styles will be avaible before the DOM is rendered.

The commit callbacks will only be called once, per render cycle, this means you cannot recursivley call `onCommit` from within the callback.

```zig
const Vapor = @import("vapor");

fn mount() void {
    Vapor.onCommit(addTextComponent, .{});
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
