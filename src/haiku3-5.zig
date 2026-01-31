const std = @import("std");
const Vapor = @import("vapor");

const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.ButtonCtx;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;

const Item = struct {
    text: []const u8,
    done: bool = false,
};

// ─────────────────────────────
// State (OUTSIDE render)
// ─────────────────────────────

var input: []const u8 = "";
var items: Vapor.Array(Item) = undefined;

// ─────────────────────────────
// Init
// ─────────────────────────────

pub fn init() void {
    items = Vapor.array(Item, .persist);
    Vapor.Page(.{ .src = @src() }, render, null);
}

// ─────────────────────────────
// Actions
// ─────────────────────────────

fn addItem() void {
    if (input.len == 0) return;

    // const copy = Vapor.arena(.persist).dupe(u8, input) catch return;
    items.append(.{ .text = input }) catch return;

    input = "";
}

fn deleteItem(index: usize) void {
    _ = items.orderedRemove(index);
}

fn toggleItem(index: usize) void {
    items.items[index].done = !items.items[index].done;
}

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        addItem();
    }
}

// ─────────────────────────────
// Render
// ─────────────────────────────

fn render() void {
    Center().children({
        Box()
            .width(.px(420))
            .padding(.all(24))
            .spacing(16)
            .direction(.column)
            .border(.round(.hex("#e5e7eb"), .all(12)))
            .background(.white)
            .children({

            // Title
            Text("Todo List")
                .font(20, 700, .hex("#111827"))
                .end();

            // Input row
            Box()
                .direction(.row)
                .spacing(8)
                .children({
                TextField(.string)
                    .bind(&input)
                    .onEvent(.keydown, handleKeyDown)
                    .end();

                Button(addItem)
                    .hoverScale()
                    .cursor(.pointer)
                    .children({
                    Text("Add")
                        .font(14, 600, .hex("#2563eb"))
                        .end();
                });
            });

            // Todo items
            Box()
                .direction(.column)
                .spacing(8)
                .children({
                for (items.items, 0..) |item, i| {
                    Box()
                        .direction(.row)
                        .spacing(8)
                        .padding(.all(8))
                        .border(.round(.hex("#e5e7eb"), .all(8)))
                        .children({

                        // Toggle
                        ButtonCtx(toggleItem, .{i})
                            .cursor(.pointer)
                            .children({
                            Text(if (item.done) "☑" else "☐")
                                .font(14, 600, .hex("#111827"))
                                .end();
                        });

                        // Text
                        Text(item.text)
                            .font(14, 400, .hex("#111827"))
                            .textDecoration(if (item.done) .line_through else .none)
                            .end();

                        // Spacer
                        Box().width(.grow).children({});

                        // Delete
                        ButtonCtx(deleteItem, .{i})
                            .cursor(.pointer)
                            .children({
                            Text("✕")
                                .font(14, 600, .hex("#ef4444"))
                                .end();
                        });
                    });
                }
            });
        });
    });
}

