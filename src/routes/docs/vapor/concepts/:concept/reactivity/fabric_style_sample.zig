const Fabric = @import("fabric");
const Style = Fabric.Style;
const Static = Fabric.Static;

pub fn render() void {
    // default style
    Static.FlexBox(Style.default)({});

    // override default styles
    Static.FlexBox(Style.override(.{ .background = .hex("#FF6B6B") }))({});

    // merging two styles 
    Static.FlexBox(Style.merge(Style.Opaque, Style.Modern))({});

}
