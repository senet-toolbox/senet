{#introduction}

# UI Inversion

UI Inversion flips the traditional state management model.

In most frameworks (like React), you must explicitly **"mark"** your data as stateful
(e.g., `useState(0)`). This special **"state"** variable then dictates how your UI renders.
This model creates a chain of dependencies, hooks (`useEffect`, `useMemo`), and boilerplate to manage how that state synchronizes with the UI.

**Vapor inverts this.** You don't mark the data. You use normal Zig language variables.

Instead, you **"mark"** the components that should be reactive.

{#component-types}

### In Vapor, we have two Component types

This simple inversion gives us two fundamental component types

- **Static Components:** Rendered once and never updated. They are "write-once" and immutable from the UI's perspective, even if the variables passed to them change.

- **Pure Components:** Stateful and reactive. A `Pure` component "subscribes" to any variables it uses. When those variables change, the component (and only that specific component) will update.

This simple inversion eliminates, an entire class of problems, such as
**useEffect, useMemo, infinite loops, dependency chains, state batch cycles, readability, synchronization, ect.**

{#react-comparison}

## React Comparison

React requires an explicit state management system, which differs from raw JavaScript. This becomes messy when multiple state variables are needed and interact with each other.

Moreover, making a simple update to an element in an array requires a complex, verbose update function.

```jsx
// React
function App() {
  const [count, setCount] = useState(0);
  const [array, setArray] = useState([1, 2, 3]);

  function editArray() {
    // Update element at index 1 to value 5
    setArray((prevArray) => {
      const newArray = [...prevArray]; // Here we are creating an entirely new array
      newArray[1] = 5;
      return newArray;
    });

    // Or using map
    setArray((prevArray) =>
      prevArray.map((item, index) => (index === 1 ? 5 : item)),
    );
  }

  function increment() {
    setCount(count + 1);
  }

  return (
    <div>
      <h1>You clicked {count} times</h1>
      <button onClick={increment}>Click me</button>
      <button onClick={editArray}>Edit array</button>
      {array.map((item, index) => (
        <div key={index}>{item}</div>
      ))}
    </div>
  );
}
```

{#vapor}

### Vapor

In Vapor, the state (`count`, `array`) is just a standard Zig variable. We don't need special setters.

By using Pure components (like `TextFmt` and `Text`), we tell Vapor that these specific UI elements should update when their inputs change.
The `increment` and `editArray` functions can mutate the variables directly, and the `Pure` components **"listening"** to them will update automatically and granularly.

**Note** We can also update the array within the UI itself, since its all just Zig code.

```zig
// Zig
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Pure = Vapor.Pure; // 👈 New
const Box = Vapor.Static.Box;
const Text = Vapor.Pure.Text; // 👈 New
const TextFmt = Vapor.Pure.TextFmt; // 👈 New

var count: u32 = 0;
fn increment() void {
    count += 1;
}

var array: [3]u32 = .{ 1, 2, 3 }; // array
fn editArray() void {
    array[1] = 5;
}

pub fn render() void {
    Box().children({
        TextFmt("You clicked {d} times", .{count}).end(); // 👈 New
        Button(.{ .on_press = increment }).children({
            Text("Click me").end();
        });
        Button(.{ .on_press = editArray }).children({
            Text("Edit array").end();
        });
        for (array) |item| {
            Text(item).end();
        }
    });
}
```

- The syntax for the `array` `.{}`, is a little different from typical JS or TS, however this is the same syntax used in many langauges including C, C++, Rust, C#,
  Java, Lua, and Go.

{#inversion-and-reactivity-modes}

## Inversion & Reactivity Modes

This system of `Static` and `Pure` components is controlled by two primary modes.

- **Automatic Mode (Default):** All components are treated as `Pure` by default.
  This is the simplest way to work—you get full, granular reactivity without any special "markers." **This very site runs in Automatic Mode.**

- **Marker Mode (Optimization):** You must explicitly mark reactive components as `Pure`.
  Any component not marked `Pure` defaults to `Static`. This is an optimization tool.
  It allows a developer to signal to the compiler that entire sections of the UI can never change, saving memory and processing time.

{#granularity}

## Granularity

No matter the mode you choose, evey update is granular, if only the text changes and none of the styles, or other properties, then only the text will update.
No **useMemo**, **derived**, **computed**, or **cached** state is required.

The **Modes** are purely a performance optimization, in which any Component marked as `Static` will be skipped during reconciliation.
This means that on an average application, about 80% of the components will be skipped.

{#code-within-the-ui}

### Code within the UI

A powerful side-effect of this model is that your UI is just Zig code.
It isn't transpiled. This allows you to embed logic, localize state changes,
and use the full power of the language directly within your render tree.

**In all honesty, I never realized how much I would do this, once I could.**

```zig
fn SectionList(current_menu_item: MenuItem, sections: Vapor.Set(bool)) void {
    if (current_menu_item) |current| {
        for (current.sections) |section| {

            // This is all just Zig code
            // We can localize the state changes, and change colors, or anything else
            const url = Vapor.fmtln("#{s}", .{section.link});
            const active_section = sections.get(section.link) orelse false;
            const text_color: Vapor.Types.Color = if (active_section) .palette(.tint) else .palette(.text_color);

            ListItem.hw(.fit, .full).children({
                Link(.{ .url = url }).children({
                    Text(section.title).font(14, 300, text_color).end();
                });
            });
        }
    }
}
```

{#mode-usecases}

## Mode Usecases

As stated before, like the broken record I am, _Vapor_ is a toolkit, not just a framework for web development or iOS.
The purpose is to create a toolbox of components, engines, and processors that can be exchanged,
swapped, and combined to create various UIs for various deployment targets.

It is not Flutter or Dioxus.

For example, GUIs typically run in **Immediate Mode**. There is no need for state management or other complexity.
The UI is updated once per frame, and the state is managed by the application. When using Immediate Mode, the entire reconciler,
virtual tree generator, and other such components do not need to be compiled.

While on the other hand, _Acorn_ is a full-fledged Application and uses **Atomic** and **Marker** mode, as it is a complex application and
requires explicit state management to improve legibility and performance.
