{#gotchas}

# Gotchas & Common Mistakes

#### Avoid these pitfalls when building with Vapor.

{#string-slice-gotcha}

## String Slices Are References, Not Copies

The TextField Component, holds an internal buffer to binded values:

```zig
var user_input: []const u8 = "";

var list = Vapor.persist.array([]const u8);

fn saveInput() void {
    // ❌ This stores a reference to TextField's internal buffer
    // When the user types again, this reference points to new data!
    // every item in the list will have the same text now;
    list.append(user_input);
}

fn render() void {
    TextField(.string)
        .bind(&user_input)
        .end();
}
```

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
    my_saved_data = Vapor.persist.dupe(user_input);
    list.append(my_saved_data);
}
```

{#event-handler-gotcha}

## Event Handler Signatures

**The Problem:** Wrong function signatures for event handlers.

```zig
// ❌ WRONG - Button handler shouldn't take Event
fn handleClick(evt: *Vapor.Event) void {
    // ...
}
Button(handleClick)  // Won't compile!

// ❌ WRONG - Button handler has wrong parameter order
fn handleDelete(evt: *Vapor.Event, id: u32) void {
    // ...
}
Button(handleDelete, .{42})  // Won't compile!
```

**The Fix:** Match the expected signatures:

```zig
// ✅ Button - no parameters
fn handleClick() void {
    // ...
}
Button(handleClick, .{})

// ✅ Button - context params only (no Event)
fn handleDelete(id: u32) void {
    // ...
}
Button(handleDelete, .{42})

// ✅ onEvent - Event pointer
fn handleKeyDown(evt: *Vapor.Event) void {
    const key = evt.key();
    // ...
}
TextField(.string).onEvent(.keydown, handleKeyDown, .{})

// ✅ onEvent - arg first, then Event
fn handleHover(item_id: u32, evt: *Vapor.Event) void {
    // ...
}
Box().onEvent(.pointerenter, handleHover, .{item_id})
```

**Handler Signature Reference:**

| Pattern                         | Signature                     |
| ------------------------------- | ----------------------------- |
| `Button(fn, .{a, b})`           | `fn(A, B) void`               |
| `.onEvent(.event, fn, .{args})` | `fn(args, *Vapor.Event) void` |

{#state-in-render-gotcha}

## State Inside Render Functions

**The Problem:** Declaring state inside `render()` resets it every frame.

```zig
fn render() void {
    var count: u32 = 0;  // ❌ Always 0!

    Button(increment, .{}).children({
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
    Button(increment, .{}).children({
        Text(count).end();
    });
}

fn increment() void {
    count += 1;  // ✅ Works!
}
```

Or within a struct. If you plan on reusing the component in multiple place and want seperate state.

```zig
const Counter = @This();
count: u32 = 0;  // ✅ Persists between renders

fn render(counter: *Counter) void {
    Button(increment, .{counter}).children({
        Text(counter.count).end();
    });
}

fn increment(counter: *Counter) void {
    counter.count += 1;  // ✅ Works!
}
```

## Moving Elements Need an `.id()`

Vapor names every element automatically, from its type and its position among
its siblings. The reconciler matches the old tree to the new one by that name,
so an element that **moves** gets a new name and is treated as a delete plus an
insert — not as the same element in a new place.

```zig
// ❌ Reorder this list and every row below the change is destroyed and rebuilt
for (todos.items) |todo| {
    Row().children({
        Text(todo.title).end();
    });
}

// ✅ The id travels with the row, so a move stays a move
for (todos.items) |todo| {
    Row().id(todo.id).children({
        Text(todo.title).end();
    });
}
```

Use an id whenever:

- a list can reorder, sort, or filter
- items are inserted or removed anywhere except the end
- an element sits **after** a sibling that renders conditionally

That last one is the surprising case. A switch that toggles an extra field into
a form renumbers everything below it, so the submit button underneath is torn
down and rebuilt on every toggle:

```zig
Form(submit, .{}).children({
    if (show_details) {
        TextField(.string).end();
    }
    Button(save, .{}).id("save-btn").children({   // ← keeps its identity
        Text("Save").end();
    });
});
```

The symptoms of a missing id are an element that briefly appears twice — the
outgoing copy is held while its exit animation runs — or one that loses DOM
state it should have kept: scroll position, focus, text selection, or an
in-flight CSS transition.

The value becomes the element's DOM id as well, so it has to be unique in the
document. `.src(@src())` is a shortcut that derives one from the call site,
which is enough when an element only needs to be distinguished from its
siblings rather than tracked across moves.
