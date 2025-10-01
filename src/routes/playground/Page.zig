const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Page = Fabric.Page;
const Pure = Fabric.Pure;
const Binded = Fabric.Binded;
const Editor = @import("Editor.zig");

var json_editor: Editor = undefined;
pub fn init() void {
    json_editor.init(
        \\{"hello": "world"}
    );
    Page(@src(), render, null, .{});
}

fn submit() void {}

pub fn render() void {
    Static.Column(.{
        .width = .percent(100),
        .height = .percent(100),
        .display = .Flex,
        .padding = .horizontal(24),
    })({
        Static.Text("Playground", .{
            .font_size = 32,
            .font_weight = 700,
        });
        Static.Column(.{
            .width = .percent(50),
            .height = .percent(50),
        })({
            json_editor.render();
            Static.Button(.{ .onPress = submit, .aria_label = "submit-btn" }, .{
                .width = .px(32),
                .height = .px(32),
                .border_radius = .all(4),
                .cursor = .pointer,
                .border_color = .rgb(0, 0, 0),
                .border_thickness = .all(1),
            })({
                Static.Icon("bi bi-check", .{
                    .font_size = 24,
                });
            });
        });
    });
}
