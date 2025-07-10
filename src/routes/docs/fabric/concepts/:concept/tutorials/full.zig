const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Signal = Fabric.Signal;

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
