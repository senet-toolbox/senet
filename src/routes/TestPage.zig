// const std = @import("std");
// const Vapor = @import("vapor");
// const Style = Vapor.Style;
// const Static = Vapor.Static;
// const Pure = Vapor.Pure;
// const Box = Static.Box;
// const Button = Static.Button;
// const TextFmt = Static.TextFmt;
// const Page = Vapor.Page;
//
// const Item = struct { id: []const u8, value: usize };
// var buffer: [1000]Item = undefined;
// var list: std.array_list.Managed(Item) = undefined;
//
// pub fn init() void {
//     // 1. Initialize the parser
//     // const allocator = Vapor.lib.frame_arena.getFrameAllocator();
//     // var parser = Mark.Parser.init(allocator, @embedFile("test.md"));
//
//     // 2. Run the parser
//     // root_node = parser.parse() catch unreachable;
//
//     // text.init("isFocused");
//     list = std.array_list.Managed(Item).init(Vapor.lib.allocator_global);
//     for (0..buffer.len) |i| {
//         buffer[i] = .{ .value = i, .id = std.fmt.allocPrint(Vapor.lib.allocator_global, "{d}", .{i}) catch unreachable };
//     }
//     list.appendSlice(&buffer) catch |err| Vapor.lib.printlnErr("Error appending {any}", .{err});
//     Page(.{ .src = @src() }, render, null);
// }
//
// fn remove() void {
//     if (list.items.len == 0) return;
//     const item = list.orderedRemove(0);
//     Vapor.println("Removed {s}", .{item.id});
//     Vapor.cycle();
// }
//
// pub fn render() void {
//     // Box().style(&.{
//     //     .child_gap = 8,
//     //     .direction = .column,
//     //     .margin = .{ .bottom = 32 },
//     //     .size = .w(.percent(100)),
//     // })({
//     // Vapor.Text("Hello").end();
//     // Button(.{ .on_press = remove })
//     //     .size(.{ .width = .fit, .height = .fit })
//     //     .background(.transparent)
//     //     .cursor(.pointer)
//     //     .border(.simple(.palette(.border_color_light)))
//     //     .children({
//     //     TextFmt("Remove first Item", .{}).font(18, 500, .palette(.text_color)).layout(.center).done();
//     // });
//     // // Box().layout(.flex)
//     // // .wrap(.wrap)
//     // // .children({
//     Vapor.List().direction(.column).layout(.{}).pos(.{}).children({
//         for (list.items) |i| {
//             TextFmt("{d},", .{i.value}).plain();
//         }
//     });
//     // });
//     // });
// }

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
const Todo = struct {
    id: u32,
    text: []const u8,
    completed: bool,
};

// --- 2. GLOBAL STATE ---
// In Vapor, we often keep state global or in a top-level struct.
// We assume an allocator is available (using page_allocator for demo simplicity).
var todos: Vapor.Array(Todo) = undefined;
var current_input: []const u8 = ""; // Bound to TextField
var next_id: u32 = 0;

// --- 3. INIT ---
pub fn init() void {
    // Initialize the list
    todos = Vapor.array(Todo, .persist);

    // Initialize Vapor
    Vapor.Page(.{ .route = "/" }, Home, null);
}

// --- 4. LOGIC / ACTIONS ---
// These functions mutate the global state.
// Vapor's Atomic Mode detects these changes automatically after events.

fn addTodo() void {
    if (current_input.len == 0) return;

    // In a real app, you'd duplicate the string memory here.
    // For this demo, we assume the binding handles the lifetime or we trust the flow.
    const new_todo = Todo{
        .id = next_id,
        .text = current_input, // In prod: allocator.dupe(u8, current_input) catch return
        .completed = false,
    };

    next_id += 1;
    todos.append(new_todo) catch return;

    // Reset input
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

fn editTodo(item: Todo) void {
    current_input = item.text;
}

// --- 5. GLOBAL COMPONENTS (The Builder Pattern) ---

// This is the "Calendar" concept you mentioned.
// It's just a function that takes DATA and styles it.
// It is NOT a class instance.
fn TodoRow(item: Todo) void {
    // Dynamic styling based on data
    const text_color = if (item.completed) Vapor.Types.Color.black else Vapor.Types.Color.black;

    // Layout: Row
    Box().direction(.row).spacing(12).padding(.all(8)).layout(.left_center).children({

        // 1. Toggle Button (Checkbox-ish)
        ButtonCtx(toggleTodo, .{item.id})
            .border(.simple(if (item.completed) .green else .black))
            .width(.px(24)).height(.px(24))
            .layout(.center)
            .children({
            if (item.completed) {
                Text("✓").font(16, 700, .green).end();
            }
        });

        // 2. The Task Text
        Text(item.text)
            .font(18, 400, text_color)
            .end();

        // 3. Delete Button
        ButtonCtx(removeTodo, .{item.id})
            .background(.red)
            .padding(.all(6))
            .children({
            Text("Delete").font(14, 700, .white).end();
        });

        ButtonCtx(editTodo, .{item})
            .background(.vapor_blue)
            .padding(.all(6))
            .children({
            Text("edit").font(14, 700, .white).end();
        });
    });
}

fn updateText(evt: *Vapor.Event) void {
    current_input = evt.text();
}

// --- 6. MAIN PAGE ---
fn Home() void {
    // Main Container
    Vapor.Stack().layout(.top_center).padding(.all(40)).spacing(20).children({

        // Header
        Text("Vapor Todo").font(32, 800, .black).end();
        Text("Global Components & Atomic State").font(14, 400, .black).end();

        // Input Area
        Box().direction(.row).spacing(10).children({
            TextField(.string)
                .bind(&current_input)
                .placeholder("What needs to be done?")
                .width(.px(300))
                .padding(.all(12))
                .border(.simple(.black))
                .end();

            TextField(.int)
                // .bind(&current_input)
                .placeholder(32)
                .width(.px(300))
                .padding(.all(12))
                .border(.simple(.black))
                .end();

            Button(.{ .on_press = addTodo })
                .background(.black)
                .padding(.horizontal(20))
                .layout(.center)
                .children({
                Text("Add").font(16, 700, .white).end();
            });
        });

        // List Area
        // We iterate over the data, calling our functional component for each.
        Vapor.Stack().width(.px(400)).spacing(8).children({
            for (todos.items) |item| {
                TodoRow(item);
            }
        });
    });
}
