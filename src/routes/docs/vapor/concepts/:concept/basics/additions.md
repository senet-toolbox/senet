
#### When state changes, Vapor performs two phases:

1. **Render Pass** - Your entire render() function executes in WebAssembly, generating a fresh virtual tree

2. **Reconciliation** - Vapor diffs the new tree against the previous one, identifying exactly which DOM elements need updates

Only the reconciliation results are applied to the actual DOM—this is what
makes updates fine-grained.

#### Performance comparison 10,000 node updates (Render, Diff, DOM Patch):

Vapor delivers fine-grained DOM updates without the complexity of signals or reactive primitives.
When state changes, Vapor re-runs your render function and diffs the virtual tree—but because this happens in WebAssembly,
it's **8-10x** faster than typical React like reconcilers.

- Vanilla JavaScript: **~10ms** _(Raw DOM updates)_
- Vapor (WASM): **~12ms**
- React: ~100-150ms (frame drops at 60fps)

{#engine}

## Engine

Vapor is akin to modern game engines, where the entire rendering is handled by the engine.

Vapor runs the entire render cycle, on every state change. Vapor generates a Virtual Tree (DOM),
and then reconciles the differences between the old and new tree.

This is done in a single pass, and is extremely fast, even with large trees. Vapor can rerender a total of 10,000 nodes in just 12ms on a 2021 M1 MacBook Pro.
**At 80FPS.**

After reconciliation, Vapor spits out an array of nodes:

1. An array of nodes that need to be removed

2. An array of nodes that need to be added

3. An array of nodes that need to be updated

These are then applied to the DOM granularly for minimal overhead.

We can access these via the following commands:

```zig
const dirty_nodes = Vapor.dirty_nodes;
const added_nodes = Vapor.added_nodes;
const removed_nodes = Vapor.removed_nodes;

for (dirty_nodes.items) |node| {
    // Do something with the dirty node
}
```

This is different from React, where changing a parent's state triggers
re-renders of all children—even if their props didn't change. Vapor's
reconciliation is component-agnostic: it doesn't matter where the state lives,
only which elements display it.
