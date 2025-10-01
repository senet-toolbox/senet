const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;

const HtmlOptions = struct {
    text: []const u8,
    style: ?*const Style = null,
};

pub inline fn HtmlText(options: HtmlOptions) void {
    const elem_decl = Fabric.ElementDecl{
        .dynamic = .static,
        .elem_type = .HtmlText,
        .text = options.text,
        .style = options.style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    Fabric.LifeCycle.close({});
}

pub const Chain = struct {
    const Self = @This();
    text: []const u8,
    elem_type: Fabric.ElementType,
    pub fn HtmlText(text: []const u8) Self {
        return Self{ .text = text, .elem_type = .HtmlText };
    }
    pub inline fn style(self: *const Self, style_ptr: *const Fabric.Style) void {
        const elem_decl = Fabric.ElementDecl{
            .dynamic = .static,
            .elem_type = self.elem_type,
            .text = self.text,
            .style = style_ptr,
        };

        _ = Fabric.LifeCycle.open(elem_decl);
        Fabric.LifeCycle.configure(elem_decl);
        Fabric.LifeCycle.close({});
    }
};

pub inline fn GradientText(text: []const u8, style: Style) void {
    const elem_decl = Fabric.ElementDecl{
        .dynamic = .static,
        .elem_type = .TextGradient,
        .text = text,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    Fabric.LifeCycle.close({});
}

pub inline fn Gradient(style: Style) fn (void) void {
    const elem_decl = Fabric.ElementDecl{
        .dynamic = .static,
        .elem_type = .Gradient,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    return Fabric.LifeCycle.close;
}

pub inline fn PreImage(link: []const u8, style: Style) void {
    const elem_decl = Fabric.ElementDecl{
        .href = link,
        .elem_type = .PreImage,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    Fabric.LifeCycle.close({});
}

pub inline fn LazyImage(link: []const u8, style: Style) void {
    const elem_decl = Fabric.ElementDecl{
        .href = link,
        .elem_type = .LazyImage,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    Fabric.LifeCycle.close({});
}

pub inline fn Virtualize(style: *const Style) fn (void) void {
    const elem_decl = Fabric.ElementDecl{
        .elem_type = .Virtualize,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    return Fabric.LifeCycle.close;
}

pub inline fn Intersection(style: *const Style) fn (void) void {
    const elem_decl = Fabric.ElementDecl{
        .elem_type = .Intersection,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    return Fabric.LifeCycle.close;
}

var copied: bool = false;
var copied_text: []const u8 = "";
fn copy(text: []const u8) void {
    Fabric.Clipboard.copy(text);
    copied = true;
    copied_text = text;
    Fabric.println("Hello", .{});
    Fabric.cycle();
    Fabric.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = false;
    copied_text = "";
    Fabric.cycle();
}

pub fn code_snippet_single(text: []const u8) void {
    Static.Box(.{
        .height = .percent(100),
        .background = .hex("#282a36"),
        .border_radius = .all(8),
        .padding = .all(8),
        .width = .percent(100),
        .direction = .column,
        .position = .{ .type = .relative },
    })({
        Static.CtxButton(copy, .{text}, .{
            .width = .px(22),
            .height = .px(22),
            .border_radius = .all(4),
            .display = .Center,
            .cursor = .pointer,
            .transition = .{ .duration = 300 },
            .hover = .{ .background = .hex("#2D303E") },
            .position = .{ .type = .absolute, .right = .px(8), .top = .px(8) },
        })({
            if (copied and std.mem.eql(u8, text, copied_text)) {
                Pure.Icon("bi bi-check", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            } else {
                Pure.Icon("bi bi-clipboard", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            }
        });
        HtmlText(text, .{
            .font_size = 16,
            .text_color = .hex("#ffffff"),
        });
    });
}
