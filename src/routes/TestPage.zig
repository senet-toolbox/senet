const std = @import("std");
const Vapor = @import("vapor");

// Shorten common imports
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.CtxButton; // Use Context buttons to pass arguments
const TextField = Vapor.TextField;

// --- 1. DATA MODELS ---
// Just a simple Zig struct. Not a UI component.
const Todo = struct { id: u32, text: []const u8, completed: bool };

const Mode = enum { add, edit };

var mode: Mode = .add;

// --- 2. GLOBAL STATE ---
// In Vapor, we often keep state global or in a top-level struct.
// We assume an allocator is available (using page_allocator for demo simplicity).
var todos: Vapor.Array(Todo) = undefined;
var current_input: []const u8 = ""; // Bound to TextField
var selected_item: ?*Todo = null;
var next_id: u32 = 0;

// --- 3. INIT ---
pub fn init() void {
    // Initialize the list
    todos = Vapor.array(Todo, .persist);

    todos.append(Todo{ .id = 0, .text = "Hello", .completed = false }) catch unreachable;
    next_id += 1;

    // Initialize Vapor
    Vapor.Page(.{ .route = "/" }, TodoApp, null);
}

// --- 4. LOGIC / ACTIONS ---
// These functions mutate the global state.
// Vapor's Atomic Mode detects these changes automatically after events.

fn addTodo() void {
    if (current_input.len == 0) {
        Vapor.alert("Please enter a todo", .{});
        return;
    }

    // In a real app, you'd duplicate the string memory here.
    // For this demo, we assume the binding handles the lifetime or we trust the flow.
    const new_todo = Todo{
        .id = next_id,
        .text = Vapor.arena(.scratch).dupe(u8, current_input) catch unreachable,
        .completed = false,
    };

    next_id += 1;
    todos.append(new_todo) catch return;

    // Reset input
    current_input = "";
}

fn submitEdit() void {
    if (selected_item) |item| {
        item.text = current_input;
    }

    // Reset input
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
            const todo = todos.orderedRemove(i);
            Vapor.arena(.scratch).free(todo.text);
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
    const text_color = if (item.completed) Vapor.Types.Color.black else Vapor.Types.Color.black;

    Box()
        .border(.simple(.black))
        .direction(.row).spacing(12).padding(.tblr(4, 4, 8, 4)).layout(.left_center).children({
        ButtonCtx(toggleTodo, .{item.id})
            .border(.simple(if (item.completed) .vapor_blue else .black))
            .width(.px(24)).height(.px(24))
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

// --- 6. MAIN PAGE ---
fn TodoApp() void {
    // Main Container
    Vapor.Stack().layout(.top_center).padding(.all(40)).spacing(20).children({

        // Header
        Text("Vapor Todo").font(32, 800, .black).end();
        Text("Global Components & Atomic State").font(14, 400, .black).end();

        // Input Area
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

        // List Area
        // We iterate over the data, calling our functional component for each.
        Vapor.Stack().width(.px(400)).spacing(8).children({
            for (todos.items) |*item| {
                TodoRow(item);
            }
        });
    });
}
