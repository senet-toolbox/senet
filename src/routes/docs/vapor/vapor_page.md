{#what-is-vapor}

# What is Vapor?

{#vapor-is-a-frontend}

## Vapor is the frontend framework of Tether.

We believe developers should control their tools, not the other way around.
Every API is explicitly exposed, every internal is accessible, and every component can be customized.
No black boxes, no hidden magic—just transparent, controllable architecture that puts you in the driver's seat.

Vapor should be treated and seen as a set of tools, which can be used to adapt the core framework,
it's purpose is to be unopinionated, and modular. However, there are guidelines, and best practices that we follow.

{#vapor-is-simple}

### Vapor is simple by nature

- Only write `Zig`.

- Automatic UI updates, or controlled via `.cycle()` or `Signal(T)`

- Inject custom `HTML`, `JS`, `CSS`

- Powerful Styling `.layout(.center)`

- Simplified memory management

- Native performance

{#memory-is-scary}

### Memory is not Scary

Most of you who may not be familiar with low level programming, will assume that you will need to manage memory, and that memory management is a pain.

**This is not the case.**

Vapor, handles all the memory management for you, and when need be, you can use a set of memory functions,
which automatically frees the memory when it is no longer needed.

- `Vapor.frameList(T)` - A list allocated on the frame, and will be freed when the frame is updated.

```zig
var dynamic_list = Vapor.frameList(u32);
dynamic_list.append(1);
dynamic_list.append(2);
dynamic_list.append(3);
```

- `Vapor.routeList(T)` - A list allocated on the route, and will be freed when the route is changed.

```zig
var dynamic_list = Vapor.routeList(u32);
dynamic_list.append(1);
dynamic_list.append(2);
dynamic_list.append(3);
```

- `Vapor.persistentList(T)` - A list allocated, and never freed.

```zig
var dynamic_list = Vapor.persistentList(u32);
dynamic_list.append(1);
dynamic_list.append(2);
dynamic_list.append(3);
```

You also have access to the arena allocators themselves,
via:

- `Vapor.getFrameAllocator()`

- `Vapor.getRouteAllocator()`

- `Vapor.getPersistentAllocator()`

{#making-a-button}

## Making a button!

We will jump into depth with styling, in the next section. For now though, we will make a button.
The `Button` component is part of the Static and Pure Structs.

** As you can see, we do not allocate or use any memory, just simple pure functions.**

```zig
// All normal Zig code
const Vapor = @import("vapor");
const Static = Vapor.Static;

// Components
const Button = Static.Button;
const TextFmt = Static.TextFmt;

var counter: usize = 0;
fn increment() void {
    counter += 1;
}

// Render
pub fn render() void {
    Button(.{ .on_press = increment })
        .border(.simple(.palette(.border_color_light)))
        .body()({
        TextFmt("Increment {d}", .{counter})
            .font(18, null, .palette(.text_color))
            .close();
    });
}
```

Every Component follows the builder pattern. We start by creating a `Button` struct, and then we can
call any set of **styling** functions such as `.border()`.

We attach a `on_press` handler to the button, and pass the increment function to it.

Within the `increment` function, we increment the counter, this will automatically result in the text being updated.
There is no need to use signals or state management in Vapor, it is all reactive. It is also fine grained,
only the content that you define to be updated will be updated. No more useMemo, or state definitions, just pure functions.

{#a-glimpse-under-the-hood}

### A glimpse under the hood

The following is a base explanation of how Vapor works at it's core. **It is not necessary for writing Vapor components.**
However, it is useful to understand the basics of how Vapor works. If you ever want to use it to it's full potential,
or understand how frontend frameworks work, this is a great place to start.

{#ui-node}

### A UI Node

A UI Node is a generalized element which represents all UI primitives. Think of it as the boxes or text on your screen.
Each Box is generalized to a UI Node. In Web these are _divs, spans, p tags, links._

In Vapor, eveything is a UI Node, during rendering, we build a tree of UI Nodes, each with a element type and style.
This tree is then rendered to the DOM. Since Vapor is renderer agnostic, we can use the same UI tree and just swap the renderer.

![Diagram](/src/assets/tree.svg)

```zig
pub inline fn Node() NodeBody {
    const elem_decl = ElementDefinition{
        .state_type = .static,
        .element_type = .Box,
    };

    LifeCycle.open(elem_decl);
    LifeCycle.configure(elem_decl);
    return LifeCycle.body;
}
```

`LifeCycle` is a struct that handles configuring Nodes, and adding them to the UI tree.
`.open` adds the node to the tree and sets it as the current open node
or parent node.
We return `body` which is a function that allows
for child nodes to be added to the current node.

This is all abstracted away, it is up to the developer to decided whether they want to create their
own custom UI Node types.
