const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Style = Fabric.Style;

pub inline fn HtmlText(text: []const u8, style: Style) void {
    const elem_decl = Fabric.ElementDecl{
        .dynamic = .static,
        .elem_type = .HtmlText,
        .text = text,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    Fabric.LifeCycle.close({});
}
