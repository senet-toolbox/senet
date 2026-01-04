{#todo-app-tutorial}

# Building a Todo App

#### Learn Vapor fundamentals by building a complete todo application

This tutorial demonstrates core Vapor concepts including state management, event handling, and component composition by building a fully functional todo app.

![Todo App](/assets/todo-app-preview.svg)

{#what-well-build}

## What We'll Build

A todo application with the following features:

- ✅ Add new todos
- ✅ Mark todos as complete/incomplete
- ✅ Edit existing todos
- ✅ Delete todos
- ✅ Real-time UI updates with zero boilerplate

**No `useState`, no `useEffect`, no hooks.** Just pure Zig code with automatic reactivity.

{#project-setup}

## Project Setup

First, create a new Vapor project:

```bash
metal create vapor todo-app
cd todo-app
metal run web
```

Navigate to `src/main.zig` and let's start building.

{#step-1-data-models}

## Step 1: Data Models

Vapor uses plain Zig structs for data. No special annotations or decorators needed.

```zig
const std = @import("std");
const Vapor = @import("vapor");

const Todo = struct {
    id: u32,
    text: []const u8,
    completed: bool,
};

const Mode = enum {
    add,
    edit,
};
```

**Key Points:**

- `Todo` is just a regular Zig struct
- `Mode` tracks whether we're adding or editing
- No framework magic—it's just data

{#step-2-global-state}

## Step 2: Global State

In Vapor, state lives **outside** the render function. This is what makes reactivity automatic.

```zig
var mode: Mode = .add;
var todos: Vapor.Array(Todo) = undefined;
var current_input: []const u8 = "";
var selected_item: ?*Todo = null;
var next_id: u32 = 0;
```

**Why Global?**

Remember from the docs: variables inside `render()` get reset every frame. By placing state globally, it persists between renders.

**Memory Type:** We use `Vapor.Array(Todo)` which handles memory automatically based on the arena type we specify.

{#step-3-initialization}

## Step 3: Initialization

The `init()` function runs once when the app loads. This is where we set up our initial state.

```zig
pub fn init() void {
    // Initialize with persist arena - data lives for app lifetime
    todos = Vapor.array(Todo, .persist);

    // Add a sample todo
    todos.append(Todo{
        .id = 0,
        .text = "Hello",
        .completed = false
    }) catch unreachable;

    next_id += 1;

    // Register our page
    Vapor.Page(.{ .route = "/" }, TodoApp, null);
}
```

**Arena Types:**

- `.persist` - Lives for the entire application lifetime
- `.view` - Freed when navigating away from the page
- `.frame` - Freed after each render cycle

For a todo app, `.persist` makes sense since we want todos to survive across the entire session.

{#step-4-actions}

## Step 4: Actions (Business Logic)

These functions mutate our global state. Vapor's **Atomic Mode** automatically detects changes and updates the UI.

```zig
fn addTodo() void {
    if (current_input.len == 0) {
        Vapor.alert("Please enter a todo");
        return;
    }

    const new_todo = Todo{
        .id = next_id,
        .text = current_input,
        .completed = false,
    };

    next_id += 1;
    todos.append(new_todo) catch return;

    // Reset input - UI updates automatically
    current_input = "";
}

fn toggleTodo(id: u32) void {
    for (todos.items) |*t| {
        if (t.id == id) {
            t.completed = !t.completed;
            return;
        }
    }
}

fn removeTodo(id: u32) void {
    for (todos.items, 0..) |t, i| {
        if (t.id == id) {
            _ = todos.orderedRemove(i);
            return;
        }
    }
}

fn editTodo(item: *Todo) void {
    current_input = item.text;
    selected_item = item;
    mode = .edit;
}

fn submitEdit() void {
    if (selected_item) |item| {
        item.text = current_input;
    }
    current_input = "";
    mode = .add;
}
```

**Notice:** No `setState()`, no `dispatch()`, no reducers. Just mutate the variables directly.

**How it works:**

1. User clicks a button (event triggered)
2. Event handler runs (e.g., `addTodo`)
3. State mutates (`todos.append(...)`)
4. Vapor detects the event, reconciles the tree, updates UI

This is **Atomic Mode** in action—user interactions automatically trigger UI updates.

{#step-5-todo-row-component}

## Step 5: TodoRow Component

Let's create a reusable component for rendering individual todos. This is a **Function Component** in Vapor.

```zig
const Box = Vapor.Box;
const Text = Vapor.Text;
const ButtonCtx = Vapor.CtxButton;

fn TodoRow(item: *Todo) void {
    const text_color = if (item.completed)
        Vapor.Types.Color.black
    else
        Vapor.Types.Color.black;

    Box()
        .border(.simple(.black))
        .direction(.row)
        .spacing(12)
        .padding(.tblr(4, 4, 8, 4))
        .layout(.left_center)
        .children({

        // Checkbox button
        ButtonCtx(toggleTodo, .{item.id})
            .border(.simple(if (item.completed) .vapor_blue else .black))
            .width(.px(24))
            .height(.px(24))
            .layout(.center)
            .children({
                if (item.completed) {
                    Text("✓").font(16, 700, .vapor_blue).end();
                }
            });

        // Todo text
        Text(item.text)
            .width(.grow)
            .font(18, 400, text_color)
            .end();

        // Action buttons
        const style = Vapor.Style{
            .visual = .{
                .border = .simple(.black),
                .background = .white,
            },
            .padding = .all(6),
        };

        ButtonCtx(removeTodo, .{item.id}).style(&style)({
            Text("Delete").font(14, 700, .black).end();
        });

        ButtonCtx(editTodo, .{item}).style(&style)({
            Text("Edit").font(14, 700, .black).end();
        });
    });
}
```

**Key Concepts:**

**ButtonCtx vs Button:**

- `Button(.{ .on_press = handler })` - No arguments
- `ButtonCtx(handler, .{arg1, arg2})` - Pass context/arguments

**Builder Pattern:**

```zig
Box()
    .border(.simple(.black))
    .direction(.row)
    .spacing(12)
    .children({ ... })
```

Each method returns `Self`, allowing chaining just like SwiftUI.

**Conditional Rendering:**

```zig
if (item.completed) {
    Text("✓").font(16, 700, .vapor_blue).end();
}
```

Standard Zig control flow—no special JSX syntax needed.

{#step-6-main-ui}

## Step 6: Main UI (TodoApp)

Now we compose everything into the main page render function.

```zig
const TextField = Vapor.TextField;
const Button = Vapor.Button;

fn TodoApp() void {
    Vapor.Stack()
        .layout(.top_center)
        .padding(.all(40))
        .spacing(20)
        .children({

        // Header
        Text("Vapor Todo")
            .font(32, 800, .black)
            .end();

        Text("Global Components & Atomic State")
            .font(14, 400, .black)
            .end();

        // Input Area
        Box()
            .direction(.row)
            .spacing(10)
            .children({

            TextField(.string)
                .bind(&current_input)
                .placeholder("Add a todo")
                .width(.px(300))
                .padding(.all(12))
                .border(.simple(.black))
                .end();

            // Dynamic button based on mode
            switch (mode) {
                .add => Button(.{ .on_press = addTodo })
                    .background(.black)
                    .padding(.horizontal(20))
                    .layout(.center)
                    .children({
                        Text("Add").font(16, 700, .white).end();
                    }),

                .edit => Button(.{ .on_press = submitEdit })
                    .background(.black)
                    .padding(.horizontal(20))
                    .layout(.center)
                    .children({
                        Text("Submit").font(16, 700, .white).end();
                    }),
            }
        });

        // Todo List
        Vapor.Stack()
            .width(.px(400))
            .spacing(8)
            .children({
                for (todos.items) |*item| {
                    TodoRow(item);
                }
            });
    });
}
```

**Data Binding:**

```zig
TextField(.string)
    .bind(&current_input)
```

The `bind()` method automatically syncs the input value with `current_input`. No `onChange` handlers needed for basic binding.

**Dynamic UI with switch:**

```zig
switch (mode) {
    .add => Button(...) // Show "Add"
    .edit => Button(...) // Show "Submit"
}
```

When `mode` changes, the UI automatically updates to show the correct button.

**List Rendering:**

```zig
for (todos.items) |*item| {
    TodoRow(item);
}
```

Standard Zig `for` loop. No `.map()`, no keys needed (though Vapor supports stable keys for performance).

{#complete-code}

## Complete Code

Here's the full `main.zig`:

```zig
const std = @import("std");
const Vapor = @import("vapor");

const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.CtxButton;
const TextField = Vapor.TextField;

const Todo = struct {
    id: u32,
    text: []const u8,
    completed: bool,
};

const Mode = enum { add, edit };

var mode: Mode = .add;
var todos: Vapor.Array(Todo) = undefined;
var current_input: []const u8 = "";
var selected_item: ?*Todo = null;
var next_id: u32 = 0;

pub fn init() void {
    todos = Vapor.array(Todo, .persist);
    todos.append(Todo{
        .id = 0,
        .text = "Hello",
        .completed = false
    }) catch unreachable;
    next_id += 1;
    Vapor.Page(.{ .route = "/" }, TodoApp, null);
}

fn addTodo() void {
    if (current_input.len == 0) {
        Vapor.alert("Please enter a todo");
        return;
    }
    const new_todo = Todo{
        .id = next_id,
        .text = current_input,
        .completed = false,
    };
    next_id += 1;
    todos.append(new_todo) catch return;
    current_input = "";
}

fn submitEdit() void {
    if (selected_item) |item| {
        item.text = current_input;
    }
    current_input = "";
    mode = .add;
}

fn toggleTodo(id: u32) void {
    for (todos.items) |*t| {
        if (t.id == id) {
            t.completed = !t.completed;
            return;
        }
    }
}

fn removeTodo(id: u32) void {
    for (todos.items, 0..) |t, i| {
        if (t.id == id) {
            _ = todos.orderedRemove(i);
            return;
        }
    }
}

fn editTodo(item: *Todo) void {
    current_input = item.text;
    selected_item = item;
    mode = .edit;
}

fn TodoRow(item: *Todo) void {
    const text_color = if (item.completed)
        Vapor.Types.Color.black
    else
        Vapor.Types.Color.black;

    Box()
        .border(.simple(.black))
        .direction(.row)
        .spacing(12)
        .padding(.tblr(4, 4, 8, 4))
        .layout(.left_center)
        .children({

        ButtonCtx(toggleTodo, .{item.id})
            .border(.simple(if (item.completed) .vapor_blue else .black))
            .width(.px(24))
            .height(.px(24))
            .layout(.center)
            .children({
                if (item.completed) {
                    Text("✓").font(16, 700, .vapor_blue).end();
                }
            });

        Text(item.text)
            .width(.grow)
            .font(18, 400, text_color)
            .end();

        const style = Vapor.Style{
            .visual = .{
                .border = .simple(.black),
                .background = .white,
            },
            .padding = .all(6),
        };

        ButtonCtx(removeTodo, .{item.id}).style(&style)({
            Text("Delete").font(14, 700, .black).end();
        });

        ButtonCtx(editTodo, .{item}).style(&style)({
            Text("Edit").font(14, 700, .black).end();
        });
    });
}

fn TodoApp() void {
    Vapor.Stack()
        .layout(.top_center)
        .padding(.all(40))
        .spacing(20)
        .children({

        Text("Vapor Todo").font(32, 800, .black).end();
        Text("Global Components & Atomic State").font(14, 400, .black).end();

        Box().direction(.row).spacing(10).children({
            TextField(.string)
                .bind(&current_input)
                .placeholder("Add a todo")
                .width(.px(300))
                .padding(.all(12))
                .border(.simple(.black))
                .end();

            switch (mode) {
                .add => Button(.{ .on_press = addTodo })
                    .background(.black)
                    .padding(.horizontal(20))
                    .layout(.center)
                    .children({
                        Text("Add").font(16, 700, .white).end();
                    }),
                .edit => Button(.{ .on_press = submitEdit })
                    .background(.black)
                    .padding(.horizontal(20))
                    .layout(.center)
                    .children({
                        Text("Submit").font(16, 700, .white).end();
                    }),
            }
        });

        Vapor.Stack().width(.px(400)).spacing(8).children({
            for (todos.items) |*item| {
                TodoRow(item);
            }
        });
    });
}
```

{#running-the-app}

## Running the App

```bash
metal run web
```

Open [localhost:5173](http://localhost:5173/) and you'll see your todo app!

@todo-app-demo

{#what-you-learned}

## What You Learned

**1. State Management:**

- State lives **outside** render functions
- Just mutate variables—no `setState()`
- Atomic Mode handles reactivity automatically

**2. Memory Management:**

- Used `Vapor.Array(T)` with `.persist` arena
- No manual allocation/deallocation needed
- Memory is automatically managed based on arena type

**3. Event Handling:**

- `Button(.{ .on_press = handler })` for simple clicks
- `ButtonCtx(handler, .{args})` for passing context
- `.bind(&variable)` for two-way data binding

**4. Component Composition:**

- Functions like `TodoRow()` are components
- Use standard Zig control flow (`if`, `for`, `switch`)
- Builder pattern for styling (`.padding()`, `.layout()`, etc.)

**5. UI Updates:**

- No manual DOM manipulation
- No dependency tracking
- Just mutate state—Vapor reconciles automatically

{#next-steps}

## Next Steps

**Add Persistence:**

```zig
// Save to localStorage
fn saveTodos() void {
    const json = std.json.stringify(todos.items);
    Vapor.localStorage.set("todos", json);
}

// Load on init
fn loadTodos() void {
    if (Vapor.localStorage.get("todos")) |json| {
        // Parse and restore todos
    }
}
```

**Add Filtering:**

```zig
const Filter = enum { all, active, completed };
var filter: Filter = .all;

fn filteredTodos() []Todo {
    return switch (filter) {
        .all => todos.items,
        .active => // filter logic
        .completed => // filter logic
    };
}
```

**Add Animations:**

```zig
Box()
    .transition(.{ .duration = 200 })
    .hoverScale()
    .children({ ... })
```

**Fetch from API:**

```zig
fn loadFromServer() void {
    Vapor.fetch(.{
        .url = "https://api.example.com/todos",
        .method = .GET,
    }, handleResponse);
}

fn handleResponse(response: Vapor.Response) void {
    // Parse JSON and update todos
}
```

{#comparison-to-react}

## Comparison to React

**React Todo (simplified):**

```jsx
function TodoApp() {
  const [todos, setTodos] = useState([]);
  const [input, setInput] = useState("");
  const [mode, setMode] = useState("add");

  const addTodo = () => {
    setTodos([
      ...todos,
      {
        id: Date.now(),
        text: input,
        completed: false,
      },
    ]);
    setInput("");
  };

  const toggleTodo = (id) => {
    setTodos(
      todos.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t)),
    );
  };

  return (
    <div>
      <input value={input} onChange={(e) => setInput(e.target.value)} />
      <button onClick={addTodo}>Add</button>
      {todos.map((todo) => (
        <TodoRow
          key={todo.id}
          todo={todo}
          onToggle={() => toggleTodo(todo.id)}
        />
      ))}
    </div>
  );
}
```

**Lines of code:**

- React: ~80 lines (with proper styling/structure)
- Vapor: ~140 lines (but no build step, smaller bundle)

**Bundle size:**

- React: ~50KB (React) + ~30KB (ReactDOM) = 80KB minimum
- Vapor: ~28KB (entire framework + your code)

**Memory usage:**

- React: Variable (garbage collection, virtual DOM overhead)
- Vapor: Plateaus at ~500KB regardless of app size

{#key-takeaways}

## Key Takeaways

✅ **No special state primitives** - Just Zig variables  
✅ **Automatic reactivity** - Mutate and move on  
✅ **Simple mental model** - Data outside, UI inside  
✅ **Type-safe** - Compile-time guarantees  
✅ **Minimal memory management** - Arena system handles it  
✅ **Tiny bundle size** - 28KB including framework

**Vapor makes web development feel like systems programming—and that's a good thing.**
