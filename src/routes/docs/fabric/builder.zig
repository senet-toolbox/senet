const Fabric = @import("fabric");
const LifeCycle = Fabric.LifeCycle;
const Element = Fabric.Element;
const Style = Fabric.Style;
const ElementDeclaration = Fabric.ElementDeclaration;

pub const Builder = struct {
    const Self = @This();
    _elem_type: Fabric.ElementType,
    _id: ?[]const u8 = null,

    pub const Box = Self{ ._elem_type = .FlexBox };

    pub inline fn bind(self: *const Self, element: *Element) *const Self {
        element._node_ptr = self._ui_node orelse unreachable;
        return self;
    }

    pub inline fn style(self: *const Self, style_ptr: *const Style) fn (void) void {
        const elem_decl = ElementDeclaration{
            .dynamic = .static,
            .elem_type = self._elem_type,
            .style = style_ptr,
        };

        _ = LifeCycle.open(elem_decl) orelse unreachable;
        LifeCycle.configure(elem_decl);
        return LifeCycle.close;
    }
};
