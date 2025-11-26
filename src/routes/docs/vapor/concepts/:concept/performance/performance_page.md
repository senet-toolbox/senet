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

Out the gate, Vapor handles rendering **1,000 nodes** in (2-3ms), and updating in (2-3ms).
With **10,000 nodes at** 80fps, (8-12ms), for both rendering and updating.

Compare this to traditional frameworks:

- React: ~1000 nodes **create** (45ms), **update** (35ms).

- React: ~10000 nodes **create** (450ms), **update** (350ms).

- Svelte: ~1000 nodes **create** (25ms), **update** (20ms).

- Svelte: ~10000 nodes **create** (250ms), **update** (20ms).

- Solid: ~1000 nodes **create** (15ms), **update** (12ms).

- Solid: ~10000 nodes **create** (150ms), **update** (120ms).

- **Vapor 🧨: 10,000+ nodes** at (60ms).

This is possible because Vapor's reconciliation runs in WASM
with linear memory, then sends a compact diff to the DOM
rather than traversing JavaScript objects.

We can see this with the following code:

```zig
const std = @import("std");
const Vapor = @import("fabric");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Box = Static.Box;
const Button = Static.Button;
const TextFmt = Static.TextFmt;

const Item = struct { id: []const u8, value: usize };
var buffer: [10000]Item = undefined;
var list: std.array_list.Managed(Item) = undefined;

fn init() void {
    list = Vapor.persistList(Item);
    for (0..buffer.len) |i| {
        buffer[i] = .{ .value = i, .id = std.fmt.allocPrint(Vapor.getPersistentAllocator(), "{d}", .{i}) catch unreachable };
    }
    list.appendSlice(&buffer) catch |err| Vapor.lib.printlnErr("Error appending {any}", .{err});
}

fn remove() void {
    if (list.items.len == 0) return;
    const item = list.orderedRemove(0);
    Vapor.println("Removed {s}", .{item.id});
    Vapor.cycle();
}

pub fn render() void {
    Box().style(&.{
        .child_gap = 8,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .size = .w(.percent(100)),
    })({
       Button(.{ .on_press = remove })
            .size(.{ .width = .fit, .height = .fit })
            .background(.transparent)
            .cursor(.pointer)
            .border(.simple(.palette(.border_color_light)))
            .children({
            TextFmt("Remove first Item", .{}).font(18, 500, .palette(.text_color)).layout(.center).close();
        });
        Box().layout(.flex)
            .wrap(.wrap)
            .children({
            for (list.items) |i| {
                TextFmt("{d},", .{i.value}).font(18, 500, .palette(.text_color)).layout(.center).close();
            }
        });
    });
}
```

The above is a practical example updating a dynamic list. Notice
there's no `useState`, `useEffect`, or reactive declarations –
Vapor handles reactivity automatically:

{#note}

## Note

Make sure to build Vapor in release mode, this way we can strip off all the debug, assert checks. Otherwise, the performance will be lower.

```zig
metal release
```

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

**Backend (Tether Server):**

- 220K requests/second (M1 MacBook Pro)

- HTTP/WebSocket support

- Zero external dependencies

**Database (Tether DB):**

- SQL and RESP protocol support

- In-memory hashmap performance

- Embedded or standalone modes

All from one `metal release` command. No Docker, no config
files, no dependency hell.
