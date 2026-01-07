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



// // src/routes/home/Page.zig
// const std = @import("std");
// const Vapor = @import("vapor");
// const Animation = Vapor.Animation;
// const Box = Vapor.Box;
// const Text = Vapor.Text;
// const Button = Vapor.Button;
// const Center = Vapor.Center;
// const ButtonCtx = Vapor.CtxButton;
//
// // ============================================
// // GAME STATE
// // ============================================
// var board: [9]?bool = .{ null, null, null, null, null, null, null, null, null };
// var is_x_turn: bool = true;
// var game_over: bool = false;
// var winner: ?bool = null;
// var winning_line: ?[3]usize = null;
//
// // ============================================
// // ANIMATIONS
// // ============================================
// const win_animation = Animation.init("winPulse")
//     .prop(.scale, 1, 1.05)
//     .duration(400)
//     .easing(.easeInOut)
//     .iterations(0) // infinite
//     .dir(.alternate);
//
// const place_animation = Animation.init("place")
//     .prop(.scale, 0.5, 1)
//     .prop(.opacity, 0, 1)
//     .duration(150)
//     .easing(.easeOutBack)
//     .fill(.forwards);
//
// // ============================================
// // STYLES
// // ============================================
// const title_style = Vapor.Style{
//     .visual = .{
//         .font_size = 42,
//         .font_weight = 700,
//         .text_color = .hex("#2c3e50"),
//     },
//     .margin = .b(10),
// };
//
// const board_container_style = Vapor.Style{
//     .visual = .{
//         .background = .hex("#34495e"),
//         .border = .solid(.all(4), .hex("#2c3e50"), .all(12)),
//         .shadow = .card(.hex("#00000033")),
//     },
//     .padding = .all(8),
// };
//
// const cell_base = Vapor.Style{
//     .size = .square_px(90),
//     .margin = .all(4),
//     .visual = .{
//         .border = .solid(.all(1), .hex("#ecf0f1"), .all(4)),
//     },
//     .layout = .center,
//     .transition = .{ .duration = 100 },
// };
//
// const reset_button_style = Vapor.Style{
//     .padding = .tblr(14, 14, 28, 28),
//     .visual = .{
//         .background = .hex("#27ae60"),
//         .font_size = 16,
//         .font_weight = 600,
//         .text_color = .white,
//         .border_radius = .all(8),
//     },
//     .interactive = .hover_scale(),
//     .margin = .t(20),
// };
//
// // ============================================
// // INITIALIZATION
// // ============================================
// pub fn init() void {
//     win_animation.build();
//     place_animation.build();
//     Vapor.Page(.{ .src = @src() }, render, null);
// }
//
// // ============================================
// // RENDER FUNCTIONS
// // ============================================
// fn render() void {
//     Center()
//         .height(.percent(100))
//         .background(.hex("#ecf0f1"))
//         .children({
//             Box()
//                 .direction(.column)
//                 .layout(.center)
//                 .spacing(16)
//                 .children({
//                     // Title
//                     Text("Tic-Tac-Toe")
//                         .style(&title_style);
//
//                     // Status
//                     renderStatus();
//
//                     // Board
//                     Box()
//                         .style(&board_container_style)({
//                             renderBoard();
//                     });
//
//                     // Reset Button
//                     Button(.{ .on_press = resetGame })
//                         .style(&reset_button_style)({
//                             Text("New Game").end();
//                     });
//             });
//     });
// }
//
// fn renderStatus() void {
//     const message: []const u8 = if (game_over)
//         if (winner) |is_x|
//             if (is_x) "🎉 X Wins!" else "🎉 O Wins!"
//         else
//             "🤝 It's a Draw!"
//     else if (is_x_turn)
//         "X's Turn"
//     else
//         "O's Turn";
//
//     const color: Vapor.Types.Color = if (game_over and winner != null)
//         if (winner.?) .hex("#e74c3c") else .hex("#3498db")
//     else
//         .hex("#7f8c8d");
//
//     Text(message)
//         .font(22, 600, color)
//         .margin(.b(8))
//         .end();
// }
//
// fn renderBoard() void {
//     Box()
//         .width(.px(306))
//         .wrap(.wrap)
//         .children({
//             for (0..9) |i| {
//                 renderCell(i);
//             }
//     });
// }
//
// fn renderCell(index: usize) void {
//     const cell_value = board[index];
//     const is_clickable = !game_over and cell_value == null;
//     const is_winning = isWinningCell(index);
//
//     // Dynamic background color
//     const bg_color: Vapor.Types.Background = if (is_winning)
//         if (winner.?) .hex("#fadbd8") else .hex("#d4e6f1")
//     else if (is_clickable)
//         .hex("#ffffff")
//     else
//         .hex("#f5f5f5");
//
//     var cell = ButtonCtx(makeMove, .{index})
//         .baseStyle(&cell_base)
//         .background(bg_color);
//
//     if (is_clickable) {
//         cell = cell.hoverBackground(.hex("#e8e8e8")).cursor(.pointer);
//     }
//
//     if (is_winning) {
//         cell = cell.animation(&win_animation);
//     }
//
//     cell.children({
//         if (cell_value) |is_x| {
//             Text(if (is_x) "X" else "O")
//                 .font(44, 700, if (is_x) .hex("#e74c3c") else .hex("#3498db"))
//                 .animationEnter(&place_animation)
//                 .end();
//         }
//     });
// }
//
// // ============================================
// // GAME LOGIC
// // ============================================
// fn makeMove(index: usize) void {
//     if (game_over) return;
//     if (board[index] != null) return;
//
//     board[index] = is_x_turn;
//
//     if (checkWinner()) |result| {
//         game_over = true;
//         winner = result.winner;
//         winning_line = result.line;
//         return;
//     }
//
//     if (isBoardFull()) {
//         game_over = true;
//         winner = null;
//         return;
//     }
//
//     is_x_turn = !is_x_turn;
// }
//
// const WinResult = struct {
//     winner: bool,
//     line: [3]usize,
// };
//
// fn checkWinner() ?WinResult {
//     const patterns = [_][3]usize{
//         .{ 0, 1, 2 }, .{ 3, 4, 5 }, .{ 6, 7, 8 }, // Rows
//         .{ 0, 3, 6 }, .{ 1, 4, 7 }, .{ 2, 5, 8 }, // Columns
//         .{ 0, 4, 8 }, .{ 2, 4, 6 },               // Diagonals
//     };
//
//     for (patterns) |pattern| {
//         const a = board[pattern[0]];
//         const b = board[pattern[1]];
//         const c = board[pattern[2]];
//
//         if (a != null and a == b and b == c) {
//             return WinResult{
//                 .winner = a.?,
//                 .line = pattern,
//             };
//         }
//     }
//     return null;
// }
//
// fn isBoardFull() bool {
//     for (board) |cell| {
//         if (cell == null) return false;
//     }
//     return true;
// }
//
// fn isWinningCell(index: usize) bool {
//     if (winning_line) |line| {
//         return index == line[0] or index == line[1] or index == line[2];
//     }
//     return false;
// }
//
// fn resetGame() void {
//     board = .{ null, null, null, null, null, null, null, null, null };
//     is_x_turn = true;
//     game_over = false;
//     winner = null;
//     winning_line = null;
// }
//

const std = @import("std");
const Vapor = @import("vapor");

// State: Lives outside the render function to persist between cycles
var tasks : Vapor.Array([]const u8) = undefined;
var current_input: []const u8 = "";

pub fn init() void {
    tasks = Vapor.array([]const u8, .persist);
    Vapor.Page(.{ .src = @src() }, render, null);
}

// Logic: Modifies the state directly
fn addTask() void {
    if (current_input.len > 0) {
        // dupe the string into persistent memory so it doesn't vanish
        const task_copy = Vapor.arena(.persist).dupe(u8, current_input) catch return;
        tasks.append(task_copy) catch return;
        current_input = ""; // Clear the input field
    }
}

fn removeTask(index: usize) void {
    _ = tasks.orderedRemove(index);
}

pub fn render() void {
    Vapor.Box().layout(.center).padding(.all(40)).spacing(20).children({
        Vapor.Text("Vapor Todo List").font(32, 700, .black).end();

        // Input Area
        Vapor.Box().direction(.row).spacing(10).children({
            Vapor.TextField(.string)
                .bind(&current_input) // Two-way binding
                .placeholder("What needs to be done?")
                .width(.px(300))
                .end();

            Vapor.Button(.{ .on_press = addTask }).children({
                Vapor.Text("Add Task").end();
            });
        });

        // Tasks List
        Vapor.List().direction(.column).spacing(10).children({
            for (tasks.items, 0..) |task, i| {
                Vapor.ListItem().direction(.row).spacing(15).children({
                    Vapor.Text(task).fontSize(18).end();
                    
                    // ButtonCtx allows passing arguments (the index) to the handler
                    Vapor.CtxButton(removeTask, .{i}).children({
                        Vapor.Text("Delete").font(16, null, .hex("#ff0000")).end();
                    });
                });
            }
        });
    });
}
