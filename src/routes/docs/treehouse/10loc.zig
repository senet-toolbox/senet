pub inline fn FlexBox(style: Style) fn (void) void {
    const elem_decl = ElementDecl{
        .style = style,
        .dynamic = .static,
        .elem_type = .FlexBox,
    };

    LifeCycle.open(elem_decl);
    LifeCycle.configure(elem_decl);
    return LifeCycle.close;
}
