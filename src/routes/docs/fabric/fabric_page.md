{#what-is-fabric}

# What is Fabric? 

## Fabric is the frontend framework of Tether.

We believe developers should control their tools, not the other way around.
Every API is explicitly exposed, every internal is accessible, and every component can be customized.
No black boxes, no hidden magic—just transparent, controllable architecture that puts you in the driver's seat.

Fabric should be treated and seen as a set of tools, which can be used to adapt the core framework,
it's purpose is to be unopinionated, and modular. However, there are guidelines, and best practices that we follow.

{#fabric-is-simple}

### Fabric is simple by nature

- Only write `Zig`.

- Update the UI via `.cycle()` or `Signal(T)`

- You can embed any custom `HTML`, `JS`, `CSS`

- Powerful Styling

- Minimal memory management

- Native performance

{#making-a-button}

### Making a button!

We will jump into depth with styling, in the next section. For now though, we will make a button.
The `Button` component is part of the Static and Pure Structs.

Every Component follows the builder pattern. We start by creating a `Button` struct, and then we call the `style` function.
We can now pass any styling to said component. There are many more functions that can be used.

We attach a `on_press` handler to the button, and pass the increment function to it.

Within the `increment` function, we call `Fabric.cycle()` to trigger the UI to update.
There is no need to use signals or state management in Fabric, it is all reactive. It is also fine grained,
only the content that you define to be updated will be updated. No more useMemo, or state definitions, just pure functions.

Fabric does expose a few signals, types, if you truly want explicity over your code. However, they are no more performant
than calling `Fabric.cycle()`.

Finally, `Fabric.cycle()` only needs to called once, not for every variable change. Thus updating
the color of the button and it's counter, only requires one call to `Fabric.cycle()`.

{#a-glimpse-under-the-hood}

### A glimpse under the hood

The following is a base explanation of how Fabric works at it's core. **It is not neccesary for writing Fabric components.**
However, it is useful to understand the basics of how Fabric works. If you ever want to use it to it's full potential,
or understand how frontend frameworks work, this is a great place to start.

{#ui-node}

### A UI Node

A UI Node is a generalized element which represents all UI primitives. Think of it as the boxes or text on your screen.
Each Box is generalized to a UI Node. In Web these are *divs, spans, p tags, links.*

In Fabric, eveything is a UI Node, during rendering, we build a tree of UI Nodes, each with a element type and style.
This tree is then rendered to the DOM. Since Fabric is renderer agnostic, we can use the same UI tree and just swap the renderer.

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
