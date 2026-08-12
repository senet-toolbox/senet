const std    = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Grid   = @import("../../components/Grid.zig");

pub fn init() void {
    Fabric.Page(@src(), render, null, .{});
    Grid.init(); // 👈 🚧 Ensure component state is initialised once 🚧
}

pub fn render() void {
    Static.Center(.{
        .direction = .column,
        .width     = .percent(100),
        .height    = .percent(100),
        .child_gap             = 20,
    })({
        Static.Text("Tic‑Tac‑Toe!", .{});
        // Constrain the board to 30 % of the viewport for now.
        Static.Row(.{
            .width  = .percent(30),
            .height = .percent(30),
        })({
            Grid.render(); // 👈 🚧 Draw the board 🚧
        });
    });
}
