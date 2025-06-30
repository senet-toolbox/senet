pub inline fn HtmlText(text: []const u8, style: Style) void {
    const elem_decl = ElementDecl{
        .style = style,
        .dynamic = .static,
        .elem_type = .HtmlText,
        .text = text,
    };
    LifeCycle.open(elem_decl);
    LifeCycle.configure(elem_decl);
    LifeCycle.close({});
}
