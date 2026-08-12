const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;

const GridRow = struct {
    clicked: bool = false, // Will track whether this cell has been played
};

var grid_boxes: [9]GridRow = undefined;

/// Initialise component‑level state (called once from the page).
pub fn init() void {
    for (0..9) |i| {
        grid_boxes[i] = GridRow{}; // all cells start unclicked
    }
}

/// Render a 3×3 flex grid that currently shows each cell index.
pub fn render() void {
    Static.FlexRow(.{
        .width = .percent(100),
        .height = .percent(100),
        .flex_wrap = .wrap,
    })({
        for (grid_boxes, 0..) |_, i| {
            Static.FlexRow(.{
                .border_color = .hex("#CCCCCC"),
                .border_thickness = .all(1),
                .width = .percent(33),
                .height = .percent(33),
            })({
                // Placeholder content; will later become “X” / “O” marks.
                Pure.AllocText("{d}", .{i}, .{});
            });
        }
    });
}
