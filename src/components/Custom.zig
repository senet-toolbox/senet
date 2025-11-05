const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Style = Vapor.Style;
const CtxButton = Static.CtxButton;
const Text = Static.Text;
const Icon = Static.Icon;
const Box = Static.Box;

const HtmlOptions = struct {
    text: []const u8,
    style: ?*const Style = null,
};

pub const Chain = struct {
    const Self = @This();
    text: []const u8 = "",
    elem_type: Vapor.ElementType,
    pub fn HtmlText(text: []const u8) Self {
        return Self{
            .elem_type = .HtmlText,
            .text = if (Vapor.lib.isGenerated) "" else text,
            // .text = text,
        };
    }
    pub inline fn style(self: *const Self, style_ptr: *const Vapor.Style) void {
        const elem_decl = Vapor.ElementDecl{
            .state_type = .static,
            .elem_type = self.elem_type,
            .text = self.text,
            .style = style_ptr,
        };

        _ = Vapor.LifeCycle.open(elem_decl);
        Vapor.LifeCycle.configure(elem_decl);
        Vapor.LifeCycle.close({});
    }
};

pub inline fn GradientText(text: []const u8, style: Style) void {
    const elem_decl = Vapor.ElementDecl{
        .state_type = .static,
        .elem_type = .TextGradient,
        .text = text,
        .style = style,
    };
    _ = Vapor.LifeCycle.open(elem_decl);
    Vapor.LifeCycle.configure(elem_decl);
    Vapor.LifeCycle.close({});
}

pub inline fn Gradient(style: Style) fn (void) void {
    const elem_decl = Vapor.ElementDecl{
        .state_type = .static,
        .elem_type = .Gradient,
        .style = style,
    };
    _ = Vapor.LifeCycle.open(elem_decl);
    Vapor.LifeCycle.configure(elem_decl);
    return Vapor.LifeCycle.close;
}

pub inline fn PreImage(link: []const u8, style: Style) void {
    const elem_decl = Vapor.ElementDecl{
        .href = link,
        .elem_type = .PreImage,
        .style = style,
    };
    _ = Vapor.LifeCycle.open(elem_decl);
    Vapor.LifeCycle.configure(elem_decl);
    Vapor.LifeCycle.close({});
}

pub inline fn LazyImage(link: []const u8, style: Style) void {
    const elem_decl = Vapor.ElementDecl{
        .href = link,
        .elem_type = .LazyImage,
        .style = style,
    };
    _ = Vapor.LifeCycle.open(elem_decl);
    Vapor.LifeCycle.configure(elem_decl);
    Vapor.LifeCycle.close({});
}

pub inline fn Virtualize(style: *const Style) fn (void) void {
    const elem_decl = Vapor.ElementDecl{
        .elem_type = .Virtualize,
        .style = style,
    };
    _ = Vapor.LifeCycle.open(elem_decl);
    Vapor.LifeCycle.configure(elem_decl);
    return Vapor.LifeCycle.close;
}

pub inline fn Intersection(style: *const Style) fn (void) void {
    const elem_decl = Vapor.ElementDecl{
        .elem_type = .Intersection,
        .style = style,
    };
    _ = Vapor.LifeCycle.open(elem_decl);
    Vapor.LifeCycle.configure(elem_decl);
    return Vapor.LifeCycle.close;
}

var copied: bool = false;
var copied_text: []const u8 = "";
fn copy(text: []const u8) void {
    Vapor.Clipboard.copy(text);
    copied = true;
    copied_text = text;
    Vapor.println("Hello", .{});
    Vapor.cycle();
    Vapor.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = false;
    copied_text = "";
    Vapor.cycle();
}

pub fn code_snippet_single(text: []const u8) void {
    CtxButton(copy, .{text})
        // .tooltip(&.{
        //     .text = "Copy",
        //     .position = .right,
        //     .layout = .center,
        //     .color = .palette(.background),
        //     .background = .palette(.text_color),
        //     .border = .solid(.all(0), .palette(.text_color), .all(4)),
        // })
        .style(&.{
        .visual = .{
            .border = .simple(.palette(.border_color_light)),
            .text_color = .palette(.text_color),
            .cursor = .pointer,
            .background = .transparent,
        },
        .padding = .all(8),
        .size = .square_percent(100),
        .direction = .column,
        .layout = .flex,
        .interactive = .{
            .hover = .{ .text_color = .palette(.tint), .border = .{ .color = .palette(.tint) } },
        },
        .position = .relative,
    })({
        Box.style(&.{
            .position = .{ .type = .absolute, .right = .px(8), .top = .px(8) },
            .size = .square_px(22),
            .transition = .{ .duration = 100 },
            .visual = .{
                .border_radius = .all(4),
                .background = .transparent,
                .cursor = .pointer,
            },
            .layout = .center,
        })({
            if (copied and std.mem.eql(u8, text, copied_text)) {
                Icon(.check).style(&.{
                    .visual = .{ .font_size = 18 },
                });
            } else {
                Icon(.clipboard).style(&.{
                    .visual = .{ .font_size = 18 }, // we need to fix this to make sure it does not repalce the class of the text below
                    // setting it to 16 results in the Text below being overwritten
                });
            }
        });
        Text(text).style(&.{
            .visual = .font(16, null, null),
            .font_family = "Azeret Mono, monospace",
            .layout = .center,
            .size = .w(.grow),
        });
    });
}
