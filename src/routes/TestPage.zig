// const std = @import("std");
// const Vapor = @import("vapor");
//
// // Shorten common imports
// const Box = Vapor.Box;
// const Text = Vapor.Text;
// const Button = Vapor.Button;
// const ButtonCtx = Vapor.CtxButton; // Use Context buttons to pass arguments
// const TextField = Vapor.TextField;
//
// // --- 1. DATA MODELS ---
// // Just a simple Zig struct. Not a UI component.
// const Todo = struct { id: u32, text: []const u8, completed: bool };
//
// const Mode = enum { add, edit };
//
// var mode: Mode = .add;
//
// // --- 2. GLOBAL STATE ---
// // In Vapor, we often keep state global or in a top-level struct.
// // We assume an allocator is available (using page_allocator for demo simplicity).
// var todos: Vapor.Array(Todo) = undefined;
// var current_input: []const u8 = ""; // Bound to TextField
// var selected_item: ?*Todo = null;
// var next_id: u32 = 0;
//
// // --- 3. INIT ---
// pub fn init() void {
//     // Initialize the list
//     todos = Vapor.array(Todo, .persist);
//
//     todos.append(Todo{ .id = 0, .text = "Hello", .completed = false }) catch unreachable;
//     next_id += 1;
//
//     // Initialize Vapor
//     Vapor.Page(.{ .route = "/" }, TodoApp, null);
// }
//
// // --- 4. LOGIC / ACTIONS ---
// // These functions mutate the global state.
// // Vapor's Atomic Mode detects these changes automatically after events.
//
// fn addTodo() void {
//     if (current_input.len == 0) {
//         Vapor.alert("Please enter a todo", .{});
//         return;
//     }
//
//     // In a real app, you'd duplicate the string memory here.
//     // For this demo, we assume the binding handles the lifetime or we trust the flow.
//     const new_todo = Todo{
//         .id = next_id,
//         .text = Vapor.arena(.scratch).dupe(u8, current_input) catch unreachable,
//         .completed = false,
//     };
//
//     next_id += 1;
//     todos.append(new_todo) catch return;
//
//     // Reset input
//     current_input = "";
// }
//
// fn submitEdit() void {
//     if (selected_item) |item| {
//         item.text = current_input;
//     }
//
//     // Reset input
//     current_input = "";
//     mode = .add;
// }
//
// fn toggleTodo(id: u32) void {
//     for (todos.items) |*t| {
//         if (t.id == id) {
//             t.completed = !t.completed;
//             return;
//         }
//     }
// }
//
// fn removeTodo(id: u32) void {
//     for (todos.items, 0..) |t, i| {
//         if (t.id == id) {
//             const todo = todos.orderedRemove(i);
//             Vapor.arena(.scratch).free(todo.text);
//             return;
//         }
//     }
// }
//
// fn editTodo(item: *Todo) void {
//     current_input = item.text;
//     selected_item = item;
//     mode = .edit;
// }
//
// fn TodoRow(item: *Todo) void {
//     const text_color = if (item.completed) Vapor.Types.Color.black else Vapor.Types.Color.black;
//
//     Box()
//         .border(.simple(.black))
//         .direction(.row).spacing(12).padding(.tblr(4, 4, 8, 4)).layout(.left_center).children({
//         ButtonCtx(toggleTodo, .{item.id})
//             .border(.simple(if (item.completed) .vapor_blue else .black))
//             .width(.px(24)).height(.px(24))
//             .layout(.center)
//             .children({
//             if (item.completed) {
//                 Text("✓").font(16, 700, .vapor_blue).end();
//             }
//         });
//
//         Text(item.text)
//             .width(.grow)
//             .font(18, 400, text_color)
//             .end();
//
//         const style = Vapor.Style{
//             .visual = .{
//                 .border = .simple(.black),
//                 .background = .white,
//             },
//             .padding = .all(6),
//         };
//
//         ButtonCtx(removeTodo, .{item.id}).style(&style)({
//             Text("Delete").font(14, 700, .black).end();
//         });
//
//         ButtonCtx(editTodo, .{item}).style(&style)({
//             Text("Edit").font(14, 700, .black).end();
//         });
//     });
// }
//
// // --- 6. MAIN PAGE ---
// fn TodoApp() void {
//     // Main Container
//     Vapor.Stack().layout(.top_center).padding(.all(40)).spacing(20).children({
//
//         // Header
//         Text("Vapor Todo").font(32, 800, .black).end();
//         Text("Global Components & Atomic State").font(14, 400, .black).end();
//
//         // Input Area
//         Box().direction(.row).spacing(10).children({
//             TextField(.string)
//                 .bind(&current_input)
//                 .placeholder("Add a todo")
//                 .width(.px(300))
//                 .padding(.all(12))
//                 .border(.simple(.black))
//                 .end();
//
//             switch (mode) {
//                 .add => Button(.{ .on_press = addTodo })
//                     .background(.black)
//                     .padding(.horizontal(20))
//                     .layout(.center)
//                     .children({
//                     Text("Add").font(16, 700, .white).end();
//                 }),
//                 .edit => Button(.{ .on_press = submitEdit })
//                     .background(.black)
//                     .padding(.horizontal(20))
//                     .layout(.center)
//                     .children({
//                     Text("Submit").font(16, 700, .white).end();
//                 }),
//             }
//         });
//
//         // List Area
//         // We iterate over the data, calling our functional component for each.
//         Vapor.Stack().width(.px(400)).spacing(8).children({
//             for (todos.items) |*item| {
//                 TodoRow(item);
//             }
//         });
//     });
// }

// src/routes/home/Page.zig
const std = @import("std");
const Vapor = @import("vapor");
const Animation = Vapor.Animation;
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const Center = Vapor.Center;
const ButtonCtx = Vapor.CtxButton;

// ============================================
// GAME STATE
// ============================================
var board: [9]?bool = .{ null, null, null, null, null, null, null, null, null };
var is_x_turn: bool = true;
var game_over: bool = false;
var winner: ?bool = null;
var winning_line: ?[3]usize = null;

// ============================================
// ANIMATIONS
// ============================================
const win_animation = Animation.init("winPulse")
    .prop(.scale, 1, 1.05)
    .duration(400)
    .easing(.easeInOut)
    .iterations(0) // infinite
    .dir(.alternate);

const place_animation = Animation.init("place")
    .prop(.scale, 0.5, 1)
    .prop(.opacity, 0, 1)
    .duration(150)
    .easing(.easeOutBack)
    .fill(.forwards);

// ============================================
// STYLES
// ============================================
const title_style = Vapor.Style{
    .visual = .{
        .font_size = 42,
        .font_weight = 700,
        .text_color = .hex("#2c3e50"),
    },
    .margin = .b(10),
};

const board_container_style = Vapor.Style{
    .visual = .{
        .background = .hex("#34495e"),
        .border = .solid(.all(4), .hex("#2c3e50"), .all(12)),
        .shadow = .card(.hex("#00000033")),
    },
    .padding = .all(8),
};

const cell_base = Vapor.Style{
    .size = .square_px(90),
    .margin = .all(4),
    .visual = .{
        .border = .solid(.all(1), .hex("#ecf0f1"), .all(4)),
    },
    .layout = .center,
    .transition = .{ .duration = 100 },
};

const reset_button_style = Vapor.Style{
    .padding = .tblr(14, 14, 28, 28),
    .visual = .{
        .background = .hex("#27ae60"),
        .font_size = 16,
        .font_weight = 600,
        .text_color = .white,
        .border_radius = .all(8),
    },
    .interactive = .hover_scale(),
    .margin = .t(20),
};

// ============================================
// INITIALIZATION
// ============================================
pub fn init() void {
    win_animation.build();
    place_animation.build();
    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================
// RENDER FUNCTIONS
// ============================================
fn render() void {
    Center()
        .height(.percent(100))
        .background(.hex("#ecf0f1"))
        .children({
            Box()
                .direction(.column)
                .layout(.center)
                .spacing(16)
                .children({
                    // Title
                    Text("Tic-Tac-Toe")
                        .style(&title_style).end();

                    // Status
                    renderStatus();

                    // Board
                    Box()
                        .style(&board_container_style).children({
                            renderBoard();
                    });

                    // Reset Button
                    Button(resetGame)
                        .style(&reset_button_style).children({
                            Text("New Game").end();
                    });
            });
    });
}

fn renderStatus() void {
    const message: []const u8 = if (game_over)
        if (winner) |is_x|
            if (is_x) "🎉 X Wins!" else "🎉 O Wins!"
        else
            "🤝 It's a Draw!"
    else if (is_x_turn)
        "X's Turn"
    else
        "O's Turn";

    const color: Vapor.Types.Color = if (game_over and winner != null)
        if (winner.?) .hex("#e74c3c") else .hex("#3498db")
    else
        .hex("#7f8c8d");

    Text(message)
        .font(22, 600, color)
        .margin(.b(8))
        .end();
}

fn renderBoard() void {
    Box()
        .width(.px(306))
        .wrap(.wrap)
        .children({
            for (0..9) |i| {
                renderCell(i);
            }
    });
}

fn renderCell(index: usize) void {
    const cell_value = board[index];
    const is_clickable = !game_over and cell_value == null;
    const is_winning = isWinningCell(index);

    // Dynamic background color
    const bg_color: Vapor.Types.Background = if (is_winning)
        if (winner.?) .hex("#fadbd8") else .hex("#d4e6f1")
    else if (is_clickable)
        .hex("#ffffff")
    else
        .hex("#f5f5f5");

    var cell = ButtonCtx(makeMove, .{index})
        .baseStyle(&cell_base)
        .background(bg_color);

    if (is_clickable) {
        cell = cell.hoverBackground(.hex("#e8e8e8")).cursor(.pointer);
    }

    if (is_winning) {
        cell = cell.animation("win-pulse");
    }

    cell.children({
        if (cell_value) |is_x| {
            Text(if (is_x) "X" else "O")
                .font(44, 700, if (is_x) .hex("#e74c3c") else .hex("#3498db"))
                .animationEnter("place")
                .end();
        }
    });
}

// ============================================
// GAME LOGIC
// ============================================
fn makeMove(index: usize) void {
    if (game_over) return;
    if (board[index] != null) return;

    board[index] = is_x_turn;

    if (checkWinner()) |result| {
        game_over = true;
        winner = result.winner;
        winning_line = result.line;
        return;
    }

    if (isBoardFull()) {
        game_over = true;
        winner = null;
        return;
    }

    is_x_turn = !is_x_turn;
}

const WinResult = struct {
    winner: bool,
    line: [3]usize,
};

fn checkWinner() ?WinResult {
    const patterns = [_][3]usize{
        .{ 0, 1, 2 }, .{ 3, 4, 5 }, .{ 6, 7, 8 }, // Rows
        .{ 0, 3, 6 }, .{ 1, 4, 7 }, .{ 2, 5, 8 }, // Columns
        .{ 0, 4, 8 }, .{ 2, 4, 6 },               // Diagonals
    };

    for (patterns) |pattern| {
        const a = board[pattern[0]];
        const b = board[pattern[1]];
        const c = board[pattern[2]];

        if (a != null and a == b and b == c) {
            return WinResult{
                .winner = a.?,
                .line = pattern,
            };
        }
    }
    return null;
}

fn isBoardFull() bool {
    for (board) |cell| {
        if (cell == null) return false;
    }
    return true;
}

fn isWinningCell(index: usize) bool {
    if (winning_line) |line| {
        return index == line[0] or index == line[1] or index == line[2];
    }
    return false;
}

fn resetGame() void {
    board = .{ null, null, null, null, null, null, null, null, null };
    is_x_turn = true;
    game_over = false;
    winner = null;
    winning_line = null;
}
//
// const std = @import("std");
// const Vapor = @import("vapor");
//
// // State: Lives outside the render function to persist between cycles
// var tasks : Vapor.Array([]const u8) = undefined;
// var current_input: []const u8 = "";
//
// pub fn init() void {
//     tasks = Vapor.array([]const u8, .persist);
//     Vapor.Page(.{ .src = @src() }, render, null);
// }
//
// // Logic: Modifies the state directly
// fn addTask() void {
//     if (current_input.len > 0) {
//         // dupe the string into persistent memory so it doesn't vanish
//         const task_copy = Vapor.arena(.persist).dupe(u8, current_input) catch return;
//         tasks.append(task_copy) catch return;
//         current_input = ""; // Clear the input field
//     }
// }
//
// fn removeTask(index: usize) void {
//     _ = tasks.orderedRemove(index);
// }
//
// pub fn render() void {
//     Vapor.Box().layout(.center).padding(.all(40)).spacing(20).children({
//         Vapor.Text("Vapor Todo List").font(32, 700, .black).end();
//
//         // Input Area
//         Vapor.Box().direction(.row).spacing(10).children({
//             Vapor.TextField(.string)
//                 .bind(&current_input) // Two-way binding
//                 .placeholder("What needs to be done?")
//                 .width(.px(300))
//                 .end();
//
//             Vapor.Button(.{ .on_press = addTask }).children({
//                 Vapor.Text("Add Task").end();
//             });
//         });
//
//         // Tasks List
//         Vapor.List().direction(.column).spacing(10).children({
//             for (tasks.items, 0..) |task, i| {
//                 Vapor.ListItem().direction(.row).spacing(15).children({
//                     Vapor.Text(task).fontSize(18).end();
//
//                     // ButtonCtx allows passing arguments (the index) to the handler
//                     Vapor.CtxButton(removeTask, .{i}).children({
//                         Vapor.Text("Delete").font(16, null, .hex("#ff0000")).end();
//                     });
//                 });
//             }
//         });
//     });
// }

// // src/routes/home/Page.zig
// const std = @import("std");
// const Vapor = @import("vapor");
// const Opaque = @import("../components/Opaque.zig");
//
// // Vapor components
// const Box = Vapor.Box;
// const Stack = Vapor.Stack;
// const Text = Vapor.Text;
// const Button = Vapor.CtxButton;
// const TextField = Vapor.TextField;
// const Icon = Vapor.Icon;
// const Center = Vapor.Center;
// const ButtonCtx = Vapor.CtxButton;
//
// // Opaque UI components
// const Chart = Opaque.Chart;
// const Toast = Opaque.Toast;
// const Field = Opaque.Field;
// const Switch = Opaque.Switch;
//
// // ============================================
// // DATA STRUCTURES
// // ============================================
// const Todo = struct {
//     id: usize,
//     text: []const u8,
//     completed: bool,
// };
//
// const Priority = enum {
//     low,
//     medium,
//     high,
// };
//
// // ============================================
// // STATE
// // ============================================
// var todos: [32]?Todo = [_]?Todo{null} ** 32;
// var todo_count: usize = 0;
// var next_id: usize = 0;
// var new_todo_text: []const u8 = "";
//
// // Stats
// var completed_count: usize = 0;
// var pending_count: usize = 0;
//
// // Chart
// var chart: Chart = undefined;
//
// // ============================================
// // STYLES
// // ============================================
// const card_style = Vapor.Style{
//     .padding = .all(20),
//     .visual = .{
//         .background = .palette(.background),
//         .border = .round(.palette(.border_color_light), .all(12)),
//     },
//     .direction = .column,
//     .child_gap = 12,
// };
//
// const stat_card_style = Vapor.Style{
//     .padding = .all(16),
//     .visual = .{
//         .background = .palette(.background),
//         .border = .round(.palette(.border_color_light), .all(12)),
//     },
//     .size = .{ .width = .percent(30), .height = .px(120) },
//     .direction = .column,
//     .layout = .center,
// };
//
// const todo_item_style = Vapor.Style{
//     .padding = .tblr(12, 12, 16, 16),
//     .visual = .{
//         .border = .round(.palette(.border_color_light), .all(8)),
//     },
//     .layout = .x_between_center,
//     .size = .{ .width = .percent(100) },
// };
//
// const add_button_style = Vapor.Style{
//     .padding = .tblr(12, 12, 20, 20),
//     .visual = .{
//         .background = .palette(.tint),
//         .border_radius = .all(8),
//         .cursor = .pointer,
//     },
//     .layout = .center,
//     .interactive = .hover_scale(),
// };
//
// // ============================================
// // INITIALIZATION
// // ============================================
// pub fn init() void {
//     Opaque.new();
//
//     // Add some sample todos
//     addTodoInternal("Review pull requests");
//     addTodoInternal("Update documentation");
//     addTodoInternal("Fix navigation bug");
//     addTodoInternal("Deploy to production");
//
//     // Mark one as completed for demo
//     if (todos[0]) |*todo| {
//         todo.completed = true;
//         completed_count += 1;
//         pending_count -= 1;
//     }
//
//     // Initialize chart
//     chart = Chart.init(Vapor.arena(.persist), .{
//         .height = 200,
//         .width = 400,
//         .palette = .{ .colors = &.{ "#3b82f6", "#22c55e" } },
//     });
//
//     const tasks_created = [_]Chart.Point{
//         .{ .x = 1, .y = 5 },
//         .{ .x = 2, .y = 8 },
//         .{ .x = 3, .y = 12 },
//         .{ .x = 4, .y = 7 },
//         .{ .x = 5, .y = 15 },
//         .{ .x = 6, .y = 10 },
//         .{ .x = 7, .y = 18 },
//     };
//
//     const tasks_completed = [_]Chart.Point{
//         .{ .x = 1, .y = 3 },
//         .{ .x = 2, .y = 6 },
//         .{ .x = 3, .y = 10 },
//         .{ .x = 4, .y = 5 },
//         .{ .x = 5, .y = 12 },
//         .{ .x = 6, .y = 8 },
//         .{ .x = 7, .y = 14 },
//     };
//
//     chart.addSeries(.bar, "Created", &tasks_created, .{ .color = .palette(.tint) }) catch unreachable;
//     chart.addSeries(.line_smooth, "Completed", &tasks_completed, .{ .color = .hex("#22c55e") }) catch unreachable;
//     chart.xAxis(.{ .label = "Day", .tick_count = 7 });
//     chart.yAxis(.{ .label = "Tasks", .tick_count = 5 });
//     chart.legend(.{ .position = .top_right });
//     chart.build() catch unreachable;
//
//     Vapor.Page(.{ .src = @src() }, render, null);
// }
//
// // ============================================
// // TODO LOGIC
// // ============================================
// fn addTodoInternal(text: []const u8) void {
//     if (todo_count >= 32) return;
//
//     todos[todo_count] = Todo{
//         .id = next_id,
//         .text = text,
//         .completed = false,
//     };
//     todo_count += 1;
//     next_id += 1;
//     pending_count += 1;
// }
//
// fn addTodo() void {
//     if (new_todo_text.len == 0) {
//         Toast.warning(.{ .title = "Empty task", .description = "Please enter a task description" });
//         return;
//     }
//
//     if (todo_count >= 32) {
//         Toast.err(.{ .title = "List full", .description = "Maximum 32 todos allowed" });
//         return;
//     }
//
//     // Copy the text to persistent memory
//     const text_copy = Vapor.arena(.persist).alloc(u8, new_todo_text.len) catch return;
//     @memcpy(text_copy, new_todo_text);
//
//     addTodoInternal(text_copy);
//     new_todo_text = "";
//
//     Toast.success(.{ .title = "Task added", .description = "New task has been created" });
// }
//
// fn toggleTodo(index: usize) void {
//     if (todos[index]) |*todo| {
//         todo.completed = !todo.completed;
//         if (todo.completed) {
//             completed_count += 1;
//             pending_count -= 1;
//         } else {
//             completed_count -= 1;
//             pending_count += 1;
//         }
//     }
// }
//
// fn deleteTodo(index: usize) void {
//     if (todos[index]) |todo| {
//         if (todo.completed) {
//             completed_count -= 1;
//         } else {
//             pending_count -= 1;
//         }
//     }
//
//     // Shift remaining todos
//     var i = index;
//     while (i < todo_count - 1) : (i += 1) {
//         todos[i] = todos[i + 1];
//     }
//     todos[todo_count - 1] = null;
//     todo_count -= 1;
//
//     Toast.info(.{ .title = "Task deleted", .description = "Task has been removed" });
// }
//
// fn getCompletionRate() usize {
//     if (todo_count == 0) return 0;
//     return (completed_count * 100) / todo_count;
// }
//
// // ============================================
// // RENDER FUNCTIONS
// // ============================================
// fn render() void {
//     Box()
//         .width(.percent(100))
//         .height(.percent(100))
//         .padding(.all(32))
//         .background(.palette(.background))
//         .direction(.column)
//         .spacing(24)
//         .children({
//
//         // Header
//         renderHeader();
//
//         // Stats row
//         renderStats();
//
//         // Main content - two columns
//         Box()
//             .width(.percent(100))
//             .spacing(24)
//             .children({
//
//             // Left column - Todo list
//             Box()
//                 .width(.percent(50))
//                 .style(&card_style)({
//                 renderTodoList();
//             });
//
//             // Right column - Chart
//             Box()
//                 .width(.percent(50))
//                 .style(&card_style)({
//                 renderChartSection();
//             });
//         });
//
//         // Toast stack
//         Toast.renderStack();
//     });
// }
//
// fn renderHeader() void {
//     Box()
//         .width(.percent(100))
//         .layout(.x_between_center)
//         .children({
//         Stack().children({
//             Text("Dashboard")
//                 .font(32, 700, .palette(.text_color))
//                 .end();
//             Text("Manage your tasks and track progress")
//                 .font(14, 400, .hex("#6b7280"))
//                 .end();
//         });
//
//         Box()
//             .spacing(12)
//             .children({
//             Button(addSuccessToast, .{})
//                 .padding(.tblr(10, 10, 16, 16))
//                 .border(.round(.palette(.border_color_light), .all(8)))
//                 .cursor(.pointer)
//                 .children({
//                 Icon(.bell)
//                     .font(18, 400, .palette(.text_color))
//                     .end();
//             });
//
//             Button(addSuccessToast, .{})
//                 .padding(.tblr(10, 10, 16, 16))
//                 .border(.round(.palette(.border_color_light), .all(8)))
//                 .cursor(.pointer)
//                 .children({
//                 Icon(.gear)
//                     .font(18, 400, .palette(.text_color))
//                     .end();
//             });
//         });
//     });
// }
//
// fn addSuccessToast() void {
//     Toast.success(.{ .title = "Action", .description = "Button clicked!" });
// }
//
// fn renderStats() void {
//     Box()
//         .width(.percent(100))
//         .layout(.x_between_center)
//         .children({
//
//         // Total tasks
//         Box().style(&stat_card_style)({
//             Icon(.list_task)
//                 .font(28, 400, .palette(.tint))
//                 .end();
//             Text(Vapor.fmtln("{d}", .{todo_count}))
//                 .font(36, 700, .palette(.text_color))
//                 .end();
//             Text("Total Tasks")
//                 .font(14, 400, .hex("#6b7280"))
//                 .end();
//         });
//
//         // Completed
//         Box().style(&stat_card_style)({
//             Icon(.check_circle)
//                 .font(28, 400, .hex("#22c55e"))
//                 .end();
//             Text(Vapor.fmtln("{d}", .{completed_count}))
//                 .font(36, 700, .palette(.text_color))
//                 .end();
//             Text("Completed")
//                 .font(14, 400, .hex("#6b7280"))
//                 .end();
//         });
//
//         // Pending
//         Box().style(&stat_card_style)({
//             Icon(.clock)
//                 .font(28, 400, .hex("#f59e0b"))
//                 .end();
//             Text(Vapor.fmtln("{d}", .{pending_count}))
//                 .font(36, 700, .palette(.text_color))
//                 .end();
//             Text("Pending")
//                 .font(14, 400, .hex("#6b7280"))
//                 .end();
//         });
//     });
// }
//
// fn renderTodoList() void {
//     // Header
//     Box()
//         .width(.percent(100))
//         .layout(.x_between_center)
//         .children({
//         Text("Tasks")
//             .font(20, 600, .palette(.text_color))
//             .end();
//         Text(Vapor.fmtln("{d}% complete", .{getCompletionRate()}))
//             .font(14, 400, .hex("#6b7280"))
//             .end();
//     });
//
//     // Add new todo
//     Box()
//         .width(.percent(100))
//         .spacing(8)
//         .children({
//         Box()
//             .width(.percent(80))
//             .children({
//             Field.render(.{
//                 .label = "New task...",
//                 .value = .{ .string = &new_todo_text },
//             });
//         });
//
//         Button(addTodo, .{})
//             .style(&add_button_style)({
//             Icon(.plus)
//                 .font(18, 600, .white)
//                 .end();
//         });
//     });
//
//     // Todo items
//     Stack()
//         .width(.percent(100))
//         .spacing(8)
//         .children({
//         for (0..todo_count) |i| {
//             if (todos[i]) |todo| {
//                 renderTodoItem(i, &todo);
//             }
//         }
//
//         if (todo_count == 0) {
//             Center()
//                 .height(.px(100))
//                 .children({
//                 Text("No tasks yet. Add one above!")
//                     .font(14, 400, .hex("#9ca3af"))
//                     .end();
//             });
//         }
//     });
// }
//
// fn renderTodoItem(index: usize, todo: *const Todo) void {
//     const text_color: Vapor.Types.Color = if (todo.completed)
//         .hex("#9ca3af")
//     else
//         .palette(.text_color);
//
//     Box().style(&todo_item_style)({
//         Box()
//             .spacing(12)
//             .layout(.left_center)
//             .children({
//
//             // Checkbox
//             ButtonCtx(toggleTodo, .{index})
//                 .width(.px(24))
//                 .height(.px(24))
//                 .border(.round(if (todo.completed) .hex("#22c55e") else .palette(.border_color_light), .all(6)))
//                 .background(if (todo.completed) .hex("#22c55e") else .transparent)
//                 .layout(.center)
//                 .cursor(.pointer)
//                 .children({
//                 if (todo.completed) {
//                     Icon(.check)
//                         .font(14, 600, .white)
//                         .end();
//                 }
//             });
//
//             // Text
//             Text(todo.text)
//                 .font(15, 400, text_color)
//                 .end();
//         });
//
//         // Delete button
//         ButtonCtx(deleteTodo, .{index})
//             .width(.px(32))
//             .height(.px(32))
//             .border(.round(.transparent, .all(6)))
//             .layout(.center)
//             .cursor(.pointer)
//             .hover(.{ .background = .hex("#fee2e2") })
//             .children({
//             Icon(.trash)
//                 .font(16, 400, .hex("#ef4444"))
//                 .end();
//         });
//     });
// }
//
// fn renderChartSection() void {
//     Text("Weekly Progress")
//         .font(20, 600, .palette(.text_color))
//         .end();
//
//     Text("Tasks created vs completed this week")
//         .font(14, 400, .hex("#6b7280"))
//         .end();
//
//     Box()
//         .width(.percent(100))
//         .padding(.t(16))
//         .children({
//         chart.render();
//     });
// }

// const std = @import("std");
// const V = @import("vapor");
//
// const State = struct {
//     board: [9]?bool = .{null} ** 9,
//     is_x: bool = true,
//     over: bool = false,
//     winner: ?bool = null,
//     line: ?[3]usize = null,
// };
//
// var g = State{};
//
// var win_anim: V.Animation = V.Animation.init("win").prop(.scale, 1, 1.05).duration(400).iterations(0).dir(.alternate);
// var place_anim: V.Animation = V.Animation.init("place").prop(.scale, 0.5, 1).prop(.opacity, 0, 1).duration(150);
//
// pub fn init() void {
//     win_anim.build();
//     place_anim.build();
//     V.Page(.{ .src = @src() }, render, null);
// }
//
// fn render() void {
//     V.Center().height(.percent(100)).background(.hex("#ecf0f1")).children({
//         V.Box().direction(.column).layout(.center).spacing(16).children({
//             V.Text("Tic-Tac-Toe").font(42, 700, .hex("#2c3e50")).end();
//
//             // Status Section
//             const msg = if (g.over) (if (g.winner) |x| (if (x) "🎉 X Wins!" else "🎉 O Wins!") else "🤝 Draw!") else (if (g.is_x) "X's Turn" else "O's Turn");
//             V.Text(msg).font(22, 600, .hex(if (g.over and g.winner != null) (if (g.winner.?) "#e74c3c" else "#3498db") else "#7f8c8d")).end();
//
//             // Board
//             V.Box().padding(.all(8)).background(.hex("#34495e")).border(.round(.transparent, .all(12))).children({
//                 V.Box().width(.px(294)).wrap(.wrap).children({
//                     for (0..9) |i| {
//                         const win = if (g.line) |l| (i == l[0] or i == l[1] or i == l[2]) else false;
//                         var cell = V.CtxButton(makeMove, .{i}).size(.square_px(90)).margin(.all(4)).layout(.center).border(.solid(.all(1), .hex("#ecf0f1"), .all(4)))
//                             .background(.hex(if (win) (if (g.winner.?) "#fadbd8" else "#d4e6f1") else if (!g.over and g.board[i] == null) "#ffffff" else "#f5f5f5"));
//
//                         if (win) cell = cell.animation(&win_anim);
//                         cell.children({
//                             if (g.board[i]) |is_x| {
//                                 V.Text(if (is_x) "X" else "O").font(44, 700, .hex(if (is_x) "#e74c3c" else "#3498db")).animationEnter(&place_anim).end();
//                             }
//                         });
//                     }
//                 });
//             });
//
//             V.Button(.{ .on_press = reset }).padding(.tblr(14, 14, 28, 28)).background(.hex("#27ae60")).children({
//                 V.Text("New Game").textColor(.white).end();
//             });
//         });
//     });
// }
//
// fn makeMove(i: usize) void {
//     if (g.over or g.board[i] != null) return;
//     g.board[i] = g.is_x;
//     const wins = [8][3]usize{ .{ 0, 1, 2 }, .{ 3, 4, 5 }, .{ 6, 7, 8 }, .{ 0, 3, 6 }, .{ 1, 4, 7 }, .{ 2, 5, 8 }, .{ 0, 4, 8 }, .{ 2, 4, 6 } };
//     for (wins) |w| {
//         if (g.board[w[0]] != null and g.board[w[0]] == g.board[w[1]] and g.board[w[1]] == g.board[w[2]]) {
//             g.over = true;
//             g.winner = g.board[w[0]];
//             g.line = w;
//             return;
//         }
//     }
//     if (for (g.board) |c| {
//         if (c == null) break false;
//     } else true) {
//         g.over = true;
//         return;
//     }
//     g.is_x = !g.is_x;
// }
//
// fn reset() void {
//     g = State{};
// }
