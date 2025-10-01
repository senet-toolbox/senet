const std = @import("std");
const Fabric = @import("fabric");
const Kit = Fabric.Kit;
const Element = Fabric.Element;
const Overlay = @import("Overlay.zig");
const println = Fabric.println;

// Reactive Signals for updating state.
const Signal = Fabric.Signal;

// Static components never rerender.
const Static = Fabric.Static;

// Static components never rerender.
const Binded = Fabric.Binded;

// Pure components only rerender when props change.
const Pure = Fabric.Pure;

// Dynamic components depend on signals and props.
const Dynamic = Fabric.Dynamic;

// Internal Util structs
const DateTime = Fabric.DateTime;
const Animation = Fabric.Animation;
const Style = Fabric.Style;

// Colors/Themes/Styling
var primary: [4]f32 = undefined;
var secondary: [4]f32 = undefined;
var btn_color: [4]f32 = undefined;
var border_color: [4]f32 = undefined;
var text_color: [4]f32 = undefined;

// Animations
var entry_anim: Animation.Specs = undefined;
var exit_anim: Animation.Specs = undefined;

const JsonEditor = @This();
overlay: Overlay = undefined,
text_area: Element = undefined,
overlay_element: Element = undefined,
input_callback: ?*const fn (*JsonEditor, []const u8) void = null,
_rerender: Signal(void) = undefined,
_text: []const u8 = "",

pub fn init(jse: *JsonEditor, default_text: ?[]const u8) void {
    jse.* = .{};
    jse.text_area = Element{};
    jse.overlay_element = Element{};
    if (default_text) |dt| {
        jse._text = dt;
    }
    jse._rerender.init({});
    _ = jse.overlay.init(&Fabric.lib.allocator_global, jse._text);
}

fn rerenderText(jse: *JsonEditor, _: *Fabric.Event) void {
    const json = jse.text_area.getInputValue() orelse "";
    jse.overlay.reinit(json) catch return;
    jse._text = json;
    jse._rerender.force();
    if (jse.input_callback) |cb| {
        cb(jse, json);
    }
}

fn autoScroll(jse: *JsonEditor, _: *Fabric.Event) void {
    if (Kit.throttle()) return;
    const scrollTop = jse.text_area.getAttributeNumber("scrollTop");
    jse.overlay_element.scrollTop(scrollTop);
}

fn get(jse: *JsonEditor) []const u8 {
    return jse._text;
}

pub fn reinit(jse: *JsonEditor, text: []const u8) void {
    jse.overlay.reinit(text) catch return;
    jse._text = text;
    jse._rerender.force();
    if (jse.input_callback) |cb| {
        cb(jse, text);
    }
}

fn mount(jse: *JsonEditor) void {
    _ = jse.text_area.addInstListener(.input, jse, rerenderText);
    _ = jse.text_area.addInstListener(.scroll, jse, autoScroll);
}

pub fn render(jse: *JsonEditor) void {
    Static.FlexBox(.{
        .width = .percent(100),
        .position = .{ .type = .relative },
        .direction = .column,
        .child_gap = 60,
    })({
        Static.Block(.{
            .position = .{ .type = .absolute, .top = .px(0) },
            .width = .percent(100),
            .height = .px(360),
            .margin = .all(12),
            // .background = .hex("#121212"),
            // .border_radius = .all(10),
            .border_color = .rgb(0, 0, 0),
            .border_thickness = .all(1),
        })({
            jse.overlay.render(0);
        });
        Static.CtxHooks(.mounted, mount, .{jse}, .{
            .position = .{ .type = .relative, .top = .px(0) },
            .width = .percent(100),
            // .height = .px(360),
            .height = .percent(100),
            .direction = .column,
            .margin = .all(12),
            .z_index = 1000,
        })({
            Static.Box(.{
                .width = .percent(100),
            })({
                Static.Block(.{ .height = .px(360), .width = .px(24) })({});
                Binded.JsonEditor(&jse.text_area, jse._text, .{
                    .width = .percent(100),
                    .height = .px(360),
                    .direction = .column,
                    .child_alignment = .{ .x = .start, .y = .center },
                    .text_color = .rgba(0, 0, 0, 0),
                    .outline = .none,
                    .padding = .all(12),
                    .font_size = 14,
                    .background = .rgba(0, 0, 0, 0),
                    .font_family = "JetBrains Mono,Fira Code,Consolas,monospace",
                    .border_thickness = .all(1),
                    .border_color = .rgb(0, 0, 0),
                });
            });
        });
    });
}
