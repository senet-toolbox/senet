# `app.zig` Tic-Tac-Toe Demo

**File role:** Bootstraps a **Vapor** web application compiled to WebAssembly,
binds it to the browser viewport, wires up route discovery, and orchestrates each render cycle.

## 1. Building the “Tic‑Tac‑Toe” Demo Route

This section walks you through adding a fully‑working Tic‑Tac‑Toe game as a new page in your Vapor application. We’ll start by wiring up the route, then progressively add game logic and styling in later chapters.

### 1.1 Create the Route Folder

**Using the metal cli, run...**

%metal create mytictactoegame

%cd mytictactoegame

%metal run web

Visit [localhost:5173](http://localhost:5173/)
You should see a counter element which you can click!

### 1.2 Create the tictac route

%mkdir src/routes/tictac

%cd src/routes/tictac

Vapor’s router maps URL segments to matching folders under `src/routes`. Creating the `tictac` directory means that visiting **`/tictac`** in the browser will load whatever components you register from this folder.

### 1.2 Scaffold `Page.zig`

Inside `src/routes/tictac/`, add **`Page.zig`** with the minimal boilerplate:

%metal gen page /routes/tictac

```zig
const std    = @import("std");
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Static = Vapor.Static;
const Box = Static.Box;
const Text = Static.Text;

/// Called from `instantiate()` to register the page.
pub fn init() void {
    // Source location (`@src()`) becomes the unique page key.
    Page(@src(), render, null);
}

/// Renders a full‑window flexbox with a header.
pub fn render() void {
    Box.size(.hw_percent(100, 100)).body()({
        Text("Tic‑Tac‑Toe!").plain();
    });
}
```

### 1.3 Register the Page in `main.zig`

Update the imports and add **one** line inside `instantiate()`:

```zig
const TicTacToe = @import("routes/tictac/Page.zig"); // 👈 NEW;
// ...
export fn instantiate(window_width: i32, window_height: i32) void {
    Vapor.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = allocator,
    });

    RootPage.init();
    TicTacToe.init(); // 👈 NEW
}
```

No other code changes are required—`Vapor.cycle()` already chooses the correct page implementation based on the route.

At this stage the page simply displays a centred title; we will flesh out the 3×3 grid and game state in upcoming sections.

### 1.4 Smoke‑test the Route

- Navigate to [localhost:5173/tictac](http://localhost:5173/tictac) in the browser.

- You should see the centred “Tic‑Tac‑Toe!” header.

If you get a blank screen, confirm:

- The folder is named **exactly** `tictac` (case‑sensitive).

- `TicTacToe.init()` is indeed called before the first `renderUI`.

In the next chapter you’ll replace the placeholder header with a 3 × 3 board, wire up click handling, and
implement win‑detection logic—all in a single Zig file.

## 2. Creating a Reusable `Grid` Component

With the route skeleton in place, the next step is to render a 3 × 3 board. We’ll encapsulate board‑drawing in a separate component so it can be tested or swapped out easily later.

### 2.1 Add the components Directory

Make sure your in the root directory

%mkdir src/components

### 2.2 Implement `Grid.zig`

%metal gen component -o /components/Grid.zig

```zig
const std    = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Box = Static.Box;
const TextFmt = Static.TextFmt;

const GridBox = struct {
    clicked: bool = false, // Will track whether this cell has been played
};

var grid_boxes: [9]GridBox = undefined;

/// Initialise component‑level state (called once from the page).
pub fn init() void {
    for (0..9) |i| {
        grid_boxes[i] = GridBox{}; // all cells start unclicked
    }
}

/// Render a 3×3 flex grid that currently shows each cell index.
pub fn render() void {
    Box.size(.hw_percent(100, 100)).wrap(.wrap).body()({
        for (grid_boxes, 0..) |_, i| {
            Box
            .border(.simple(.hex("#CCCCCC")))
            .size(.hw_percent(33, 33))
            .body()({
                // Placeholder content; will later become “X” / “O” marks.
                TextFmt("{d}", .{i}).layout(.center).close();
            });
        }
    });
}
```

**What this does:**

- Lays out nine equal‑sized flex children, producing the Tic‑Tac‑Toe grid.

- Each cell currently shows its index (0‑8). We’ll swap this for **X / O** characters once click handling is in place.

### 2.3 Wire the Component into the Tic‑Tac‑Toe Page

Update `src/routes/tictac/Page.zig` so that it imports and renders the new component:

```zig
const std    = @import("std");
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Static = Vapor.Static;
const Box = Static.Box;
const Text = Static.Text;
const Grid   = @import("../../components/Grid.zig");

/// Called from `instantiate()` to register the page.
pub fn init() void {
    // Source location (`@src()`) becomes the unique page key.
    Page(@src(), render, null);
    Grid.init(); // 👈 Ensure component state is initialised once
}

/// Renders a full‑window flexbox with a header.
pub fn render() void {
    Box.size(.hw_percent(100, 100)).direction(.column).spacing(20).body()({
        Text("Tic‑Tac‑Toe!").plain();
        Box.size(.hw_percent(30, 30)).body()({
            Grid.render(); // 👈 Draw the board
        });
    });
}
```

Re‑build and refresh **`/tictac`** — you should now see a 3 × 3 grid with cell indices.

### 2.4 Quick Checklist

| Check          | Expectation                                            |
| -------------- | ------------------------------------------------------ |
| **Page loads** | Grid displays nine numbered squares under the heading. |
| **Responsive** | Resizing the browser keeps squares evenly sized.       |
| **No panics**  | Console is free of allocation errors.                  |

### 2.5 Up Next

In the following section we’ll:

- Replace the index numbers with interactive **X / O** marks.

- Introduce a simple win‑detection routine and reset button.

---

## 11. Embedding X / O SVG Assets & Click Handling

Unlike a text‑based “X” or “O”, SVG graphics scale crisply at any resolution.
Vapor can embed static asset files at **compile‑time** using Zig’s `@embedFile` builtin, or fetch during client-side rendering.

### 11.1 Add the SVG files

Create an **`assets`** folder at project root (or any path you like) and drop two files:

- **`assets/X.svg`**

```svg
  <svg viewBox="0 0 530 530" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M20.14 20.86L509.14 509.86" stroke="black" stroke-width="40" stroke-linecap="round"/>
    <path d="M509.14 20.86L20.14 509.86" stroke="black" stroke-width="40" stroke-linecap="round"/>
  </svg>
```

- **`assets/O.svg`**

```svg
  <svg viewBox="0 0 530 530" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="265" cy="265" r="224.5" stroke="black" stroke-width="40"/>
  </svg>
```

> **Tip:** Keep the view‑box square and content centred so the icon looks correct when Vapor constrains it to a fixed pixel size.

### 11.2 Extend `Grid.zig`

Replace the placeholder‐number implementation with click‑aware logic and embedded icons:

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;

const Player = enum { x, o };

const GridBox = struct {
    clicked: bool = false,
    player: Player = undefined,
};

// Compile‑time embed of the SVG markup.
fn drawX() void {
    Static.Svg(@embedFile("../assets/X.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

fn drawO() void {
    Static.Svg(@embedFile("../assets/O.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

var grid_boxes: [9]GridBox = undefined;
var current_player: Player = .x;

/// Initialise the board for a new game.
pub fn init() void {
    for (&grid_boxes) |*box| box.* = GridBox{};
    current_player = .x;
}

/// Button callback when a square is selected.
fn selectBox(box: *GridBox) void {
    Vapor.println("Selecting a box!", .{});
    if (box.clicked) return; // Ignore already‑played squares

    box.clicked = true;
    box.player = current_player;

    // TODO: call win‑detection here.

    // Swap turns
    current_player = switch (current_player) {
        .x => .o,
        .o => .x,
    };

    // Mark the component dirty so Vapor schedules a re‑render.
}

/// Render the interactive grid.
pub fn render() void {
    Static.FlexBox(.{
        .width = .percent(100),
        .height = .percent(100),
        .flex_wrap = .wrap,
    })({
        for (&grid_boxes) |*box| {
            Static.CtxButton(selectBox, .{box}, .{
                .border_color = .hex("#CCCCCC"),
                .border_thickness = .all(1),
                .width = .percent(33),
                .height = .percent(33),
                .padding = .all(24),
            })({
                if (box.clicked) switch (box.player) {
                    .x => drawX(),
                    .o => drawO(),
                };
            });
        }
    });
}
```

**Key points**

| Concept          | Where it appears        | Why it matters                                                                                          |
| ---------------- | ----------------------- | ------------------------------------------------------------------------------------------------------- |
| **`@embedFile`** | `drawX()` / `drawO()`   | Embeds raw SVG markup in the Wasm binary; zero runtime fetches.                                         |
| **`Static.Svg`** | same                    | Lets Vapor treat the markup like any other DOM node, inheriting flex‑box centring and size constraints. |
| **Turn state**   | `current_player` global | Ensures clicks alternate X→O→X…                                                                         |

### 11.3 Smoke‑test Interaction

1. Click squares; should log Selecting a box!.
2. Clicking an already‑taken square does nothing.

If icons are missing, verify the asset path in `@embedFile` and that Zig’s build file includes the `assets` folder in `build.zig`.

---

## 12. Adding a Global **Force** Signal

Before we wire in win‑detection, we need a clean way to tell Vapor _“re‑evaluate the entire board component now”_ whenever a move is made.
Instead of sprinkling many small `Signal`s throughout the grid, we can leverage a **single** _force signal_ that explicitly invalidates the component tree.

### 12.1 Why use a force signal?

- ✔ **Simplicity** – One line (`rerender.force()`) after any mutation guarantees a fresh render pass.
- ✔ **Explicit intent** – Makes it crystal‑clear where state changes occur.
- ✔ **Zero payload** – A `Signal(void)` carries no data; it’s purely a _recompute_ trigger.

### 12.2 Updated `Grid.zig` with `Signal`

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Signal = Vapor.Signal; // 👈 Add the signal;

const Player = enum { x, o };

const GridBox = struct {
    clicked: bool = false,
    player: Player = undefined,
};

// Compile‑time embed of the SVG markup.
fn drawX() void {
    Static.Svg(@embedFile("../assets/X.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

fn drawO() void {
    Static.Svg(@embedFile("../assets/O.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

var grid_boxes: [9]GridBox = undefined;
var current_player: Player = .x;
var rerender: Signal(void) = undefined;
/// Initialise the board for a new game.
pub fn init() void {
    for (&grid_boxes) |*box| box.* = GridBox{};
    current_player = .x;
    rerender.init({}); // Initialise the force signal once
}

/// Button callback when a square is selected.
fn selectBox(box: *GridBox) void {
    if (box.clicked) {
        Vapor.println("This square is already taken!", .{});
        return;
    }

    box.clicked = true;
    box.player = current_player;

    // TODO: call checkWin() here.

    // Toggle turn
    current_player = switch (current_player) {
        .x => .o,
        .o => .x,
    };

    rerender.force(); // ⬅ Trigger a full re‑render via the signal
}

/// Render the interactive grid.
pub fn render() void {
    Static.FlexBox(.{
        .width = .percent(100),
        .height = .percent(100),
        .flex_wrap = .wrap,
    })({
        for (&grid_boxes) |*box| {
            Static.CtxButton(selectBox, .{box}, .{
                .display = .flex, // 👈 Add the flex
                .border_color = .hex("#CCCCCC"),
                .height = .percent(33),
                .width = .percent(33),
                .border_thickness = .all(1),
                .padding = .all(24),
            })({
                if (box.clicked) switch (box.player) {
                    .x => drawX(),
                    .o => drawO(),
                };
            });
        }
    });
}
```

### 12.3 Quick test

1. **Re‑build** and reload `/tictac`.
2. Play a few moves—each click should instantly reflect the new X/O.
3. No console warnings about unused `Signal` or double initialisation.

---

## 13. Win Detection & Game Reset

The grid now re‑renders on every move. Next we need a routine that inspects the board after each click and returns the winner—if any.

### 13.1 `checkWin()` implementation

```zig
// All 8 possible winning line combinations (rows, columns, diagonals)
const win_patterns = [8][3]usize{
    .{ 0, 1, 2 }, // top row
    .{ 3, 4, 5 }, // middle row
    .{ 6, 7, 8 }, // bottom row
    .{ 0, 3, 6 }, // left column
    .{ 1, 4, 7 }, // middle column
    .{ 2, 5, 8 }, // right column
    .{ 0, 4, 8 }, // main diagonal
    .{ 2, 4, 6 }, // anti‑diagonal
};

/// Returns the winning player, or `null` if no one has yet won.
fn checkWin() ?Player {
    for (win_patterns) |pattern| {
        const a = &grid_boxes[pattern[0]];
        const b = &grid_boxes[pattern[1]];
        const c = &grid_boxes[pattern[2]];

        if (a.clicked and b.clicked and c.clicked and a.player == b.player and a.player == c.player) {
            return a.player;
        }
    }
    return null;
}
```

### 13.2 Integrate with `selectBox`

Add a **global** to track the outcome:

```zig
var winner: ?Player = null;
```

Then update the click handler:

```zig
fn selectBox(box: *GridBox) void {
    if (box.clicked or winner != null) return; // ignore if game over

    box.clicked = true;
    box.player  = current_player;

    if (checkWin()) |p| {
        winner = p;
    } else {
        // Toggle turn only if no winner yet
        current_player = switch (current_player) { .x => .o, .o => .x };
    }

    rerender.force(); // request re‑render
}
```

### 13.3 Display the winner & reset button

Append this overlay inside `render()` **after** the grid loops:

```zig
      if (winner) |winning_player| {
            switch (winning_player) {
                .x => {
                    Static.Text("Player X Won!", .{
                        .font_size = 24,
                        .font_weight = 900,
                        .text_color = .hex("#744DFF"),
                        .margin = .{ .top = 32 },
                    });
                },
                .o => {
                    Static.Text("Player O Won!", .{
                        .font_size = 24,
                        .font_weight = 900,
                        .text_color = .hex("#744DFF"),
                        .margin = .{ .top = 32 },
                    });
                },
            }
        }
```

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Signal = Vapor.Signal;

const Player = enum { x, o };

const GridBox = struct {
    clicked: bool = false,
    player: Player = undefined,
};

// Compile‑time embed of the SVG markup.
fn drawX() void {
    Static.Svg(@embedFile("../assets/X.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

fn drawO() void {
    Static.Svg(@embedFile("../assets/O.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

var grid_boxes: [9]GridBox = undefined;
var current_player: Player = .x;
var rerender: Signal(void) = undefined;
var winner: ?Player = null;
/// Initialise the board for a new game.
pub fn init() void {
    for (&grid_boxes) |*box| box.* = GridBox{};
    current_player = .x;
    rerender.init({}); // Initialise the force signal once
}

fn selectBox(box: *GridBox) void {
    if (box.clicked or winner != null) return; // ignore if game over

    box.clicked = true;
    box.player = current_player;

    if (checkWin()) |p| {
        winner = p;
    } else {
        // Toggle turn only if no winner yet
        current_player = switch (current_player) {
            .x => .o,
            .o => .x,
        };
    }

    rerender.force(); // request re‑render
}

// All 8 possible winning line combinations (rows, columns, diagonals)
const win_patterns = [8][3]usize{
    .{ 0, 1, 2 }, // top row
    .{ 3, 4, 5 }, // middle row
    .{ 6, 7, 8 }, // bottom row
    .{ 0, 3, 6 }, // left column
    .{ 1, 4, 7 }, // middle column
    .{ 2, 5, 8 }, // right column
    .{ 0, 4, 8 }, // main diagonal
    .{ 2, 4, 6 }, // anti‑diagonal
};

/// Returns the winning player, or `null` if no one has yet won.
fn checkWin() ?Player {
    for (win_patterns) |pattern| {
        const a = &grid_boxes[pattern[0]];
        const b = &grid_boxes[pattern[1]];
        const c = &grid_boxes[pattern[2]];

        if (a.clicked and b.clicked and c.clicked and a.player == b.player and a.player == c.player) {
            return a.player;
        }
    }
    return null;
}

/// Render the interactive grid.
pub fn render() void {
    Static.FlexBox(.{
        .width = .percent(100),
        .height = .percent(100),
        .flex_wrap = .wrap,
    })({
        for (&grid_boxes) |*box| {
            Static.CtxButton(selectBox, .{box}, .{
                .display = .flex,
                .border_color = .hex("#CCCCCC"),
                .height = .percent(33),
                .width = .percent(33),
                .border_thickness = .all(1),
                .padding = .all(24),
            })({
                if (box.clicked) switch (box.player) {
                    .x => drawX(),
                    .o => drawO(),
                };
            });
        }
        if (winner) |winning_player| {
            switch (winning_player) {
                .x => {
                    Static.Text("Player X Won!", .{
                        .font_size = 24,
                        .font_weight = 900,
                        .text_color = .hex("#744DFF"),
                        .margin = .{ .top = 32 },
                    });
                },
                .o => {
                    Static.Text("Player O Won!", .{
                        .font_size = 24,
                        .font_weight = 900,
                        .text_color = .hex("#744DFF"),
                        .margin = .{ .top = 32 },
                    });
                },
            }
        }
    });
}
```

### 13.4 Quick test checklist

| Scenario                                       | Expected behaviour                                                     |
| ---------------------------------------------- | ---------------------------------------------------------------------- |
| Complete any row/col/diagonal                  | Overlay appears announcing the correct winner; further clicks ignored. |
| Click **Play Again**                           | Board resets; X always starts first.                                   |
| Play until all 9 squares filled with no winner | (Optional) treat as a draw—easy extension.                             |

---

🎉 **Your Tic‑Tac‑Toe game is now fully playable!** The remaining polish tasks are aesthetic: animations, hover states, and maybe an AI opponent.

---

## 14. Alternative: Using an **Array Signal** for Fine‑Grained State

Some teams prefer an **explicit data‑signal** over a global force signal. The idea is to wrap the entire `[9]GridBox` array in a `Signal`, mutate only the relevant element, and let Vapor automatically re‑diff dependent views. This adds a bit of boilerplate but makes the reactive dataflow crystal‑clear.

### 14.1 Full Source (array‑signal version)

```zig
const std = @import("std");
const Fabric = @import("vapor");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Signal = Fabric.Signal;

const Player = enum {
    x,
    o,
};

const GridBox = struct {
    clicked: bool = false,
    player: Player = undefined,
};

fn X() void {
    Static.Svg(@embedFile("X.svg"), .{
        .width = .fixed(42),
        .height = .fixed(42),
    });
}

fn O() void {
    Static.Svg(@embedFile("O.svg"), .{
        .width = .fixed(42),
        .height = .fixed(42),
    });
}

var grid_boxes_sig: Signal([9]GridBox) = undefined;
var current_player: Player = .x;
var winner: ?Player = null;

pub fn init() void {
    var grid_boxes: [9]GridBox = undefined;
    for (0..9) |i| {
        grid_boxes[i] = GridBox{};
    }
    grid_boxes_sig.init(grid_boxes);
}

fn selectBox(index: usize) void {
    var grid_box = grid_boxes_sig.getElement(index);
    if (grid_box.clicked or winner != null) return; // ignore if game over

    grid_box.clicked = true;
    grid_box.player = current_player;
    grid_boxes_sig.updateElement(index, grid_box);

    if (checkWin()) |p| {
        winner = p;
    } else {
        // Toggle turn only if no winner yet
        current_player = switch (current_player) {
            .x => .o,
            .o => .x,
        };
    }
}

// All 8 possible winning line combinations (rows, columns, diagonals)
const win_patterns = [8][3]usize{
    .{ 0, 1, 2 }, // top row
    .{ 3, 4, 5 }, // middle row
    .{ 6, 7, 8 }, // bottom row
    .{ 0, 3, 6 }, // left column
    .{ 1, 4, 7 }, // middle column
    .{ 2, 5, 8 }, // right column
    .{ 0, 4, 8 }, // main diagonal
    .{ 2, 4, 6 }, // anti‑diagonal
};

/// Returns the winning player, or `null` if no one has yet won.
fn checkWin() ?Player {
    for (win_patterns) |pattern| {
        const a = grid_boxes_sig.get()[pattern[0]];
        Fabric.println("{any}", .{a});
        const b = grid_boxes_sig.get()[pattern[1]];
        const c = grid_boxes_sig.get()[pattern[2]];

        if (a.clicked and b.clicked and c.clicked and a.player == b.player and a.player == c.player) {
            return a.player;
        }
    }
    return null;
}

pub fn render() void {
    Static.FlexBox(.{
        .width = .percent(100),
        .height = .percent(100),
        .flex_wrap = .wrap,
    })({
        for (grid_boxes_sig.get(), 0..) |grid_box, i| {
            Static.CtxButton(selectBox, .{i}, .{
                .display = .flex,
                .border_color = .hex("#CCCCCC"),
                .height = .percent(33),
                .width = .percent(33),
                .border_thickness = .all(1),
                .padding = .all(24),
            })({
                if (grid_box.clicked) {
                    switch (grid_box.player) {
                        .x => X(),
                        .o => O(),
                    }
                }
            });
        }
        if (winner) |winning_player| {
            switch (winning_player) {
                .x => {
                    Static.Text("Player X Won!", .{
                        .font_size = 24,
                        .font_weight = 900,
                        .text_color = .hex("#744DFF"),
                        .margin = .{ .top = 32 },
                    });
                },
                .o => {
                    Static.Text("Player O Won!", .{
                        .font_size = 24,
                        .font_weight = 900,
                        .text_color = .hex("#744DFF"),
                        .margin = .{ .top = 32 },
                    });
                },
            }
        }
    });
}
```

### 14.2 Comparing the Two Approaches

| Aspect                  | **Force‑Signal** (Section 12)                               | **Array‑Signal** (Section 14)                          |
| ----------------------- | ----------------------------------------------------------- | ------------------------------------------------------ |
| Lines of code           | Shorter                                                     | Slightly longer (explicit get/update)                  |
| Mutation granularity    | Any state change → global `force()`                         | Only changed element updates; automatic diffing        |
| Visibility of data flow | Less explicit; relies on readers knowing you call `force()` | Crystal‑clear that `[9]GridBox` is the reactive source |
| Performance             | Negligible difference for 9 cells                           | Scales better for larger boards/components             |
| When to prefer          | Quick demos, small components                               | Complex UIs, teamwork, fine‑grained reactivity         |

### 14.3 Takeaway

Both techniques are valid. Pick **force‑signal** for speed of implementation or when state mutations are rare. Choose **array‑signal** (or multiple finer signals) when you want maintainability and precise reactive scopes.

---
