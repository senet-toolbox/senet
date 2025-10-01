const std = @import("std");
const Fabric = @import("fabric");
const Theme = @import("theme");
const Navbar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Chain = Fabric.Chain;
const ChainClose = Fabric.ChainClose;
const Center = Chain.Center;
const Box = Chain.Box;
const Image = ChainClose.Image;
const Text = ChainClose.Text;
const Page = Fabric.Page;
const Pure = Fabric.Pure;
const Graphic = Chain.Graphic;
const Icon = ChainClose.Icon;
const Button = Chain.Button;
const Stack = Chain.Stack;
const HtmlText = Custom.Chain.HtmlText;

// Initialization
pub fn init() void {
    Page(@src(), render, null, &.{});
}

fn render() void {
    Fabric.println("Rendering Acorn {any}", .{Theme.mode});
    Center.style(&.{ .size = .hw(.percent(100), .percent(100)) })({
        Stack.style(&.{
            .layout = .center,
            .child_gap = 8,
        })({
            Box.style(&.{
                .size = .{ .height = .px(60) },
                .layout = .x_even_center,
                .child_gap = 8,
            })({
                if (Theme.mode == .light) {
                    Image(.{ .src = "/assets/acorn.png" }).style(&.{ .id = "acorn-image-light", .size = .{ .width = .px(42) } });
                } else {
                    Image(.{ .src = "/assets/acornwhite.png" }).style(&.{ .id = "acorn-image-dark", .size = .{ .width = .px(42) } });
                }
                Text("Acorn").style(&.{ .visual = .font(32, 500, .palette(.text_color)) });
            });
            HtmlText("<i>A dashboard for manging your Tether projects, coming soon...</i>").style(&.{ .visual = .font(18, 500, .palette(.text_color)) });
        });
    });
}
