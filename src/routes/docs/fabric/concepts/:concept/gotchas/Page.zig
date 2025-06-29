const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const CodeEditor = @import("../CodeEditor.zig");

// Initialization
var sample_fetch: CodeEditor = undefined;
pub fn init() void {}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    Static.FlexBox(.{
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Gotchas", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("A common gotcha for rendering switch or if statements with Static Content is how the reconciler handles knowing what is a new UI node or a old UI Node.");
        Txt("When we are generating the UI tree we attach ids to each UI node depending on their route, node type, parent node, and their position in the tree depth and length wise.");
        Txt("Imagine a scenario as below where we have an if statement, is true we render a FlexBox -> Block -> Text, when we construct the tree, we create the UI node ids:");
        Static.List(.{
            .padding = .{ .left = 32 },
        })({
            Static.ListItem(.{})({
                Static.Text("e601d322f9ae0e6f_Flex_0", .{});
            });
            Static.ListItem(.{})({
                Static.Text("94ffe4febfc9e2a6_Bloc_0", .{});
            });
            Static.ListItem(.{})({
                Static.Text("66140d4e71cf28c6_Text_0", .{});
            });
        });
        Txt("Now we switch the show signal to false, and render the same Blocks with a different text or style props. Since we are still Static content, even though in our code we are showing different information. Our Reconciler creates the same ids for each UI node since they all have the same route, depth and length as well as node type.");
        Txt("The Reconciler compares both new and old tree constructed, and sees that the ids are the same, and they are static. Hence on the wasi side, we assume nothing has changed, and thus do not remove current nodes, and add the new ones.");
        Txt("In the JS files, we store all the nodes for the current route inside the domRegistry, and the active displayed ones in the activeSet. This way we know what exists in the current route, and which are active. We remove and add nodes to the active set via the id of the UI node.");
        Static.Svg(@embedFile("cycler.svg"), .{
            .width = .percent(100),
            .height = .percent(100),
        });
        Static.Text("Solution", .{
            .font_size = 28,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("The easiest solution is to change the Static Components to Pure Components, then the Reconciler will check there props and set the Node as dirty and thus update them.");
        Txt("Another approach is to set the id of the node directly so that the Components in each statement are different. Therefore the domRegistry and activeSet hold different ids, and remove the current static content and add the new content.");
        Txt("One fast trick, to solve this is to just change the id of the outermost parent, since the ids of all nodes depend on their parent, this means that changing just one parent node id, will have an effect on all children.");
    });
}
