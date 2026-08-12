const Fabric = @import("fabric");
const Static = Fabric.Static;
const Style = Fabric.Style;

fn StyledFlexRow(style: Style) fn (void) void {
    const elem_decl = Fabric.ElementDecl{
        .style = Style.override(style),
        .elem_type = .FlexRow,
    };
    Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    return Fabric.LifeCycle.close;
}

fn sample() void {
    // the Text UI node is centered
    Static.Button(.{ .onPress = clicked }, .{
        .display = .Center,
        .width = .fit,
        .height = .px(48),
        .border = .{ .radius = .all(4) },
        .padding = .all(8),
    })({
        // the text content is also centered
        Static.Text("Click Me", .{
            .font_size = 18,
            .display = .Center,
            .width = .px(200),
        });
    });

    // Here we create and set a default style we want to use
    Fabric.Style.setDefault(.{
        .display = .Center,
        .width = .percent(100),
        .height = .percent(100),
        .border = .{ .radius = .all(4), .thickness = .all(2) },
        .padding = .all(8),
    });

    // we then overide the default with width = .fit, and height = .px(48)
    const overided_default_style = Style.override(.{ .width = .fit, .height = .px(48) });

    // the Text UI node is centered, cause we are using a default
    Static.Button(
        .{ .onPress = clicked },
        overided_default_style,
    )({
        // the text content is also centered, here we are not using the default and instead
        // passing our own defined Style
        Static.Text("Click Me", .{
            .font_size = 18,
            .display = .Center,
            .width = .px(200),
        });
    });

    // Here we use the StyledFlexRow, instead of overidding within the UI node style argument
    StyledFlexRow(.{
        .width = .fit,
        .height = .px(48),
    })({
        // the text content is also centered, here we are not using the default and instead
        // passing our own defined Style
        Static.Text("Click Me", .{
            .font_size = 18,
            .display = .Center,
            .width = .px(200),
        });
    });
}
