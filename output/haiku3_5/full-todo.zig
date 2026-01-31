const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const TextField = Vapor.TextField;
const ButtonCtx = Vapor.ButtonCtx;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const TextFmt = Vapor.TextFmt;

// ============================================
// DATA STRUCTURES
// ============================================
const TodoItem = struct {
    text: []const u8,
    completed: bool = false,
};

// ============================================
// STATE (outside render!)
// ============================================
var todos: Vapor.Array(TodoItem) = undefined;
var input_text: []const u8 = "";

// ============================================
// STYLES
// ============================================
const container_style = Vapor.Style{
    .size = .{ .width = .px(400) },
    .padding = .all(24),
    .visual = .{
        .background = .white,
        .border = .round(.hex("#e2e8f0"), .all(12)),
        .shadow = .card(.hex("#00000011")),
    },
};

const todo_item_style = Vapor.Style{
    .layout = .x_between_center,
    .padding = .tblr(12, 12, 16, 16),
    .margin = .b(8),
    .visual = .{
        .background = .hex("#f7fafc"),
        .border = .round(.hex("#e2e8f0"), .all(8)),
    },
};

const add_btn_style = Vapor.Style{
    .padding = .tblr(10, 10, 16, 16),
    .visual = .{
        .background = .hex("#4299e1"),
        .text_color = .white,
        .font_weight = 600,
        .border = .round(.transparent, .all(8)),
    },
    .interactive = .hover_scale(),
};

const delete_btn_style = Vapor.Style{
    .padding = .tblr(6, 6, 12, 12),
    .visual = .{
        .background = .transparent,
        .text_color = .hex("#e53e3e"),
        .font_size = 14,
    },
    .interactive = .hover_scale(),
};

// ============================================
// INITIALIZATION
// ============================================
pub fn init() void {
    todos = Vapor.array(TodoItem, .persist);
    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================
// ACTIONS
// ============================================
fn addTodo() void {
    if (input_text.len == 0) return;

    // CRITICAL: Copy text to persistent memory!
    const text_copy = Vapor.arena(.persist).dupe(u8, input_text) catch return;

    todos.append(.{
        .text = text_copy,
        .completed = false,
    }) catch return;

    input_text = "";
}

fn toggleTodo(index: usize) void {
    if (index >= todos.items.len) return;
    todos.items[index].completed = !todos.items[index].completed;
}

fn deleteTodo(index: usize) void {
    if (index >= todos.items.len) return;
    _ = todos.orderedRemove(index);
}

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        addTodo();
    }
}

// ============================================
// RENDER
// ============================================
fn render() void {
    Center().height(.percent(100)).background(.hex("#edf2f7")).children({
        Box().style(&container_style)({
            // Header
            Text("Todo List")
                .font(28, 700, .hex("#2d3748"))
                .margin(.b(20))
                .end();

            // Input row
            Box().layout(.left_center).spacing(8).margin(.b(16)).children({
                TextField(.string)
                    .bind(&input_text)
                    .placeholder("Enter a new todo")
                    .width(.grow)
                    .padding(.all(12))
                    .border(.round(.hex("#e2e8f0"), .all(8)))
                    .onEvent(.keydown, handleKeyDown)
                    .end();

                Button(addTodo).style(&add_btn_style)({
                    Text("Add").end();
                });
            });

            // Todo list
            Stack().spacing(0).children({
                if (todos.items.len == 0) {
                    Text("No todos yet!")
                        .font(14, 400, .hex("#a0aec0"))
                        .padding(.all(20))
                        .end();
                } else {
                    for (todos.items, 0..) |todo, i| {
                        renderTodoItem(todo, i);
                    }
                }
            });

            // Footer
            if (todos.items.len > 0) {
                TextFmt("{d} item{s}", .{
                    todos.items.len,
                    if (todos.items.len == 1) "" else "s",
                })
                    .font(12, 400, .hex("#a0aec0"))
                    .margin(.t(16))
                    .end();
            }
        });
    });
}

fn renderTodoItem(todo: TodoItem, index: usize) void {
    Box().style(&todo_item_style)({
        // Left side: checkbox + text
        Box().layout(.left_center).children({
            // Checkbox/Toggle
            ButtonCtx(toggleTodo, .{index})
                .width(.px(24))
                .height(.px(24))
                .layout(.center)
                .border(.round(.hex("#cbd5e0"), .all(4)))
                .margin(.r(12))
                .background(if (todo.completed) .hex("#48bb78") else .white)
                .hoverScale()
                .children({
                    if (todo.completed) {
                        Text("✓").font(14, 700, .white).end();
                    }
                });

            // Todo text
            Text(todo.text)
                .font(16, if (todo.completed) 400 else 500,
                    if (todo.completed) .hex("#a0aec0") else .hex("#2d3748"))
                .textDecoration(if (todo.completed) .line_through else .none)
                .end();
        });

        // Delete button
        ButtonCtx(deleteTodo, .{index}).style(&delete_btn_style)({
            Text("Delete").end();
        });
    });
}
