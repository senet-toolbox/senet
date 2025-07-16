pub inline fn Box(style: Style) fn (void) void {
    const elem_decl = ElementDecl{
        .style = style,
        .dynamic = .static,
        .elem_type = .Box,
    };

    LifeCycle.open(elem_decl);
    LifeCycle.configure(elem_decl);
    return LifeCycle.close;
}
