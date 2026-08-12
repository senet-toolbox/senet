{#reactivity}

# Reactivity

#### Most frameworks make variables reactive. Vapor makes the UI reactive.

This inversion removes `useState`, `useEffect`, and dependency arrays. There is no reactive primitive to learn — you create a variable, mutate it, and the element that reads it updates.

If you're new to app development: reactivity is the UI updating in real time, without a page refresh. Vapor's take is simpler than most. You don't declare what is reactive (`let counter = $state(0)`). Every element is reactive by default, and when the state it reads changes, only that element updates — **granularly**, down to the prop or style that actually changed.

Here is a counter that increments and changes color on hover. Inspect the elements: only the text and the color class are touched, nothing else re-renders.

```zig
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;

var counter: usize = 0;
var text: []const u8 = "Increment";

pub fn increment() void {
    counter += 1;
    text = "Increment Again";
}

var color: Vapor.Types.Color = .palette(.text_color);
var changed_color: bool = false;

// Callbacks attached via .onHover / .onClick receive the event.
fn changeColor(_: *Vapor.Event) void {
    changed_color = !changed_color;
    color = if (changed_color) .palette(.tint) else .palette(.text_color);
}

pub fn render() void {
    Button(increment, .{})
        .onHover(changeColor, .{})
        .children({
            Text(text).font(22, 700, color).end();
        });
}
```

@counter

We say Vapor handles **+90%** of state management, not 100%. That last 10% is one named function, `cycle()`, with one clear rule for when you need it. The rest of this page is mostly that one rule, plus the fact that everything else is ordinary Zig.

{#state-persists}

## State persists by default

Increment the counter above, navigate away, and come back — it's still incremented. The same is true of forms, modals, and any other component. Everything is stateful.

This is not a feature Vapor turns on. It's the absence of one. There's no unmount, no teardown, no lifecycle that wipes your variables. `counter` is a module-level variable, so it holds its value for exactly as long as a variable does. Nothing is resetting it because nothing is doing anything to it.

So you reset state the way you'd reset any variable — by assigning to it. Want a fresh counter when the user lands on a page? Set it in the page's render or on navigation:

```zig
var counter: usize = 0;

pub fn render() void {
    counter = 0; // reset on entry, if that's what you want
    // ...
}
```

This is the whole mental model for the page: there is no transpilation magic. State lifetime is variable lifetime, and you are in charge of it.

{#one-rule}

## One rule: events in, UI out

Atomic mode (the default) works as an event engine. Any event that enters Vapor runs your handler and reconciles the UI when that handler **returns**. The diff checks what was added, removed, or changed, and patches only those elements.

The same shape covers everything:

- a click → `onClick` handler runs → reconcile
- a hover → `onHover` handler runs → reconcile
- typed input → bound value updates → reconcile
- a `timeout` fires → handler runs → reconcile
- a `fetch` completes → handler runs → reconcile

You don't manage any of this. You mutate normally inside the handler and the UI is correct when it returns. Because the diff is per-event and granular, the overhead is small.

> **The rule:** an event into Vapor runs your handler and reconciles on return. You only call `cycle()` when the UI changed *without* an event entering Vapor.

That second sentence is the entire 10%. `cycle()` is defined by exclusion — it's for changes that didn't come in as an event:

- you ran your own external functionality outside Vapor's handlers
- you queried the rendered tree and built more elements from the result (this is how the numbered boxes on the right are made — querying is a function call, not an event, so the UI doesn't know to update until you ask it to)
- you're driving the UI from something continuous that Vapor doesn't hook by default, like raw `mousemove`

Continuous streams like mouse movement aren't wired as events by default — hooking every frame of pointer motion is rarely what you want and isn't free. If you do want the UI to follow them, you read the values and call `cycle()` yourself.

{#using-cycle}

### Using cycle()

`cycle()` asks Vapor to update the UI now. It is agnostic to which variable changed — it reconciles **everything** that changed, not just the one you were thinking about. In the example below, both `counter` and `text` update from a single `cycle()`:

```zig
const Vapor = @import("vapor");
const TextFmt = Vapor.TextFmt;
const Text = Vapor.Text;

const Button = Vapor.Builder(.static).Button;

var counter: usize = 0;
var text: []const u8 = "Increment";

pub fn increment() void {
    counter += 1;
    text = "Increment again";
    Vapor.cycle(); // reconciles both reads below
}

pub fn render() void {
    Button(increment, .{}).children({
        Text(text).end();
    });
    TextFmt("{d}", .{counter}).end();
}
```

@cycle_example

{#its-just-zig}

## It's just Zig

This is the part worth internalizing, because it's where Vapor differs most from React or Svelte. Vapor isn't transpiled — there's no compiler step rewriting your control flow into framework calls. So control flow *is* Zig control flow. The things other frameworks turn into APIs (`useState`, `<For>`, `<Show>`, prop drilling) are just language features here.

**Sharing state is an import.** No `useState`, no passing setters down the tree. Define the variable where it lives and import it where you need it — parent to child, child to parent, anywhere:

```zig
// GlobalCounter.zig
const Vapor = @import("vapor");
const Page = Vapor.Page;
const TextFmt = Vapor.TextFmt;

pub var count: u32 = 0;

pub fn init() void {
    Page(.{ .route = "/global-counter" }, render, null);
}

fn render() void {
    TextFmt("I am a counter: {d}", .{count}).end();
}
```

```zig
// Anywhere.zig
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;
const GlobalCounter = @import("GlobalCounter.zig");

pub fn increment() void {
    GlobalCounter.count += 1;
}

pub fn render() void {
    Button(increment, .{}).children({
        Text("Increment the Global Counter").end();
    });
}
```

**Lists are loops.** There is no list component and no keyed-reconciliation API to learn. You write a `for`. You build elements inside it. If items need stable identity, you opt in with `id()` or `key()`:

```zig
for (current.sections) |section| {
    const url = Vapor.fmtln("#{s}", .{section.link});
    const active = sections.get(section.link) orelse false;
    const text_color: Vapor.Types.Color =
        if (active) .palette(.tint) else .palette(.text_color);

    ListItem().hw(.fit, .percent(100)).children({
        Link(.{ .url = url, .aria_label = section.title })
            .pointer()
            .noDecoration()
            .cursor(.pointer)
            .border(.l(2, if (active) .palette(.tint) else .transparent))
            .pl(6)
            .width(.full)
            .layout(.left_center)
            .children({
                Text(section.title).font(14, 300, text_color).end();
            });
    });
}
```

Everything Vapor-specific there is the element builders. The `for`, the `orelse false`, the inline `if` for the color and border — all plain Zig.

**Conditionals are `if`.** Show or hide by branching in `render`, the same way you'd branch anywhere else. No `<Show>`, no ternary-in-JSX dance.

**Async is the same rule.** A completed `fetch` is just another event in, so you mutate inside the handler and the UI reconciles on return — `cycle()` runs under the hood when your handler finishes. You don't treat data-loading as a special reactive concern:

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Kit = Vapor.Kit;
const Fetch = Vapor.Kit.Fetch;

pub export fn init() void {
    Vapor.init(.{});
    Kit.init();
    Vapor.Page(.{ .route = "/" }, render, null);

    var f = Fetch.fetch("/documents/kit_page.md", .{ .method = .GET });
    f.debug = true;
    f.handle(handleResponse, .{});
}

fn handleResponse(response: Kit.Fetch.Result) void {
    switch (response) {
        .ok => |data| {
            std.debug.print("Status: {d}\n", .{data.status});
            std.debug.print("Body: {s}\n", .{data.body});
            // mutate state here; the UI reconciles when this returns
        },
        .err => |err| {
            std.debug.print("Error: {s}\n", .{err.message});
        },
    }
}
```

So loops, conditionals, async, state sharing, and state lifetime aren't five framework features with five APIs. They're one fact — it's just Zig — and the single event rule on top.

{#modes}

## Modes

Vapor is a toolkit: you choose how reactivity behaves. The default suits almost everyone; the others are there when you want a different tradeoff.

| Mode | What triggers an update | When you call `cycle()` | Cost | Reach for it when |
|------|------------------------|------------------------|------|-------------------|
| **Atomic** ⚛️ (default) | Each event into Vapor (click, hover, input, timeout, fetch) | Only for changes with no event in (your own code, queries, raw `mousemove`) | Minimal — one granular diff per event | Almost always |
| **Immediate** | The whole render tree runs every frame; Vapor still patches only what changed | Never | Higher — tree evaluated each frame | Highly dynamic UIs where you'd rather not think about events at all |
| **Static** (coming soon) | — | — | — | — |

{#atomic-mode}

### Atomic Mode ⚛️

The default. Each event in triggers one diff out. See [One rule](#one-rule) above — that section *is* atomic mode. It covers the +90% with no state management, and `cycle()` covers the rest.

@graphics

{#immediate-mode}

### Immediate Mode

Immediate mode runs the entire render tree every frame, the way an immediate-mode GUI does — but unlike a GUI, Vapor still patches only the elements that changed. The payoff: **no `cycle()`, ever.** If a variable changes, the UI follows, full stop. 100% of the work is Vapor's; you give up some per-frame cost in exchange.

```zig
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;
const TextField = Vapor.TextField;

export fn init() void {
    Vapor.init(.{ .mode = .immediate });
    Vapor.Page(.{ .route = "/" }, Home, null);
}

var text: []const u8 = "Initial Text";
var counter: usize = 0;

pub fn increment() void {
    counter += 1;
}

pub fn Home() void {
    TextField(.string).bind(&text).end();
    Text(text).end(); // updates as you type

    Button(increment, .{}).children({
        Text("Increment").end();
    });
    Text(counter).end(); // updates on click
}
```

{#static-mode}

### Static Mode

Coming soon.

{#performance}

## A note on performance

The diff runs in WASM and is cheap because it's granular: Vapor compares props and styles and patches only what moved, rather than re-rendering subtrees or diffing a virtual DOM. In atomic mode it runs once per event; in immediate mode once per frame. Either way the work scales with what *changed*, not with the size of your tree — which is what keeps the per-event overhead small.
