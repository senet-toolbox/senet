const std = @import("std");
const Fabric = @import("fabric");
const Element = Fabric.Element;
const CodeEditor = @import("CodeEditor.zig");
const println = Fabric.println;

// Reactive Signals for updating state.
const Signal = Fabric.Signal;

// Style
const Style = Fabric.Style;

// Static components never rerender.
const Static = Fabric.Static;

// Animation Components.
const Animation = Fabric.Animation;

// Pure components only rerender when props change.
const Pure = Fabric.Pure;

// Dynamic components depend on signals and props.
const Dynamic = Fabric.Dynamic;

// Colors/Themes/Styling
var styles: Styles = undefined;
var primary: [4]f32 = undefined;
var secondary: [4]f32 = undefined;
var text_color: [4]f32 = undefined;
var border_color: [4]f32 = undefined;

const ViewCode = @This();
allocator: *std.mem.Allocator,
selected_display: *Signal([]const u8) = undefined,
code_editor: CodeEditor = undefined,
height: f32 = 500,

fn switchDisplay(view_code: *ViewCode, selected: []const u8) void {
    view_code.selected_display.set(selected);
}

fn selectedDisplay(view_code: *ViewCode, current_display: []const u8) [4]f32 {
    const value = view_code.selected_display.get();
    if (std.mem.eql(u8, current_display, value)) {
        return text_color;
    }
    return Fabric.hexToRgba("#71717a");
}

pub fn init(view_code: *ViewCode, allocator: *std.mem.Allocator, code: []const u8) void {
    primary = Fabric.Theme.getAttribute("secondary");
    secondary = Fabric.Theme.getAttribute("secondary");
    border_color = Fabric.Theme.getAttribute("border_color");
    text_color = Fabric.Theme.getAttribute("text_color");
    styles = Styles.init();
    view_code.* = .{
        .allocator = allocator,
        .selected_display = Signal([]const u8).init("view", allocator),
    };
    view_code.code_editor.init(allocator, code);
}

pub fn deinit(view_code: *ViewCode) void {
    view_code.selected_display.deinit();
    view_code.code_editor.deinit();
}

// Type-erased wrapper function
pub fn renderWrapper(ptr: *anyopaque) void {
    const self: *ViewCode = @ptrCast(@alignCast(ptr));
    self.render();
}

pub fn render(view_code: *ViewCode, component: *const fn () void) void {
    Static.FlexBox(styles.outer_container)({
        Static.FlexBox(.{
            .width = .percent(1),
            .height = .fixed(40),
            .child_alignment = .{ .x = .start, .y = .center },
            .child_gap = 8,
            .direction = .row,
        })({
            Static.CtxButton(switchDisplay, .{ view_code, "code" }, .{})({
                Pure.Text("code", .{
                    .text_color = view_code.selectedDisplay("code"),
                    .font_size = 16,
                });
            });
            Static.CtxButton(switchDisplay, .{ view_code, "view" }, .{})({
                Pure.Text("view", .{
                    .text_color = view_code.selectedDisplay("view"),
                    .font_size = 16,
                });
            });
        });

        Pure.FlexBox(.{
            .width = .percent(1),
            .box_sizing = .border_box,
            .height = .fixed(view_code.height),
            .border_thickness = .all(1),
            .border_radius = .all(8),
            .border_color = border_color,
        })({
            if (std.mem.eql(u8, view_code.selected_display.get(), "view")) {
                @call(.auto, component, .{});
            } else {
                view_code.code_editor.render(500);
            }
        });
    });
}

const Styles = struct {
    outer_container: Style,
    container: Style,
    view_code_container: Style,
    icon: Style,

    pub fn init() Styles {
        return .{
            .outer_container = Style{
                .display = .flex,
                .child_alignment = .{ .x = .center, .y = .center },
                .child_gap = 12,
                .width = .percent(1),
                .box_sizing = .border_box,
                .direction = .column,
            },
            .container = Style{
                .display = .flex,
                .child_alignment = .{ .x = .start, .y = .start },
                .child_gap = 16,
                .width = .fixed(600),
                .border_color = border_color,
                .border_thickness = .all(1),
                .border_radius = .all(8),
                .padding = .all(10),
                .box_sizing = .border_box,
            },
            .view_code_container = Style{},
            .icon = Style{
                .display = .flex,
                .text_color = secondary,
                .font_size = 16,
                .width = .fixed(20),
                .height = .fixed(20),
                .background = .{ 0, 0, 0, 0 },
            },
        };
    }
};
