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
