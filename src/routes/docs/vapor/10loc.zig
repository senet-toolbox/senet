pub inline fn Node() NodeBody {
    const elem_decl = ElementDefinition{
        .state_type = .static,
        .element_type = .Row,
    };

    LifeCycle.open(elem_decl);
    LifeCycle.configure(elem_decl);
    return LifeCycle.body;
}
