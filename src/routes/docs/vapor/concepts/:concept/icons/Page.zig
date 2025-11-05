const std = @import("std");
const Fabric = @import("vapor");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;

// Initialization
pub fn init() void {
    Page(@src(), render, null, .{});
}

// Deinitialization
pub fn deinit() void {}

// Render
pub fn render() void {}

