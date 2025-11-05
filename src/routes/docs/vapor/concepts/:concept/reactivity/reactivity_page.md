{#reactivity}

# Reactivity


**Most frameworks make variables reactive. Vapor makes 
the UI reactive.**

This simple inversion eliminates useState, useEffect, 
and dependency arrays entirely.

If you're new to application development, reactivity, is the concept of being able to update your application in real time, without having to refresh the page.

Many frameworks, such as React, Svelte, and Vue, have there own reactivity system, with their own pros and cons.
All of these reactivity systems, are known as Signal based systems. When a value is changed, only the component that
depends on that value will be updated.

{#signal-types}

## Signal Types

- React uses `useState`, and `useEffect` to achieve this.

- Svelte uses `$state`, and `$effect` or `$derived` to achieve this.

- Vue uses `useRef`, `reactive`, and more to achieve this.

The issue with all of these, is the requirement for both the UI and the functions to use the same reactivity variable. 

Updating a value in a JS function, like `let x = 1; x+=1;`
Will not update the UI. This is because React, Svelte, Vue, and many other frameworks are transpiled.

For new developers, the `useState`, `useEffect` symptom,
has become an overwhelming and complex issue.

Tracking down dependency chains, or having to use
`useMemo`, `useEffect`, or `useRef`, to avoid cascading updates, has caused developers to become frustrated.

Moreover, this means that the developer must now understand both the UI's functional nature, and the language's own nature. We must switch
contexts, when working with these frameworks.

{#ui-as-reactivity}

## UI as reactivity

Vapor, is a toolkit, this means that the developer can decide how they want there application's reactivity to work.

- Immediate Mode

- Retained Mode

There are two types of state components in Vapor.
Vapor, has taken the concept of reactivity, and _Inversed It!_
Instead of defining a reactive variable like `let counter = $state(0);`
we define our UI as reactive.

There are two types of state management systems in Vapor,

- Static components, will never update!

- Pure components, will only update if their styles or props change.

```zig
const Vapor = @import("fabric");
const Pure = Vapor.Pure;
const Static = Vapor.Static;
const TextField = Static.TextField;

var text_field: Vapor.Binded = .{
    .text = "Inital Text",
};

pub fn render() void {
    TextField(.string)
        .bind(&text_field)
        .plain();

    Static.Text(text_field.text).plain(); // This will never update
    Pure.Text(text_field.text).plain(); // This will update
}
```

{#immediate-mode}

### Immediate Mode

Immediate mode is the default mode of Vapor. It is the simplest mode, and is the very performant, this site runs in immediate mode.

Immediate mode is extremely fast.
In a worst case sceanrio, with a list of 10,000 nodes, no stable
keys, in which the first node is order removed,
the entire render
cycle from removal to UI update takes 15ms on a 2021 M1 MacBook Pro.

Immediate mode requires no state management, if a variable changes the UI will change, only the elements that are affected will be updated.

This means that if we define a `var counter: usize = 0;` and then we increment it
`counter += 1;` then the Pure UI will update.

```zig
const Vapor = @import("fabric");
const Pure = Vapor.Pure;
const Box = Pure.Box;
const TextFmt = Pure.TextFmt;
const Text = Pure.Text;
const Button = Pure.Button;

var counter: usize = 0;
var text: []const u8 = "Increment";

pub fn increment() void {
    counter += 1;
    text = "Increment again";
}

pub fn render() void {
    Button(.{ .on_press = increment }).plain()({
        Text(text).plain();
    });
    TextFmt("{d}", .{counter}).plain();
}
```

{#80-content-is-static}

### 80% of content in an application is static

Most UI elements never change after initial render. 
Vapor optimizes for this reality by making `Static`
components the default.

In practice, you'll import Static components most of 
the time and only use Pure when you need reactivity:


```zig
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Text = Static.Text;
const Button = Static.Button;
```

{#retained-mode}

### Retained Mode

There are two types of state management systems in Vapor,

- Signal(T)

- cycle()

{#using-cycle}

### Using cycle()

```zig
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const TextFmt = Pure.TextFmt;
const Text = Static.Text;
const Button = Static.Button;

var counter: usize = 0;

pub fn increment() void {
    counter += 1;
    Fabric.cycle();
}

pub fn render() void {
    Button(.{ .on_press = increment }).plain()({
        Text("Increment").plain();
    });
    TextFmt("{d}", .{counter}).plain(); // Only this updates
}
```

The `cycle()` function tells Vapor, to update the UI, this is agnostic to the variables. It will update all the UI that has changed, not just
the `counter` variable. For example the following will udpate both the
`counter` and the `text`.

```zig
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const TextFmt = Pure.TextFmt;
const Text = Pure.Text; // We changed this to Pure
const Button = Static.Button;

var counter: usize = 0;
var text: []const u8 = "Increment";

pub fn increment() void {
    counter += 1;
    text = "Increment again";
    Fabric.cycle();
}

pub fn render() void {
    Button(.{ .on_press = increment }).plain()({
        Text(text).plain(); // This now updates
    });
    TextFmt("{d}", .{counter}).plain(); // This still updates
}
```

{#zig-is-meant-to-be-explicit}

### Zig is meant to be Explicit!

Developers and Zig users alike, will most likely want to have explicit control over the UI, and not depend on the framework.
Svelte came to this realization, and implemented runes, which are explicit UI variables.

Vapor, has the same concept. When need be developers, can define their own UI variables through the `Signal(T)` type.

{#signalT}

### Signal(T)

`Signal(T)` is a type that is used to define UI variables.
It is a wrapper around a `Vapor.cycle()`.

```zig
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Signal = Fabric.Signal;

var counter: Signal(u32) = undefined;

fn init() void {
    counter.init(0);
}

fn increment() void {
    counter.increment();
}

fn render() void {
    Static.Button(.{ .on_press = increment }).plain()({
        Pure.TextFmt("{d}", .{counter.get()}).plain();
    });
}
```

`Signal(T)` has a number of methods, that can be used to change or update the state variable.

- `get()`

- `set()`

- `increment()`

- `decrement()`

- `toggle()`

- `append()`

- `getElement()`

- `compare()`

- and much more...

{#effects}

### Effects

Vapor, has decided to completely remove the concept of useEffect, useMemo, and subscriptions, entirely.
Instead, a functional approach should be used.

{#with-the-concept-of-effects}

### With the concept of effects

```zig
const Fabric = @import("fabric");
const Signal = Fabric.Signal;

var counter: Signal(u32) = undefined;
var text: Signal([]const u8) = undefined;
fn init() void {
    counter.init(0);
    text.init("Is 0");
++    counter.effect(updateText);
}

fn updateText(count: u32) void {
++    text.set(Fabric.fmtln("Is {d}", .{count}));
}

fn increment() void {
    counter.increment();
}
```

{#without-the-concept-of-effects}

### Without the concept of effects

```zig
const Fabric = @import("fabric");
const Signal = Fabric.Signal;

var counter: Signal(u32) = undefined;
var text: Signal([]const u8) = undefined;
fn init() void {
    counter.init(0);
    text.init("Is 0");
}

fn increment() void {
    counter.increment();
++    text.set(Fabric.fmtln("Is {d}", .{counter.get()}));
}
```

While Vapor, takes a strong stance against the use of effects, subscriptions, and such, it does not mean you cannot build your own effect system.
I did this originally, to determine if Vapor needed an effect system, however with the complexity and history of issues
with effects, I removed it.
If you truly want one, then you are going to have to build it yourself.

{#its-just-zig}

### Its just Zig

Since Vapor is not transpiled, and is just Zig, this means the variables can be passed from file to file.
Instead of defining `const [counter, setCounter] = useState(0);` variables,
and then passing them down the tree, to use in a child component.

We can just import the variable where needed. `const Parent = @import("parent.zig");`
`Parent.counter += 1;`

This also means that we can pass variables from parent to child, or child to parent.
This shows the immense power of Zig, and keeping the framework away from transpilation!
