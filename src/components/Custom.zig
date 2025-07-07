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

pub inline fn Intersection(style: Style) fn (void) void {
    const elem_decl = Fabric.ElementDecl{
        .elem_type = .Intersection,
        .style = style,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    return Fabric.LifeCycle.close;
}
